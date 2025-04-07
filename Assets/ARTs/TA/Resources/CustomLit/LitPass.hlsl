struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
#if defined _WIND || _COLLISION
    half3  color        : COLOR;
#endif
    float2 texcoord     : TEXCOORD0;
    float2 texcoord1    : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 uv                       : TEXCOORD0;
    float4 normalWS                 : TEXCOORD1;
    float3 normalOS                 : TEXCOORD2;
    float4 tangentWS                : TEXCOORD3;    // xyz: tangent, w: sign
    float4 bitangentWS              : TEXCOORD4;
    float3 positionOS               : TEXCOORD5;
    float4 positionSS               : TEXCOORD6;
    float2 staticLightmapUV         : TEXCOORD7;

    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

///////////////////////////////////////////////////////////////////////////////
//                              Vertex                                       //
///////////////////////////////////////////////////////////////////////////////
Varyings BasicVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);

//Warp ----------------------------------
    VertexWarp(positionWS, positionOS, _WarpPosition, _WarpIntensity, _WarpRange);
// --------------------------------------

//Wind-----------------------------------
#if defined _WIND
    float time = fmod(_Time.y, 2e5);
    VertexWind(positionWS, positionOS, _WindDir, _WindSpeed, _WindStrength, _WindNoise, input.color.r, time);
#endif
//---------------------------------------

//Collision -----------------------------
#if defined _COLLISION
    VertexCollision(positionWS, positionOS, _ObjectArrayPos, _PosCount, _ColIntensity, input.color.r);
#endif
//---------------------------------------

    positionOS = TransformWorldToObject(positionWS);
    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    
    output.positionCS = vertexInput.positionCS;
    output.positionOS = positionOS;
    output.positionSS = ComputeScreenPos(vertexInput.positionCS);
    output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
    output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
    output.normalWS = float4(normalInput.normalWS, positionWS.z);
    output.normalOS = input.normalOS;
    output.uv.xy = input.texcoord;
    output.uv.zw = input.texcoord1;
    OUTPUT_LIGHTMAP_UV(input.texcoord1.xy, unity_LightmapST, output.staticLightmapUV.xy);

    // half3 light = 0;
    // for (int i = 0; i < _LightCount; i++)
    // {
    //     float intensity = _LightsArrayPos[i].w;
    //     float lightRange = clamp(_LightsArrayColor[i].w - distance(positionWS, _LightsArrayPos[i].xyz), 0, _LightsArrayColor[i].w);
    //     lightRange *= lightRange;
    //     float3 lightDir = normalize(_LightsArrayPos[i].xyz - positionWS);
    //     float lambert = saturate(dot(lightDir, output.normalWS.xyz));
    //     light += _LightsArrayColor[i].rgb * lightRange * intensity * lambert;
    // }
    //
    // output.lightColor = light * _GlobleLight;

    return output;
}

///////////////////////////////////////////////////////////////////////////////
//                              Fragment                                     //
///////////////////////////////////////////////////////////////////////////////
half4 BasicFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    CustomData customData = InitializecustomData(input.uv, positionWS, input.positionOS, input.positionSS, shadowCoord,
                                                 input.normalWS.xyz, input.tangentWS.xyz, input.bitangentWS.xyz, input.normalOS, input.staticLightmapUV);

    //customData.emission += input.lightColor * customData.baseColor;

    half3 color = DefaultShading(customData, _Exposure);
    
    return half4(color, customData.alpha);
}