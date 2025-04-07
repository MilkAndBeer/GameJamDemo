// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//#include "Common.hlsl"

float Pow5(float k)
{
	float t = clamp(1 - k, 0, 1);
	float t2 = t * t;
	return  t2 * t2 * t;
}

//环境贴图采样
TEXTURECUBE(_CubeMap);
SAMPLER(sampler_CubeMap);


//=================================================
// 漫反射
//=================================================

// [Lambert]
float3 Diffuse_Lambert( float3 DiffuseColor )
{
	return DiffuseColor * (1 / PI);
}

// [Burley 2012, "Physically-Based Shading at Disney"]
float3 Diffuse_Burley( float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH )
{
	float FD90 = 0.5 + 2 * VoH * VoH * Roughness;
	float FdV = 1 + (FD90 - 1) * Pow5( 1 - NoV );
	float FdL = 1 + (FD90 - 1) * Pow5( 1 - NoL );
	return DiffuseColor * ( (1 / PI) * FdV * FdL );
}


//=================================================
// 镜面反射
//=================================================

//--------------------------------------------------------
// 1. Specular D: 法线分布函数(Normal Distribution Function)
//--------------------------------------------------------

// GGX / Trowbridge-Reitz
// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
float D_GGX_UE( float a2, float NoH )
{
    float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
    return a2 / ( PI*d*d );					// 4 mul, 1 rcp
}

// Anisotropic GGX
// [Burley 2012, "Physically-Based Shading at Disney"]
float D_GGXaniso( float ax, float ay, float NoH, float XoH, float YoH )
{
    // The two formulations are mathematically equivalent
    #if 1
    float a2 = ax * ay;
    float3 V = float3(ay * XoH, ax * YoH, a2 * NoH);
    float S = dot(V, V);

    return (1.0f / PI) * a2 * sqrt(a2 / S);
    #else
    float d = XoH*XoH / (ax*ax) + YoH*YoH / (ay*ay) + NoH*NoH;
    return 1.0f / ( PI * ax*ay * d*d );
    #endif
}

//GGX / Mobile
#define MEDIUMP_FLT_MAX		65504.0
#define MEDIUMP_FLT_MIN		0.00006103515625

half D_GGX_Mobile(float NoH, half Roughness)
{
    // Walter et al. 2007, "Microfacet Models for Refraction through Rough Surfaces"
    float OneMinusNoHSqr = 1.0 - NoH * NoH; 
    //half a = Roughness * Roughness;
    half n = NoH * Roughness;
    half p = Roughness / (OneMinusNoHSqr + n * n);
    half d = p * p;
    // clamp to avoid overlfow in a bright env
    return min(d, 2048.0) / PI;
}


//--------------------------------------------------------
// 2. Specular F: 菲涅尔函数(Fresnel Function)
//--------------------------------------------------------

// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
float3 F_Schlick_UE(float3 SpecularColor, float VoH)
{
    float Fc = Pow5( 1 - VoH );					// 1 sub, 3 mul
    //return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad

    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    return saturate( 50.0 * SpecularColor.g ) * Fc + (1 - Fc) * SpecularColor;
}

float3 F_Schlick_UE(float3 F0, float3 F90, float VoH)
{
    float Fc = Pow5(1 - VoH);
    return F90 * Fc + (1 - Fc) * F0;
}

float3 F_Fresnel(float3 SpecularColor, float VoH)
{
    float3 SpecularColorSqrt = sqrt( clamp( float3(0, 0, 0), float3(0.99, 0.99, 0.99), SpecularColor ));
    float3 n = ( 1 + SpecularColorSqrt ) / ( 1 - SpecularColorSqrt );
    float3 g = sqrt( n*n + VoH*VoH - 1 );
    return 0.5 * sqrt((g - VoH) / (g + VoH)) * (1 + sqrt(((g+VoH)*VoH - 1) / ((g-VoH)*VoH + 1) ));
}

float3 F_Specular(float3 F0, float VoH)
{
    return (1 - F0) * exp2((-5.55473 * (VoH) - 6.98316) * VoH) + F0;
}

half3 F_FresnelTerm (half3 F0, half VoH)
{
    half t = Pow5 (1 - VoH);    // ala Schlick interpoliation
    return F0 + (1-F0) * t;
} 

//F布料
half3 F_Fabric(half NdotV, half3 F0)
{
	half t0 = Pow4(1 - NdotV);
	half t1 = 0.4 * (1 - NdotV);
	return (t1 - t0) * F0 + t0;
}


//环境菲涅尔
half3 F_Env(half a2, half3 F0, half grazingTerm, half fresnelTerm)
{
    float surfaceReduction = 1.0 / (a2 + 1.0);
    return half3(surfaceReduction * lerp(F0, grazingTerm.rrr, fresnelTerm));
}

