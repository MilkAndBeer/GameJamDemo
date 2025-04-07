#include "Common.hlsl"
//#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/BSDF.hlsl"

float3 ShadingPBR(half3 albedo, Light mainLight, half3 shadowColor, float smoothness, float metallic, float occlusion, float3 N, float3 positionWS, float exposure, float reflectExposure)
{
    float3 V = GetWorldSpaceNormalizeViewDir(positionWS);
    float3 L = normalize(mainLight.direction.xyz);

    BxDF directionalContex = GetContex(N, V, L);
    float NoV = directionalContex.NoV;
    float NoL = directionalContex.NoL;
    float NoH = directionalContex.NoH;
    float VoH = directionalContex.VoH;
    
    float perRoughness = 1 - smoothness;
    float roughness = max(perRoughness * perRoughness, 0.0078125);
    float a2 = max(roughness * roughness, 6.103515625e-5);
    
    // half a2MinusOne = a2 - half(1.0);
    // half normalizationTerm = roughness * half(4.0) + half(2.0);
    
    half KD = dielectric.a - metallic * dielectric.a;
    half reflectivity = half(1.0) - KD;
    float grazingTerm = saturate(smoothness + reflectivity);
    half3 F0 = lerp(dielectric.rgb, albedo, metallic);
    half fresnelTerm = Pow4(1.0 - NoV);
    
    half3 lightColor = mainLight.color.rgb;
    half3 shadow = LerpWhiteTo(shadowColor, 1 - mainLight.shadowAttenuation * NoL);

    //直接光照
    float D = D_GGX_Mobile(NoH, roughness);
    float3 F = F_Schlick_UE(F0, VoH);
    //float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    
    half3 dirDiff = albedo * KD;
    
    //float3 dirSpec = (D * F * Vis) / 4;
    half3 dirSpec = (roughness * 0.25 + 0.25) * D * F / 4;
    half3 dirColor = (dirDiff + dirSpec) * lightColor * shadow;


    //多光源
    #ifdef _ADDITIONAL_LIGHTS
    
        int lightsCount = GetAdditionalLightsCount();
        half3 vertexLightColor = half3(0, 0, 0);
    
        for (int i = 0; i < lightsCount; ++i)
        {
            Light addLight = GetAdditionalLight(i, positionWS);
            half3 addLightColor = addLight.color;
                            
            #ifdef _LIGHT
            half3 addShadow = LerpWhiteTo(shadowColor, 1 - addLight.shadowAttenuation);
            #else
            half3 addShadow = LerpWhiteTo(shadowColor, 1 - addLight.distanceAttenuation * addLight.distanceAttenuation);
            #endif
            
            float3 addLightDir = normalize(addLight.direction.xyz);
            float3 addHalfDir = normalize(addLightDir + V);
    
            BxDF additionalContex = GetContex(N, V, addLightDir);
    
            float addD = D_GGX_Mobile(additionalContex.NoH, roughness);
            float3 addF = F_Schlick_UE(F0, additionalContex.VoH);
            //float addVis = Vis_SmithJointApprox(a2, additionalContex.NoV, additionalContex.NoL);
            
            //float3 addSpec = (addD * addF * addVis) / 4;
            half3 addSpec = (roughness * 0.25 + 0.25) * addD * addF / 4;
            
            float3 addDiff = albedo * KD;
            float3 addColor = (addDiff + addSpec) * additionalContex.NoL * addLightColor.rgb * addShadow;
                            
            vertexLightColor += addColor;
        }
    
        dirColor += vertexLightColor;
    
    #endif
    

    //环境光照
    float3 R = normalize(reflect(-V, N));
    
    float3 indirKS = F_Env(a2, F0, grazingTerm, fresnelTerm);
    float3 indirKD = (1 - indirKS) * (1 - metallic);

    half3 ambient = SampleSH(N) * exposure;
    half3 indirDiff = albedo * ambient * indirKD;

    float3 indirSpecCube = CubeLookup(R, perRoughness, occlusion, reflectExposure);
    float3 indirSpecBRDF = EnvBRDFApprox(F0, roughness, NoV);
    float3 indirSpec = indirSpecCube * indirSpecBRDF;
    
    half3 indirColor = indirDiff + indirSpec;

    //half3 color = (dirColor + indirColor) * shadow;
    half3 color = dirColor + indirColor;

    return color;
}



