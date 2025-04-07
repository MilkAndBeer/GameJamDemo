#ifndef SPHERICAL_GAUSSIAN
#define SPHERICAL_GAUSSIAN
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
#endif

//Remap
float4 Remap(float In, float2 InMinMax, float2 OutMinMax)
{
    float4 Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    return Out;
}

//Depth
float DepthFade(float sceneDepth, float positionSS, float distance, float falloff)
{
    return powBetter(saturate(1 - (sceneDepth - positionSS) / distance), falloff);
}

//Dither
float Dither(half In, float4 ScreenPosition)
{
    float2 uv = ScreenPosition.xy * _ScreenParams.xy;
    float DITHER_THRESHOLDS[16] =
    {
        1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
        13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
        4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
        16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
    };
    uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
    return In - DITHER_THRESHOLDS[index];
}

//Normal Blend
half3 NormalBlend(half3 A, half3 B)
{
    return normalize(half3(A.rg + B.rg, 1));
}

half3 ReorientNormal(in half3 u, in half3 t, in half3 s)
{
    // Build the shortest-arc quaternion
    half4 q = half4(cross(s, t), dot(s, t) + 1) / sqrt(2 * (dot(s, t) + 1));
    // Rotate the normal
    return u * (q.w * q.w - dot(q.xyz, q.xyz)) + 2 * q.xyz * dot(q.xyz, u) + 2 * q.w * cross(q.xyz, u);
}


half3 UnpackDerivativeHeight(half3 textureData)
{
    half3 DH = textureData;
    DH.xy = DH.xy * 2 - 1;
    return DH;
}

//Triplanar Normal Blend (Triplanar法线混合)
half3 TriplanarBlend(half3 normalWS, float blend)
{
    half3 triBlend = saturate(pow(abs(normalWS), blend));
    triBlend = triBlend / (triBlend.x + triBlend.y + triBlend.z).xxx;
    
    return triBlend;
}

half3 TriplanarNormal(half3 bumpX, half3 bumpY, half3 bumpZ, half3 normalWS, half3 blend)
{
    bumpX = half3(bumpX.xy + normalWS.zy, abs(bumpX.z) * normalWS.x);
    bumpY = half3(bumpY.xy + normalWS.xz, abs(bumpY.z) * normalWS.y);
    bumpZ = half3(bumpZ.xy + normalWS.xy, abs(bumpZ.z) * normalWS.z);
    half3 normal = NormalizeNormalPerPixel(
        bumpX.zyx * blend.x +
        bumpY.xzy * blend.y +
        bumpZ.xyz * blend.z
    );
    return normal;
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

//Color Split
half3 ColorSplit(Texture2D map, SamplerState samplerMap, float2 uv, float scale, float speed, float splitRGB)
{
    uv = uv * scale + speed;
    half s = splitRGB;

    half r = SAMPLE_TEXTURE2D(map, samplerMap, uv + half2(+s, +s)).r;
    half g = SAMPLE_TEXTURE2D(map, samplerMap, uv + half2(+s, -s)).g;
    half b = SAMPLE_TEXTURE2D(map, samplerMap, uv + half2(-s, -s)).b;

    half3 color = half3(r, g, b);
    
    return color;
}

//Bend
float Bend(float x, float y)
{
    float a = x * y;
    float a2 = (a + 1) * (a + 1);
    float a4 = a2 * a2;
    
    return a4 - a2;
}

//Sample Noise
inline float Unity_Noise_RandomValue(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

inline float Unity_Noise_Interpolate(float a, float b, float t)
{
    return(1.0 - t) * a + (t * b);
}

inline float Unity_ValueNoise(float2 uv)
{
    float2 i = floor(uv);
    float2 f = frac(uv);
    f = f * f * (3.0 - 2.0 * f);

    uv = abs(frac(uv) - 0.5);
    float2 c0 = i + float2(0.0, 0.0);
    float2 c1 = i + float2(1.0, 0.0);
    float2 c2 = i + float2(0.0, 1.0);
    float2 c3 = i + float2(1.0, 1.0);
    float r0 = Unity_Noise_RandomValue(c0);
    float r1 = Unity_Noise_RandomValue(c1);
    float r2 = Unity_Noise_RandomValue(c2);
    float r3 = Unity_Noise_RandomValue(c3);

    float bottomOfGrid = Unity_Noise_Interpolate(r0, r1, f.x);
    float topOfGrid = Unity_Noise_Interpolate(r2, r3, f.x);
    float t = Unity_Noise_Interpolate(bottomOfGrid, topOfGrid, f.y);
    return t;
}

float SimpleNoise(float2 UV, float Scale)
{
    float t = 0.0;

    float freq = powBetter(2.0, float(0));
    float amp = powBetter(0.5, float(3 - 0));
    t += Unity_ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    //freq = pow(2.0, float(1));
    //amp = powBetter(0.5, float(3 - 1));
    //t += Unity_ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    //freq = pow(2.0, float(2));
    //amp = powBetter(0.5, float(3 - 2));
    //t += Unity_ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    return t;
}

//Gradient Noise
float2 GradientNoise_Dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}
float GradientNoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(GradientNoise_Dir(ip), fp);
    float d01 = dot(GradientNoise_Dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(GradientNoise_Dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(GradientNoise_Dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}
float GradientNoise(float2 UV, float Scale)
{
    return GradientNoise(UV * Scale) + 0.5;
}

//Flipbook
float2 Flipbook(float2 UV, float Width, float Height, float Tile)
{
    float2 count = float2(1.0, 1.0) / float2(Width, Height);
    float x = floor(Tile);
    float y = floor(Tile / Width) + 1;
    return (frac(UV) + float2(x, -y)) * count;
}

//Voronoi Noise
inline float2 Voronoi_RandomVector_float (float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
}

float Voronoi_float(float2 UV, float AngleOffset, float CellDensity)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);
    float Out;
    float Cells;
    for(int y=-1; y<=1; y++)
    {
        for(int x=-1; x<=1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);
        
            if(d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Out = res.x;
                Cells = res.y;
            }
        }
    }
    return Out;
}

float Voronoi_Cells(float2 UV, float AngleOffset, float CellDensity)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);
    float Cells;
    for(int y=-1; y<=1; y++)
    {
        for(int x=-1; x<=1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = Voronoi_RandomVector_float(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);
        
            if(d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                Cells = res.y;
            }
        }
    }
    return Cells;
}

//Color Blend
half3 BlendScreen(half3 a, half3 b)
{
    half3 color = 1 - (1 - a) * (1 - b);
    return color;
}

half3 BlendOverlay(half3 a, half3 b)
{
    return a < 0.5 ? (2.0 * a * b):(1.0 - 2.0 * (1.0 - a) * (1.0 - b));
}

half3 BlendSoftlight(half3 a, half3 b)
{
    return b < 0.5 ? 2.0 * a * b + a * a * (1.0 - 2.0 * b) : sqrt(a) * (2.0 * b - 1.0) + 2.0 * a * (1.0 - b);
}