//--------------------------------------------------------
//3. Specular G: 几何函数(Geomerty Function, Specular G)
//--------------------------------------------------------

// Tuned to match behavior of Vis_Smith
// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
float Vis_Schlick( float a2, float NoV, float NoL )
{
	float k = sqrt(a2) * 0.5;
	float Vis_SchlickV = NoV * (1 - k) + k;
	float Vis_SchlickL = NoL * (1 - k) + k;
	return 0.25 / ( Vis_SchlickV * Vis_SchlickL );
}

// Smith term for GGX
// [Smith 1967, "Geometrical shadowing of a random rough surface"]
float Vis_Smith( float a2, float NoV, float NoL )
{
	float Vis_SmithV = NoV + sqrt( NoV * (NoV - NoV * a2) + a2 );
	float Vis_SmithL = NoL + sqrt( NoL * (NoL - NoL * a2) + a2 );
	return rcp( Vis_SmithV * Vis_SmithL );
}

// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJointApprox( float a2, float NoV, float NoL )
{
	float a = sqrt(a2);
	float Vis_SmithV = NoL * ( NoV * ( 1 - a ) + a );
	float Vis_SmithL = NoV * ( NoL * ( 1 - a ) + a );
	return 0.5 * rcp( Vis_SmithV + Vis_SmithL );
}

// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJoint(float a2, float NoV, float NoL) 
{
	float Vis_SmithV = NoL * sqrt(NoV * (NoV - NoV * a2) + a2);
	float Vis_SmithL = NoV * sqrt(NoL * (NoL - NoL * a2) + a2);
	return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}

// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJointAniso(float ax, float ay, float NoV, float NoL, float XoV, float XoL, float YoV, float YoL)
{
	float Vis_SmithV = NoL * length(float3(ax * XoV, ay * YoV, NoV));
	float Vis_SmithL = NoV * length(float3(ax * XoL, ay * YoL, NoL));
	return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}


//=================================================
//环境光照
//=================================================


//--------------------------------------------------------
//球谐光照
//--------------------------------------------------------

float3 SampleSH(float3 normalWS)
{
    // LPPV is not supported in Ligthweight Pipeline
    float4 SHCoefficients[7];
    SHCoefficients[0] = unity_SHAr;
    SHCoefficients[1] = unity_SHAg;
    SHCoefficients[2] = unity_SHAb;
    SHCoefficients[3] = unity_SHBr;
    SHCoefficients[4] = unity_SHBg;
    SHCoefficients[5] = unity_SHBb;
    SHCoefficients[6] = unity_SHC;

    return max(float3(0, 0, 0), SampleSH9(SHCoefficients, normalWS));
}


//--------------------------------------------------------
//预过滤环境贴图（Pre-filtered environment map）
//--------------------------------------------------------

//Unity系统cubemap的mip级别采样
float3 UnityCubeLookUp(float3 reflectDirWS, float roughness, float AO)
{
	roughness = roughness * (1.7 - 0.7 * roughness);
	float MidLevel = roughness * 6;
	float4 speColor = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectDirWS, MidLevel);

	return DecodeHDREnvironment(speColor, unity_SpecCube0_HDR) * AO;
}

//自定义cubemap的mip级别采样
float3 CubeLookup(float3 reflectDirWS, float roughness, float AO, float exposure)
{
	roughness = roughness * (1.7 - 0.7 * roughness);
	float MidLevel = roughness * 6;
	float4 color = SAMPLE_TEXTURECUBE_LOD(_CubeMap, sampler_CubeMap, reflectDirWS, MidLevel);

	return color.rgb * exposure * AO;
}


//--------------------------------------------------------
//环境BRDF（Environment BRDF）
//--------------------------------------------------------

// [Karis 2013, "Real Shading in Unreal Engine 4" slide 11]
half3 EnvBRDF(half3 F0, half roughness, half NoV, float3 reflectDirWS)
{
	// Importance sampled preintegrated G * F
    roughness = roughness * (1.7 - 0.7 * roughness);
    float MidLevel = roughness * 6;
	float2 AB = SAMPLE_TEXTURECUBE_LOD(_CubeMap, sampler_CubeMap, reflectDirWS, MidLevel).rg;

	// Anything less than 2% is physically impossible and is instead considered to be shadowing 
	float3 GF = F0 * AB.x + saturate(50.0 * F0.g) * AB.y;
	return GF;
}

half2 EnvBRDFApproxLazarov(half Roughness, half NoV)
{
	// [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
	// Adaptation to fit our G term.
	const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
	const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
	half4 r = Roughness * c0 + c1;
	half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
	half2 AB = half2(-1.04, 1.04) * a004 + r.zw;
	return AB;
}

