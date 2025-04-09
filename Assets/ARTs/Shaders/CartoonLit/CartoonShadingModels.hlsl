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
    
    //--@@@@@@@@
    return diffuse;
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
    
    //--@@@@@@@@@@@
    return direct;
}