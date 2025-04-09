
TEXTURE2D(_Ramp);       SAMPLER(sampler_Ramp);

CBUFFER_START(UnityMaterial)
//Stylized
float _ShadowThreshold;
float _ShadowSmooth;
float _ShadowIntensity;

//Reflect Refraction
half3 _AmbientColor;
half _Exposure;
float4 _SH[7];

CBUFFER_END