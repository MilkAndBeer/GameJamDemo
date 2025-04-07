#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShadingModels.hlsl"
//#include "CustomFunction.hlsl"
#include "LitFunction.hlsl"

#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)

//Sampler Textures
TEXTURE2D(_BaseMap);               SAMPLER(sampler_BaseMap);

TEXTURE2D(_DMSMap);                SAMPLER(sampler_DMSMap);

#if defined _EMISSION
TEXTURE2D(_EmissionMap);           SAMPLER(sampler_EmissionMap);
#endif

CBUFFER_START(UnityPerMaterial)
//Basic
half4 _BaseColor;               half _Metallic;                 half _Smoothness;               
half _Normal;                   half3 _SpecColor;

//HSL
half _H;                        half _S;                        half _L;
half _Random;                   half _RandomSize;

//AlphaTest
half _Cutoff;                   float _DitherThreshold;         float _FadeThreshold;

//Subsurface
half3 _SubsurfaceColor;         float _SubsurfaceIntensity;     float _SubsurfaceFalloff;

//Hair
half3 _HairColor1;              half3 _HairColor2;              half _SpecSlide;                half _Exponent;

//Emission
half3 _EmissionColor;           half _EmissionStrength;         half _EmissionBakedIntensity;

//Wind
//float _BendNoise;               float _BendStrength;            half _BendThreshold;            half _BendSmooth;

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

//Additional Lights
bool _IsLight;

//Collision
float _ColIntensity;

CBUFFER_END


///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                                //
///////////////////////////////////////////////////////////////////////////////
CustomData InitializecustomData (float4 uv, float3 positionWS, float3 positionOS, float4 positionSS, float4 shadowCoord,
                                    float3 N, float3 T, float3 B, float3 normalOS, float2 staticLightmapUV)
{
    CustomData customData = (CustomData)0;

    //Light mainLight = GetMainLight();
    //float3 L = normalize(mainLight.direction);
    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    float3x3 tbn = float3x3(T, B, N);
    
    half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv.xy);
    half3 baseColor = baseTex.rgb * _BaseColor.rgb;
    
    half alpha = baseTex.a * _BaseColor.a;
    
    #if defined _ALPHATEST
        clip(alpha - _Cutoff);
    #endif

    // #if defined _DITHER
    //     half dither = Dither(_DitherThreshold, positionSS / positionSS.w);
    //     clip(alpha - dither);
    // #endif

    #if defined _FADE
        half fade = Dither(_FadeThreshold, positionSS / positionSS.w);
        clip(fade);
    #endif

    half4 dmsTex = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, uv.xy);
    float metallic = dmsTex.b * _Metallic;
    float smoothness = dmsTex.a * _Smoothness;
    float specular = 1;
    float3 normalTS = normalize(UnpackDerivativeHeight(float3(dmsTex.rg, 1)));
    float3 normalWS = normalize(TransformTangentToWorld(normalTS, tbn));

//Emission ------------------------------------
#if defined _EMISSION
    half emissive = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv.xy).g;
    customData.emission = lerp(emissive * _EmissionColor * _EmissionStrength, emissive * _EmissionColor * _EmissionIntensity, _IsLight);
#endif
//---------------------------------------------

//HSL -------------------------------------------
#if defined _RANDOM
    float random = SimpleNoise(positionWS.xz, _RandomSize) * _Random;
    float hue = Remap(_H + random, float2(0, 100), float2(0, 360)).x;
#else
    float hue = Remap(_H, float2(0, 100), float2(0, 360)).x;
#endif
    
    baseColor = saturate(Hue(baseColor, hue));
    baseColor = saturate(Saturation(baseColor, _S));
    baseColor *= _L;
//-----------------------------------------------

//Ripple ----------------------------------------
#if defined _RAIN
    specular = 0;
    baseColor = lerp(baseColor * 0.9, baseColor * 0.8, _RainAmount);
    Ripple(_RippleMap, positionWS, normalWS, _DepthRT, _DepthCamPos.xyz, _DepthCameraSize, _CamFarPlane, baseColor, smoothness);
#endif
//---------------------------------------------

//Snow ----------------------------------------
#if defined _SNOW
    SnowLit(normalWS, N, 1 - _SnowOff, baseColor, smoothness, metallic, _DepthRT, _DepthCamPos.xyz, _DepthCameraSize, _CamFarPlane, positionWS);
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
    customData.specular = specular;
    customData.staticLightmapUV = staticLightmapUV;

#if defined _SUBSURFACE
    customData.subsurfaceColor = _SubsurfaceColor;
    customData.subsurfaceIntensity = _SubsurfaceIntensity;
    customData.subsurfaceFalloff = _SubsurfaceFalloff;
#endif
    
    
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