half3 EnvBRDFApprox( half3 SpecularColor, half Roughness, half NoV )
{
	half2 AB = EnvBRDFApproxLazarov(Roughness, NoV);

	// Anything less than 2% is physically impossible and is instead considered to be shadowing
	// Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
	float F90 = saturate( 50.0 * SpecularColor.g );

	return SpecularColor * AB.x + F90 * AB.y;
}

half3 EnvBRDFApprox(half3 F0, half3 F90, half Roughness, half NoV)
{
	half2 AB = EnvBRDFApproxLazarov(Roughness, NoV);
	return F0 * AB.x + F90 * AB.y;
}

half EnvBRDFApproxNonmetal( half Roughness, half NoV )
{
	// Same as EnvBRDFApprox( 0.04, Roughness, NoV )
	const half2 c0 = { -1, -0.0275 };
	const half2 c1 = { 1, 0.0425 };
	half2 r = Roughness * c0 + c1;
	return min( r.x * r.x, exp2( -9.28 * NoV ) ) * r.x + r.y;
}

//镜面反射半球方向反射率
void EnvBRDFApproxFullyRough(inout half3 DiffuseColor, inout half3 SpecularColor)
{
	// Factors derived from EnvBRDFApprox( SpecularColor, 1, 1 ) == SpecularColor * 0.4524 - 0.0024
	DiffuseColor += SpecularColor * 0.45;
	SpecularColor = 0;
	// We do not modify Roughness here as this is done differently at different places.
}
void EnvBRDFApproxFullyRough(inout half3 DiffuseColor, inout half SpecularColor)
{
	DiffuseColor += SpecularColor * 0.45;
	SpecularColor = 0;
}
void EnvBRDFApproxFullyRough(inout half3 DiffuseColor, inout half3 F0, inout half3 F90)
{
	DiffuseColor += F0 * 0.45;
	F0 = F90 = 0;
}

// COD: Black Ops2 数值积分拟合(适合移动端)
float3 EnvDFGLazarov(float3 F0, float smoothness, float NdotV)
{
    float4 p0 = float4(0.5745, 1.548, -0.02397, 1.301);
    float4 p1 = float4(0.5753, -0.2511, -0.02066, 0.4755);
    float4 t = smoothness * p0 + p1;
    float bias = saturate(t.x * min(t.y, exp2(-7.672 * NdotV)) + t.z);
    float delta = saturate(t.w);
    float scale = delta - bias;
    bias *= saturate(50.0 * F0.y);
    return F0 * scale + bias;
}

half3 GlossyEnvReflect(half3 reflectVector, float3 positionWS, half perceptualRoughness, half occlusion)
{
    #if !defined(_ENVIRONMENTREFLECTIONS_OFF)
    half3 irradiance;

    #ifdef _REFLECTION_PROBE_BLENDING
    irradiance = CalculateIrradianceFromReflectionProbes(reflectVector, positionWS, perceptualRoughness);
    #else
    #ifdef _REFLECTION_PROBE_BOX_PROJECTION
    reflectVector = BoxProjectedCubemapDirection(reflectVector, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
    #endif // _REFLECTION_PROBE_BOX_PROJECTION
    half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
    half4 encodedIrradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip));

    #if defined(UNITY_USE_NATIVE_HDR)
    irradiance = encodedIrradiance.rgb;
    #else
    irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
    #endif // UNITY_USE_NATIVE_HDR
    #endif // _REFLECTION_PROBE_BLENDING
    return irradiance * occlusion;
    #else
    return _GlossyEnvironmentColor.rgb * occlusion;
    #endif // _ENVIRONMENTREFLECTIONS_OFF
}



// Hair
//-----------------------------------------------------------------------------

	//http://web.engr.oregonstate.edu/~mjb/cs519/Projects/Papers/HairRendering.pdf
	float3 ShiftT(float3 T, float3 N, float shift)
    {
    	return normalize(T + N * shift);
    }

	// Note: this is Blinn-Phong, the original paper uses Phong.
	float3 D_Kajiya(float3 T, float3 H, float exponent)
    {
    	float TdotH = dot(T, H);
    	float sinTHSq = saturate(1.0 - TdotH * TdotH);

    	//float dirAttn = saturate(TdotH + 1.0); // Evgenii: this seems like a hack? Do we really need this?
    	float dirAttn = smoothstep(-1, 0, TdotH);

    	// Note: Kajiya-Kay is not energy conserving.
    	// We attempt at least some energy conservation by approximately normalizing Blinn-Phong NDF.
    	// We use the formulation with the NdotL.
    	// See http://www.thetenthplanet.de/archives/255.

    	return dirAttn * pow(sinTHSq, exponent);
    }
