#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)
TEXTURECUBE(_CubeMap);             SAMPLER(sampler_CubeMap);
/// helper
float sqr(float x)
{
    return x * x;
}

float2 sqr(float2 x)
{
    return x * x;
}

float3 sqr(float3 x)
{
    return x * x;
}

#ifndef SPHERICAL_GAUSSIAN
#define SPHERICAL_GAUSSIAN
// Spherical Gaussian Power Function 
float powBetter(float x, float n)
{
    n = n * 1.4427f + 1.4427f; // 1.4427f --> 1/ln(2)
    return exp2(x * n - n);
}
float3 powBetter(float3 x, float3 n)
{
    n = n * 1.4427f + 1.4427f; // 1.4427f --> 1/ln(2)
    return exp2(x * n - n);
}
#endif


half3 SampleColor(half3 baseColor)
{
    half Luma = dot(baseColor, half3(0.3, 0.59, 0.11));
    return abs(baseColor / Luma);
}

half3 F_Schlick_Mobile(half VoH, half3 SpecularColor)
{
    half OneMinusVoH = 1 - VoH;
    half Fc = OneMinusVoH * OneMinusVoH;
    Fc = Fc * Fc;
    Fc = Fc * OneMinusVoH;
    //return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad

    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    return saturate(50.0 * SpecularColor.g) * Fc + (1 - Fc) * SpecularColor;
}

float3 F_Schlick_UE(float VoH, float3 SpecularColor)
{
    float Fc = powBetter( 1 - VoH, 5 );					// 1 sub, 3 mul
    //return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad
	
    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    return saturate( 50.0 * SpecularColor.g ) * Fc + (1 - Fc) * SpecularColor;
}

half3 fresnelSchlickRoughness(half cosTheta, half3 F0, half roughness)
{
    return F0 + (max(half3(1.0 - roughness, 1.0 - roughness, 1.0 - roughness), F0) - F0) * powBetter(1.0 - cosTheta, 5.0);
}

half GGX_Mobile(half NoH, half Roughness)
{
    // Walter et al. 2007, "Microfacet Models for Refraction through Rough Surfaces"
    float OneMinusNoHSqr = 1.0 - NoH * NoH; 
    half a = Roughness * Roughness;
    half n = NoH * a;
    half p = a / (OneMinusNoHSqr + n * n);
    half d = p * p;
    // clamp to avoid overlfow in a bright env
    return min(d, 2048.0);
}

half Vis_SmithJointApprox_Mobile(half a, half NoV, half NoL)
{
    half Vis_SmithV = NoL * (NoV * (1 - a) + a);
    half Vis_SmithL = NoV * (NoL * (1 - a) + a);

    return saturate(0.5 * rcp(max(Vis_SmithV + Vis_SmithL, 0.0001)));
}

half Vis_SmithJointAniso(half ax, half ay, half NoV, half NoL, half XoV, half XoL, half YoV, half YoL)
{
    half Vis_SmithV = NoL * length(half3(ax * XoV, ay * YoV, NoV));
    half Vis_SmithL = NoV * length(half3(ax * XoL, ay * YoL, NoL));
    return 0.5 * rcp(Vis_SmithV + Vis_SmithL);
}

half Vis_Cloth( half NoV, half NoL )
{
    return rcp( 4 * ( NoL + NoV - NoL * NoV ) );
}

half3 Diffuse_Lambert(half3 DiffuseColor)
{
    return DiffuseColor * (1 / PI);
}

half3 Diffuse_Burley( half3 DiffuseColor, half Roughness, half NoV, half NoL, half VoH )
{
    half FD90 = 0.5 + 2 * VoH * VoH * Roughness;
    half FdV = 1 + (FD90 - 1) * powBetter(1 - NoV, 5);
    half FdL = 1 + (FD90 - 1) * powBetter(1 - NoL, 5);
    return DiffuseColor * ((1 / PI) * FdV * FdL);
}

///
/// PBR indirect
///
half3 F_Indir(half NdotV, half3 F0, half roughness)
{
    half Fre = exp2((-5.55473 * NdotV - 6.98316) * NdotV);
    return F0 + Fre * saturate(1 - roughness - F0);
}

half3 F_Fresnel( half3 SpecularColor, half VoH )
{
    half3 SpecularColorSqrt = sqrt( clamp( half3(0, 0, 0), half3(0.99, 0.99, 0.99), SpecularColor ) );
    half3 n = ( 1 + SpecularColorSqrt ) / ( 1 - SpecularColorSqrt );
    half3 g = sqrt( n*n + VoH*VoH - 1 );
    return 0.5 * sqr( (g - VoH) / (g + VoH) ) * ( 1 + sqr( ((g+VoH)*VoH - 1) / ((g-VoH)*VoH + 1) ) );
}


