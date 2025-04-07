#include "Deferred.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 texcoord1    : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 uv                       : TEXCOORD0;
    float3 normalWS                 : TEXCOORD1;
    float3 tangentWS                : TEXCOORD2;    // xyz: tangent, w: sign
    float3 bitangentWS              : TEXCOORD3;
    float3 positionWS               : TEXCOORD4;
    float3 positionOS               : TEXCOORD5;
    float4 positionSS               : TEXCOORD6;
    
    float4 positionCS               : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

///////////////////////////////////////////////////////////////////////////////
//                              Vertex                                       //
///////////////////////////////////////////////////////////////////////////////
Varyings CustomGBufferVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    float3 positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);
    float time = fmod(_Time.y, 2e5);

//Warp ----------------------------------
    float dist = clamp(_WarpRange - distance(positionWS, _WarpPosition), 0, _WarpRange);
    float3 dir = positionWS - _WarpPosition;
    positionWS -= dir * dist * _Warp;
    positionOS = TransformWorldToObject(positionWS);
// --------------------------------------

//Thickness -----------------------------
#if defined _THICKNESS
    float3 normal = normalize(input.normalOS.xyz);
    positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
    positionWS = TransformObjectToWorld(positionOS.xyz);
#endif
// --------------------------------------

//Height --------------------------------
#if defined _HEIGHT
    float2 uv = positionWS.xz;
    float waveOffset = time * _Frequency;
    float height = SimpleNoise(uv + waveOffset, _Length).r;
    height = Remap(height, float2(0, 1), float2(-1, 1)).r;
    float3 offset = height * _Magnitude * 0.1;
    positionWS += offset;
    positionOS = TransformWorldToObject(positionWS);
#endif
// --------------------------------------
    
//Wind-----------------------------------
#if defined _WIND
    float bendRange = pow(saturate(input.texcoord1.y), _BendRange);
    float bend = _WindSpeed * (_BendStrength * 0.1) * bendRange;
    float bendNoise = SimpleNoise(positionWS.xz + time * _WindSpeed * 0.1, _BendNoise);
    float3 wind = float3(bend * _WindDir.x, 0, bend * _WindDir.y);
    positionWS = lerp(positionWS, positionWS + wind, bendNoise);
    positionOS = TransformWorldToObject(positionWS);
#endif
//---------------------------------------

    VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    output.positionCS = vertexInput.positionCS;
    output.positionWS = vertexInput.positionWS;
    output.positionOS = input.positionOS.xyz;
    output.positionSS = ComputeScreenPos(vertexInput.positionCS);
    output.tangentWS = normalInput.tangentWS;
    output.bitangentWS = normalInput.bitangentWS;
    output.normalWS = normalInput.normalWS;
    output.uv.xy = input.texcoord;
    output.uv.zw = input.texcoord1;

    return output;
}
///////////////////////////////////////////////////////////////////////////////
//                              Fragment                                     //
///////////////////////////////////////////////////////////////////////////////
FragmentOutput CustomGBufferFragment(Varyings input)
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    CustomData customData = InitializecustomData(input.uv, input.positionWS, input.positionOS, input.positionSS, shadowCoord,
                                                 input.normalWS, input.tangentWS, input.bitangentWS);

    half3 indirect = IndirectLighting(customData, _Exposure, custom_SH);
    
    return InitializeGbuffer(customData, indirect + customData.emission);
}