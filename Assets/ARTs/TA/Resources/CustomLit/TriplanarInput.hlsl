#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShadingModels.hlsl"
//#include "CustomFunction.hlsl"
#include "LitFunction.hlsl"

//Sampler Textures
TEXTURE2D(_BaseMap);                SAMPLER(sampler_BaseMap);
TEXTURE2D(_DMSMap);                 SAMPLER(sampler_DMSMap);

#if defined _EMISSION
TEXTURE2D(_EmissionMap);            SAMPLER(sampler_EmissionMap);
#endif

#if defined _SNOW
TEXTURE2D_X(_SnowDepthRT);
#endif

#if defined _TOP
TEXTURE2D(_TopBaseMap);             SAMPLER(sampler_TopBaseMap);
TEXTURE2D(_TopDMSMap);              SAMPLER(sampler_TopDMSMap);
#endif

#if defined _BOTTOM
TEXTURE2D(_BottomBaseMap);          SAMPLER(sampler_BottomBaseMap);
TEXTURE2D(_BottomDMSMap);           SAMPLER(sampler_BottomDMSMap);
#endif

CBUFFER_START(UnityPerMaterial)

//Basic
half4 _BaseColor;               half _Metallic;                 half _Smoothness;               half _SpecIntensity;
half _Normal;                   

//HSL
half _H;                        half _S;                        half _L;

//Emission
half3 _EmissionColor;           half _EmissionStrength;         half _EmissionBakedIntensity;

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

//Snow
float4 _SnowDepthCamPos;
float _SnowCamFarPlane;
float _SnowDepthCameraSize;

///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                               //
///////////////////////////////////////////////////////////////////////////////
CustomData InitializecustomData (float4 uv, float3 positionWS, float3 positionOS, float4 positionSS, float4 shadowCoord,
                                    float3 N, float3 T, float3 B, float3 normalOS, float2 staticLightmapUV)
{
    CustomData customData = (CustomData)0;

    //Light mainLight = GetMainLight();
    //float3 L = normalize(mainLight.direction);
    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
#if defined _OBJECT
    float2 uvX = positionOS.zy * float2(_UTilingZY, _VTilingZY) + float2(_UOffsetZY, _VOffsetZY);
    float2 uvY = positionOS.xz * float2(_UTilingXZ, _VTilingXZ) + float2(_UOffsetXZ, _VOffsetXZ);
    float2 uvZ = positionOS.xy * float2(_UTilingXY, _VTilingXY) + float2(_UOffsetXY, _VOffsetXY);
    float3 blend = TriplanarBlend(normalOS, _TriBlend);
#else
    float2 uvX = positionWS.zy * float2(_UTilingZY, _VTilingZY) + float2(_UOffsetZY, _VOffsetZY);
    float2 uvY = positionWS.xz * float2(_UTilingXZ, _VTilingXZ) + float2(_UOffsetXZ, _VOffsetXZ);
    float2 uvZ = positionWS.xy * float2(_UTilingXY, _VTilingXY) + float2(_UOffsetXY, _VOffsetXY);
    float3 blend = TriplanarBlend(N, _TriBlend);
#endif

    //Albedo采样
    half4 albedoX = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvX).rgba;
    half4 albedoY = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvY).rgba;
    half4 albedoZ = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvZ).rgba;

    //DMS采样
    half4 DMSX = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvX).rgba;
    half4 DMSY = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvY).rgba;
    half4 DMSZ = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvZ).rgba;
    
    float3 bumpX = normalize(UnpackDerivativeHeight(half3(DMSX.xy, 1)));
    float3 bumpY = normalize(UnpackDerivativeHeight(half3(DMSY.xy, 1)));
    float3 bumpZ = normalize(UnpackDerivativeHeight(half3(DMSZ.xy, 1)));

    //顶面不同
    #if defined _TOP
        float2 uvTop = positionOS.xz * _TopTiling;
        half4 albedoTop = SAMPLE_TEXTURE2D(_TopBaseMap, sampler_TopBaseMap, uvTop).rgba;
        half4 DMSTop = SAMPLE_TEXTURE2D(_TopDMSMap, sampler_TopDMSMap, uvTop).rgba;
        float3 bumpTop = normalize(UnpackDerivativeHeight(half3(DMSTop.xy, 1)));
        float top = saturate(dot(N, half3(0, 1, 0)));
        albedoY = lerp(albedoY, albedoTop, top);
        DMSY.zw = lerp(DMSY.zw, DMSTop.zw, top);
        bumpY = lerp(bumpY, bumpTop, top);
    #endif

    //底面不同
    #if defined _BOTTOM
        float2 uvBottom = positionOS.xz * _BottomTiling;
        half4 albedoBottom = SAMPLE_TEXTURE2D(_BottomBaseMap, sampler_BottomBaseMap, uvBottom).rgba;
        half4 DMSBottom = SAMPLE_TEXTURE2D(_BottomDMSMap, sampler_BottomDMSMap, uvBottom).rgba;
        float3 bumpBottom = normalize(UnpackDerivativeHeight(half3(DMSBottom.xy, 1)));
        float bottom = saturate(dot(N, half3(0, -1, 0)));
        albedoY = lerp(albedoY, albedoBottom, bottom);
        DMSY.zw = lerp(DMSY.zw, DMSBottom.zw, bottom);
        bumpY = lerp(bumpY, bumpBottom, bottom);
    #endif

    //Albedo混合
    half4 albedo = (albedoX * blend.x + albedoY * blend.y + albedoZ * blend.z) * _BaseColor;

    //DMS混合
    float2 DMSTriplanar = DMSX.zw * blend.x + DMSY.zw * blend.y + DMSZ.zw * blend.z;

    //法线混合
    float3 blendNormal = TriplanarNormal(bumpX, bumpY, bumpZ, N, blend);

    half3 baseColor = albedo.rgb;
    half alpha = 1;
    float3 normalWS = blendNormal;
    //float3 normalTS = normalize(TransformWorldToTangent(normalWS, tbn));
    half smoothness = DMSTriplanar.y * _Smoothness;
    half metallic = DMSTriplanar.x * _Metallic;
    float specular = 1;

//HSL ---------------------------------------
    float hue = Remap(_H, float2(0, 100), float2(0, 360)).x;
    baseColor = saturate(Hue(baseColor, hue));
    baseColor = saturate(Saturation(baseColor, _S));
    baseColor *= _L;
//-------------------------------------------

//Ripple ----------------------------------------
#if defined _RAIN
    specular = 0;
    baseColor = lerp(baseColor * 0.9, baseColor * 0.8, _RainAmount);
    Ripple(_RippleMap, positionWS, normalWS, _DepthRT, _DepthCamPos.xyz, _DepthCameraSize, _CamFarPlane, baseColor, smoothness);
#endif
//---------------------------------------------

//Snow ----------------------------------------
#if defined _SNOW
    float3x3 tbn = float3x3(T, B, N);
    SnowTri(_SnowAlbedoMap, _SnowDMSMap, positionWS, normalWS, tbn, 1, baseColor, smoothness, metallic,
        _DepthRT, _DepthCamPos.xyz, _DepthCameraSize, _CamFarPlane);
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

