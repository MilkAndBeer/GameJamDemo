#define MAX_POSITION_COUNT 20
#define MAX_OBJECTPOS_COUNT 100

TEXTURE2D(_Ramp);       SAMPLER(sampler_Ramp);

CBUFFER_START(UnityMaterial)
//Stylized
float _ShadowThreshold;
float _ShadowSmooth;
float _ShadowIntensity;

//Reflect Refraction
half3 _AmbientColor;
half _Exposure;
float4 _SHData[16];

CBUFFER_END