//Kajiyakay
half3 KajiyaKayDiffuseAttenuation(half3 L, half3 V, half3 N, half3 baseColor, half rougness, half shadow)
{
    // Use soft Kajiya Kay diffuse attenuation
    half KajiyaDiffuse = 1 - abs(dot(N, L));

    half3 FakeNormal = normalize(V - N * dot(V, N));
    //N = normalize( N + FakeNormal * 2 );
    N = FakeNormal;

    // Hack approximation for multiple scattering.
    half Wrap = 1;
    half NoL = saturate((dot(N, L) + Wrap) / sqr(1 + Wrap));
    half DiffuseScatter = lerp(NoL, KajiyaDiffuse, 0.33) * (1 - rougness);
    half Luma = dot(baseColor, half3(0.3, 0.59, 0.11));
    half3 ScatterTint = powBetter(abs(baseColor / Luma), 1 - shadow);
    return sqrt(abs(baseColor)) * DiffuseScatter * ScatterTint;
}

///////////////////////////////////////////////////////////////////////////////
//                          Sample Spherical Harmonics                       //
///////////////////////////////////////////////////////////////////////////////
real3 L1(real3 N, real4 shAr, real4 shAg, real4 shAb)
{
    real4 vA = real4(N, 1.0);

    real3 x1;
    // Linear (L1) + constant (L0) polynomial terms
    x1.r = dot(shAr, vA);
    x1.g = dot(shAg, vA);
    x1.b = dot(shAb, vA);

    return x1;
}

real3 L2(real3 N, real4 shBr, real4 shBg, real4 shBb, real4 shC)
{
    real3 x2;
    // 4 of the quadratic (L2) polynomials
    real4 vB = N.xyzz * N.yzzx;
    x2.r = dot(shBr, vB);
    x2.g = dot(shBg, vB);
    x2.b = dot(shBb, vB);

    // Final (5th) quadratic (L2) polynomial
    real vC = N.x * N.x - N.y * N.y;
    real3 x3 = shC.rgb * vC;

    return x2 + x3;
}

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

float3 SampleSH(float4 SHCoefficients[7], float3 N)
{
    float4 shAr = SHCoefficients[0];
    float4 shAg = SHCoefficients[1];
    float4 shAb = SHCoefficients[2];
    float4 shBr = SHCoefficients[3];
    float4 shBg = SHCoefficients[4];
    float4 shBb = SHCoefficients[5];
    float4 shCr = SHCoefficients[6];

    // Linear + constant polynomial terms
    float3 res = L1(N, shAr, shAg, shAb);

    // Quadratic polynomials
    res += L2(N, shBr, shBg, shBb, shCr);

    #ifdef UNITY_COLORSPACE_GAMMA
    res = LinearToSRGB(res);
    #endif

    return max(float3(0, 0, 0), res);
}

///////////////////////////////////////////////////////////////////////////////
//                          Sample Reflection Probe                          //
///////////////////////////////////////////////////////////////////////////////
half3 EnvBRDF(half3 N, half3 V, half perRoughness)
{
    float3 reflectWS = float3(reflect(-V, N));
#if defined(_REFLECTION_PROBE_BLENDING) || USE_FORWARD_PLUS
    irradiance = CalculateIrradianceFromReflectionProbes(reflectVector, positionWS, perceptualRoughness, normalizedScreenSpaceUV);
#else
    #ifdef _REFLECTION_PROBE_BOX_PROJECTION
        reflectWS = BoxProjectedCubemapDirection(reflectWS, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
    #endif // _REFLECTION_PROBE_BOX_PROJECTION
    
    float mip = perRoughness * (1.7 - 0.7 * perRoughness) * 6;
    
    half4 irradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectWS, mip));
    //half4 irradiance = SAMPLE_TEXTURECUBE_LOD(_CubeMap, sampler_CubeMap, reflectWS, mip);
    half3 decode_specColorProbe = DecodeHDREnvironment(irradiance, unity_SpecCube0_HDR);
#endif
    return decode_specColorProbe;
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

half3 EnvBRDFApprox(half3 SpecularColor, half Roughness, half NoV)
{
    half2 AB = EnvBRDFApproxLazarov(Roughness, NoV);

    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    // Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
    float F90 = saturate( 50.0 * SpecularColor.g );

    return SpecularColor * AB.x + F90 * AB.y;
}


