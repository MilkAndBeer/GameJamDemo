#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

//LinearStep
half LinearStep(half minValue, half maxValue, half In)
{
    return saturate((In - minValue) / max(0.0001, maxValue - minValue));
}

half3 LinearStep(half minValue, half maxValue, half3 In)
{
    return saturate((In - minValue) / max(0.0001, maxValue - minValue));
}
 
//Remap
float4 Remap(float4 In, float2 InMinMax, float2 OutMinMax)
{
    float4 Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
    return Out;
}


//Depth
float DepthFade(float sceneDepth, float positionSS, float distance, float falloff)
{
    return pow(saturate(1 - (sceneDepth - positionSS) / distance), falloff);
}


//Fresnel
float FresnelEffect(float3 Normal, float3 ViewDir, float Power)
{
    float fres = pow(1.0 - saturate(dot(Normal, ViewDir)), Power);
    return fres;
}


//导数贴图Derivative Map
float3 UnpackDerivativeHeight(float3 textureData)
{
    float3 DH = textureData;
    DH.xy = DH.xy * 2 - 1;
    return DH;
}


//法线混合UDN
half3 BlendNormalUDN(half3 normal1, half3 normal2)
{
    normal1 = normal1.xyz * 2 - 1;
    normal2 = normal2.xyz * 2 - 1;
    half3 normal = normalize(half3(normal1.xy + normal2.xy, normal1.z) * 0.5 + 0.5);

    return normal;
}


//法线混合
float3 NormalBlend(float3 A, float3 B)
{
    return normalize(float3(A.rg + B.rg, 1));
}

float3 NormalBlendOption(float3 A, float3 B, float option)
{
    return normalize(float3(A.rg * option + B.rg * option, 1));
}

float3 NormalBlendReoriented(float3 A, float3 B)
{
    float3 t = A.xyz + float3(0.0, 0.0, 1.0);
    float3 u = B.xyz * float3(-1.0, -1.0, 1.0);
    return  (t / t.z) * dot(t, u) - u;
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

half3 TriplanarNormalSeparator(half3 bumpX, half3 bumpY, half3 bumpZ, half blendX, half blendY, half blendZ, half3 normalWS)
{
    bumpX = half3(bumpX.x + normalWS.z, bumpX.y + normalWS.y, abs(bumpX.z) * normalWS.x);
    bumpY = half3(bumpY.x + normalWS.x, bumpY.y + normalWS.z, abs(bumpY.z) * normalWS.y);
    bumpZ = half3(bumpZ.x + normalWS.x, bumpZ.y + normalWS.y, abs(bumpZ.z) * normalWS.z);
    half3 normal = NormalizeNormalPerPixel(
        bumpX.zyx * blendX +
        bumpY.xzy * blendY +
        bumpZ.xyz * blendZ
    );
    return normal;
}


//UV扰动(Flow UV)
float3 FlowUVW(float2 uv, float2 flowVector, float2 jump, float waveScale, float time, float AB)
{
    float phaseOffset = AB ? 0.5 : 0;
    float progress = frac(time + phaseOffset);
    float3 UVW;
    UVW.xy = uv - flowVector * progress;
    UVW.xy = UVW.xy * waveScale + phaseOffset + (time - progress) * jump;
    UVW.z = 1 - abs(1 - 2 * progress);
    return UVW;
}

float2 DirectFlowUV (float2 uv, float2 flow)
{
    float2 dir = normalize(flow.xy);
    uv = mul(float2x2(dir.y, dir.x, -dir.x, dir.y), uv);
    return uv;
}


//色相
float3 Hue(float3 In, float Offset)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
    float D = Q.x - min(Q.w, Q.y);
    float E = 1e-10;
    float3 hsv = float3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), Q.x);

    float hue = hsv.x + Offset / 360;
    hsv.x = (hue < 0)
    ? hue + 1
    : (hue > 1)
    ? hue - 1
    : hue;

    float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
    float3 Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
    return Out;
}


