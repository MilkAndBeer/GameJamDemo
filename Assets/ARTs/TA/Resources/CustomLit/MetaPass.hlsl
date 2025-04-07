#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
#if defined(LOD_FADE_CROSSFADE)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

#define kDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 texcoord1    : TEXCOORD1;
    float2 texcoord2    : TEXCOORD2;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;
    float4 normalWS     : TEXCOORD3;
    float3 normalOS     : TEXCOORD4;
    float4 tangentWS    : TEXCOORD5;    // xyz: tangent, w: sign
    float4 bitangentWS  : TEXCOORD6;
    float3 positionOS   : TEXCOORD7;
    float4 positionSS   : TEXCOORD8;
#ifdef EDITOR_VISUALIZATION
    float2 VizUV        : TEXCOORD1;
    float4 LightCoord   : TEXCOORD2;
#endif
};

Varyings MetaVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    output.positionCS = UnityMetaVertexPosition(input.positionOS.xyz, input.texcoord1, input.texcoord2);
    output.uv = input.texcoord;
#ifdef EDITOR_VISUALIZATION
    UnityEditorVizData(input.positionOS.xyz, input.uv0, input.uv1, input.uv2, output.VizUV, output.LightCoord);
#endif
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionSS = ComputeScreenPos(output.positionCS);
    output.tangentWS = float4(normalInput.tangentWS, positionWS.x);
    output.bitangentWS = float4(normalInput.bitangentWS, positionWS.y);
    output.normalWS = float4(normalInput.normalWS, positionWS.z);
    output.normalOS = input.normalOS;
    
    return output;
}

half4 MetaFragmentLit(Varyings input) : SV_Target
{
    MetaInput metaInput;

    float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    float4 uv = float4(input.uv, 0, 0);
    CustomData customData = InitializecustomData(uv, positionWS, input.positionOS, input.positionSS, shadowCoord,
                                                 input.normalWS.xyz, input.tangentWS.xyz, input.bitangentWS.xyz, input.normalOS, float2(1,1));

//     float2 uv = input.uv.xy;
//     half4 basemap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
//     half3 baseColor = basemap.rgb * _BaseColor.rgb;
//
//     half4 dmsTex = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, uv.xy);
//     half metallic = dmsTex.b * _Metallic;
//     half smoothness = dmsTex.a * _Smoothness;
//     
//     float perRoughness = 1 - smoothness;
//     float roughness = max(perRoughness * perRoughness, 0.0078125);
//     
// #if defined _EMISSION 
//     half emissive = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv.xy).g;
//     half3 emission = lerp(emissive * _EmissionColor * _EmissionStrength, emissive * _EmissionColor * _EmissionIntensity, _IsLight);
// #else
//     half3 emission = 0;
// #endif


    half3 diffuse = lerp(customData.baseColor, half3(0.0,0.0,0.0), customData.metallic);
    half3 specular = lerp(kDielectricSpec.rgb, customData.baseColor, customData.metallic);
    
    metaInput.Albedo = diffuse + specular * customData.roughness * 0.5;
    metaInput.Emission = customData.emission;

#ifdef EDITOR_VISUALIZATION
    metaInput.VizUV = fragIn.VizUV;
    metaInput.LightCoord = fragIn.LightCoord;
#endif
    
    return UnityMetaFragment(metaInput);
}