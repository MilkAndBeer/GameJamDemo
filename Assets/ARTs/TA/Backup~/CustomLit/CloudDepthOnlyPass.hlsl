#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/CustomCore.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float3 positionWS   : TEXCOORD1;
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation

    output.positionCS = vertexInput.positionCS;
    output.positionWS = vertexInput.positionWS;
    
    output.uv = input.texcoord;

    return output;
}

half DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float3 positionWS = normalize(input.positionWS);
    half ground = smoothstep(0, _CloudFalloff, max(0, -positionWS.y));
    float time = fmod(_Time.y, 2e5);
    half cloudNoise = GradientNoise(input.uv + time * _CloudNoiseSpeed * 0.1, _CloudNoiseScale) * _CloudNoiseIntensity * 0.05;
    half4 cloudTex = SAMPLE_TEXTURE2D(_CloudMap, sampler_CloudMap, input.uv - half2(cloudNoise, cloudNoise));

    half alpha = smoothstep(cloudTex.b, 0, saturate(1 - _CloudAmount)) * cloudTex.a;
    alpha *= 1 - ground;

    return alpha;
}
