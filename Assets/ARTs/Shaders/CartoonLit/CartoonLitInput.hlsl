#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);

CBUFFER_START(UnityPerMaterial)
    //Basic
    float4 _BaseMap_ST;
    half4 _BaseColor;
    //HSL
    half _H;
    half _S;
    half _L;

CBUFFER_END
