#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShadingModels.hlsl"
#include "CustomFunction.hlsl"
#include "LitFunction.hlsl"

//Sampler Textures
TEXTURE2D(_NormalMap);              SAMPLER(sampler_NormalMap);
TEXTURE2D(_WaveMap);                SAMPLER(sampler_WaveMap);
TEXTURE2D(_TopFoamMap);             SAMPLER(sampler_TopFoamMap);
TEXTURE2D(_CausticsMap);            SAMPLER(sampler_CausticsMap);
TEXTURE2D(_HeightMap);              SAMPLER(sampler_HeightMap);

TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D_X(_CameraOpaqueTexture);              SAMPLER(sampler_CameraOpaqueTexture);

CBUFFER_START(UnityPerMaterial)
half3 _BaseColor;               half3 _ShallowColor;                

float _Blend;                   float _DepthIntensity;              float _DepthFalloff;                float _Smoothness;
half _IOR;                      half _Thickness;

half _OffsetFrequency;          half _OffsetLength;                 half _OffsetMagnitude;

half _NormalIntensity;          half _NormalScale;                  float _NormalSpeed;

half3 _EdgeColor;               half _EdgeIntensity;                half _EdgeDistance;                 half _EdgeFalloff;

half3 _WaveColor;               half _WaveScale;                    float _WaveSpeed;                   half _WaveIntensity;
half _DistortionScale;          float _DistortionSpeed;             half _DistortionIntensity;

half3 _FoamColor;               half _FoamThreshold;                half _FoamSmooth;                   half _FoamIntensity;

half _TopFoamScale;             float _TopFoamSpeed;
half _TopNoiseScale;            float _TopNoiseSpeed;               half _TopNoiseIntensity;

half _FallFoamScale;            float _FallFoamSpeed;
half _FallNoiseScale;           float _FallNoiseSpeed;              half _FallNoiseIntensity;

half3 _CausticsColor;           half _SplitRGB;                     half _CausticsDistance;             half _CausticsFalloff;
half _CausticsIntensity;        half _CausticsScale;                float _CausticsSpeed;

CBUFFER_END

///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                               //
///////////////////////////////////////////////////////////////////////////////
CustomData InitializecustomData (float2 uv, float3 positionWS, float3 positionOS, float4 positionSS, float4 shadowCoord, half3 N, half mask)
{
    CustomData customData = (CustomData)0;

    Light light = GetMainLight(shadowCoord);
    half3 lightDirWS = normalize(light.direction);
    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    float2 screenPosDefault = positionSS.xy / positionSS.w;
    
    //Triplanar UVs
    float2 uvX = positionOS.zy;
    float2 uvY = positionOS.xz;
    float2 uvZ = positionOS.xy;

    //Depth
    float sceneDepthEye = LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(screenPosDefault)).r, _ZBufferParams);
    float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(positionSS.z);
    float depthDifference = sceneDepthEye - surfaceDepth;
    float depth = saturate(depthDifference / _DepthFalloff) * _DepthIntensity;
    float edge = DepthFade(sceneDepthEye, positionSS.w, _EdgeDistance, _EdgeFalloff) * _EdgeIntensity;

    //Offset
    float time = fmod(_Time.y, 2e5);
    float waveOffset = time * _WaveSpeed;
    float distortionOffset = time * _DistortionSpeed;
    float normalOffset = time * _NormalSpeed;
    float topFoamOffset = time * _TopFoamSpeed;
    float topNoiseOffset = time * _TopNoiseSpeed;
    float fallFoamOffset = time * _FallFoamSpeed;
    float fallNoiseOffset = time * _FallNoiseSpeed;
    float causticsOffset = time * _CausticsSpeed;

    //Normal
    half3 normal1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, float2(uvY * (1 / _NormalScale) + normalOffset)), _NormalIntensity);
    half3 normal2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, float2(-uvY * (1 / _NormalScale * 0.6) + normalOffset * 0.8)), _NormalIntensity * 0.8);
    half3 normal = normalize(normal1 + normal2);
    half3 blend = TriplanarBlend(N, _Blend);
    half3 normalTS = NormalizeNormalPerVertex(normal * blend.x + normal * blend.y + normal * blend.z);
    half3 normalWS = TriplanarNormal(normal, normal, normal, N.xyz, blend);
    
    //Distorted
    float distortion = SimpleNoise(float2(uvY + distortionOffset), _DistortionScale) * _DistortionIntensity;

    //Wave
    float wave = saturate(SAMPLE_TEXTURE2D(_WaveMap, sampler_WaveMap, float2(-uvY * (1 / _WaveScale) + waveOffset - distortion))).r * _WaveIntensity;
    
    //Foam
    half foamMask = smoothstep(_FoamThreshold, _FoamThreshold + _FoamSmooth, mask);
    
    float noiseY = SimpleNoise(float2(uvY + topNoiseOffset), _TopNoiseScale) * _TopNoiseIntensity;
    float foamY = SAMPLE_TEXTURE2D(_TopFoamMap, sampler_TopFoamMap, float2(uv.yy * (1 / _TopFoamScale) + topFoamOffset - noiseY)).r;
    
    float noiseX = SimpleNoise(float2(uvX.x, uvX.y + fallNoiseOffset), _FallNoiseScale) * _FallNoiseIntensity;
    float foamX = GradientNoise(float2(uvX.x, uvX.y + fallFoamOffset - noiseX), _FallFoamScale);
    
    float noiseZ = SimpleNoise(float2(uvZ.x, uvZ.y + fallNoiseOffset), _FallNoiseScale) * _FallNoiseIntensity;
    float foamZ = GradientNoise(float2(uvZ.x, uvZ.y + fallFoamOffset - noiseZ), _FallFoamScale);
    
    float foam = foamX * blend.x + foamY * blend.y + foamZ * blend.z;
    foam = step(foam, foamMask) * _FoamIntensity * foamMask;

    //Caustics
    half3 cameraDir = -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2]).xyz;
    half3 cameraPos = _WorldSpaceCameraPos;
    half3 causticsPos = viewDirWS / dot(viewDirWS, cameraDir) * sceneDepthEye + cameraPos;
    half NoL = saturate(dot(N, lightDirWS));
    half shadow = light.shadowAttenuation * light.distanceAttenuation * NoL;
    
    half3x3 tran = half3x3(half3(cos(120), 0, -sin(120)), half3(0, 1, 0), half3(sin(120), 0, cos(120)));
    half3 tangent = mul(tran, half3(0, 0, -1));
    half3 bitangent = normalize(cross(tangent, -lightDirWS));
    tangent = normalize(cross(-lightDirWS, bitangent));
    
    half3 positionLS = mul(half3x3(tangent, bitangent, lightDirWS), causticsPos);
    float2 causticsUV = positionLS.xy;
    
    half3 caustics1 = ColorSplit(_CausticsMap, sampler_CausticsMap, causticsUV, 1 / _CausticsScale, causticsOffset, _SplitRGB);
    half3 caustics2 = ColorSplit(_CausticsMap, sampler_CausticsMap, -causticsUV, 1 / _CausticsScale, causticsOffset, _SplitRGB);
    
    half3 caustics = min(caustics1, caustics2) * _CausticsColor * _CausticsIntensity;
    half causticsMask = shadow;
    
    //Refraction
    float refractionMask = step(positionSS.w - LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(screenPosDefault + normalTS.xy)).r, _ZBufferParams), 0);
    float2 refractionUV = positionSS.xy / positionSS.w;
    half3 refractionColor = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, UnityStereoTransformScreenSpaceTex(refractionUV + normalTS.xy * refractionMask * _IOR)).rgb;

    //Color
    half3 baseColor = lerp(_ShallowColor, _BaseColor, depth);
    baseColor = lerp(baseColor, _WaveColor, wave);
    baseColor = lerp(baseColor, _EdgeColor, edge);
    baseColor = lerp(baseColor, _FoamColor, foam);

    half metallic = 0;
    half smoothness = _Smoothness;

    //Emissive
    half3 emission = lerp(refractionColor, 0, depth) + caustics * causticsMask;

