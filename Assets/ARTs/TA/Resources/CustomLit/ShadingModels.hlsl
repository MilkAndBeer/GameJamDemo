#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
//#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariables.hlsl"
#include "BRDF.hlsl"
#include "CustomData.hlsl"
#include "CustomFunction.hlsl"
#include "GlobalInput.hlsl"

///////////////////////////////////////////////////////////////////////////////
//                            Direct Lighting                                //
///////////////////////////////////////////////////////////////////////////////
//Default-----------------------------------------
half3 DirectDefault (Light light, CustomData customData)
{
    float3 L = normalize(light.direction);
    float att = light.shadowAttenuation * light.distanceAttenuation;
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = SafeNormalize(L + V);
    
    float NdotL = max(0, dot(N, L));
    float NdotH = max(0, dot(N, H));
    float LdotH = max(0, dot(L, H));
    float halfLambert = dot(N, L) * 0.5 + 0.5;
    //float backLambert = max(0, dot(N, -L));

    half3 lightColor = light.color;
    half3 baseColor = customData.baseColor;
    
    half3 F0 = lerp(kDielectricSpec.rgb, baseColor, customData.metallic);
    float a = max(customData.roughness * customData.roughness, HALF_MIN);

    // float mid = LinearStep(_BoundaryThreshold - _BoundarySmooth, _BoundaryThreshold + _BoundarySmooth, NdotL);
    // half3 midtone = lerp(_BoundaryColor, 1, mid);
    //
    // half3 shadowColor = lerp(_ShadowColor, midtone, att * NdotL);
    //
    // float back = LinearStep(_BackThreshold - _BackSmooth, _BackThreshold + _BackSmooth, saturate(1 - backLambert));
    // half3 backColor = lerp(_BackColor, 0, back);
    //
    // half3 lambertColor = lerp(shadowColor, _ShadowEdgeColor, att * saturate(1 - att) * NdotL) + backColor * _BackIntesity;
    
    //BRDF
    // float D = GGX_Mobile(NdotH, customData.roughness);
    //float3 F = F_Schlick_Mobile(VdotH, F0);
    // float Vis = Vis_SmithJointApprox_Mobile(a, NdotV, NdotL);
    // float3 brdf = D * Vis * F * PI;
    
    float roughness2MinusOne = a - 1.0;
    float d = NdotH * NdotH * roughness2MinusOne + 1.00001f;

    float LdotH2 = LdotH * LdotH;
    float normalizationTerm = customData.roughness * 4.0 + 2.0;
    float specularTerm = a / ((d * d) * max(0.1, LdotH2) * normalizationTerm);

    float3 KD = saturate((1 - F0) * (1 - customData.metallic));
    float3 KS = lerp((1 - KD) * PI, 1 - KD, customData.metallic);
    
    //Subsurface
#if defined _SUBSURFACE
    float NdotV = max(0, dot(N, V));
    float VdotH = max(0, dot(V, H));
    float fres = pow(saturate(1 - NdotV), customData.subsurfaceFalloff);
    half3 subsurface = customData.subsurfaceColor * customData.subsurfaceIntensity * fres * saturate(VdotH);
    baseColor += subsurface;
#endif

    //Diffuse
    float shadow = LinearStep(_ShadowThreshold - _ShadowSmooth, _ShadowThreshold + _ShadowSmooth, halfLambert * att);
    float shadowArea = saturate(shadow + (1 - _ShadowIntensity));
    float2 shadowRange = float2(shadowArea, 0.5);
    half3 shadowRamp = SAMPLE_TEXTURE2D_LOD(_Ramp, sampler_Ramp, shadowRange, 0).rgb;
    
    half3 diffuse = baseColor * lightColor * shadowRamp * KD;
    
    //Specular
    half3 specular = baseColor * lightColor * specularTerm * NdotL * att * customData.specular * KS;

    return saturate(diffuse + specular);
}
//-----------------------------------------------

//Additional Light ------------------------------
half3 DirectVertex (half3 lightColor, float3 lightDir, float lightRange, CustomData customData)
{
    float3 L = normalize(lightDir);
    float3 N = customData.normalWS;
    
    float lambert = max(0, dot(N, L));
    float backLambert = max(0, dot(N, -L));

    float mid = LinearStep(_BoundaryThreshold - _BoundarySmooth, _BoundaryThreshold + _BoundarySmooth, lambert);
    half3 midtone = lerp(lightColor, 1, mid);

    float shadow = LinearStep(_ShadowThreshold - _ShadowSmooth, _ShadowThreshold + _ShadowSmooth, lambert);
    half3 shadowColor = lerp(_ShadowColor, midtone, shadow);

    float back = LinearStep(_BackThreshold - _BackSmooth, _BackThreshold + _BackSmooth, saturate(1 - backLambert));
    half3 lambertColor = lerp(_BackColor, shadowColor, back);
    
    half3 diffuse = customData.baseColor * lightColor * lightRange * lambertColor;
    
    return saturate(diffuse);
}

