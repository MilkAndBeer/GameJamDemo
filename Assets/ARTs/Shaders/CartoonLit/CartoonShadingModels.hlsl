#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../Common/BRDF.hlsl"
#include "CartoonLitFunction.hlsl"
#include "../Common/GlobalInput.hlsl"

//Default -----------------------------------------
half3 DirectDefault(Light light, CartoonCustomData customData)
{
    float3 L = normalize(light.direction);
    float att = light.shadowAttenuation * light.distanceAttenuation;
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = SafeNormalize(L + V);
    
    float NdotL = max(0, dot(N, L));
    float NdotH = max(0, dot(N, H));
    float LdotH = max(0, dot(L, H));
    float halfLambert = dot(N, L) * 0.5f + 0.5f;
    
    half3 lightColor = light.color;
    half3 baseColor = customData.baseColor;
    
    half3 F0 = lerp(kDielectricSpec.rgb, baseColor, customData.metallic);
    float a = max(customData.roughness * customData.roughness, HALF_MIN);
    
    float roughness2MinusOne = a - 1.0;
    float d = NdotH * NdotH * roughness2MinusOne + 1.000001f;
    
    float LdotH2 = LdotH * LdotH;
    float normalizationTerm = customData.roughness * 4.0 + 2.0;
    float specularTerm = a / ((d * d) * max(0.1, LdotH2) * normalizationTerm);
    
    float3 KD = saturate((1 - F0) * (1 - customData.metallic));
    float3 KS = lerp((1 - KD) * PI, 1 - KD, customData.metallic);
    
    //Diffuse
    float shadow = LinearStep(_ShadowThreshold - _ShadowSmooth, _ShadowThreshold + _ShadowSmooth, halfLambert /* * att */);
    float shadowArea = saturate(shadow + (1.01f - _ShadowIntensity));
    float2 shadowRange = float2(shadowArea, 0.5f);
    half3 shadowRamp = SAMPLE_TEXTURE2D_LOD(_Ramp, sampler_Ramp, shadowRange, 0).rgb;
    
    half3 diffuse = baseColor * lightColor * shadowRamp * KD;
    
    //Specular
    half3 specular = baseColor * lightColor * specularTerm * NdotL * att * customData.specular * KS;
    
    return diffuse + specular;
}

///////////////////////////////////////////////////////////////////////////////
//                            Indirect Lighting                              //
///////////////////////////////////////////////////////////////////////////////
half3 IndirectLighting(CartoonCustomData customData, half exposure, float4 SHData[16])
{
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    
    float NdotV = max(0, dot(float3(N), V));
    
    float3 F0 = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    
    float3 KS = F_Indir(NdotV, F0, customData.roughness);
    float3 KD = 1 - KS;
    
    half3 envBRDF = EnvBRDF(N, V, customData.perRoughness);
    half3 envBRDFApprox = EnvBRDFApprox(F0, customData.roughness, NdotV);
    
    //LightMap
    #if defined(LIGHTMAP_ON)
        float2 staticLightmapUV = customData.staticLightmapUV;
        float4 encodedIrradiance = SAMPLE_TEXTURE2D_LOD(unity_Lightmap, samplerunity_Lightmap, staticLightmapUV, 0);
        half3 irradiance = DecodeLightmap(encodedIrradiance, float4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h)) * _AmbientColor;
    #else
        half3 irradiance = GetEvaluateSH(customData.normalWS, SHData) * _AmbientColor;
    #endif
    
    #if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
        Light mainLight = GetMainLight(customData.shadowCoord);
        irradiance = SubtractDirectMainLightFromLightmap(mainLight, N, irradiance);
    #endif
    
    half3 diffuse = customData.baseColor * max(0, irradiance) * exposure * KD;
    half3 specular = envBRDF * envBRDFApprox * KS;
    
    return saturate(diffuse+specular);
}

///////////////////////////////////////////////////
half3 DefaultShading(CartoonCustomData customData)
{
    Light mainLight = GetMainLight(customData.shadowCoord);
    half3 direct = 0;
#ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
#endif
    {
        direct = DirectDefault(mainLight, customData);
    }
    
    //AddLights
#if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();
    for(uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
    {
        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
    #ifdef _LIGHT_LAYERS
        if(IsMatchingLightLayer(addLight.layerMask, meshRenderingLayers))
    #endif
        {
            half3 lightColor = addLight.color * addLight.distanceAttenuation * addLight.shadowAttenuation;
            direct += LightingLambert(lightColor, addLight.direction, customData.normalWS) * customData.baseColor;
        }
    }
#endif

#if defined(_ADDITIONAL_LIGHTS_VERTEX)
    uint pixelLightCount = GetAdditionalLightsCount();
    
    for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
    {
        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
        half3 lightColor = addLight.color * addLight.distanceAttenuation * addLight.shadowAttenuation;
        direct += LightingLambert(lightColor, addLight.direction, customData.normalWS) * customData.baseColor;
    }
#endif
    
    //PBR
    half3 indirect = IndirectLighting(customData, _Exposure, _SHData);
    
    half3 resultColor = direct + indirect;
    
    return resultColor + customData.emission;
}