float3 ShadingNPR(half3 albedo, Light mainLight, half3 shadowColor, float smoothness, float metallic, float occlusion, float3 N, float3 positionWS, float exposure, float reflectExposure)
{
    float3 V = GetWorldSpaceNormalizeViewDir(positionWS);
    float3 L = normalize(mainLight.direction.xyz);

    BxDF directionalContex = GetContex(N, V, L);
    float NoV = directionalContex.NoV;
    float NoL = directionalContex.NoL;
    float NoH = directionalContex.NoH;
    float VoH = directionalContex.VoH;
    
    float perRoughness = 1 - smoothness;
    float roughness = max(perRoughness * perRoughness, 0.0078125);
    float a2 = max(roughness * roughness, 6.103515625e-5);
    
    // half a2MinusOne = a2 - half(1.0);
    // half normalizationTerm = roughness * half(4.0) + half(2.0);
    
    half KD = dielectric.a - metallic * dielectric.a;
    half reflectivity = half(1.0) - KD;
    float grazingTerm = saturate(smoothness + reflectivity);
    half3 F0 = lerp(dielectric.rgb, albedo, metallic);
    half fresnelTerm = Pow4(1.0 - NoV);
    
    half3 lightColor = mainLight.color.rgb;
    float atten = 1 - mainLight.shadowAttenuation * NoL;
    //atten = smoothstep(0, 1, atten);
    half3 shadow = LerpWhiteTo(shadowColor, atten);

    //直接光照
    float D = D_GGX_Mobile(NoH, roughness);
    float3 F = F_Schlick_UE(F0, VoH);
    //float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    
    half3 dirDiff = albedo * KD;
    
    //float3 dirSpec = (D * F * Vis) / 4;
    half3 dirSpec = (roughness * 0.25 + 0.25) * D * F / 4;
    half3 dirColor = (dirDiff + dirSpec) * lightColor * shadow;


    //多光源
    #ifdef _ADDITIONAL_LIGHTS
    
        int lightsCount = GetAdditionalLightsCount();
        half3 vertexLightColor = half3(0, 0, 0);
    
        for (int i = 0; i < lightsCount; ++i)
        {
            Light addLight = GetAdditionalLight(i, positionWS);
            half3 addLightColor = addLight.color;
                            
            #ifdef _LIGHT
            half3 addShadow = LerpWhiteTo(shadowColor, 1 - addLight.shadowAttenuation);
            #else
            half3 addShadow = LerpWhiteTo(shadowColor, 1 - addLight.distanceAttenuation * addLight.distanceAttenuation);
            #endif
            
            float3 addLightDir = normalize(addLight.direction.xyz);
            float3 addHalfDir = normalize(addLightDir + V);
    
            BxDF additionalContex = GetContex(N, V, addLightDir);
    
            float addD = D_GGX_Mobile(additionalContex.NoH, roughness);
            float3 addF = F_Schlick_UE(F0, additionalContex.VoH);
            //float addVis = Vis_SmithJointApprox(a2, additionalContex.NoV, additionalContex.NoL);
            
            //float3 addSpec = (addD * addF * addVis) / 4;
            half3 addSpec = (roughness * 0.25 + 0.25) * addD * addF / 4;
            
            float3 addDiff = albedo * KD;
            float3 addColor = (addDiff + addSpec) * additionalContex.NoL * addLightColor.rgb * addShadow;
                            
            vertexLightColor += addColor;
        }
    
        dirColor += vertexLightColor;
    
    #endif
    

    //环境光照
    float3 R = normalize(reflect(-V, N));
    
    float3 indirKS = F_Env(a2, F0, grazingTerm, fresnelTerm);
    float3 indirKD = (1 - indirKS) * (1 - metallic);

    half3 ambient = SampleSH(N) * exposure;
    half3 indirDiff = albedo * ambient * indirKD;

    float3 indirSpecCube = CubeLookup(R, perRoughness, occlusion, reflectExposure);
    float3 indirSpecBRDF = EnvBRDFApprox(F0, roughness, NoV);
    float3 indirSpec = indirSpecCube * indirSpecBRDF;
    
    half3 indirColor = indirDiff + indirSpec;

    //half3 color = (dirColor + indirColor) * shadow;
    half3 color = dirColor + indirColor;

    return color;
}

