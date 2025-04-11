
struct a2v
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float2 texcoord1 : TEXCOORD1;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
};

struct v2f
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;
    float4 normalWS     : TEXCOORD1;
    float4 tangentWS    : TEXCOORD2;
    float4 bitangentWS  : TEXCOORD3;
    float4 positionSS   : TEXCOORD4;
    float2 staticLightmapUV : TEXCOORD5;
};

v2f vert(a2v v)
{
    v2f o;
    
    float3 positionOS = v.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);
    //-- 添加顶点位移操作处 --
    
    //------------------------
    
    positionOS = TransformWorldToObject(positionWS);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);
    
    o.positionCS = vertexInput.positionCS;
    o.uv = TRANSFORM_TEX(v.uv, _BaseMap);   
    o.tangentWS = float4(normalInput.tangentWS, positionWS.x);
    o.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
    o.normalWS = float4(normalInput.normalWS, positionWS.z);
    o.positionSS = ComputeScreenPos(vertexInput.positionCS);
    o.staticLightmapUV = float2(0, 0);
    OUTPUT_LIGHTMAP_UV(v.texcoord1.xy, unity_LightmapST, o.staticLightmapUV.xy);
    
    return o;
}

half4 frag(v2f i) : SV_Target
{
    float3 positionWS = float3(i.tangentWS.w, i.bitangentWS.w, i.normalWS.w);
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    
    CartoonCustomData customData = InitializeCartoonCustomData(i.uv, positionWS, i.positionSS, shadowCoord,
        i.normalWS.xyz, i.tangentWS.xyz, i.bitangentWS.xyz, i.staticLightmapUV);
    
    half3 color = DefaultShading(customData);
    color = HSL(color, _H, _S, _L);
    
    half4 finalColor = half4(color, customData.baseAlpha);
 
    return finalColor;
}