half3 DirectAddition (Light light, CustomData customData)
{
    float3 L = normalize(light.direction);
    float att = light.shadowAttenuation * light.distanceAttenuation;
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = normalize(L + V);
    
    float NdotL = max(0, dot(N, L));
    // float NdotV = max(0, dot(N, V));
    // float VdotH = max(0, dot(V, H));
    float LdotH = max(0, dot(L, H));
    float NdotH = max(0, dot(N, H));

    half3 lightColor = light.color;
    half3 F0 = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    float a = max(customData.roughness * customData.roughness, HALF_MIN);

    //BRDF
    float roughness2MinusOne = a - 1.0;
    float d = NdotH * NdotH * roughness2MinusOne + 1.00001f;

    float LdotH2 = LdotH * LdotH;
    float normalizationTerm = customData.roughness * 4.0 + 2.0;
    float specularTerm = a / ((d * d) * max(0.1, LdotH2) * normalizationTerm);

    float3 KD = saturate((1 - F0) * (1 - customData.metallic));
    float3 KS = lerp((1 - KD) * PI, 1 - KD, customData.metallic);

    half3 baseColor = customData.baseColor;

    //Diffuse
    half3 diffuse = baseColor * lightColor * att * NdotL * KD;
    
    //Specular
    half3 specular = baseColor * lightColor * specularTerm * NdotL * att * customData.specular * KS;

    return saturate(diffuse + specular);
}
//-----------------------------------------------

//Default-----------------------------------------
half3 DirectTree (Light light, CustomData customData)
{
    float3 L = normalize(light.direction);
    float att = light.shadowAttenuation * light.distanceAttenuation;
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = SafeNormalize(L + V);
    
    float NdotL = max(0, dot(N, L));
    float NdotV = max(0, dot(N, V));
    float VdotH = max(0, dot(V, H));
    float halfLambert = dot(N, L) * 0.5 + 0.5;
    float backLambert = max(0, dot(N, -L));

    half3 lightColor = light.color;
    //half3 baseColor = lerp(customData.secondColor, customData.baseColor, halfLambert) * customData.normalWS.y;
    half3 baseColor = lerp(customData.secondColor, customData.baseColor, halfLambert);

    // float mid = LinearStep(_BoundaryThreshold - _BoundarySmooth, _BoundaryThreshold + _BoundarySmooth, NdotL);
    // half3 midtone = lerp(_BoundaryColor, 1, mid);
    //
    // //float shadow = LinearStep(_ShadowThreshold - _ShadowSmooth, _ShadowThreshold + _ShadowSmooth, NdotL);
    // half3 shadowColor = lerp(_ShadowColor, midtone, att * NdotL);
    //
    // float back = LinearStep(_BackThreshold - _BackSmooth, _BackThreshold + _BackSmooth, saturate(1 - backLambert));
    // half3 backColor = lerp(_BackColor, 0, back);
    //
    // half3 lambertColor = lerp(shadowColor, _ShadowEdgeColor, att * saturate(1 - att) * NdotL) + backColor * _BackIntesity;
    
    //Subsurface
    float fres = pow(saturate(1 - NdotV), customData.subsurfaceFalloff) * NdotL;
    half3 subsurface = customData.subsurfaceColor * customData.subsurfaceIntensity * saturate(VdotH) * fres;
    baseColor += subsurface;

    //Rim
    half3 rim = lightColor * customData.rimColor * customData.rimMask * NdotL;

    //Diffuse
    float shadowArea = LinearStep(_ShadowThreshold - _ShadowSmooth, _ShadowThreshold + _ShadowSmooth, halfLambert);
    shadowArea = saturate(shadowArea * att + (1 - _ShadowIntensity));
    float2 shadowRange = float2(shadowArea, 0.5);
    half3 shadowRamp = SAMPLE_TEXTURE2D_LOD(_Ramp, sampler_Ramp, shadowRange, 0).rgb;
    
    half3 diffuse = baseColor * lightColor * shadowRamp;

    return saturate(diffuse + rim);
}
//-----------------------------------------------

