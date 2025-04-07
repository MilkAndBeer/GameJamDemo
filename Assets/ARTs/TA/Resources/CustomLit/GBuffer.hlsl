#include "Deferred.hlsl"

#if !defined(LIGHTMAP_ON) && defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK)
#define OUTPUT_SHADOWMASK 1 // subtractive
#elif defined(SHADOWS_SHADOWMASK)
#define OUTPUT_SHADOWMASK 2 // shadow mask
#elif defined(_DEFERRED_MIXED_LIGHTING)
#define OUTPUT_SHADOWMASK 3 // we don't know if it's subtractive or just shadowMap (from deferred lighting shader, LIGHTMAP_ON does not need to be defined)
#else
#endif

#if _RENDER_PASS_ENABLED
    #define GBUFFER_OPTIONAL_SLOT_1 GBuffer4
    #define GBUFFER_OPTIONAL_SLOT_1_TYPE float
#if OUTPUT_SHADOWMASK && (defined(_WRITE_RENDERING_LAYERS) || defined(_LIGHT_LAYERS))
    #define GBUFFER_OPTIONAL_SLOT_2 GBuffer5
    #define GBUFFER_OPTIONAL_SLOT_3 GBuffer6
    #define GBUFFER_LIGHT_LAYERS GBuffer5
    #define GBUFFER_SHADOWMASK GBuffer6
#elif OUTPUT_SHADOWMASK
    #define GBUFFER_OPTIONAL_SLOT_2 GBuffer5
    #define GBUFFER_SHADOWMASK GBuffer5
#elif (defined(_WRITE_RENDERING_LAYERS) || defined(_LIGHT_LAYERS))
    #define GBUFFER_OPTIONAL_SLOT_2 GBuffer5
    #define GBUFFER_LIGHT_LAYERS GBuffer5
#endif //#if OUTPUT_SHADOWMASK && defined(_WRITE_RENDERING_LAYERS)
#else
    #define GBUFFER_OPTIONAL_SLOT_1_TYPE half4
#if OUTPUT_SHADOWMASK && (defined(_WRITE_RENDERING_LAYERS) || defined(_LIGHT_LAYERS))
    #define GBUFFER_OPTIONAL_SLOT_1 GBuffer4
    #define GBUFFER_OPTIONAL_SLOT_2 GBuffer5
    #define GBUFFER_LIGHT_LAYERS GBuffer4
    #define GBUFFER_SHADOWMASK GBuffer5
#elif OUTPUT_SHADOWMASK
    #define GBUFFER_OPTIONAL_SLOT_1 GBuffer4
    #define GBUFFER_SHADOWMASK GBuffer4
#elif (defined(_WRITE_RENDERING_LAYERS) || defined(_LIGHT_LAYERS))
    #define GBUFFER_OPTIONAL_SLOT_1 GBuffer4
    #define GBUFFER_LIGHT_LAYERS GBuffer4
#endif //#if OUTPUT_SHADOWMASK && defined(_WRITE_RENDERING_LAYERS)
#endif //#if _RENDER_PASS_ENABLED
#define kLightingInvalid  -1  // No dynamic lighting: can aliase any other material type as they are skipped using stencil
#define kLightingLit       1  // lit shader
#define kLightingSimpleLit 2  // Simple lit shader

// Material flags
#define kMaterialFlagReceiveShadowsOff        1 
#define kMaterialFlagDefaultShading           2 
#define kMaterialFlagHairShading              4 
#define kMaterialFlagSubsurfaceShading        8
#define kMaterialFlagStylizedShading          16
#define kMaterialFlagEyeShading               32
#define kMaterialFlagSkinShading               64

//#define kMaterialFlagSubtractiveMixedLighting 16

float PackMaterialFlags(uint materialFlags)
{
    return materialFlags * (1.0h / 255.0h);
}

uint UnpackMaterialFlags(float packedMaterialFlags)
{
    return uint((packedMaterialFlags * 255.0h) + 0.5h);
}

struct FragmentOutput
{
    half4 GBuffer0 : SV_Target0;
    half4 GBuffer1 : SV_Target1;
    half4 GBuffer2 : SV_Target2;
    half4 GBuffer3 : SV_Target3; 
};

FragmentOutput InitializeGbuffer(CustomData customData, half3 indirect)
{
    half3 packedNormalWS = (customData.normalWS + 1) / 2;
    uint materialFlags = 0;

#ifdef _RECEIVE_SHADOWS_OFF
    materialFlags |= kMaterialFlagReceiveShadowsOff;
#endif

#ifdef _SHADINGMODE_BASIC
    materialFlags |= kMaterialFlagDefaultShading;
#endif

#ifdef _SHADINGMODE_HAIR
    materialFlags |= kMaterialFlagHairShading;
#endif

#ifdef _SHADINGMODE_SUBSURFACE
    materialFlags |= kMaterialFlagSubsurfaceShading;
#endif

#ifdef _SHADINGMODE_STYLIZED
    materialFlags |= kMaterialFlagStylizedShading;
#endif

#ifdef _SHADINGMODE_EYE
    materialFlags |= kMaterialFlagEyeShading;
#endif

#ifdef _SHADINGMODE_SKIN
    materialFlags |= kMaterialFlagSkinShading;
#endif
    
    FragmentOutput output = (FragmentOutput)0;
    output.GBuffer0 = half4(customData.baseColor, PackMaterialFlags(materialFlags));
    output.GBuffer1 = half4(customData.specAndSSS, customData.specMask, customData.rampType, customData.metallic);
    output.GBuffer2 = half4(packedNormalWS, customData.smoothness);
    output.GBuffer3 = half4(indirect, 1);
    
    return output;
}

CustomData UnpackGBuffer (float3 positionWS, half4 gbuffer0, half4 gbuffer1, half4 gbuffer2)
{
    CustomData customData = (CustomData)0;

    customData.positionWS = half3(positionWS);
    customData.viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    customData.baseColor = gbuffer0.rgb;
    customData.specAndSSS = gbuffer1.r;
    customData.specMask = gbuffer1.g;
    customData.rampType = gbuffer1.b;
    customData.metallic = gbuffer1.a;
    customData.smoothness = gbuffer2.a;
    customData.perRoughness = 1.0 - gbuffer2.a;
    customData.roughness = max(customData.perRoughness * customData.perRoughness, 0.0078125);
    customData.normalWS = normalize(gbuffer2.rgb * 2 - 1);
    
    return customData;
}