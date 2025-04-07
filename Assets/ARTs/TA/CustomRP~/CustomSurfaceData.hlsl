#ifndef UNIVERSAL_SURFACE_DATA_INCLUDED
#define UNIVERSAL_SURFACE_DATA_INCLUDED

// Must match Universal ShaderGraph master node
struct SurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 normalWS;
    half3 tangentWS;
    half3 emission;
    half  occlusion;
    half  alpha;
    half  clearCoatMask;
    half  clearCoatSmoothness;

    half3 borderColor;
    half borderThreshold;
    half borderSmooth;

    half3 shadowColor;
    half shadowThreshold;
    half shadowSmooth;

    half3 reflectColor;
    half reflectThreshold;
    half reflectSmooth;

    half3 specColor;
    half specThreshold;
    half specSmooth;
    half specIntensity;
   
    half3 fresColor;
    half fresThreshold;
    half fresSmooth;
    half fresIntensity;

    half exposure;
    half reflectExposure;
    
    half castShadow;

    half hairSpecExponent;
    half hairSpecMask;

    float4 customSH[7];
};

#endif
