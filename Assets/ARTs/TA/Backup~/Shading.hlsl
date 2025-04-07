#include "BRDF.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GlobalIllumination.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RealtimeLights.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/AmbientOcclusion.hlsl"
// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
//
// #if defined(LIGHTMAP_ON)
//     #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) float2 lmName : TEXCOORD##index
//     #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT) OUT.xy = lightmapUV.xy * lightmapScaleOffset.xy + lightmapScaleOffset.zw;
//     #define OUTPUT_SH(normalWS, OUT)
// #else
//     #define DECLARE_LIGHTMAP_OR_SH(lmName, shName, index) half3 shName : TEXCOORD##index
//     #define OUTPUT_LIGHTMAP_UV(lightmapUV, lightmapScaleOffset, OUT)
//     #define OUTPUT_SH(normalWS, OUT) OUT.xyz = SampleSHVertex(normalWS)
// #endif
//
// #define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)
// #define HALF_MIN_SQRT 0.0078125
// #define HALF_MIN 6.103515625e-5


//--------------------------------------------------------
//PBR
//--------------------------------------------------------
float3 ShadingBasic(DataInput dataInput)
{
    BxDF contex = GetContex(dataInput);
    BRDFInput BRDFData = InitializeBRDFInput(dataInput.albedo, dataInput.metallic, dataInput.smoothness);

    half fresnelTerm = Pow4(1.0 - contex.NoV);
    
    half3 lightColor = dataInput.light.color.rgb;
    half3 shadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - dataInput.light.shadowAttenuation * contex.NoL);

    half3 radiance = lightColor * shadowMask;
    ///////////////////////////////////////////////////////////////////////////////
    //                        Direct Lighting                                     /
    ///////////////////////////////////////////////////////////////////////////////
    //DirectBRDFDiffuse
    half3 directDiffuse = BRDFData.diffuse * radiance;
    
    //DirectBRDFSpecular
    float d = contex.NoH * contex.NoH * BRDFData.roughness2MinusOne + 1.00001f;
    half d2 = half(d * d);
    half LoH2 = contex.LoH * contex.LoH;
    half specularTerm = BRDFData.roughness2 / (d2 * max(half(0.1), LoH2) * BRDFData.normalizationTerm);
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0);
    half3 directSpecular = BRDFData.specular * specularTerm;
    
    //DirectBRDF
    half3 directBRDF = directDiffuse + directSpecular;

    ///////////////////////////////////////////////////////////////////////////////
    //                        Additional Lighting                                 /
    ///////////////////////////////////////////////////////////////////////////////
    #ifdef _ADDITIONAL_LIGHTS
    
    int lightsCount = GetAdditionalLightsCount();
    half3 vertexLightColor = half3(0, 0, 0);
        
    for (int i = 0; i < lightsCount; ++i)
    {
        Light addLight = GetAdditionalLight(i, dataInput.positionWS);
        half3 addLightColor = addLight.color;
        float3 addLightDir = SafeNormalize(addLight.direction.xyz);
        dataInput.L = addLightDir;
        
        BxDF addContex = GetContex(dataInput);

        #ifdef _LIGHT
        half3 addShadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - addLight.shadowAttenuation * addContex.NoL);
        #else
        half3 addShadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - addLight.distanceAttenuation * addLight.distanceAttenuation * addContex.NoL);
        #endif

        //half3 addRadiance = GetRadiance(dataInput);
        half3 addRadiance = addLightColor * addShadowMask;
        
        //AdditionalBRDFDiffuse
        half3 addDiffuse = BRDFData.diffuse * addRadiance;
        
        //AdditionalBRDFSpecular
        float addD = addContex.NoH * addContex.NoH * BRDFData.roughness2MinusOne + 1.00001f;
        half addD2 = half(addD * addD);
        half addLoH2 = addContex.LoH * addContex.LoH;
        half addSpecularTerm = BRDFData.roughness2 / (addD2 * max(half(0.1), addLoH2) * BRDFData.normalizationTerm);
        addSpecularTerm = addSpecularTerm - HALF_MIN;
        addSpecularTerm = clamp(addSpecularTerm, 0.0, 100.0);
        addSpecularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, addSpecularTerm) * dataInput.specIntensity;
        
        half3 addSpecular = BRDFData.specular * addSpecularTerm;
        
        //DirectBRDF
        half3 addBRDF = addDiffuse + addSpecular;
                
            
                                
        vertexLightColor += addBRDF;
    }
        
    directBRDF += vertexLightColor;
    
    #endif

    ///////////////////////////////////////////////////////////////////////////////
    //                        Environment Lighting                                /
    ///////////////////////////////////////////////////////////////////////////////
    //IndirectBRDFDiffuse
    half3 ambient = SampleSH(dataInput.N) * dataInput.exposure;
    half3 indirectDiffuse = BRDFData.diffuse * ambient;

    //IndirectBRDFSpecular
    float surfaceReduction = 1.0 / (BRDFData.roughness2 + 1.0);
    half3 indirectSpecularTerm = surfaceReduction * lerp(BRDFData.specular, BRDFData.grazingTerm, fresnelTerm);
    float3 R = SafeNormalize(reflect(-dataInput.V, float3(dataInput.N)));
    
    half3 indirectSpecular = CubeLookup(R, BRDFData.perceptualRoughness, 1.0h, dataInput.reflectExposure) * indirectSpecularTerm;
    
    //IndirectBRDF
    half3 indirectBRDF = indirectDiffuse + indirectSpecular;
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Final Color                                         /
    ///////////////////////////////////////////////////////////////////////////////
    half3 color = directBRDF + indirectBRDF;

    return color;
}


