#define dielectric float4(0.04, 0.04, 0.04, 0.96)
#define INV_PI      0.31830988618379067154
#define PI          3.14159265358979323846

TEMPLATE_2_REAL(PosPow, base, power, return pow(abs(base), power))

//点乘
struct BxDF
{
    float NoV;
    float NoL;
    float NoH;
    float VoH;
};

BxDF GetContex(float3 N, float3 V, float3 L)
{
    float3 H = normalize(L + V);
    BxDF contex;
    contex.NoV = max(saturate(dot(N, V)), 0.001);
    contex.NoL = max(saturate(dot(N, L)), 0.001);
    contex.NoH = max(saturate(dot(N, H)), 0.001);
    contex.VoH = max(saturate(dot(V, H)), 0.001);

    return  contex;
}


//电解质高光颜色转换(Dielectric)
float F0ToSpecular(float F0)
{
    return saturate(F0 / 0.08f);
}

float SpecularToF0(float Specular)
{
    return 0.08f * Specular;
}

// [Burley, "Extending the Disney BRDF to a BSDF with Integrated Subsurface Scattering"]
float F0ToIOR(float F0)
{
    return 2.0f / (1.0f - sqrt(F0)) - 1.0f;
}

float IORToF0(float Ior)
{
    const float F0Sqrt = (Ior-1)/(Ior+1);
    const float F0 = F0Sqrt*F0Sqrt;
    return F0;
}

float3 ComputeF0(float Specular, float3 BaseColor, float Metallic)
{
    return lerp(SpecularToF0(Specular).xxx, BaseColor, Metallic.xxx);
}

float3 ComputeF90(float3 F0, float3 EdgeColor, float Metallic)
{
    return lerp(1.0, EdgeColor, Metallic.xxx);
}

// float GetF0 (float NdotL, float NdotV, float LdotH, float roughness){
//     float FresnelLight = pow5(NdotL); 
//     float FresnelView = pow5(NdotV);
//     float fd90 = 0.5 + 2.0 * LdotH*LdotH * roughness;
//     return lerp(fd90, 1, FresnelLight) * lerp(fd90, 1, FresnelView);
// }