//Default-----------------------------------------
half3 DirectWater (Light light, CustomData customData)
{
    float3 L = normalize(light.direction);
    float att = light.shadowAttenuation * light.distanceAttenuation;
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = SafeNormalize(L + V);
    
    float NdotL = max(0, dot(N, L));
    float NdotV = max(0, dot(N, V));
    float VdotH = max(0, dot(V, H));
    float halfLambert = dot(N, L) * 0.5 + 0.5;
    float backLambert = max(0, dot(N, -L));

    half3 lightColor = light.color;
    half3 baseColor = lerp(customData.secondColor, customData.baseColor, halfLambert);

    float mid = LinearStep(_BoundaryThreshold - _BoundarySmooth, _BoundaryThreshold + _BoundarySmooth, NdotL);
    half3 midtone = lerp(_BoundaryColor, 1, mid);
    
    half3 shadowColor = lerp(_ShadowColor, midtone, att * NdotL);

    float back = LinearStep(_BackThreshold - _BackSmooth, _BackThreshold + _BackSmooth, saturate(1 - backLambert));
    half3 backColor = lerp(_BackColor, 0, back);
    
    half3 lambertColor = lerp(shadowColor, _ShadowEdgeColor, att * saturate(1 - att) * NdotL) + backColor * _BackIntesity;
    
    //Diffuse
    half3 diffuse = baseColor * lightColor * lambertColor;

    //Specular
    //half3 specular = 

    return saturate(diffuse);
}
//-----------------------------------------------

///////////////////////////////////////////////////////////////////////////////
//                            Indirect Lighting                              //
///////////////////////////////////////////////////////////////////////////////
half3 IndirectLighting(CustomData customData, float exposure, float4 SH[7])
{
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    
    float NdotV = max(0, dot(float3(N), V));
    
    half3 F0 = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    
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
    half3 irradiance = SampleSH9(SH, customData.normalWS) * _AmbientColor;
#endif

#if defined(LIGHTMAP_ON) && defined(_MIXED_LIGHTING_SUBTRACTIVE)
    Light mainLight = GetMainLight(customData.shadowCoord);
    irradiance = SubtractDirectMainLightFromLightmap(mainLight, N, irradiance);
#endif

    half3 diffuse = customData.baseColor * max(0, irradiance) * exposure * KD;
    half3 specular = envBRDF * envBRDFApprox * KS;
    
    return saturate(diffuse + specular);
}

///////////////////////////////////////////////////////////////////////////////
//                                 Default Lit                               //
///////////////////////////////////////////////////////////////////////////////
half3 DefaultShading(CustomData customData, half exposure)
{
    Light mainLight = GetMainLight(customData.shadowCoord);
    
    half3 direct = 0;

#ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
#endif
    {
        direct = DirectDefault(mainLight, customData);
    }
    
#if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();
    
    for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
    {
        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
    #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(addLight.layerMask, meshRenderingLayers))
    #endif
        {
            direct += DirectAddition(addLight, customData);
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
    
    // for (int i = 0; i < _LightCount; i++)
    // {
    //     float intensity = _LightsArrayPos[i].w;
    //     float lightRange = clamp(0, _LightsArrayColor[i].w - distance(customData.positionWS, _LightsArrayPos[i].xyz), _LightsArrayColor[i].w);
    //     lightRange = saturate(lightRange * lightRange);
    //     float3 addLightDir = normalize(_LightsArrayPos[i].xyz - customData.positionWS);
    //     
    //     direct += DirectVertex(_LightsArrayColor[i].rgb * intensity, addLightDir, lightRange, customData);
    // }

    half3 indirect = IndirectLighting(customData, exposure, custom_SH);
    
    half3 color = direct + indirect;
    
    return color + customData.emission;
}

///////////////////////////////////////////////////////////////////////////////
//                                  Tree Lit                                 //
///////////////////////////////////////////////////////////////////////////////
half3 TreeShading(CustomData customData, half exposure)
{
    Light mainLight = GetMainLight(customData.shadowCoord);
    
    half3 direct = 0;

#ifdef _LIGHT_LAYERS
    if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
#endif
    {
        direct = DirectTree(mainLight, customData);
    }
    
#if defined(_ADDITIONAL_LIGHTS) 
    uint pixelLightCount = GetAdditionalLightsCount();
    
    for (uint lightIndex = 0; lightIndex < pixelLightCount; lightIndex++)
    {
        Light addLight = GetAdditionalLight(lightIndex, customData.positionWS, unity_ProbesOcclusion);
    #ifdef _LIGHT_LAYERS
        if (IsMatchingLightLayer(addLight.layerMask, meshRenderingLayers))
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

    half3 indirect = IndirectLighting(customData, exposure, custom_SH);
    
    half3 color = direct + indirect;
    
    return color + customData.emission;
}