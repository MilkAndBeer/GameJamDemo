#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURECUBE(_MoonMap);       SAMPLER(sampler_MoonMap);
TEXTURECUBE(_StarMap);       SAMPLER(sampler_StarMap);

CBUFFER_START(UnityPerMaterial)
//Sky
half3 _SkyColor;
half3 _HorizonColor;
half3 _GroundColor;
half _SkyRange;
half _SkyFalloff;
half _GroundRange;
half _GroundFalloff;
//Sun
half3 _SunColor;
half _SunIntensity;
half _SunSize;
half _SunFalloff;
half3 _SunBloomColor;
half _SunBloomIntensity;
half _SunBloomRange;
half _SunBloomFalloff;
//Moon
half3 _MoonColor;
half _MoonIntensity;
half _MoonSize;
half _MoonFalloff;
half _MoonBlock;
half3 _MoonBloomColor;
half _MoonBloomIntensity;
half _MoonBloomRange;
half _MoonBloomFalloff;
//Star
half _StarIntensity;

CBUFFER_END

CBUFFER_START(GlobalMaterial)
half3 _SunDirWS;
half3 _MoonDirWS;
half4x4 _TBN;
CBUFFER_END

struct Attributes
{
    float4 positionOS   : POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS               : SV_POSITION;
    float3 positionWS               : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

float sphIntersect(half3 rayDir, half3 spherePos, half radius)
{
    float3 oc = float3(-spherePos);
    float b = dot(oc, float3(rayDir));
    float c = dot(oc, oc) - float(radius) * float(radius);
    float h = b * b - c;
    if(h < 0.0)
    {
        return -1.0;
    }
    else
    {
        h = sqrt(h);
        return -b - h;
    }
}

//GradientNoise
float2 unity_gradientNoise_dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float unity_gradientNoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(unity_gradientNoise_dir(ip), fp);
    float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float GradientNoise(float2 UV, float Scale)
{
    return unity_gradientNoise(UV * Scale) + 0.5;
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionWS = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;
    
    return output;
}

half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    
    float3 positionWS = normalize(input.positionWS);
    
    //Sky
    half skyBlend = smoothstep(1 - _SkyRange, 1 - _SkyRange + _SkyFalloff, max(0, positionWS.y));
    half groundBlend = smoothstep(1 - _GroundRange, 1 - _GroundRange + _GroundFalloff, max(0, -positionWS.y));
    half horizonBlend = 1 - (skyBlend + groundBlend);
    half3 skyColor = _SkyColor * skyBlend;
    half3 groundColor = _GroundColor * groundBlend;
    half3 horizonColor = _HorizonColor * horizonBlend;
    half3 skybox = skyColor + groundColor + horizonColor;
    
    //Sun
    half halfMask = smoothstep(0, 0.1, max(0, positionWS.y));
    half sunDist = distance(positionWS, _SunDirWS);
    half sunSize = 1 - saturate(sunDist / (_SunSize * 0.1));
    half sunMask = smoothstep(0, _SunFalloff, sunSize) * halfMask;
    half3 sunColor = _SunColor * _SunIntensity * sunMask;

    half sunBloomSize = smoothstep(1 - _SunBloomRange, 1 - _SunBloomRange + _SunBloomFalloff, saturate(dot(_SunDirWS, positionWS))) * _SunBloomIntensity;
    half sunBloomMask = sunBloomSize * pow(saturate(positionWS.y + 1), 10);
    half3 sunBloomColor = lerp(_SunBloomColor, skyColor, _SunDirWS.y) * sunBloomMask;
    
    half3 sun = sunColor + sunBloomColor;
 
    //Moon
    
    /*Sample
    half moonDist = distance(positionWS, _MoonDirWS);
    half moonSize = 1 - saturate(moonDist / (_MoonSize * 0.1));
    half moonMask = smoothstep(0, _MoonFalloff, moonSize) * smoothstep(0, 0.1, max(0, positionWS.y));
    
    half crescentMoonDist = distance(half3(positionWS.x + _MoonBlock * _MoonSize, positionWS.y, positionWS.z), _MoonDirWS);
    half crescentMoonSize = 1 - saturate(crescentMoonDist / (_MoonSize * 0.1));
    half crescentMoonMask = smoothstep(0, _MoonFalloff, crescentMoonSize) * smoothstep(0, 0.1, max(0, positionWS.y));

    moonMask = saturate(moonMask - crescentMoonMask);

    half3 moonUV = mul(_TBN, half4(positionWS, 0)).xyz;
    half3 moonTex = SAMPLE_TEXTURECUBE(_MoonMap, sampler_MoonMap, moonUV).rgb;

    half3 moonColor = _MoonColor * moonTex * _MoonIntensity * moonMask;
    */
    
    //Raytrace
    half moonIntersect = sphIntersect(positionWS, _MoonDirWS, _MoonSize * 0.1);
    half moonDist = distance(positionWS, _MoonDirWS);
    half moonSize = 1 - saturate(moonDist / (_MoonSize * 0.1));
    half moonMask = smoothstep(0, _MoonFalloff, moonSize) * halfMask;
    
    half3 moonNormal = normalize(_MoonDirWS - positionWS * moonIntersect);
    half3 moonUV = mul(_TBN, half4(moonNormal, 0)).xyz;
    half3x3 correctionMatrix = half3x3(0, -0.2588190451, -0.9659258263,
                                    0.08715574275, 0.9622501869, -0.2578341605,
                                    0.9961946981, -0.08418598283, 0.02255756611);
    moonUV = mul(correctionMatrix, moonUV);
    half moonTex = clamp(0, 1, SAMPLE_TEXTURECUBE(_MoonMap, sampler_MoonMap, moonUV).r + 0.2);

    half crescentMoonDist = distance(half3(positionWS.x + _MoonBlock * _MoonSize, positionWS.y, positionWS.z), _MoonDirWS);
    half crescentMoonSize = 1 - saturate(crescentMoonDist / (_MoonSize * 0.4));
    half crescentMoonMask = smoothstep(0, _MoonFalloff, crescentMoonSize) * smoothstep(0, 0.1, max(0, positionWS.y));

    moonMask = saturate(moonMask - crescentMoonMask);
    
    half3 moonColor = _MoonColor * moonTex * _MoonIntensity * moonMask;
    
    half moonBloomSize = smoothstep(1 - _MoonBloomRange, 1 - _MoonBloomRange + _MoonBloomFalloff, saturate(dot(_MoonDirWS, positionWS))) * _MoonBloomIntensity;
    half moonBloomMask = moonBloomSize * pow(saturate(positionWS.y + 1), 10);
    half3 moonBloomColor = lerp(_MoonBloomColor, skyColor, _MoonDirWS.y) * moonBloomMask;

    half3 moon = moonColor + moonBloomColor;

    //Star
    half3 starTex = SAMPLE_TEXTURECUBE_BIAS(_StarMap, sampler_StarMap, positionWS, -1).rgb;
    float time = fmod(_Time.y, 2e5);
    half starNoise = GradientNoise(positionWS.xz + time * 0.1, 5);
    half starMask = halfMask * (1 - sunMask) * (1 - moonMask) * starNoise;
    half3 star = starTex * _StarIntensity * starMask;

    half3 color = skybox + sun + moon + star;
    
    return half4(color, 1);
}

