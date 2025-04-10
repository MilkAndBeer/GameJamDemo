#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CartoonCustomData.hlsl"
#include "CartoonShadingModels.hlsl"

TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);
TEXTURE2D(_DMSMap);     SAMPLER(sampler_DMSMap);

#if defined _EMISSION
TEXTURE2D(_EmissionMap);   SAMPLER(sampler_EmissionMap);
#endif

CBUFFER_START(UnityPerMaterial)
//Basic
float4 _BaseMap_ST;
half4 _BaseColor;
float4 _DMSMap_ST;
half _Metallic;
half _Smoothness;
half _Normal;

//HSL
half _H;
half _S;
half _L;

//Emission
half _IsLight;
half _EmissionStrength;
half4 _EmissionColor;
half _EmissionBakedIntensity;

CBUFFER_END


///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                                //
///////////////////////////////////////////////////////////////////////////////
CartoonCustomData InitializeCartoonCustomData(float2 uv, float3 positionWS, float4 positionSS, float4 shadowCoord, 
            float3 N, float3 T, float3 B, float2 staticLightmapUV)
{
    CartoonCustomData data = GetDefaultCartoonCustomData();
    
    half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv.xy);
    half3 baseColor = baseTex.rgb * _BaseColor.rgb;
    
    half alpha = baseTex.a * _BaseColor.a;

    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    float3x3 tbn = float3x3(T, B, N);

    float metallic = _Metallic;
    float smoothness = _Smoothness;
    float3 normalWS = N;
    float specular = 1;
    #if defined _DMSMAPON
        half4 dmsTex = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, uv.xy);
    
        metallic *= dmsTex.b;
        smoothness *= dmsTex.a;
        float3 normalTS = normalize(UnpackDerivativeHeight(float3(dmsTex.rg, 1)));
        normalWS = normalize(TransformTangentToWorld(normalTS, tbn));
    #endif    

    float perRoughness = 1 - smoothness;
    float roughness = max(perRoughness * perRoughness, 0.0078125);

    #if defined _EMISSION
        half emissive = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv.xy).g;
        half3 emissionColor = lerp(emissive * _EmissionColor.rgb * _EmissionStrength, emissive * _EmissionColor.rgb * _EmissionBakedIntensity, _IsLight);
        data.emission = emissionColor;
    #endif

    data.baseColor = baseColor.rgb;
    data.baseAlpha = alpha;
    data.metallic = metallic;
    data.smoothness = smoothness;
    data.perRoughness = perRoughness;
    data.roughness = roughness;

    data.positionWS = positionWS;
    data.normalWS = normalWS;
    data.viewDirWS = viewDirWS;
    data.shadowCoord = shadowCoord;
    data.specular = specular;
    data.staticLightmapUV = staticLightmapUV;

    return data;
}