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
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    output.normalWS = normalInput.normalWS;
    output.uv = input.texcoord;
    
    return output;
}

half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    float3 positionWS = normalize(input.positionWS);
    half ground = smoothstep(0, _CloudFalloff, max(0, -positionWS.y));
    Light mainLight = GetMainLight();
    half3 lightDirWS = normalize(mainLight.direction);
    half NdotL = saturate(dot(input.normalWS, -lightDirWS));
    float time = fmod(_Time.y, 2e5);
    half cloudNoise = GradientNoise(input.uv + time * _CloudNoiseSpeed * 0.1, _CloudNoiseScale) * _CloudNoiseIntensity;
    half4 cloudTex = SAMPLE_TEXTURE2D(_CloudMap, sampler_CloudMap, input.uv);
    
    //Base Color
    half3 cloudColor = lerp(_ShadowColor, _BrightColor, cloudTex.r);

    //Rim Color
    half3 rimColor = _RimColor * mainLight.color.rgb * cloudTex.g * NdotL * _RimStrength;

    //Range
    //half alpha = smoothstep(cloudTex.b, 0, saturate(1 - _CloudAmount)) * cloudTex.a;
    half ctrl = LinearStep(1 - _CloudAmount - _CloudFalloff, 1 - _CloudAmount + _CloudFalloff, cloudTex.b);
    //half ctrl = pow(cloudTex.b, max(_CloudAmount, 0.001));
    half alpha = BlendOverlay(half3(ctrl, ctrl, ctrl), cloudNoise).r * cloudTex.a;
    //half alpha = smoothstep(saturate(ctrl - 0.3), ctrl, cloudTex.b) * cloudTex.a;

    //half alpha = Sigmoid(_CloudAmount, 1 - cloudTex.b, max(0.05, 1 - 0.0)) * cloudTex.a;
    
    half3 color = cloudColor + rimColor;
    
    return half4(color, alpha * (1 - ground));
}

