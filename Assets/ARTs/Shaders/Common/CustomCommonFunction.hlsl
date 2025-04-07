#ifndef CUSTOMCOMMONFUNC
#define CUSTOMCOMMONFUNC

// Spherical Gaussian Power Function 
float powBetter(float x, float n)
{
    n = n * 1.4427f + 1.4427f; // 1.4427f --> 1/ln(2)
    return exp2(x * n - n);
}
float3 powBetter(float3 x, float3 n)
{
    n = n * 1.4427f + 1.4427f; // 1.4427f --> 1/ln(2)
    return exp2(x * n - n);
}

//色相
half3 Hue(half3 In, half Offset)
{
    half4 K = half4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    half4 P = lerp(half4(In.bg, K.wz), half4(In.gb, K.xy), step(In.b, In.g));
    half4 Q = lerp(half4(P.xyw, In.r), half4(In.r, P.yzx), step(P.x, In.r));
    half D = Q.x - min(Q.w, Q.y);
    half E = 1e-10;
    half3 hsv = half3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);

    half hue = hsv.x + Offset / 360;
    hsv.x = (hue < 0)
        ? hue + 1
        : (hue > 1)
        ? hue - 1
        : hue;

    half4 K2 = half4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    half3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
    half3 Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
    return Out;
}

//对比度
half3 Contrast(half3 color, half contrast)
{
    float midpoint = powBetter(0.5, 2.2);
    return (color - midpoint) * contrast + midpoint;
}

//饱和度
half3 Saturation(half3 In, half Saturation)
{
    half luma = dot(In, half3(0.2126729, 0.7151522, 0.0721750));
    half3 Out = luma.xxx + Saturation.xxx * (In - luma.xxx);
    return Out;
}

float4 Remap(float In, float2 InMinMax, float2 OutMinMax)
{
    float4 Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    return Out;

}

#endif