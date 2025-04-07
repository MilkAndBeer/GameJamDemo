#define MAX_POSITION_COUNT 100

TEXTURE2D(_RampMap);                SAMPLER(sampler_RampMap);

//TEXTURE2D(_LightRamp);              SAMPLER(sampler_LightRamp);

#if defined _RAIN
sampler2D _RippleMap;           
#endif

#if defined _SNOW
sampler2D _SnowAlbedoMap;           sampler2D _SnowDMSMap;
#endif

#if defined _CLOUD
sampler2D _CloudMaskMap;
#endif

// #if defined _PROJECT
// TEXTURE2D(_projectMaskMap);         SAMPLER(sampler_projectMaskMap);
// #endif

#if defined _MASKON
TEXTURE2D(_MapMaskTexture);         SAMPLER(sampler_MapMaskTexture);
#endif

#if defined _SHADINGMODE_HAIR
TEXTURE2D(_HairSpecMap);            SAMPLER(sampler_HairSpecMap);
#endif

CBUFFER_START(GlobalMaterial)
//Stylized
half _Stylized;                 half _Threshold;                half _Smooth;

//Wind
float _WindSpeed;               float2 _WindDir;

//Rain
half _RainAmount;               half _RippleScale;              half3 _RippleColor;                 half _RainScale;
half _RippleStrength;           half _RippleSpeed;

//Snow
half _SnowScale;                half _SnowAmount;

//Cloud
half _CloudScale;               half _CloudSpeed;               half _CloudIntensity;

//Project
// half _ProjectScale;             half _ProjectThreshold;         half _ProjectSmooth;

//Emission
half _EmissionIntensity;

//FrontLight
half3 _FrontLightColor;         half _FrontLightIntensity;

//BackLight
half3 _BackLightColor;          half _BackLightIntensity;

//Shadow
half3 _ShadowColor;

half3 _AmbientColor;
half _Exposure;
//float4 custom_SH[7];
half3 _MaskColor;

//Warp
float _Warp;
float3 _WarpPosition;
float _WarpRange;

//Collision
half _ColIntensity;
half _ColRange;

float4 _LightsArrayPos[MAX_POSITION_COUNT];
float4 _LightsArrayColor[MAX_POSITION_COUNT];
float4 _ObjectArrayPos;
float _LightCount;
float _GlobleLight;

CBUFFER_END
