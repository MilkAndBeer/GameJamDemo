#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShadingModels.hlsl"
#include "CustomFunction.hlsl"
#include "LitFunction.hlsl"

#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)

//Sampler Textures
TEXTURE2D(_BaseMap);               SAMPLER(sampler_BaseMap);

TEXTURE2D(_Depth);               SAMPLER(sampler_Depth);

TEXTURE2D(_DMSMap);                SAMPLER(sampler_DMSMap);

#if defined _EMISSION
TEXTURE2D(_EmissionMap);            SAMPLER(sampler_EmissionMap);
#endif

#if defined _TRIPLANAR && _TOP
TEXTURE2D(_TopBaseMap);             SAMPLER(sampler_TopBaseMap);
TEXTURE2D(_TopDMSMap);              SAMPLER(sampler_TopDMSMap);
#endif

#if defined _TRIPLANAR && _BOTTOM
TEXTURE2D(_BottomBaseMap);             SAMPLER(sampler_BottomBaseMap);
TEXTURE2D(_BottomDMSMap);              SAMPLER(sampler_BottomDMSMap);
#endif

#if defined _SUBSURFACE
TEXTURE2D(_SubsurfaceMap);             SAMPLER(sampler_SubsurfaceMap);
#endif

#if defined _SHADINGMODE_HAIR
TEXTURE2D(_HairSpecMask);             SAMPLER(sampler_HairSpecMask);
#endif

//TopDownDepth
// TEXTURE2D(_TopDownDepth);           SAMPLER(sampler_TopDownDepth);

CBUFFER_START(UnityPerMaterial)
//Ramp
half _SurfaceType;

//Basic
half4 _BaseColor;               half _Metallic;                 half _Smoothness;               half _SpecIntensity;
half _Normal;                   half3 _SpecColor;

//HSL
half _H;                      half _S;               half _L;

//AlphaTest
half _Cutoff;                   half _DitherThreshold;          half _FadeThreshold;

//Subsurface
half3 _SubsurfaceColor;         half _SubsurfaceIntensity;

//Hair
half3 _HairColor1;              half3 _HairColor2;              half _SpecSlide;            half _Exponent;

//Emission
half3 _EmissionColor;           half _EmissionStrength;

//Wind
float _BendNoise;               float _BendStrength;            half _BendRange;

//Snow
float _SnowOff;

//Triplanar
half _TriBlend;                 half _Thickness;                half _TopTiling;                half _BottomTiling;
half _UTilingXY;                half _VTilingXY;                half _UOffsetXY;
half _VOffsetXY;                half _UTilingZY;                half _VTilingZY;
half _UOffsetZY;                half _VOffsetZY;                half _UTilingXZ;
half _VTilingXZ;                half _UOffsetXZ;                half _VOffsetXZ;

//Thickness
half Thickness;

//Height
half _Frequency;                half _Length;                   half _Magnitude;

//Stylized
//half _Stylized;

CBUFFER_END
///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                               //
///////////////////////////////////////////////////////////////////////////////
CustomData InitializecustomData (float4 uv, float3 positionWS, float3 positionOS, float4 positionSS, float4 shadowCoord, float3 N, float3 T, float3 B, float3 normalOS)
{
    CustomData customData = (CustomData)0;

    Light mainLight = GetMainLight();
    float3 L = normalize(mainLight.direction);
    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    float3x3 tbn = float3x3(T, B, N);
    
    half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv.xy);
    half3 baseColor = baseTex.rgb * _BaseColor.rgb;
    
    half alpha = baseTex.a * _BaseColor.a;
    
    #if defined _ALPHATEST
        clip(alpha - _Cutoff);
    #endif

    #if defined _DITHER
        half dither = Dither(_DitherThreshold, positionSS / positionSS.w);
        clip(alpha - dither);
    #endif

    #if defined _FADE
        half fade = Dither(_FadeThreshold, positionSS / positionSS.w);
        clip(fade);
    #endif

    half4 dmsTex = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, uv.xy);
    half metallic = dmsTex.b * _Metallic;
    half smoothness = dmsTex.a * _Smoothness;
    float3 normalTS = normalize(UnpackDerivativeHeight(float3(dmsTex.rg, 1)));
    float3 normalWS = normalize(TransformTangentToWorld(normalTS, tbn));


    //Emission ------------------------------------
    #if defined _EMISSION
        customData.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv.xy).r * _EmissionColor * _EmissionStrength * _EmissionIntensity;
    #endif
    //---------------------------------------------

    float specIntensity = _SpecIntensity;

