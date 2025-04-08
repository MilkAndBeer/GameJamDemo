
struct a2v
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};

v2f vert(a2v v)
{
    v2f o;
    o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
    o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                
    return o;
}

half4 frag(v2f i) : SV_Target
{
    //half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
    //half4 finalColor = baseColor * _BaseColor;
    //finalColor.rgb = HSL(finalColor.rgb, _H, _S, _L);
    CartoonCustomData customData = InitializeCartoonCustomData(i.uv);
    
    half4 finalColor = half4(customData.baseColor, customData.baseAlpha);
    
    return finalColor;
}