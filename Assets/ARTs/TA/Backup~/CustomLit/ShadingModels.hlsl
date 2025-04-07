#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "BRDF.hlsl"
#include "CustomData.hlsl"
#include "GlobalInput.hlsl"
///////////////////////////////////////////////////////////////////////////////
//                            Direct Lighting                                //
///////////////////////////////////////////////////////////////////////////////
//Default-----------------------------------------
half3 DirectDefault (Light light, CustomData customData)
{
    float3 L = normalize(light.direction);
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = normalize(L + V);
    
    float NdotL = max(0, dot(N, L));
    float NdotV = max(0, dot(N, V));
    float VdotH = max(0, dot(V, H));
    float NdotH = max(0, dot(N, H));
    float halfLambert = dot(N, L) * 0.5 + 0.5;

    NdotL = smoothstep(_Threshold - _Smooth, _Threshold + _Smooth, NdotL);
    halfLambert = smoothstep(_Threshold - _Smooth, _Threshold + _Smooth, halfLambert);

    half lambert = lerp(NdotL, halfLambert, _Stylized);

    half3 lightColor = light.color;
    half3 specColor = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    float a = max(customData.roughness * customData.roughness, HALF_MIN);
    half3 shadow = lerp(_ShadowColor, 1, light.shadowAttenuation * lambert);

    //BRDF
    float D = GGX_Mobile(NdotH, customData.roughness);
    float3 F = F_Schlick_Mobile(VdotH, specColor);
    float Vis = Vis_SmithJointApprox_Mobile(a, NdotV, NdotL);
    float3 brdf = D * Vis * F * PI;
    float3 KD = saturate((1 - F) * (1 - customData.metallic));

    //Diffuse
    half3 diffuse = customData.baseColor * lightColor * shadow * KD;

    //Specular
    half3 specular = customData.baseColor * lightColor * brdf * NdotL * light.shadowAttenuation;
    
    return saturate(diffuse + specular);
}
//-----------------------------------------------

//Stylized---------------------------------------
half3 DirectStylized (Light light, CustomData customData)
{
    float3 L = normalize(light.direction);
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = normalize(L + V);
    
    float NdotL = max(0, dot(N, L));
    float NdotV = max(0, dot(N, V));
    float VdotH = max(0, dot(V, H));
    float NdotH = max(0, dot(N, H));
    float halfLambert = dot(N, L) * 0.5 + 0.5;

    half3 lightColor = light.color;
    half3 specColor = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    float a = max(customData.roughness * customData.roughness, HALF_MIN);
    half3 shadow = lerp(_ShadowColor, 1, light.shadowAttenuation) * light.distanceAttenuation;

    //BRDF
    float D = GGX_Mobile(NdotH, customData.roughness);
    float3 F = F_Schlick_Mobile(VdotH, specColor);
    float Vis = Vis_SmithJointApprox_Mobile(a, NdotV, NdotL);
    float3 brdf = D * Vis * F;
    float3 KD = 1 - customData.metallic;
    half3 ramp = SAMPLE_TEXTURE2D_LOD(_RampMap, sampler_RampMap, float2(halfLambert, customData.rampType), 0).rgb;
    
    //Diffuse
    half3 diffuse = customData.baseColor * lightColor * ramp * shadow * KD;

    //Specular
    half3 specular = customData.baseColor * lightColor * brdf * NdotL * light.shadowAttenuation;
    specular = specular * customData.specIntensity;
    
    return saturate(diffuse + specular);
}
//-----------------------------------------------

//Hair-------------------------------------------
half3 DirectHair (Light light, CustomData customData)
{
    float3 L = normalize(light.direction);
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = normalize(L + V);
    float3 T = customData.tangentWS;
    
    float NdotL = max(0, dot(N, L));
    float TdotH = dot(T, H);
    float sinTH = max(0.01, sqrt(1 - TdotH * TdotH));
    float dirAtten = smoothstep(-1, 0, TdotH);
    float hairSpec = dirAtten * pow(sinTH, customData.exponent) * customData.specIntensity;
    
    float halfLambert = dot(N, L) * 0.5 + 0.5;

    half3 lightColor = light.color;
    half3 shadow = lerp(_ShadowColor, 1, light.shadowAttenuation) * light.distanceAttenuation;

    //Diffuse
    half3 ramp = SAMPLE_TEXTURE2D_LOD(_RampMap, sampler_RampMap, float2(halfLambert, customData.rampType), 0).rgb;
    half3 diffuse = customData.baseColor * lightColor * ramp * shadow;

    //Specular
    half3 specular = customData.baseColor * lightColor * customData.specColor * hairSpec * NdotL * light.shadowAttenuation * customData.specMask;
    
    return saturate(diffuse + specular);
}
//-----------------------------------------------