//--------------------------------------------------------
//Stylized PBR
//--------------------------------------------------------
half3 ShadingStylized(DataInput dataInput)
{
    BxDF contex = GetContex(dataInput);
    BRDFInput BRDFData = InitializeBRDFInput(dataInput.albedo, dataInput.metallic, dataInput.smoothness);
    
    //FresnelTerm
    half fresnelTerm = Pow4(1.0 - contex.NoV) * dataInput.fresIntensity;
    fresnelTerm = LinearStep(dataInput.fresThreshold - dataInput.fresSmooth, dataInput.fresThreshold + dataInput.fresSmooth, fresnelTerm)
                    * max(0, dataInput.fresIntensity) * (1 - contex.NoL);
    
    //Radiance
    half3 radiance = GetRadiance(dataInput);
    
    half3 shadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - dataInput.light.shadowAttenuation * dataInput.light.distanceAttenuation * contex.NoL);
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Direct Lighting                                     /
    ///////////////////////////////////////////////////////////////////////////////
    //DirectBRDFDiffuse
    half3 directDiffuse = BRDFData.diffuse * radiance;
    
    //DirectBRDFSpecular
    float d = contex.NoH * contex.NoH * BRDFData.roughness2MinusOne + 1.00001f;
    half d2 = half(d * d);
    half LoH2 = contex.LoH * contex.LoH;
    half specularTerm = BRDFData.roughness2 / (d2 * max(half(0.1), LoH2) * BRDFData.normalizationTerm);
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0);

    specularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, specularTerm) *
        max(0, dataInput.specIntensity);
    
    half3 directSpecular = BRDFData.specular * dataInput.specColor * specularTerm;
    
    //DirectBRDF
    half3 directBRDF = directDiffuse + directSpecular;

    ///////////////////////////////////////////////////////////////////////////////
    //                        Additional Lighting                                 /
    ///////////////////////////////////////////////////////////////////////////////
    #ifdef _ADDITIONAL_LIGHTS   
    
    uint lightsCount = GetAdditionalLightsCount();
    half3 vertexLightColor = half3(0, 0, 0);
        
    for (int i = 0; i < lightsCount; ++i)
    {
        Light addLight = GetAdditionalLight(i, dataInput.positionWS, half4(shadowMask, 1));
        float3 addLightDir = SafeNormalize(addLight.direction.xyz);
        dataInput.L = addLightDir;
        dataInput.light = addLight;
        
        BxDF addContex = GetContex(dataInput);

        half3 addRadiance = GetRadiance(dataInput) * addContex.halfLambert;

        half3 addDiffuse = BRDFData.diffuse * addRadiance;
        
        //AdditionalBRDFSpecular
        float addD = addContex.NoH * addContex.NoH * BRDFData.roughness2MinusOne + 1.00001f;
        half addD2 = half(addD * addD);
        half addLoH2 = addContex.LoH * addContex.LoH;
        half addSpecularTerm = BRDFData.roughness2 / (addD2 * max(half(0.1), addLoH2) * BRDFData.normalizationTerm);
        addSpecularTerm = addSpecularTerm - HALF_MIN;
        addSpecularTerm = clamp(addSpecularTerm, 0.0, 100.0);
        
        addSpecularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, addSpecularTerm) *
                             max(0, dataInput.specIntensity);
        
        half3 addSpecular = BRDFData.specular * dataInput.specColor * addSpecularTerm;
        
        //DirectBRDF
        half3 addBRDF = addDiffuse + addSpecular;
                                
        vertexLightColor += addBRDF;
    }
        
    directBRDF += vertexLightColor;

    
    #endif

    ///////////////////////////////////////////////////////////////////////////////
    //                        Environment Lighting                                /
    ///////////////////////////////////////////////////////////////////////////////
    //IndirectBRDFDiffuse
    //half3 ambient = SampleSH(dataInput.N) * dataInput.occlusion * dataInput.exposure;
    half3 ambient = max(half3(0, 0, 0), SampleSH9(dataInput.customSH, dataInput.N)) * dataInput.occlusion * dataInput.exposure;
    half3 indirectDiffuse = BRDFData.diffuse * ambient;

    //IndirectBRDFSpecular
    float surfaceReduction = 1.0 / (BRDFData.roughness2 + 1.0);
    half3 indirectSpecularTerm = surfaceReduction * lerp(BRDFData.specular, BRDFData.grazingTerm * dataInput.fresColor, fresnelTerm);
    float3 R = SafeNormalize(reflect(-dataInput.V, float3(dataInput.N)));
    
    half3 indirectSpecular = CubeLookup(R, BRDFData.perceptualRoughness, dataInput.occlusion, dataInput.reflectExposure) * indirectSpecularTerm;
    
    //IndirectBRDF
    half3 indirectBRDF = indirectDiffuse + indirectSpecular;
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Final Color                                         /
    ///////////////////////////////////////////////////////////////////////////////
    half3 color = directBRDF + indirectBRDF;

    
    FragmentOutput output;
    output.GBuffer0 = half4(directBRDF, 0);
    output.GBuffer1 = half4(directSpecular, 1);
    output.GBuffer2 = half4(dataInput.N, dataInput.smoothness);
    output.GBuffer3 = half4(indirectBRDF, 1);

    return color;

    //return output;
}


