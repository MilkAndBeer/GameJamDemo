#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS               : SV_POSITION;
    float3 positionWS               : TEXCOORD0;
    float3 normalWS                 : TEXCOORD1;
    float2 uv                       : TEXCOORD2;
    float4 positionSS               : TEXCOORD3;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.normalWS = normalInput.normalWS;
    output.uv = input.texcoord;
    output.positionSS = ComputeScreenPos(vertexInput.positionCS);
    
    return output;
}

half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    float3 positionWS = normalize(input.positionWS);
    float2 screenPosDefault = input.positionSS.xy / input.positionSS.w;
    float sceneDepthEye = LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(screenPosDefault)).r, _ZBufferParams);
    half alpha = saturate((sceneDepthEye - input.positionSS.w) * _PlaneDepth);
    
    float time = fmod(_Time.y, 2e5);
    float2 uv = positionWS.xz / positionWS.y;
    float speed = time * _PlaneSpeed;
    half noise1 = GradientNoise(uv + speed * 0.5, _PlaneScale * 0.1);
    half noise2 = SimpleNoise(uv - speed, _PlaneScale);
    half noise3 = SimpleNoise(uv + speed * 1.5, _PlaneScale * 0.5);
    half noise  = saturate(noise1 + noise2) * noise3;
    half3 cloudColor = lerp(_PlaneBrightColor, _PlaneShadowColor, noise);
    half mask = smoothstep(_PlaneThreshold, _PlaneThreshold + _PlaneFalloff, input.uv.y);

    return half4(cloudColor, alpha * mask);
}

