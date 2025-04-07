#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CustomFunction.hlsl"

TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
TEXTURE2D_X(_CameraOpaqueTexture);              SAMPLER(sampler_CameraOpaqueTexture);

CBUFFER_START(UnityPerMaterial)
half3 _PlaneBrightColor;
half3 _PlaneShadowColor;
half _PlaneDepth;
half _PlaneFalloff;
half _PlaneScale;
half _PlaneSpeed;
half _PlaneThreshold;
CBUFFER_END
