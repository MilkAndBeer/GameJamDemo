#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CartoonCustomData.hlsl"
#include "CartoonLitFunction.hlsl"

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

#ifndef CARTOONCUSTOMDATA
#define CARTOONCUSTOMDATA

struct CartoonCustomData
{
    half3 baseColor;
    half baseAlpha;
};

CartoonCustomData GetDefaultCartoonCustomData()
{
    CartoonCustomData data;
    data.baseColor = half3(0, 0, 0);
    data.baseAlpha = 1;
    
    return data;
}

#endif


///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                                //
///////////////////////////////////////////////////////////////////////////////
CartoonCustomData InitializeCartoonCustomData(float2 uv)
{
    CartoonCustomData data = GetDefaultCartoonCustomData();
    
    half4 baseTex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv.xy);
    half3 baseColor = baseTex.rgb * _BaseColor.rgb;
    
    half alpha = baseTex.a * _BaseColor.a;

    data.baseColor = baseColor.rgb;
    data.baseAlpha = alpha;

    return data;
}