//--------------------------------------------------------
//Hair
//--------------------------------------------------------
half3 ShadingHair(DataInput dataInput)
{
    BxDF contex = GetContex(dataInput);
    BRDFInput BRDFData = InitializeBRDFInput(dataInput.albedo, dataInput.metallic, dataInput.smoothness);

    //FresnelTerm
    half fresnelTerm = Pow4(1.0 - contex.NoV);
    fresnelTerm = LinearStep(dataInput.fresThreshold - dataInput.fresSmooth, dataInput.fresThreshold + dataInput.fresSmooth, fresnelTerm) *
        max(0, dataInput.fresIntensity) * (1 - contex.NoL);
    
    //Radiance
    half3 radiance = GetRadiance(dataInput);

    half3 shadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - dataInput.light.shadowAttenuation * dataInput.light.distanceAttenuation * contex.NoL);
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Direct Lighting                                     /
    ///////////////////////////////////////////////////////////////////////////////
    //DirectBRDFDiffuse
    half3 directDiffuse = BRDFData.diffuse * radiance;
    
    //DirectBRDFSpecular
    half specularTerm = StrandSpecular(dataInput.T, dataInput.V, dataInput.L, dataInput.hairSpecExponent) *
        saturate(lerp(0.25, 1.0, dot(dataInput.N, dataInput.L))) * dataInput.hairSpecMask;
    specularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, specularTerm) * dataInput.specIntensity;
    
    half3 directSpecular = BRDFData.specular * dataInput.specColor * specularTerm;
    
    //DirectBRDF
    half3 directBRDF = directDiffuse + directSpecular;

    ///////////////////////////////////////////////////////////////////////////////
    //                        Additional Lighting                                 /
    ///////////////////////////////////////////////////////////////////////////////
    #ifdef _ADDITIONAL_LIGHTS   
    
    uint lightsCount = GetAdditionalLightsCount();
    half3 vertexLightColor = half3(0, 0, 0);
        
    for (int i = 0; i < lightsCount; ++i)
    {
        Light addLight = GetAdditionalLight(i, dataInput.positionWS, half4(shadowMask, 1));
        float3 addLightDir = SafeNormalize(addLight.direction.xyz);
        dataInput.L = addLightDir;
        dataInput.light = addLight;
        
        BxDF addContex = GetContex(dataInput);

        half3 addRadiance = GetRadiance(dataInput) * addContex.halfLambert;

        half3 addDiffuse = BRDFData.diffuse * addRadiance;
        
        //AdditionalBRDFSpecular
        half addSpecularTerm = StrandSpecular(dataInput.T, dataInput.V, dataInput.L, dataInput.hairSpecExponent) *
                                saturate(lerp(0.25, 1.0, dot(dataInput.N, dataInput.L))) * dataInput.hairSpecMask;
        addSpecularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, specularTerm) * dataInput.specIntensity;
        
        half3 addSpecular = BRDFData.specular * dataInput.specColor * addSpecularTerm;
        
        //DirectBRDF
        half3 addBRDF = addDiffuse + addSpecular;
                                
        vertexLightColor += addBRDF;
    }
        
    directBRDF += vertexLightColor;

    
    #endif

    ///////////////////////////////////////////////////////////////////////////////
    //                        Environment Lighting                                /
    ///////////////////////////////////////////////////////////////////////////////
    //IndirectBRDFDiffuse
    //half3 ambient = SampleSH(dataInput.N) * dataInput.occlusion * dataInput.exposure;
    half3 ambient = max(half3(0, 0, 0), SampleSH9(dataInput.customSH, dataInput.N)) * dataInput.occlusion * dataInput.exposure;
    half3 indirectDiffuse = BRDFData.diffuse * ambient;

    //IndirectBRDFSpecular
    float surfaceReduction = 1.0 / (BRDFData.roughness2 + 1.0);
    half3 indirectSpecularTerm = surfaceReduction * lerp(BRDFData.specular, BRDFData.grazingTerm * dataInput.fresColor, fresnelTerm);
    float3 R = SafeNormalize(reflect(-dataInput.V, float3(dataInput.N)));
    
    half3 indirectSpecular = CubeLookup(R, BRDFData.perceptualRoughness, dataInput.occlusion, dataInput.reflectExposure) * indirectSpecularTerm;
    
    //IndirectBRDF
    half3 indirectBRDF = indirectDiffuse + indirectSpecular;
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Final Color                                         /
    ///////////////////////////////////////////////////////////////////////////////
    half3 color = directBRDF + indirectBRDF;
    
    GBufferOutput output;
    output.GBuffer0 = half4(directDiffuse + indirectDiffuse, 1);
    output.GBuffer1 = half4(directSpecular + indirectSpecular, 1);
    output.GBuffer2 = half4(dataInput.N, dataInput.smoothness);
    output.GBuffer3 = half4(indirectBRDF, 1);

    return color;

    //return output;
}