float3 ShadingNPR(half3 albedo, Light mainLight, half3 shadowColor, float smoothness, float metallic, float occlusion, float3 N, float3 positionWS, float exposure, float reflectExposure, float rampThreshold, float rampSmooth, float4 BColor, float4 DColor)
{
    float3 V = GetWorldSpaceNormalizeViewDir(positionWS);
    float3 L = normalize(mainLight.direction.xyz);

    BxDF directionalContex = GetContex(N, V, L);
    float NoV = directionalContex.NoV;
    float NoL = directionalContex.NoL;
    float NoH = directionalContex.NoH;
    float VoH = directionalContex.VoH;

    //smoothness = clamp(smoothness, 0, 0.9);
    float perRoughness = 1 - smoothness;
    float roughness = max(perRoughness * perRoughness, 0.0078125);
    float a2 = max(roughness * roughness, 6.103515625e-5);
    
    // half a2MinusOne = a2 - half(1.0);
    // half normalizationTerm = roughness * half(4.0) + half(2.0);
    
    half KD = dielectric.a - metallic * dielectric.a;
    half reflectivity = half(1.0) - KD;
    float grazingTerm = saturate(smoothness + reflectivity);
    half3 F0 = lerp(dielectric.rgb, albedo, metallic);
    half fresnelTerm = Pow4(1.0 - NoV);
    
    half3 lightColor = mainLight.color.rgb;
    half3 shadow = LerpWhiteTo(shadowColor, 1 - mainLight.shadowAttenuation);

    //直接光照
    float D = D_GGX_Mobile(NoH, roughness);
    float3 F = F_Schlick_UE(F0, VoH);
    //float Vis = Vis_SmithJointApprox(a2, NoV, NoL);
    
    half3 dirDiff = albedo * KD;
    
    //float3 dirSpec = (D * F * Vis) / 4;
    half3 dirSpec = (roughness * 0.25 + 0.25) * D * F / 4;

    float ramp = smoothstep(rampThreshold - rampSmooth * 0.5, rampThreshold + rampSmooth * 0.5, NoL);
    half3 rampColor = lerp(DColor.rgb, BColor.rgb, ramp);
    
    half3 dirColor = (dirDiff + dirSpec) * rampColor * lightColor;// * shadow;


    //多光源
    #ifdef _ADDITIONAL_LIGHTS
    
        int lightsCount = GetAdditionalLightsCount();
        half3 vertexLightColor = half3(0, 0, 0);
    
        for (int i = 0; i < lightsCount; ++i)
        {
            Light addLight = GetAdditionalLight(i, positionWS);
            half3 addLightColor = addLight.color;
                            
            #ifdef _LIGHT
            half3 addShadow = LerpWhiteTo(shadowColor, 1 - addLight.shadowAttenuation);
            #else
            half3 addShadow = LerpWhiteTo(shadowColor, 1 - addLight.distanceAttenuation * addLight.distanceAttenuation);
            #endif
            
            float3 addLightDir = normalize(addLight.direction.xyz);
            float3 addHalfDir = normalize(addLightDir + V);
    
            BxDF additionalContex = GetContex(N, V, addLightDir);
    
            float addD = D_GGX_Mobile(additionalContex.NoH, roughness);
            float3 addF = F_Schlick_UE(F0, additionalContex.VoH);
            //float addVis = Vis_SmithJointApprox(a2, additionalContex.NoV, additionalContex.NoL);
            
            //float3 addSpec = (addD * addF * addVis) / 4;
            half3 addSpec = (roughness * 0.25 + 0.25) * addD * addF / 4;
            
            float3 addDiff = albedo * KD;
            float3 addColor = (addDiff + addSpec) * additionalContex.NoL * addLightColor.rgb * addShadow;
                            
            vertexLightColor += addColor;
        }
    
        dirColor += vertexLightColor;
    
    #endif
    

    //环境光照
    float3 R = normalize(reflect(-V, N));
    
    float3 indirKS = F_Env(a2, F0, grazingTerm, fresnelTerm);
    float3 indirKD = (1 - indirKS) * (1 - metallic);

    half3 ambient = SampleSH(N) * exposure;
    half3 indirDiff = albedo * ambient * indirKD;

    float3 indirSpecCube = CubeLookup(R, perRoughness, occlusion, reflectExposure);
    float3 indirSpecBRDF = EnvBRDFApprox(F0, roughness, NoV);
    float3 indirSpec = indirSpecCube * indirSpecBRDF;
    
    half3 indirColor = indirDiff + indirSpec;

    half3 color = dirColor + indirColor;

    return color;
}