//饱和度
float3 Saturation(float3 In, float Saturation)
{
    float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
    float3 Out = luma.xxx + Saturation.xxx * (In - luma.xxx);
    return Out;
}



float2 Flipbook(float2 UV, float Width, float Height, float Tile)
{
    Tile = floor(fmod(Tile + float(0.00001), Width*Height));
    float2 tileCount = float2(1.0, 1.0) / float2(Width, Height);
    float tileX = (Tile - Width * floor(Tile * tileCount.x));
    float tileY = (floor(Tile * tileCount.x));
    return  (UV + float2(tileX, tileY)) * tileCount;
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

    float freq = pow(2.0, float(0));
    float amp = pow(0.5, float(3 - 0));
    t += Unity_ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(1));
    amp = pow(0.5, float(3 - 1));
    t += Unity_ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

    freq = pow(2.0, float(2));
    amp = pow(0.5, float(3 - 2));
    t += Unity_ValueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;


    return t;
}


//Gradient Noise
float2 Unity_GradientNoise_Dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float Unity_GradientNoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float Unity_GradientNoise_float(float2 UV, float Scale)
{
    return Unity_GradientNoise(UV * Scale) + 0.5;
}


//Voronoi Noise
inline float2 Unity_Voronoi_RandomVector_float (float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)));
    return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
}
        
float Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity)
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
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
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

float Unity_Voronoi_Cells(float2 UV, float AngleOffset, float CellDensity)
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
            float2 offset = Unity_Voronoi_RandomVector_float(lattice + g, AngleOffset);
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


//3D Noise
float4 mod289( float4 x )
{
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 perm( float4 x )
{
    return mod289(((x * 34.0) + 1.0) * x);
}

float SimpleNoise3D( float3 p )
{
    float3 a = floor(p);
    float3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);
    float4 b = a.xxyy + float4(0.0, 1.0, 0.0, 1.0);
    float4 k1 = perm(b.xyxy);
    float4 k2 = perm(k1.xyxy + b.zzww);
    float4 c = k2 + a.zzzz;
    float4 k3 = perm(c);
    float4 k4 = perm(c + 1.0);
    float4 o1 = frac(k3 * (1.0 / 41.0));
    float4 o2 = frac(k4 * (1.0 / 41.0));
    float4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    float2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);
    return o4.y * d.y + o4.x * (1.0 - d.y);
}



//雾
float Fixed_Fog(float3 positionWS, float fogBlend, float fogFalloff, float fogSpeed, float noiseScale)
{
    float3 positionVS = TransformWorldToView(positionWS);
    float3 centerWS = float3(0, 0, 0);
    float3 centerVS = TransformWorldToView(centerWS);
    float fogMask = smoothstep(-fogFalloff, fogFalloff, positionVS.z - centerVS.z);
    fogMask = (1- saturate(fogMask)) * fogBlend;

    float3 noiseUVW = positionWS * (1 / noiseScale) + fogSpeed * _Time.y;
    float fogNoise = SimpleNoise3D(noiseUVW) * 0.5 + 0.5;

    return  fogMask *= fogNoise;
}


//Interior Mapping 
float3 InteriorDir(float3 viewDirTS, float2 uv, float tiling, float depth)
{
    uv = frac(uv * -tiling) * 2 - 1;
    float3 cubeDir = float3(uv.x, uv.y, -depth);
    float3 a = abs(1 / viewDirTS) - (1 / viewDirTS) * cubeDir;
    a = min(min(a.x, a.y), a.z) * viewDirTS;
    cubeDir = (cubeDir + a) * float3(-1, -1, 1);
    return cubeDir;
}


//Circle Shape
float Circle_Shape(float2 uv, float range, float falloff)
{
    float2 center = float2(0.5, 0.5);
    float circle = 1 - length(uv - center);
    circle = smoothstep(1 - range, 1 - range + falloff, circle);
    return circle;
}


//Twirl
float2 Twirl(float2 UV, float2 Center, float Strength, float2 Offset)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    return float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}