//--------------------------------------------------------
//Anisotropic
//--------------------------------------------------------
float3 ShadingAniso(DataInput dataInput)
{
    BRDFInput BRDFData = InitializeBRDFInput(dataInput.albedo, dataInput.metallic, dataInput.smoothness);
    BxDF contex = GetContex(dataInput);
    
    //AnisoRoughness
    half roughnessT = 0;
    half roughnessB = 0;
    ConvertAnisoToRoughness(BRDFData.roughness, dataInput.anisotropy, roughnessT, roughnessB);

    
    
    //FresnelTerm
    half fresnelTerm = Pow4(1.0 - contex.NoV);
    fresnelTerm = LinearStep(dataInput.fresThreshold - dataInput.fresSmooth, dataInput.fresThreshold + dataInput.fresSmooth, fresnelTerm) * max(0, dataInput.fresIntensity) * (1 - contex.NoL);
    
    //Radiance
    half3 radiance = GetRadiance(dataInput);
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Direct Lighting                                     /
    ///////////////////////////////////////////////////////////////////////////////
    //DirectBRDFDiffuse
    half3 directDiffuse = BRDFData.diffuse * radiance;
    
    //DirectBRDFSpecular
    half D = D_GGX_Aniso(roughnessT, roughnessB, contex.NoH, contex.ToH, contex.BoH);
    half Vis = Vis_Aniso(contex.ToV, contex.BoV, contex.NoV, contex.ToL, contex.BoL, contex.NoL, roughnessT, roughnessB);
    half3 F = F_UE(dataInput.specColor, contex.VoH);
    
    half3 specularTerm = D * Vis * F;
    specularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, specularTerm) * dataInput.specIntensity;
    
    half3 directSpecular = BRDFData.specular * dataInput.specColor * specularTerm;
    
    //DirectBRDF
    half3 directBRDF = directDiffuse + directSpecular;

    ///////////////////////////////////////////////////////////////////////////////
    //                        Additional Lighting                                 /
    ///////////////////////////////////////////////////////////////////////////////
    #ifdef _ADDITIONAL_LIGHTS
    
    int lightsCount = GetAdditionalLightsCount();
    half3 vertexLightColor = half3(0, 0, 0);
        
    for (int i = 0; i < lightsCount; ++i)
    {
        Light addLight = GetAdditionalLight(i, dataInput.positionWS);
        half3 addLightColor = addLight.color;
        float3 addLightDir = SafeNormalize(addLight.direction.xyz);
        dataInput.L = addLightDir;
        
        BxDF addContex = GetContex(dataInput);

        #ifdef _LIGHT
        half3 addShadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - addLight.shadowAttenuation * addContex.NoL);
        #else
        half3 addShadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - addLight.distanceAttenuation * addLight.distanceAttenuation * addContex.NoL);
        #endif

        half3 addRadiance = addContex.NoL * addLightColor * addShadowMask;
        
        //AdditionalBRDFDiffuse
        half3 addDiffuse = BRDFData.diffuse * addRadiance;
        
        //AdditionalBRDFSpecular
        half addD = D_GGX_Aniso(roughnessT, roughnessB, contex.NoH, contex.ToH, contex.BoH);
        half addV = Vis_Aniso(contex.ToV, contex.BoV, contex.NoV, contex.ToL, contex.BoL, contex.NoL, roughnessT, roughnessB);
        half3 addF = F_UE(dataInput.specColor, contex.VoH);
    
        half3 addSpecularTerm = addD * addV * addF;
        addSpecularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, addSpecularTerm) * dataInput.specIntensity;
        
        half3 addSpecular = BRDFData.specular * dataInput.specColor * addSpecularTerm;
        
        //DirectBRDF
        half3 addBRDF = addDiffuse + addSpecular;
                
            
                                
        vertexLightColor += addBRDF;
    }
        
    directBRDF += vertexLightColor;
    
    #endif

    ///////////////////////////////////////////////////////////////////////////////
    //                        Environment Lighting                                /
    ///////////////////////////////////////////////////////////////////////////////
    //IndirectBRDFDiffuse
    half3 ambient = SampleSH(dataInput.N) * dataInput.occlusion * dataInput.exposure;
    half3 indirectDiffuse = BRDFData.diffuse * ambient;

    //IndirectBRDFSpecular
    float surfaceReduction = 1.0 / (BRDFData.roughness2 + 1.0);
    half3 indirectSpecularTerm = surfaceReduction * lerp(BRDFData.specular, BRDFData.grazingTerm * dataInput.fresColor, fresnelTerm);
    float3 R = SafeNormalize(reflect(-dataInput.V, float3(dataInput.N)));
    
    half3 indirectSpecular = CubeLookup(R, BRDFData.perceptualRoughness, dataInput.occlusion, dataInput.reflectExposure) * indirectSpecularTerm;
    
    //IndirectBRDF
    half3 indirectBRDF = indirectDiffuse + indirectSpecular;
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Final Color                                         /
    ///////////////////////////////////////////////////////////////////////////////
    half3 color = directBRDF + indirectBRDF;

    return color;
}


