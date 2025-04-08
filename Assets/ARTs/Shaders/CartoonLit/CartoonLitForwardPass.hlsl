
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
    CartoonCustomData customData = InitializeCartoonCustomData(i.uv);
    
    half4 finalColor = half4(customData.baseColor, customData.baseAlpha);
    
    finalColor.rgb += customData.emission;
    
    return finalColor;
}