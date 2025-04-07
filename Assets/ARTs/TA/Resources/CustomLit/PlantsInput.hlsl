#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShadingModels.hlsl"
#include "CustomFunction.hlsl"
#include "LitFunction.hlsl"

#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)

//Sampler Textures
TEXTURE2D(_BaseMap);               SAMPLER(sampler_BaseMap);

#if defined _DMSMAP || _TRIPLANAR
TEXTURE2D(_DMSMap);                SAMPLER(sampler_DMSMap);
#endif

#if defined _SNOW
TEXTURE2D_X(_SnowDepthRT);
#endif


CBUFFER_START(UnityPerMaterial)
//Ramp
half _SurfaceType;

//Basic
half4 _BaseColor;               half _Metallic;                 half _Smoothness;               half _SpecIntensity;
half _Normal;                  

//HSL
half _H;                      half _S;               half _L;

//AlphaTest
half _Cutoff;           half _FadeThreshold;

//Wind
float _BendNoise;               float _BendStrength;            half _BendRange;

//Snow
float _SnowOff;
float4 _SnowDepthCamPos;
float _SnowDepthCameraSize;
float _SnowCamFarPlane;

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

    //#if defined _DITHER
    //    half dither = Dither(_DitherThreshold, positionSS / positionSS.w);
    //    clip(alpha - dither);
    //#endif

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
        float3 normalTS = normalize(TransformWorldToTangent(normalWS, tbn));
    #endif


    float specIntensity = _SpecIntensity;

//HSL ---------------------------------------
    float hue = Remap(_H, float2(0, 100), float2(0, 360)).x;
    baseColor = saturate(Hue(baseColor, hue));
    baseColor = saturate(Saturation(baseColor, _S));
    baseColor *= _L;
//-------------------------------------------

//Depth ---------------------------------------
    // float2 depthUV = positionWS.xz / 12 + 0.5; 
    // half depthTex = SAMPLE_TEXTURE2D(_TopDownDepth, sampler_TopDownDepth, depthUV).r;
    // half depth = LinearEyeDepth(depthTex, _ZBufferParams);
//---------------------------------------------

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
    Snow(_SnowAlbedoMap, _SnowDMSMap, positionWS, normalWS, tbn, 1 - _SnowOff, baseColor, smoothness, metallic,
        _SnowDepthRT, _SnowDepthCamPos.xyz, _SnowDepthCameraSize, _SnowCamFarPlane);
#endif
//---------------------------------------------

////Hair-----------------------------------------
//#if defined _SHADINGMODE_HAIR
//    // baseColor = lerp(_HairColor1, _HairColor2, baseColor.b);
//    half specMask = SAMPLE_TEXTURE2D(_HairSpecMask, sampler_HairSpecMask, uv.zw).r;
//    half specMap = (saturate(SAMPLE_TEXTURE2D(_HairSpecMap, sampler_HairSpecMap, uv.zw).r) - 0.5) * _SpecSlide;
//    half3 bitangent = normalize(B + normalWS * specMap);

//    customData.specMask = specMask;
//    customData.specColor = _SpecColor;
//    customData.exponent = _Exponent;
//    customData.tangentWS = bitangent;
//#endif
////---------------------------------------------
    
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

// //PointLights----------------------------
//     half3 light = 0;
//     for (int i = 0; i < _LightCount; i++)
//     {
//         float intensity = _LightsArrayPos[i].w;
//         float lightRange = clamp(_LightsArrayColor[i].w - distance(positionWS, _LightsArrayPos[i].xyz), 0, _LightsArrayColor[i].w);
//         float3 lightDir = normalize(_LightsArrayPos[i].xyz - positionWS);
//         half halfLambert = dot(lightDir, normalWS) * 0.5 + 0.5;
//         light += _LightsArrayColor[i].rgb * lightRange * intensity * baseColor * halfLambert;
//     }
//     customData.emission += light * _GlobleLight;
// // --------------------------------------

//Mask-----------------------------------------
#if defined _MASKON
    half2 DecalUV = (positionWS.xz + 6) / 12;
    half DecalMask = SAMPLE_TEXTURE2D(_MapMaskTexture, sampler_MapMaskTexture, DecalUV).x;
    customData.baseColor = lerp(Saturation(baseColor, 0) * _MaskColor, baseColor, DecalMask);
#endif
//---------------------------------------------
    
    return customData;
}