//HSL ---------------------------------------
    float hue = Remap(_H, float2(0, 100), float2(0, 360)).x;
    baseColor = saturate(Hue(baseColor, hue));
    baseColor = saturate(Saturation(baseColor, _S));
    baseColor *= _L;
//-------------------------------------------

//Ripple ----------------------------------------
#if defined _RAIN
    specIntensity = 0;
    baseColor = lerp(baseColor, baseColor * 0.8, _RainAmount);
    smoothness = lerp(smoothness, 0.9, _RainAmount);
    Ripple(_RippleMap, positionWS, normalWS, baseColor);
#endif
//---------------------------------------------

//Snow ----------------------------------------
#if defined _SNOW
    Snow(_SnowAlbedoMap, _SnowDMSMap, positionWS, normalWS, tbn, 1 - _SnowOff, baseColor, smoothness, metallic);
#endif
//---------------------------------------------

//Hair-----------------------------------------
#if defined _SHADINGMODE_HAIR
    half specMask = SAMPLE_TEXTURE2D(_HairSpecMask, sampler_HairSpecMask, uv.zw).r;
    half specMap = (saturate(SAMPLE_TEXTURE2D(_HairSpecMap, sampler_HairSpecMap, uv.zw).r) - 0.5) * _SpecSlide;
    half3 bitangent = normalize(B + normalWS * specMap);

    customData.specMask = specMask;
    customData.specColor = _SpecColor;
    customData.exponent = _Exponent;
    customData.tangentWS = bitangent;
#endif
//---------------------------------------------
    
    half perRoughness = 1 - smoothness;
    half roughness = max(perRoughness * perRoughness, 0.0078125);
    
    customData.baseColor = baseColor;
    customData.alpha = alpha;
    customData.metallic = metallic;
    customData.smoothness = smoothness;
    customData.perRoughness = perRoughness;
    customData.roughness = roughness;
    customData.normalWS = lerp(NormalizeNormalPerPixel(N), normalWS, _Normal);
    customData.viewDirWS = viewDirWS;
    customData.positionWS = positionWS;
    customData.shadowCoord = shadowCoord;
    customData.rampType = 1 / max(_SurfaceType, 0.0001) - 0.1;
    customData.specIntensity = specIntensity;

    //Subsurface
#if defined _SUBSURFACE
    half3 H = normalize(L + viewDirWS);
    half NdotH = max(0, dot(normalWS, H));
    half NdotL = max(0, dot(normalWS, L));

    half subsurfaceIntensity = 1 - _SubsurfaceIntensity * 0.1;
    half subsurfaceMask = saturate(SAMPLE_TEXTURE2D(_SubsurfaceMap, sampler_SubsurfaceMap, uv.xy).r);
    half inScatter = pow(saturate(dot(L, -viewDirWS)), 12) * lerp(3.0f, 0.1f, subsurfaceIntensity);
    half normalContribution = saturate(NdotH * subsurfaceIntensity + 1 - subsurfaceIntensity);
    half backScatter = normalContribution / (PI * 2) * saturate(NdotL);
    half3 subsurface = lerp(backScatter, 1, inScatter) * _SubsurfaceColor * PI * mainLight.color * subsurfaceMask;
    
    customData.transmission = subsurface;
#endif
//---------------------------------------------

//FrontLight -----------------------------------------
#if defined _FRONT
    half3 frontLightDir = half3(viewDirWS.x, 0, viewDirWS.z);
    half frontLambert = saturate(dot(customData.normalWS, frontLightDir));
    half3 front = _FrontLightColor * baseColor * frontLambert * _FrontLightIntensity;
    customData.emission += front;
#endif
//---------------------------------------------------
    
//BackLight -----------------------------------------
    half3 backLightDir = -L.xyz;
    half backLambert = dot(customData.normalWS, backLightDir) * 0.5 + 0.5;
    half3 back = _BackLightColor * baseColor * backLambert * _BackLightIntensity;
    customData.emission += back;
//---------------------------------------------------

//Cloud ---------------------------------------
#if defined _CLOUD
    half cloud = 0;
    Cloud(_CloudMaskMap, positionWS, normalWS, cloud);
    cloud = lerp(1, cloud, _CloudIntensity);
    customData.baseColor *= cloud;
#endif
//---------------------------------------------

//Mask-----------------------------------------
#if defined _MASKON
    half2 DecalUV = (positionWS.xz + 6) / 12;
    half DecalMask = SAMPLE_TEXTURE2D(_MapMaskTexture, sampler_MapMaskTexture, DecalUV).x;
    customData.baseColor = lerp(Saturation(baseColor, 0) * _MaskColor, baseColor, DecalMask);
#endif
//---------------------------------------------
    
    return customData;
}