//Eye -------------------------------------------
half3 DirectEye (Light light, CustomData customData)
{
    half3 L = normalize(light.direction);
    half3 N = customData.normalWS;
    //half3 V = customData.viewDirWS;
    //half3 H = normalize(L+V);
    
    half NdotL = max(0, dot(N, L));
    //half VdotH = dot(V, H);
    //half halfLambert = dot(N, L) * 0.5 + 0.5;

    half3 lightColor = light.color;
    half lightAtt = light.shadowAttenuation * light.distanceAttenuation;
    //half3 specColor = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    half3 shadow = lerp(_ShadowColor, 1, light.shadowAttenuation) * light.distanceAttenuation;

    //BRDF
    //half3 F = F_Schlick_Mobile(VdotH, specColor);
    half3 KD = 1 - customData.metallic;

    //Diffuse
    half3 diffuse = customData.baseColor * lightColor * shadow * NdotL * KD;

    //Specular
    half specIntensity = customData.specIntensity;
    half3 specular = lightColor * customData.specColor * lightAtt * specIntensity;
    
    return saturate(diffuse + specular);
}
//-----------------------------------------------

//BlinnPhong-------------------------------------
half3 DirectBlinnPhong (Light light, CustomData customData)
{
    half3 L = normalize(light.direction);
    half3 N = customData.normalWS;
    half3 V = customData.viewDirWS;
    half3 H = normalize(L+V);
    
    half NdotL = max(0, dot(N,L));
    half NdotH = max(0, dot(N,H));

    half3 lightColor = light.color;
    half shadow = light.shadowAttenuation * light.distanceAttenuation;
    half3 specColor = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    
    half3 diffuse = customData.baseColor * lightColor * NdotL * shadow;
    half3 specular = lightColor * specColor * pow(NdotH, customData.smoothness * 40);
    
    return saturate(diffuse + specular);
}
//-----------------------------------------------

///////////////////////////////////////////////////////////////////////////////
//                            Indirect Lighting                              //
///////////////////////////////////////////////////////////////////////////////
half3 IndirectLighting(CustomData customData, half exposure, float4 customSH[7])
{
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    
    float NdotV = max(0, dot(float3(N), V));
    
    half3 specColor = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    float3 KD = 1 - customData.metallic;
    
    half3 envBRDF = EnvBRDF(N, V, customData.perRoughness);
    half3 envBRDFApprox = EnvBRDFApprox(specColor, customData.roughness, NdotV);

    half3 diffuse = max(half3(0, 0, 0), half3(SampleSH(customSH, N))) * customData.baseColor * _AmbientColor * exposure * KD;
    half3 specular = envBRDF * envBRDFApprox;
    
    return saturate(diffuse + specular);
}

half3 StylizedIndirectLighting(CustomData customData, half exposure)
{
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    
    float NdotV = max(0, dot(float3(N), V));
    
    half3 specColor = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    float3 KD = 1 - customData.metallic;
    
    half3 envBRDF = EnvBRDF(N, V, customData.perRoughness);
    half3 envBRDFApprox = EnvBRDFApprox(specColor, customData.roughness, NdotV);

    half3 diffuse = customData.baseColor * exposure * _AmbientColor * KD * 0.1;
    half3 specular = envBRDF * envBRDFApprox;
    
    return saturate(diffuse + specular);
}

///////////////////////////////////////////////////////////////////////////////
//                                 Default Lit                               //
///////////////////////////////////////////////////////////////////////////////
half3 DefaultShading(CustomData customData, half exposure)
{
    Light mainLight = GetMainLight(customData.shadowCoord);
    
    half3 direct = DirectDefault(mainLight, customData);

    half3 indirect = StylizedIndirectLighting(customData, exposure);
    
    half3 color = direct + indirect;
    
    return color + customData.emission + customData.transmission;
}