//--------------------------------------------------------
//Cloth
//--------------------------------------------------------
float3 ShadingCloth(DataInput dataInput)
{
    BxDF contex = GetContex(dataInput);
    BRDFInput BRDFData = InitializeBRDFInput(dataInput.albedo, dataInput.metallic, dataInput.smoothness);

    //Diffuse
    half3 diffuse = BRDFData.diffuse;// * FabricLambertNoPI(BRDFData.roughness);
    
    //FresnelTerm
    half fresnelTerm = Pow4(1.0 - contex.NoV);
    fresnelTerm = LinearStep(dataInput.fresThreshold - dataInput.fresSmooth, dataInput.fresThreshold + dataInput.fresSmooth, fresnelTerm) * max(0, dataInput.fresIntensity) * (1 - contex.NoL);
    
    //Radiance
    half3 radiance = GetRadiance(dataInput);
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Direct Lighting                                     /
    ///////////////////////////////////////////////////////////////////////////////
    //DirectBRDFDiffuse
    half3 directDiffuse = diffuse * radiance;// * FabricLambertNoPI(BRDFData.roughness);
    
    //DirectBRDFSpecular
    half D = D_Charlie(contex.NoH, BRDFData.roughness);
    half Vis = V_Charlie(contex.NoL, contex.NoV, BRDFData.roughness);
    //half3 F = F_Schlick(BRDFData.specular, contex.VoH);
    half3 F = F_UE(BRDFData.specular * BRDFData.specular, contex.VoH);
    
    half3 specularTerm = D * Vis * F;
    specularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, specularTerm) * dataInput.specIntensity;
    
    half3 directSpecular = BRDFData.specular * dataInput.specColor * specularTerm;
    
    //DirectBRDF
    half3 directBRDF = directDiffuse + directSpecular;

    ///////////////////////////////////////////////////////////////////////////////
    //                        Additional Lighting                                 /
    ///////////////////////////////////////////////////////////////////////////////
    #ifdef _ADDITIONAL_LIGHTS
    
    int lightsCount = GetAdditionalLightsCount();
    half3 vertexLightColor = half3(0, 0, 0);
        
    for (int i = 0; i < lightsCount; ++i)
    {
        Light addLight = GetAdditionalLight(i, dataInput.positionWS);
        half3 addLightColor = addLight.color;
        float3 addLightDir = SafeNormalize(addLight.direction.xyz);
        dataInput.L = addLightDir;
        
        BxDF addContex = GetContex(dataInput);

        #ifdef _LIGHT
        half3 addShadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - addLight.shadowAttenuation * addContex.NoL);
        #else
        half3 addShadowMask = LerpWhiteTo(dataInput.shadowColor, 1 - addLight.distanceAttenuation * addLight.distanceAttenuation * addContex.NoL);
        #endif

        half3 addRadiance = addContex.NoL * addLightColor * addShadowMask;
        
        //AdditionalBRDFDiffuse
        half3 addDiffuse = BRDFData.diffuse * addRadiance;
        
        //AdditionalBRDFSpecular
        half addD = D_Charlie(contex.NoH, BRDFData.roughness);
        half addV = V_Charlie(contex.NoL, contex.NoV, BRDFData.roughness);
        half3 addF = F_UE(BRDFData.specular, contex.VoH);
    
        half3 addSpecularTerm = addD * addV * addF;
        addSpecularTerm = LinearStep(dataInput.specThreshold - dataInput.specSmooth, dataInput.specThreshold + dataInput.specSmooth, addSpecularTerm) * dataInput.specIntensity;
        
        half3 addSpecular = BRDFData.specular * dataInput.specColor * addSpecularTerm;
        
        //DirectBRDF
        half3 addBRDF = addDiffuse + addSpecular;
                
            
                                
        vertexLightColor += addBRDF;
    }
        
    directBRDF += vertexLightColor;
    
    #endif

    ///////////////////////////////////////////////////////////////////////////////
    //                        Environment Lighting                                /
    ///////////////////////////////////////////////////////////////////////////////
    //IndirectBRDFDiffuse
    half3 ambient = SampleSH9(dataInput.customSH, dataInput.N) * dataInput.occlusion * dataInput.exposure;
    half3 indirectDiffuse = BRDFData.diffuse * ambient;

    //IndirectBRDFSpecular
    float surfaceReduction = 1.0 / (BRDFData.roughness2 + 1.0);
    half3 indirectSpecularTerm = surfaceReduction * lerp(BRDFData.specular, BRDFData.grazingTerm * dataInput.fresColor, fresnelTerm);
    float3 R = SafeNormalize(reflect(-dataInput.V, float3(dataInput.N)));
    
    half3 indirectSpecular = CubeLookup(R, BRDFData.perceptualRoughness, dataInput.occlusion, dataInput.reflectExposure) * indirectSpecularTerm;
    
    //IndirectBRDF
    half3 indirectBRDF = indirectDiffuse + indirectSpecular;
    
    ///////////////////////////////////////////////////////////////////////////////
    //                        Final Color                                         /
    ///////////////////////////////////////////////////////////////////////////////
    half3 color = directBRDF + indirectBRDF;

    return color;
}

