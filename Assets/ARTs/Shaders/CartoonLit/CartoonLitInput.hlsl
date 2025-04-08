#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CartoonCustomData.hlsl"
#include "CartoonLitFunction.hlsl"

TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);

#if defined _EMISSION
TEXTURE2D(_EmissionMap);   SAMPLER(sampler_EmissionMap);
#endif

CBUFFER_START(UnityPerMaterial)
//Basic
float4 _BaseMap_ST;
half4 _BaseColor;

//HSL
half _H;
half _S;
half _L;

//Emission
half _IsLight;
half _EmissionStrength;
half4 _EmissionColor;
half _EmissionBakedIntensity;

CBUFFER_END


///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                                //
///////////////////////////////////////////////////////////////////////////////
CartoonCustomData InitializeCartoonCustomData(float2 uv)
{
    CartoonCustomData data = GetDefaultCartoonCustomData();
    
    half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv.xy);
    half3 baseColor = baseTex.rgb * _BaseColor.rgb;
    
    half alpha = baseTex.a * _BaseColor.a;

    #if defined _EMISSION
        half emissive = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv.xy).g;
        half3 emissionColor = lerp(emissive * _EmissionColor.rgb * _EmissionStrength, emissive * _EmissionColor.rgb * _EmissionBakedIntensity, _IsLight);
        data.emission = emissionColor;
    #endif

    data.baseColor = baseColor.rgb;
    data.baseAlpha = alpha;

    return data;
}