#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#if defined(LOD_FADE_CROSSFADE)
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
#endif

float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    half3  color        : COLOR;
    float2 texcoord     : TEXCOORD0;
    float2 texcoord1    : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionSS   : TEXCOORD1;
    float4 positionCS   : SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);
    float time = fmod(_Time.y, 2e5);

#if _CASTING_PUNCTUAL_LIGHT_SHADOW
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
#else
    float3 lightDirectionWS = _LightDirection;
#endif

//Warp ----------------------------------
    VertexWarp(positionWS, positionOS, _WarpPosition, _WarpIntensity, _WarpRange);
// --------------------------------------
    
//Thickness -----------------------------
#if defined _THICKNESS
    VertexThickness(positionWS, positionOS, input.normalOS.xyz, _Thickness);
#endif
// --------------------------------------

//Height --------------------------------
#if defined _HEIGHT
    VertexHeight(positionWS, positionOS, _Length, _Frequency, _Magnitude, time);
#endif
// --------------------------------------

//Wind-----------------------------------
#if defined _WIND
    VertexWind(positionWS, positionOS, _WindDir, _WindSpeed, _WindStrength, _WindNoise, input.color.r, time);
#endif
//---------------------------------------

//Collision -----------------------------
#if defined _COLLISION
    VertexCollision(positionWS, positionOS, _ObjectArrayPos, _PosCount, _ColIntensity, input.color.r);
#endif
//---------------------------------------
    
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

    return positionCS;
}

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    output.uv = input.texcoord;
    output.positionCS = GetShadowPositionHClip(input);
    output.positionSS = ComputeScreenPos(output.positionCS);
    return output;
}

half4 ShadowPassFragment(Varyings input) : SV_TARGET
{
    half4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    half alpha = albedoAlpha.a;

#if defined _ALPHATEST
    clip(alpha - _Cutoff);
#endif

// #if defined _DITHER
//     half dither = Dither(_DitherThreshold, input.positionSS / input.positionSS.w);
//     clip(alpha - dither);
// #endif

#if defined _FADE
    half fade = Dither(_FadeThreshold, input.positionSS / input.positionSS.w);
    clip(fade);
#endif

#ifdef LOD_FADE_CROSSFADE
    LODFadeCrossFade(input.positionCS);
#endif
    
    return 0;
}