///////////////////////////////////////////////////////////////////////////////
//                                 Hair Lit                                  //
///////////////////////////////////////////////////////////////////////////////
half3 HairShading(CustomData customData, half exposure)
{
    Light mainLight = GetMainLight(customData.shadowCoord);
    
    half3 direct = 0;
    
#ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
#endif
    {
        direct = DirectHair(mainLight, customData);
    }

//#if defined(_ADDITIONAL_LIGHTS)
//    uint pixelLightCount = GetAdditionalLightsCount();

//    // #if USE_FORWARD_PLUS
//    // for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
//    // {
//    //     FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
//    //     
//    //     Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
//    //
//    // #ifdef _LIGHT_LAYERS
//    //     if (IsMatchingLightLayer(addLight.layerMask, meshRenderingLayers))
//    // #endif
//    //     {
//    //         direct += DirectDefault(addLight, customData);
//    //     }
//    // }
//    // #endif
    
//    for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
//    {
//        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
//    #ifdef _LIGHT_LAYERS
//        if (IsMatchingLightLayer(addLight.layerMask, meshRenderingLayers))
//    #endif
//        {
//            direct += DirectDefault(addLight, customData);
//        }
//    }
//#endif

//#ifdef _ADDITIONAL_LIGHTS_VERTEX
//    uint pixelLightCount = GetAdditionalLightsCount();
    
//    for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
//    {
//        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
//        half3 lightColor = addLight.color * addLight.distanceAttenuation * addLight.shadowAttenuation;
//        direct += LightingLambert(lightColor, addLight.direction, customData.normalWS) * customData.baseColor;
//    }
//#endif

    half3 indirect = StylizedIndirectLighting(customData, exposure);

    half3 color = direct + indirect;
    
    return color + customData.emission;
}

///////////////////////////////////////////////////////////////////////////////
//                                 Eye Lit                                   //
///////////////////////////////////////////////////////////////////////////////
half3 EyeShading(CustomData customData, half exposure)
{
    Light mainLight = GetMainLight(customData.shadowCoord);
    
    half3 direct = 0;
    
#ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
#endif
    {
        direct = DirectEye(mainLight, customData);
    }
    
//#if defined(_ADDITIONAL_LIGHTS)
//    uint pixelLightCount = GetAdditionalLightsCount();

//    // #if USE_FORWARD_PLUS
//    // for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++)
//    // {
//    //     FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
//    //     
//    //     Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
//    //
//    // #ifdef _LIGHT_LAYERS
//    //     if (IsMatchingLightLayer(addLight.layerMask, meshRenderingLayers))
//    // #endif
//    //     {
//    //         direct += DirectDefault(addLight, customData);
//    //     }
//    // }
//    // #endif

    
//    for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
//    {
//        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
//    #ifdef _LIGHT_LAYERS
//        if (IsMatchingLightLayer(addLight.layerMask, meshRenderingLayers))
//    #endif
//        {
//            direct += DirectEye(addLight, customData);
//        }
//    }
//#endif

//#if defined(_ADDITIONAL_LIGHTS_VERTEX)
//    uint pixelLightCount = GetAdditionalLightsCount();
    
//    for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
//    {
//        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
//        half3 lightColor = addLight.color * addLight.distanceAttenuation * addLight.shadowAttenuation;
//        direct += LightingLambert(lightColor, addLight.direction, customData.normalWS) * customData.baseColor;
//    }
//#endif

    half3 indirect = StylizedIndirectLighting(customData, exposure);
    
    half3 color = direct + indirect;
    
    return color + customData.emission;
}

///////////////////////////////////////////////////////////////////////////////
//                                 Stylized Lit                              //
///////////////////////////////////////////////////////////////////////////////
half3 StylizedShading(CustomData customData, half exposure)
{
    Light mainLight = GetMainLight(customData.shadowCoord);
    
    half3 direct = DirectStylized(mainLight, customData);

    half3 indirect = StylizedIndirectLighting(customData, exposure);
    
    half3 color = direct + indirect;
    
    return color + customData.emission + customData.transmission;
}

