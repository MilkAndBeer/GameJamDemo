#define MAX_POSITION_COUNT 20
#define MAX_OBJECTPOS_COUNT 100

#if defined _RAIN
sampler2D _RippleMap;           
#endif

#if defined _SNOW
sampler2D _SnowAlbedoMap;           sampler2D _SnowDMSMap;
#endif

#if defined _CLOUD
sampler2D _CloudMaskMap;
#endif

#if defined _MASKON
TEXTURE2D(_MapMaskTexture);         SAMPLER(sampler_MapMaskTexture);
#endif

#if defined _SNOW || _RAIN
TEXTURE2D_X(_DepthRT);
#endif

TEXTURE2D(_Ramp);         SAMPLER(sampler_Ramp);

// sampler2D _DepthRT;

CBUFFER_START(GlobalMaterial)
//Stylized
float _Stylized;
float _BoundaryThreshold;       float _BoundarySmooth;          float _ShadowThreshold;               float _ShadowSmooth;
float _BackThreshold;           float _BackSmooth;              float _BackIntesity;
//float _ShellThreshold;              float _ShellSmooth;
half3 _ShadowColor;             half3 _BoundaryColor;           half3 _BackColor;                     half3 _ShadowEdgeColor;
float _ShadowIntensity;

//Wind
float _WindSpeed;               float2 _WindDir;                float _WindStrength;                float _WindNoise;

//Rain
half _RainAmount;               half _RippleScale;              half3 _RippleColor;                 half _RainScale;
half _RippleStrength;           half _RippleSpeed;

//Snow
half _SnowScale;                half _SnowAmount;               half3 _SnowColor;

//Cloud
half _CloudScale;               half _CloudSpeed;               half _CloudIntensity;

//Emission
half _EmissionIntensity;

// //FrontLight
// half3 _FrontLightColor;         half _FrontLightIntensity;
//

half3 _AmbientColor;
half _Exposure;
float4 custom_SH[7];
half3 _MaskColor;

//Warp
float _WarpIntensity;
float _WarpRange;
float3 _WarpPosition;

float4 _LightsArrayPos[MAX_POSITION_COUNT];
float4 _LightsArrayColor[MAX_POSITION_COUNT];
float4 _ObjectArrayPos[MAX_OBJECTPOS_COUNT];
float _PosCount;
float _LightCount;
float _GlobleLight;

//Depth
float4 _DepthCamPos;
float _DepthCameraSize;
float _CamFarPlane;

CBUFFER_END
