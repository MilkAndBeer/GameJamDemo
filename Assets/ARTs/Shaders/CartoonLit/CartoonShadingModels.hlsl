#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "CartoonLitFunction.hlsl"


//Default -----------------------------------------
half3 DirectDefault(Light light, CartoonCustomData customData)
{
    float3 L = normalize(light.direction);
    float att = light.shadowAttenuation * light.distanceAttenuation;
    float3 N = customData.normalWS;
    float3 V = customData.viewDirWS;
    float3 H = SafeNormalize(L + V);
    
    return half3(1, 0, 0);
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