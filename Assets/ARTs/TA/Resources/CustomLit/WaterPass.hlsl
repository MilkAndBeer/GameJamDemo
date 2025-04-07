struct Attributes
{
    float4 positionOS    : POSITION;
    float2 texcoord      : TEXCOORD0;
    half4  color         : COLOR;
    float3 normalOS      : NORMAL;
    float4 tangentOS     : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv            : TEXCOORD0;
    float4 tangentWS     : TEXCOORD1;
    float4 bitangentWS   : TEXCOORD2;
    float4 normalWS      : TEXCOORD3;
    float3 normalOS      : TEXCOORD7;
    float4 positionSS    : TEXCOORD4;
    float3 positionOS    : TEXCOORD5;
    //half3  lightColor    : TEXCOORD6;
    half4  color         : TEXCOORD8;

    float4 positionCS    : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

///////////////////////////////////////////////////////////////////////////////
//                              Vertex                                       //
///////////////////////////////////////////////////////////////////////////////
Varyings WaterVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);
    float time = fmod(_Time.y, 2e5);
    
    //Warp ----------------------------------
    VertexWarp(positionWS, positionOS, _WarpPosition, _WarpIntensity, _WarpRange);
    // --------------------------------------

    //Thickness ----------------------------------
    VertexThickness(positionWS, positionOS, input.normalOS.xyz, _Thickness);
    // -------------------------------------------
    
    //Wave ---------------------------------------
    VertexHeight(positionWS, positionOS, _OffsetLength, _OffsetFrequency, _OffsetMagnitude, time);
    // -------------------------------------------

    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);

    output.positionCS = vertexInput.positionCS;
    output.positionSS = ComputeScreenPos(vertexInput.positionCS);
    output.positionOS = input.positionOS.xyz;
    output.normalWS = float4(normalInputs.normalWS, positionWS.x);
    output.tangentWS = float4(normalInputs.tangentWS, positionWS.y);
    output.bitangentWS = float4(normalInputs.bitangentWS, positionWS.z);
    output.normalOS = input.normalOS;
    output.uv = input.texcoord;
    output.color = input.color;

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
half4 WaterFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    float3 positionWS = float3(input.normalWS.w, input.tangentWS.w, input.bitangentWS.w);
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    CustomData customData = InitializecustomData(input.uv, positionWS, input.positionOS, input.positionSS, shadowCoord, input.normalWS.xyz,
                                                    input.normalOS.xyz, input.color.r);

    half3 color = DefaultShading(customData, _Exposure);

    return half4(color, customData.alpha);
}