//各种混合模式

    //柔光 Soft Light
    float3 Soft_Light(float3 A, float3 B)
    {
        float3 c;
        if(B.r <= 0.5 && B.g <= 0.5 && B.b <= 0.5)
            c.r = A.r * B.r / 0.5 + pow(A.r / 1, 2) * (1 - 2 * B.r);
        c.g = A.g * B.g / 0.5 + pow(A.g / 1, 2) * (1 - 2 * B.g);
        c.b = A.b * B.b / 0.5 + pow(A.b / 1, 2) * (1 - 2 * B.b);
        if(B.r > 0.5 && B.g > 0.5 && B.b > 0.5)
            c.r = A.r * (1 - B.r) / 0.5 + sqrt(A.r / 1) * (2 * B.r - 1);
        c.g = A.g * (1 - B.g) / 0.5 + sqrt(A.g / 1) * (2 * B.g - 1);
        c.b = A.b * (1 - B.b) / 0.5 + sqrt(A.b / 1) * (2 * B.b - 1);
        return c;
    }

    //Overlay
    float4 Blend_Overlay(float4 Base, float4 Blend, float Opacity)
    {
        float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
        float4 result2 = 2.0 * Base * Blend;
        float4 zeroOrOne = step(Base, 0.5);
        float4 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
        Out = lerp(Base, Out, Opacity);
        return Out;
    }

    float3 Blend_Overlay(float3 Base, float3 Blend, float Opacity)
    {
        float3 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
        float3 result2 = 2.0 * Base * Blend;
        float3 zeroOrOne = step(Base, 0.5);
        float3 Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
        Out = lerp(Base, Out, Opacity);
        return Out;
    }

    //Dodge
    float4 Blend_Dodge(float4 Base, float4 Blend, float Opacity)
    {
        float4 Out = Base / (1.0 - Blend);
        Out = lerp(Base, Out, Opacity);
        return Out;
    }

    //Screen
    float3 Blend_Screen(float3 Base, float3 Blend, float Opacity)
    {
        float3 Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
        Out = lerp(Base, Out, Opacity);
        return Out;
    }

    float4 Blend_Screen(float4 Base, float4 Blend, float Opacity)
    {
        float4 Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
        Out = lerp(Base, Out, Opacity);
        return Out;
    }



//Height to Normal
float3 HeightToNormal(float height, float3 normal, float3 pos)
{
    float3 worldDirivativeX = ddx(pos);
    float3 worldDirivativeY = ddy(pos);
    float3 crossX = cross(normal, worldDirivativeX);
    float3 crossY = cross(normal, worldDirivativeY);
    float3 d = abs(dot(crossY, worldDirivativeX));
    float3 inToNormal = ((((height + ddx(height)) - height) * crossY) + (((height + ddy(height)) - height) * crossX)) * sign(d);
    inToNormal.y *= -1.0;
    return normalize((d * normal) - inToNormal);
}


//Rotate
float3 RotateAboutAxis(float3 In, float3 Axis, float Rotation)
{
    Rotation = radians(Rotation);
    float s = sin(Rotation);
    float c = cos(Rotation);
    float one_minus_c = 1.0 - c;

    Axis = normalize(Axis);
    float3x3 rot_mat =
    {   one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
        one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
        one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
    };
    float3 Out = mul(rot_mat,  In);
    return Out;
}


//Color Space Conversion

//RGB>Linear
float3 ColorspaceRGBToLinear(float3 In)
{
    float3 linearRGBLo = In / 12.92;;
    float3 linearRGBHi = pow(max(abs((In + 0.055) / 1.055), 1.192092896e-07), float3(2.4, 2.4, 2.4));
    return float3(In <= 0.04045) ? linearRGBLo : linearRGBHi;
}

//Linear>RGB
float3 ColorspaceLinearToRGB(float3 In)
{
    float3 sRGBLo = In * 12.92;
    float3 sRGBHi = (pow(max(abs(In), 1.192092896e-07), float3(1.0 / 2.4, 1.0 / 2.4, 1.0 / 2.4)) * 1.055) - 0.055;
    return float3(In <= 0.0031308) ? sRGBLo : sRGBHi;
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


