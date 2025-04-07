#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ShadingModels.hlsl"
#include "LitFunction.hlsl"

//Sampler Textures
TEXTURE2D(_FlowMap);                SAMPLER(sampler_FlowMap);
TEXTURE2D(_WaveMap);                SAMPLER(sampler_WaveMap);
TEXTURE2D(_FallMap);                SAMPLER(sampler_FallMap);
TEXTURE2D(_FoamMap);                SAMPLER(sampler_FoamMap);

TEXTURE2D(_CausticsMap);            SAMPLER(sampler_CausticsMap);
// TEXTURE2D(_HeightMap);              SAMPLER(sampler_HeightMap);

TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D_X(_CameraOpaqueTexture);              SAMPLER(sampler_CameraOpaqueTexture);
//TEXTURE2D_X(_PlanarReflectionTexture);          SAMPLER(sampler_PlanarReflectionTexture);

CBUFFER_START(UnityPerMaterial)
half3 _BaseColor;                     

float _DepthThreshold;          float _DepthSmooth;

float _Smoothness;              float _IOR;                           float _Thickness;                     float _ReflectionIntensity;

float _OffsetFrequency;         float _OffsetLength;                  float _OffsetMagnitude;

half3 _ShallowColor;          

half3 _WaveColor;

float _FlowIntensity;           float _FlowScale;                    float _FlowSpeed;              float2 _FlowDir;

float _WaveScale;               float _WaveSpeed;                    float2 _WaveDir;             

float _FallScale;               float _FallSpeed;

half3 _FoamColor;               float _FoamThreshold;                float _FoamSmooth;                   float _FoamIntensity;

float _FoamNoiseIntensity;      float _FoamScale;                   float _FoamSpeed;                   float _FoamStep;

float _FallFoamScale;            float _FallFoamSpeed;

//half3 _CausticsColor;
half _SplitRGB;                 float _CausticsIntensity;            half _CausticsScale;                float _CausticsSpeed;

// float _EdgeFoamThreshold;       float _EdgeFoamSmooth;              float _EdgeStep;
//
// float _EdgeScale;               float _EdgeSpeed;                  

// half _EmissionBakedIntensity;

CBUFFER_END

///////////////////////////////////////////////////////////////////////////////
//                      Initialize customData                               //
///////////////////////////////////////////////////////////////////////////////
CustomData InitializecustomData (float2 uv, float3 positionWS, float3 positionOS, float4 positionSS, float4 shadowCoord, float3 N, float3 normalOS, half mask)
{
    CustomData customData = (CustomData)0;

    Light light = GetMainLight(shadowCoord);
    float3 lightDirWS = normalize(light.direction);
    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    float2 screenPosDefault = positionSS.xy / positionSS.w;
    
    //Triplanar UVs
    float2 uvX = positionWS.zy;
    float2 uvY = positionWS.xz;
    float2 uvZ = positionWS.xy;

    //Depth
    float sceneDepthEye = LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(screenPosDefault)).r, _ZBufferParams);
    float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(positionSS.z);
    float depthDifference = sceneDepthEye - surfaceDepth;
    //float depth = saturate(depthDifference / _DepthSmooth) * _DepthIntensity;
    //float depth = LinearStep(_DepthThreshold - _DepthSmooth, _DepthThreshold + _DepthSmooth, depthDifference) * _DepthIntensity;

    //Shallow
    //float shallow = LinearStep(_ShallowThreshold - _ShallowSmooth, _ShallowThreshold + _ShallowSmooth, depthDifference);

    //Time
    float time = fmod(_Time.y, 2e5);

    float2 waveOffset = float2(time * _WaveSpeed, time * _WaveSpeed) * _WaveDir;
    float2 flowOffset = float2(time * _FlowSpeed, time * _FlowSpeed) * _FlowDir;
    
    float waveScale = 1 / _WaveScale;
    float flowScale = 1 / _FlowScale;
    
    float2 fallScale = float2(1 / _FallScale * 5, 1 / _FallScale);
    float2 fallOffset = float2(0, time * _FallSpeed);
    
    float causticsOffset = time * _CausticsSpeed * 0.1;

    float3 blend = TriplanarBlend(N, 3);

    //Flow
    float flow = SAMPLE_TEXTURE2D_LOD(_FlowMap, sampler_FlowMap, uvY * flowScale + flowOffset, 0).g * _FlowIntensity;

    //Wave
    float waveX = saturate(SAMPLE_TEXTURE2D(_FallMap, sampler_FallMap, uvX * fallScale + fallOffset)).g;
    float waveY = saturate(SAMPLE_TEXTURE2D(_WaveMap, sampler_WaveMap, uvY * waveScale + waveOffset - flow)).g;
    float waveZ = saturate(SAMPLE_TEXTURE2D(_FallMap, sampler_FallMap, uvZ * fallScale + fallOffset)).g;
    float wave = waveX * blend.x + waveY * blend.y + waveZ * blend.z;
    
    float3 normalWS = NormalBlend(N, float3(wave, wave, wave));

    //float3 normalWS = normalize(cross(float3(0, ddy(wave), 1), float3(1, ddx(wave), 0)));
    
    //Foam
    float3 upDir = float3(0, 1, 0);
    float upMask = saturate(dot(upDir, N));
    upMask = step(0.2, upMask);
    
// #if defined _EDGEFOAM
//     float edgeMask = LinearStep(1 - _EdgeFoamThreshold, 1 - _EdgeFoamThreshold + _EdgeFoamSmooth, mask);
//     float edgeScale = _EdgeScale;
//     float edgeOffset = time * _EdgeSpeed;
//     float edge = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap, uv.yy * edgeScale + edgeOffset - wave * _FoamNoiseIntensity).g * edgeMask;
//     foamEdge = step(_EdgeStep, edge) * upMask;
// #endif