//Ripple----------------------------------------
#if defined _RAIN
    Ripple(_RippleMap, positionWS, normalWS, baseColor);
#endif
//---------------------------------------------

    half perRoughness = 1.0 - smoothness;
    half roughness = max(perRoughness * perRoughness, 0.0078125);

    customData.baseColor = baseColor;
    customData.alpha = 1;
    customData.metallic = metallic;
    customData.smoothness = smoothness;
    customData.perRoughness = perRoughness;
    customData.roughness = roughness;
    customData.normalWS = normalWS;
    customData.viewDirWS = viewDirWS;
    customData.emission = emission;

// //Project--------------------------------------
// #if defined _PROJECT
//     tangent = normalize(cross(-lightDirWS, bitangent));
//     float2 lightMaskUV = positionLS.xy;
//
//     half project = saturate(1 - SAMPLE_TEXTURE2D(_projectMaskMap, sampler_projectMaskMap, lightMaskUV / _ProjectScale).r);
//     customData.project = smoothstep(_ProjectThreshold - _ProjectSmooth, _ProjectThreshold + _ProjectSmooth, project);
// #else
//     customData.project = 1;
// #endif
// //---------------------------------------------

//Cloud ---------------------------------------
#if defined _CLOUD
    half cloud = 0;
    Cloud(_CloudMaskMap, positionWS, normalWS, cloud);
    cloud = lerp(1, cloud, _CloudIntensity);
    customData.baseColor *= cloud;
#endif
//---------------------------------------------

//PointLights----------------------------
    half3 addLights = 0;
    for (int i = 0; i < _LightCount; i++)
    {
        float intensity = _LightsArrayPos[i].w;
        float lightRange = clamp(_LightsArrayColor[i].w - distance(positionWS, _LightsArrayPos[i].xyz), 0, _LightsArrayColor[i].w);
        addLights += _LightsArrayColor[i].rgb * lightRange * intensity * baseColor;
    }
    customData.emission += addLights;
// --------------------------------------
    
//Mask-----------------------------------------
#if defined _MASKON
    half2 DecalUV = (positionWS.xz + 6) / 12;
    half DecalMask = SAMPLE_TEXTURE2D(_MapMaskTexture, sampler_MapMaskTexture, DecalUV).x;
    customData.baseColor = lerp(Saturation(baseColor, 0) * _MaskColor, baseColor, DecalMask);
#endif
//---------------------------------------------

    return customData;
}
