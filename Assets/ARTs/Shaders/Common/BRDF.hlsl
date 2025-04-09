#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)

///PBR Indirect
half3 F_Indir(half NdotV, half3 F0, half roughness)
{
    half Fre = exp2((-5.55473 * NdotV - 6.98316) * NdotV);
    return F0 + Fre * saturate(1 - roughness - F0);
}

///////////////////////////////////////////////////////////////////////////////
//                          Sample Reflection Probe                          //
///////////////////////////////////////////////////////////////////////////////
half3 EnvBRDF(half3 N, half3 V, half perRoughness)
{
    float3 reflectWS = float3(reflect(-V, N));
#if defined(_REFLECTION_PROBE_BLENDING) || USE_FORWARD_PLUS
    irradiance = CalculateIrradianceFromReflectionProbes(reflectVector, positionWS, perceptualRoughness, normalizedScreenSpaceUV);
#else
    #ifdef _REFLECTION_PROBE_BOX_PROJECTION
            reflectWS = BoxProjectedCubemapDirection(reflectWS, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
    #endif // _REFLECTION_PROBE_BOX_PROJECTION
    
    float mip = perRoughness * (1.7 - 0.7 * perRoughness) * 6;
    
    half4 irradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectWS, mip));

#endif
    half3 decode_specColorProbe = DecodeHDREnvironment(irradiance, unity_SpecCube0_HDR);

    return decode_specColorProbe;
}

half2 EnvBRDFApproxLazarov(half rougness, half NoV)
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
    const half4 c0 = { -1, -0.0275, -0.572, 0.022 };
    const half4 c1 = { 1, 0.0425, 1.04, -0.04 };
    half4 r = rougness * c0 + c1;
    half a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
    half2 AB = half2(-1.04, 1.04) * a004 + r.zw;
    return AB;
}

half3 EnvBRDFApprox(half3 specularColor, half roughness, half NdotV)
{
    half2 AB = EnvBRDFApproxLazarov(roughness, NdotV);
    
    // Anything less than 2% is physically impossible and is instead considered to be shadowing
    // Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
    float F90 = saturate(50.0 * specularColor.g);
    
    return specularColor * AB.x + F90 * AB.y;
}