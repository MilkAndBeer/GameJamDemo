#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "CustomFunction.hlsl"

TEXTURE2D(_CloudMap);       SAMPLER(sampler_CloudMap);

CBUFFER_START(UnityPerMaterial)
half3 _BrightColor;
half3 _ShadowColor;
half3 _RimColor;
half _RimStrength;
half _CloudAmount;
half _CloudFalloff;
half _CloudNoiseScale;
half _CloudNoiseSpeed;
half _CloudNoiseIntensity;
CBUFFER_END

