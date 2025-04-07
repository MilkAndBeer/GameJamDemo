struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
#if defined _WIND || _COLLISION
    half3  color        : COLOR;
#endif
    float2 texcoord     : TEXCOORD0;
    float2 texcoord1    : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionSS   : TEXCOORD1;
    float4 positionCS   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
    
    float3 positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);
    float time = fmod(_Time.y, 2e5);

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
    
    output.uv = input.texcoord;
    output.positionCS = TransformWorldToHClip(positionWS);
    output.positionSS = ComputeScreenPos(output.positionCS);

    return output;
}

half DepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

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

    return input.positionCS.z;
}