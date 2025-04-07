struct Attributes
{
    float4 positionOS    : POSITION;
    float2 texcoord      : TEXCOORD0;
    half4  color         : COLOR;
    float4 normalOS      : NORMAL;
    float4 tangentOS     : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv            : TEXCOORD0;
    float4 tangentWS     : TEXCOORD1;
    float4 bitangentWS   : TEXCOORD2;
    float4 normalWS      : TEXCOORD3;
    float4 positionSS    : TEXCOORD4;
    float3 positionOS    : TEXCOORD5;
    half3  lightColor    : TEXCOORD6;
    half4  color         : COLOR;

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
    
    //Warp ----------------------------------
    float dist = clamp(_WarpRange - distance(positionWS, _WarpPosition), 0, _WarpRange);
    float3 dir = positionWS - _WarpPosition;
    positionWS -= dir * dist * _Warp;
    positionOS = TransformWorldToObject(positionWS);
    // --------------------------------------

    //Thickness ----------------------------------
    float3 normal = normalize(input.normalOS.xyz);
    positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
    positionWS = TransformObjectToWorld(positionOS.xyz);
    // -------------------------------------------
    
    //Wave ---------------------------------------
    float2 uv = positionWS.xz;
    float waveOffset = _Time.y * _OffsetFrequency * 0.1;
    float height = SAMPLE_TEXTURE2D_LOD(_HeightMap, sampler_HeightMap, uv * _OffsetLength + waveOffset, 0).g;
    height = Remap(height, float2(0, 1), float2(-1, 1)).r;
    float3 offset = float3(0, height * _OffsetMagnitude * 0.1, 0);
    positionWS += offset;
    positionOS = TransformWorldToObject(positionWS);
    // -------------------------------------------

    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS.xyz);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS.xyz, input.tangentOS);

    output.positionCS = vertexInput.positionCS;
    output.positionSS = ComputeScreenPos(vertexInput.positionCS);
    output.positionOS = input.positionOS.xyz;
    output.normalWS = float4(normalInputs.normalWS, positionWS.x);
    output.tangentWS = float4(normalInputs.tangentWS, positionWS.y);
    output.bitangentWS = float4(normalInputs.bitangentWS, positionWS.z);
    output.uv = input.texcoord;
    output.color = input.color;

    half3 light = 0;
    for (int i = 0; i < _LightCount; i++)
    {
        float intensity = _LightsArrayPos[i].w;
        float lightRange = clamp(_LightsArrayColor[i].w - distance(positionWS, _LightsArrayPos[i].xyz), 0, _LightsArrayColor[i].w);
        lightRange *= lightRange;
        float3 lightDir = normalize(_LightsArrayPos[i].xyz - positionWS);
        half halfLambert = dot(lightDir, output.normalWS.xyz) * 0.5 + 0.5;
        light += _LightsArrayColor[i].rgb * lightRange * intensity * halfLambert;
    }

    output.lightColor = light * _GlobleLight;
    
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
    CustomData customData = InitializecustomData(input.uv, positionWS, input.positionOS, input.positionSS, shadowCoord,
                                                    input.normalWS.xyz, input.color.r);

    half3 color = DefaultShading(customData, _Exposure);

    return half4(color, customData.alpha);
}

