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

//LinearStep
float LinearStep(float minValue, float maxValue, float In)
{
    return saturate((In - minValue) / (maxValue - minValue));
}

half3 UnpackDerivativeHeight(half3 textureData)
{
    half3 DH = textureData;
    DH.xy = DH.xy * 2 - 1;
    
    return DH;
}


#define PI 3.14159265358
#define Y0(v) (1.0 / 2.0) * sqrt(1.0 / PI)
#define Y1(v) sqrt(3.0 / (4.0 * PI)) * v.z
#define Y2(v) sqrt(3.0 / (4.0 * PI)) * v.y
#define Y3(v) sqrt(3.0 / (4.0 * PI)) * v.x
#define Y4(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.x * v.z
#define Y5(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.z * v.y
#define Y6(v) 1.0 / 4.0 * sqrt(5.0 / PI) * (-v.x * v.x - v.z * v.z + 2 * v.y * v.y)
#define Y7(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.y * v.x
#define Y8(v) 1.0 / 4.0 * sqrt(15.0 / PI) * (v.x * v.x - v.z * v.z)
#define Y9(v) 1.0 / 4.0 * sqrt(35.0 / (2.0 * PI)) * (3 * v.x * v.x - v.z * v.z) * v.z
#define Y10(v) 1.0 / 2.0 * sqrt(105.0 / PI) * v.x * v.z * v.y
#define Y11(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.z * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
#define Y12(v) 1.0 / 4.0 * sqrt(7 / PI) * v.y * (2 * v.y * v.y - 3 * v.x * v.x - 3 * v.z * v.z)
#define Y13(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.x * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
#define Y14(v) 1.0 / 4.0 * sqrt(105.0 / PI) * (v.x * v.x - v.z * v.z) * v.y
#define Y15(v) 1.0 / 4.0 * sqrt(35.0 / (2 * PI)) * (v.x * v.x - 3 * v.z * v.z) * v.x
float3 GetEvaluateSH(float3 normal, float4 shData[16])
{
    float3 result = 0.0;
    float3 v = normalize(normal);
    result =
      shData[0] * Y0(v) + //c0 * Y0(v) +
      shData[1] * Y1(v) + //c1 * Y1(v) +
      shData[2] * Y2(v) + //c2 * Y2(v) +
      shData[3] * Y3(v) + //c3 * Y3(v) +
      shData[4] * Y4(v) + //c4 * Y4(v) + 
      shData[5] * Y5(v) + //c5 * Y5(v) + 
      shData[6] * Y6(v) + //c6 * Y6(v) + 
      shData[7] * Y7(v) + //c7 * Y7(v) + 
      shData[8] * Y8(v) + //c8 * Y8(v) +
      shData[9] * Y9(v) + //c9 * Y9(v) +
      shData[10] * Y10(v) + //c10 * Y10(v) +
      shData[11] * Y11(v) + //c11 * Y11(v) +
      shData[12] * Y12(v) + //c12 * Y12(v) +
      shData[13] * Y13(v) + //c13 * Y13(v) +
      shData[14] * Y14(v) + //c14 * Y14(v) +
      shData[15] * Y15(v) //c15 * Y15(v)
      ;
    
    return result;
}

#endif