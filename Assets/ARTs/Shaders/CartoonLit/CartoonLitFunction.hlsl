#include "../Common/CustomCommonFunction.hlsl"

//HSL
half3 HSL(half3 baseColor, float h, half saturation, half lightness)
{
    float hue = Remap(h, float2(0, 100), float2(0, 360)).x;
    baseColor = saturate(Hue(baseColor, hue));
    baseColor = saturate(Saturation(baseColor, saturation));
    baseColor *= lightness;

    return baseColor;
}