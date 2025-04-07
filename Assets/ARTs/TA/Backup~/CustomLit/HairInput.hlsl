#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShadingModels.hlsl"
#include "CustomFunction.hlsl"
#include "LitFunction.hlsl"

#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)

//Sampler Textures
TEXTURE2D(_BaseMap);               SAMPLER(sampler_BaseMap);

#if defined _DMSMAP
TEXTURE2D(_DMSMap);                SAMPLER(sampler_DMSMap);
#endif

TEXTURE2D(_SpecMap);             SAMPLER(sampler_SpecMap);

TEXTURE2D(_HairSpecMap);            SAMPLER(sampler_HairSpecMap);


CBUFFER_START(UnityPerMaterial)

//Basic
half4 _BaseColor;               half _Metallic;                 half _Smoothness;               half _SpecIntensity;
half _Normal;                   half3 _SpecColor;

//HSL
half _H;                      half _S;               half _L;

//AlphaTest
half _FadeThreshold;

//Hair
half _SpecSlide;            half _SpecOffset;               half _Exponent;

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

    #if defined _FADE
        half fade = Dither(_FadeThreshold, positionSS / positionSS.w);
        clip(fade);
    #endif
    
    #if defined _DMSMAP
        half4 dmsTex = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, uv.xy);
        half metallic = dmsTex.b;
        half smoothness = dmsTex.a * _Smoothness;
        float3 normalTS = normalize(UnpackDerivativeHeight(float3(dmsTex.rg, 1)));
        float3 normalWS = normalize(TransformTangentToWorld(normalTS, tbn));
    #else
        half metallic = _Metallic;
        half smoothness = _Smoothness;
        float3 normalWS = NormalizeNormalPerPixel(N);
    #endif

    float specIntensity = _SpecIntensity;

//Hair-----------------------------------------
    // float specOffset = clamp(-viewDirWS.y * _SpecSlide + _SpecOffset, -1, 1);
    // float specMap = saturate(SAMPLE_TEXTURE2D(_SpecMap, sampler_SpecMap, float2(uv.z, uv.w + specOffset)).r);
    // float specMask = saturate(SAMPLE_TEXTURE2D(_SpecMap, sampler_SpecMap, uv.xy)).g;
    half specMask = SAMPLE_TEXTURE2D(_SpecMap, sampler_SpecMap, uv.zw).r;
    half specMap = (saturate(SAMPLE_TEXTURE2D(_HairSpecMap, sampler_HairSpecMap, uv.zw).r) - 0.5) * _SpecSlide;
    half3 bitangent = normalize(B + normalWS * specMap);

    customData.specMask = specMask;
    customData.specColor = _SpecColor;
    customData.exponent = _Exponent;
    customData.tangentWS = bitangent;

//---------------------------------------------

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
    
    half perRoughness = 1 - smoothness;
    half roughness = max(perRoughness * perRoughness, 0.0078125);
    
    customData.baseColor = baseColor;
    customData.alpha = 1;
    customData.metallic = metallic;
    customData.smoothness = smoothness;
    customData.perRoughness = perRoughness;
    customData.roughness = roughness;
    customData.normalWS = lerp(NormalizeNormalPerPixel(N), normalWS, _Normal);
    customData.viewDirWS = viewDirWS;
    customData.positionWS = positionWS;
    customData.shadowCoord = shadowCoord;
    customData.rampType = 0.9;
    customData.specIntensity = specIntensity;

//FrontLight -----------------------------------------
#if defined _FRONT
    half3 frontLightDir = half3(viewDirWS.x, 0, viewDirWS.z);
    half frontLambert = saturate(dot(customData.normalWS, frontLightDir));
    half3 front = _FrontLightColor * baseColor * frontLambert * _FrontLightIntensity;
    customData.emission += front;
#endif
//---------------------------------------------------
    
//BackLight -----------------------------------------
    half3 backLightDir = half3(-L.x, 0, -L.z);
    half backLambert = saturate(dot(customData.normalWS, backLightDir));
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
    
    return customData;
}