#if defined _EDGEFOAM
    float foamTopMask = LinearStep(1 - _FoamThreshold, 1 - _FoamThreshold + _FoamSmooth, mask);
    float topFoamScale = 1 / _FoamScale;
    float topFoamOffset = time * _FoamSpeed;
    float top = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap, uv.yy * topFoamScale + topFoamOffset - wave * _FoamNoiseIntensity).g * foamTopMask;
    float foamTop = step(_FoamStep, top) * upMask;
#else
    //Top
    float foamTopMask = LinearStep(1 - _FoamThreshold, 1 - _FoamThreshold + _FoamSmooth, saturate(1 - depthDifference));
    float topFoamScale = 1 / _FoamScale;
    float topFoamOffset = time * _FoamSpeed;
    float2 topUV = float2(foamTopMask, foamTopMask);
    float top = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap, topUV * topFoamScale - topFoamOffset - wave * _FoamNoiseIntensity).g * foamTopMask;
    //float foamTop = step(wave * _FoamNoiseIntensity, foamTopMask);
    float foamTop = step(_FoamStep, top) * upMask;
#endif

    //Side
    float foamSideMask = saturate(dot(N + wave, upDir));
    float foamSide = step(0.5, foamSideMask) * step(foamSideMask, 0.9);

    float foam = saturate(foamTop + foamSide) * _FoamIntensity;
    
    //Caustics
    half3 cameraDir = -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2]).xyz;
    half3 cameraPos = _WorldSpaceCameraPos;
    half3 causticsPos = viewDirWS / dot(viewDirWS, cameraDir) * sceneDepthEye + cameraPos;
    float NoL = saturate(dot(normalWS, lightDirWS));
    float shadow = light.shadowAttenuation * NoL;
    
    half3x3 tran = half3x3(half3(cos(120), 0, -sin(120)), half3(0, 1, 0), half3(sin(120), 0, cos(120)));
    half3 tangent = mul(tran, half3(0, 0, -1));
    half3 bitangent = normalize(cross(tangent, -lightDirWS));
    tangent = normalize(cross(-lightDirWS, bitangent));
    
    half3 positionLS = mul(half3x3(tangent, bitangent, lightDirWS), causticsPos);
    float2 causticsUV = positionLS.xy;
    
    half3 caustics1 = ColorSplit(_CausticsMap, sampler_CausticsMap, causticsUV, 1 / _CausticsScale, causticsOffset, _SplitRGB);
    half3 caustics2 = ColorSplit(_CausticsMap, sampler_CausticsMap, -causticsUV, 1 / _CausticsScale, causticsOffset, _SplitRGB);
    
    half3 caustics = min(caustics1, caustics2) * _CausticsIntensity;
    float causticsMask = shadow;

    //Reflection
    float2 refUV = positionSS.xy / positionSS.w;
    float2 refNoise = float2(0, (wave - 0.5) * 2);
    //half3 reflectionColor = SAMPLE_TEXTURE2D_X(_PlanarReflectionTexture, sampler_PlanarReflectionTexture, refUV + refNoise * _IOR * 0.1).rgb;
    
    //Refraction
    //float refractionMask = step(positionSS.w - LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(screenPosDefault + normalTS.xy)).r, _ZBufferParams), 0);
    // float2 refractionUV = positionSS.xy / positionSS.w;
    // half3 refractionColor = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, UnityStereoTransformScreenSpaceTex(refractionUV + normalTS.xy * refractionMask * _IOR)).rgb;
    
    half3 refractionColor = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, refUV + refNoise * _IOR * 0.1).rgb;
    
    //Color
    float depth = LinearStep(1 - _DepthThreshold, 1 - _DepthThreshold + _DepthSmooth, depthDifference);

    half3 baseColor = lerp(_WaveColor, _BaseColor, saturate(wave));
    baseColor = lerp(_ShallowColor, baseColor, depth);
    baseColor += refractionColor * (1 - depth);
    //baseColor += reflectionColor * _ReflectionIntensity;
    baseColor = lerp(baseColor + caustics * causticsMask, baseColor, depth);
    baseColor = lerp(baseColor, _FoamColor, foam);
    
    half smoothness = _Smoothness; //lerp(_Smoothness, 0.1, foam);
    half perRoughness = 1.0 - smoothness;
    half roughness = max(perRoughness * perRoughness, 0.0078125);

//Ripple----------------------------------------
#if defined _RAIN
    Ripple(_RippleMap, positionWS, normalWS, _DepthRT, _DepthCamPos.xyz, _DepthCameraSize, _CamFarPlane, baseColor, smoothness);
#endif
//---------------------------------------------
    
    customData.baseColor = baseColor;
    customData.alpha = 1;
    customData.metallic = 0;
    customData.smoothness = smoothness;
    customData.perRoughness = perRoughness;
    customData.roughness = roughness;
    customData.normalWS = normalWS;
    customData.viewDirWS = viewDirWS;
    customData.emission = 0;
    customData.specular = 1;

//Cloud ---------------------------------------
#if defined _CLOUD
    half cloud = 0;
    Cloud(_CloudMaskMap, positionWS, normalWS, cloud);
    cloud = lerp(1, cloud, _CloudIntensity);
    customData.baseColor *= cloud;
#endif
//---------------------------------------------
    
//Mask-----------------------------------------
#if defined _MASKON
    half2 DecalUV = (positionWS.xz + 6) / 12;
    half DecalMask = SAMPLE_TEXTURE2D(_MapMaskTexture, sampler_MapMaskTexture, DecalUV).x;
    customData.baseColor = lerp(Saturation(baseColor, 0) * _MaskColor, baseColor, DecalMask);
#endif
//---------------------------------------------

    return customData;
}
