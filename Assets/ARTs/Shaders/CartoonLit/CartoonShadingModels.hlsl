#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../Common/BRDF.hlsl"
#include "CartoonLitFunction.hlsl"


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
    
    //--@@@@@@@@
    return F0;
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