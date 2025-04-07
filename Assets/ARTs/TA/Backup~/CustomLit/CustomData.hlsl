struct CustomData
{
    half3 baseColor;
    half  alpha;
    half  specIntensity;
    half3 specColor;
    float3 normalWS;
    float3 tangentWS;
    float3 positionWS;
    float3 viewDirWS;
    half  metallic;
    half  smoothness;
    half  perRoughness;
    half  roughness;
    half3 emission;
    half3 transmission;
    half  specMask;
    half  exponent;
    half  rampType;
    float4 shadowCoord;
    half3 ramp;
};