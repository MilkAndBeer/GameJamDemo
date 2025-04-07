struct BRDFInput
{
    half3 albedo;
    half3 diffuse;
    half3 specular;
    half oneMinusReflectivity;
    half reflectivity;
    half perceptualRoughness;
    half roughness;
    half roughness2;
    half grazingTerm;
    half normalizationTerm;     
    half roughness2MinusOne;
};

BRDFInput InitializeBRDFInput(half3 albedo, half metallic, half smoothness)
{
    BRDFInput BRDFout = (BRDFInput)0;

    BRDFout.oneMinusReflectivity = kDielectricSpec.a - metallic * kDielectricSpec.a;
    BRDFout.reflectivity         = half(1.0) - BRDFout.oneMinusReflectivity;
    
    BRDFout.albedo               = albedo;
    BRDFout.diffuse              = albedo * BRDFout.oneMinusReflectivity;
    BRDFout.specular             = lerp(kDielectricSpec.rgb, albedo, metallic);
    BRDFout.perceptualRoughness  = 1 - smoothness;
    BRDFout.roughness            = max(BRDFout.perceptualRoughness * BRDFout.perceptualRoughness, HALF_MIN_SQRT);
    BRDFout.roughness2           = max(BRDFout.roughness * BRDFout.roughness, HALF_MIN);
    BRDFout.grazingTerm          = saturate(smoothness + BRDFout.reflectivity);
    BRDFout.normalizationTerm    = BRDFout.roughness * half(4.0) + half(2.0);
    BRDFout.roughness2MinusOne   = BRDFout.roughness2 - half(1.0);

    return BRDFout;
}


struct DataInput
{
    half3 albedo;
    half alpha;
    half smoothness;
    half metallic;
    half occlusion;
    Light light;
    float4 shadowCoord;
    float3 L;
    float3 V;
    half3 T;
    half3 B;
    half3 N;
    half3 normalTS;
    float3 positionWS;
    half exposure;
    half reflectExposure;
    half3 emissive;
    
    half anisotropy;
    
    half3 borderColor;
    half borderThreshold;
    half borderSmooth;

    half3 shadowColor;
    half shadowThreshold;
    half shadowSmooth;

    half3 reflectColor;
    half reflectThreshold;
    half reflectSmooth;

    half specThreshold;
    half specSmooth;
    half specIntensity;
    half3 specColor;
    
    half fresThreshold;
    half fresSmooth;
    half fresIntensity;
    half3 fresColor;
    
    half hairSpecExponent;
    half hairSpecMask;

    half castShadow;
    half hairShadow;

    float4 customSH[7];
};

struct BxDF
{
    float NoH;
    half NoV;
    half NoL;
    half LoH;
    half ToH;
    half BoH;
    half ToV;
    half BoV;
    half ToL;
    half BoL;
    half VoH;
    
    half halfLambert;
};

BxDF GetContex(DataInput dataInput)
{
    BxDF contex;
    
    float3 N = dataInput.N;
    float3 L = dataInput.L;
    float3 V = dataInput.V;
    float3 T = dataInput.T;
    float3 B = dataInput.B;
    float3 H = SafeNormalize(L + V);
    
    contex.NoH = saturate(dot(float3(N), H));
    contex.LoH = half(saturate(dot(L, H)));
    contex.NoL = half(saturate(dot(N, L)));
    contex.NoV = half(abs(dot(N, V)));
    contex.ToH = half(dot(T, H));
    contex.BoH = half(dot(B, H));
    contex.ToV = half(dot(T, V));
    contex.BoV = half(dot(B, V));
    contex.ToL = half(dot(T, L));
    contex.BoL = half(dot(B, L));
    contex.VoH = half(saturate(dot(V, H)));
    
    contex.halfLambert = dot(N, L) * 0.5 + 0.5;

    return contex;
}

struct GBufferOutput
{
    half4 GBuffer0 : SV_Target0;
    half4 GBuffer1 : SV_Target1;
    half4 GBuffer2 : SV_Target2;
    half4 GBuffer3 : SV_Target3;
    

    #ifdef GBUFFER_OPTIONAL_SLOT_1
    GBUFFER_OPTIONAL_SLOT_1_TYPE GBuffer4 : SV_Target4;
    #endif
    #ifdef GBUFFER_OPTIONAL_SLOT_2
    half4 GBuffer5 : SV_Target5;
    #endif
    #ifdef GBUFFER_OPTIONAL_SLOT_3
    half4 GBuffer6 : SV_Target6;
    #endif
};