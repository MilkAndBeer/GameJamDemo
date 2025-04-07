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
    float dist = clamp(_WarpRange - distance(positionWS, _WarpPosition), 0, _WarpRange);
    float3 dir = positionWS - _WarpPosition;
    positionWS -= dir * dist * _Warp;
    positionOS = TransformWorldToObject(positionWS);
// --------------------------------------
    
//Thickness -----------------------------
#if defined _THICKNESS
    float3 normal = normalize(input.normalOS.xyz);
    positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
    positionWS = TransformObjectToWorld(positionOS);
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
#endif
// --------------------------------------

//Wind-----------------------------------
#if defined _WIND
    float bendRange = pow(saturate(input.texcoord1.y), _BendRange);
    float bend = _WindSpeed * (_BendStrength * 0.1) * bendRange;
    float bendNoise = SimpleNoise(positionWS.xz + time * _WindSpeed * 0.1, _BendNoise);
    float3 wind = float3(bend * _WindDir.x, 0, bend * _WindDir.y);
    positionWS = lerp(positionWS, positionWS + wind, bendNoise);
#endif
//---------------------------------------

//Collision -----------------------------
#if defined _COLLISION
    float3 colPos = float3(_ObjectArrayPos.x, _ObjectArrayPos.y + 0.4, _ObjectArrayPos.z);
    float3 dis = distance(colPos, positionWS);
    float colSmooth = smoothstep(0.5, 1, input.texcoord1.y);
    float3 radius = 1 - saturate(dis / _ColRange);
    float3 sphere = positionWS - colPos;
    sphere *= radius;
    sphere = clamp(sphere * _ColIntensity, -0.8, 0.8);
    positionWS = lerp(positionWS, positionWS + sphere * colSmooth, _ObjectArrayPos.w);
    positionOS = TransformWorldToObject(positionWS);
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