struct CustomData
{
    half3 baseColor;
    half3 secondColor;
    half specular;
    half  alpha;
    float3 normalWS;
    float3 tangentWS;
    float3 positionWS;
    float3 viewDirWS;
    half metallic;
    half smoothness;
    half perRoughness;
    half roughness;
    half3 emission;
    float4 shadowCoord;
    half  subsurfaceIntensity;
    half  subsurfaceFalloff;
    half3 subsurfaceColor;
    float rimMask;
    half3 rimColor;
    
    float2 staticLightmapUV;
};