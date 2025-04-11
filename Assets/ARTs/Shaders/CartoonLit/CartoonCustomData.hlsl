#ifndef CARTOONCUSTOMDATA
#define CARTOONCUSTOMDATA

struct CartoonCustomData
{
    half3 baseColor;
    half baseAlpha;
    half metallic;
    half smoothness;
    half perRoughness;
    half roughness;
    half3 emission;
    float3 positionWS;
    float3 normalWS;
    float3 viewDirWS;
    float4 shadowCoord;
    half specular;
    
    float2 staticLightmapUV;
};

CartoonCustomData GetDefaultCartoonCustomData()
{
    CartoonCustomData data;
    data.baseColor = half3(0, 0, 0);
    data.baseAlpha = 1;
    data.emission = half3(0, 0, 0);
    data.metallic = 0;
    data.smoothness = 0;
    data.perRoughness = 1;
    data.roughness = 1;
    data.positionWS = half3(0, 0, 0);
    data.normalWS = half3(0, 1, 0);
    data.viewDirWS = half3(0, 0, 0);
    data.shadowCoord = float4(0, 0, 0, 0);
    data.specular = 1;
    data.staticLightmapUV = float2(0, 0);
    
    return data;
}

#endif
