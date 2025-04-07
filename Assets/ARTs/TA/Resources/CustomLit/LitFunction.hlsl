//HSL-------------------------------------------
half3 HSL(half3 baseColor, float h, half saturation, half lightness)
{
    float hue = Remap(h, float2(0, 100), float2(0, 360)).x;
    baseColor = Hue(baseColor, hue);
    baseColor = saturate(Saturation(baseColor, saturation));
    baseColor *= lightness;

    return baseColor;
}
//----------------------------------------------

//Cull-------------------------------------------
float GetCulling(float3 positionWS, Texture2D depthMap, float3 depthCenterPos, float depthSize, float camFarPlane)
{
    if(depthSize == 0) return 1;
    //----------------------Snow Culling -----------------------------
    //摄像机的size*2就是控制图照射面积的长宽
    float snowDTSize_z  = depthSize * 2;
    float snowDTSize_x = snowDTSize_z / _ScreenParams.y * _ScreenParams.x; // / 3 * 4; //
    //根据摄像机的位移和size确定采样控制图的UV
    float2 depthUV = float2(saturate((positionWS.x - depthCenterPos.x) / snowDTSize_x + 0.5f),
                            saturate((positionWS.z - depthCenterPos.z) / snowDTSize_z + 0.5f));
    
    float cullNoise = Remap(SimpleNoise(positionWS.xz, 40), float2(0, 1), float2(-1, 1)).x * 0.005;
    float4 depthRGBA = SAMPLE_TEXTURE2D(depthMap, sampler_LinearClamp, depthUV + cullNoise);
    
    //--------------------#基于高度图的雪的剔除#----------------------
    //float depthTex = (depthRGBA.r * 255 + depthRGBA.g) * ((depthRGBA.b == 1) ? 1 : -1);//深度解码
    
    //--------------------#基于深度图的雪的剔除#----------------------
    float groundY = depthCenterPos.y - camFarPlane;
    float depthHeight = depthRGBA.r * camFarPlane + groundY;
    //--------------------------------------------------------------
    //物体顶点位置加一点偏移保证比较深度时正确
    float pixeldepth = positionWS.y + 1.0f;

    //根据摄像机高度将深度对比差值归一化
    float culling = (pixeldepth - depthHeight) / camFarPlane;
    
    culling = smoothstep(-0.01f, 0.01f, culling);

    return culling;
}
//----------------------------------------------

//Ripple----------------------------------------
void Ripple(sampler2D rippleMap, float3 positionWS, float3 normalWS, Texture2D depthMap, float3 depthCenterPos,
            float depthSize, float camFarPlane, inout half3 baseColor, inout half smoothness)
{
    float time = fmod(_Time.y, 2e5);
    float upDir = saturate(dot(half3(0, 1, 0), normalWS));
    float rippleNoise = Voronoi_float(positionWS.xz, time * 5, 1 / _RippleScale);
    float rainAmount = Remap(_RainAmount, float2(0, 1), float2(0, 0.5)).x;
    float rippleRange = smoothstep(1 - rainAmount - 0.5, 1 - rainAmount + 0.5, rippleNoise) * upDir;
    rippleRange = saturate(rippleRange * 2 - 1);

    float2 rippleUV = Flipbook(positionWS.xz / _RippleScale, 4, 4, time * _RippleSpeed);
    half rippleMask = tex2D(rippleMap, rippleUV).r;
    half ripple = saturate(rippleRange * rippleMask);

    float culling = GetCulling(positionWS, depthMap, depthCenterPos, depthSize, camFarPlane);
    
    baseColor = lerp(baseColor, _RippleColor.rgb, ripple * _RippleStrength * culling);
    smoothness = lerp(smoothness, 1, _RainAmount * culling);
}
//----------------------------------------------

//Snow-----------------------------------------
void SnowLit(inout float3 normalWS, float3 N, float snow, inout half3 baseColor, inout half smoothness, inout half metallic,
    Texture2D depthMap, float3 depthCenterPos, float depthSize, float camFarPlane, float3 positionWS)
{
    half up = saturate(dot(half3(0, 1, 0), normalWS));
    float snowAmount = Remap(_SnowAmount, float2(0, 1), float2(0, 0.5)).x;
    half snowMask = smoothstep(1 - snowAmount - 0.5, 1 - snowAmount + 0.5, up);
    snowMask = saturate(snowMask * 2 - 1);

    float snowCulling = GetCulling(positionWS, depthMap, depthCenterPos, depthSize, camFarPlane);

    baseColor = lerp(baseColor, _SnowColor, snowMask * snow * snowCulling);
    metallic = lerp(metallic, 0, snowMask * snow * snowCulling);
    smoothness = lerp(smoothness, 0.8, snowMask * snow * snowCulling);
    normalWS = lerp(normalWS, N, snowMask * snow * snowCulling);
}

void SnowTri(sampler2D albedoMap, sampler2D DMSMap, float3 positionWS, inout float3 normalWS, float3x3 tbn, float snow,
    inout half3 baseColor, inout half smoothness, inout half metallic,
    Texture2D depthMap, float3 depthCenterPos, float depthSize, float camFarPlane)
{
    half2 snowUV = positionWS.xz;
    half up = saturate(dot(half3(0, 1, 0), normalWS));
        
    half4 snowAlbedo = tex2D(albedoMap, snowUV * (1 / _SnowScale));
    half4 snowDMS = tex2D(DMSMap, snowUV * (1 / _SnowScale));

    half3 snowColor = snowAlbedo.rgb;

    //float snowAmount = Remap(_SnowAmount, float2(0, 1), float2(0, 0.5)).x;
    half snowMask = smoothstep(1 - _SnowAmount - 0.2, 1 - _SnowAmount + 0.2, snowAlbedo.a) * up;
    snowMask = saturate(snowMask * 2 - 1);
     
    half3 snowNormal = normalize(UnpackDerivativeHeight(half3(snowDMS.rg, 1)));
    half snowMetallic = snowDMS.b;
    half snowSmoothness = snowDMS.a * 0.5;
        
    half3 snowNormalWS = NormalizeNormalPerVertex(TransformTangentToWorld(snowNormal, tbn));

    float snowCulling = GetCulling(positionWS, depthMap, depthCenterPos, depthSize, camFarPlane);

    baseColor = lerp(baseColor, snowColor, snowMask * snow * snowCulling);
    metallic = lerp(metallic, snowMetallic, snowMask * snow);
    smoothness = lerp(smoothness, snowSmoothness, snowMask * snow);
    normalWS = lerp(normalWS, snowNormalWS, snowMask * snow);
}

//---------------------------------------------

//Cloud ---------------------------------------
void Cloud(sampler2D cloudMaskMap, float3 positionWS, half3 N, inout half cloud)
{
    half3 down = half3(0, -1, 0);
    half mask = 1 - saturate(dot(N, down));
    float2 uvCloud = positionWS.xz;
    float time = fmod(_Time.y, 2e5);
    float speed = time * _CloudSpeed * 0.1;
    cloud = (1 - tex2D(cloudMaskMap, uvCloud / _CloudScale + speed).r) * mask;
    cloud = 1 - cloud;
}
//---------------------------------------------

real4 Flow(Texture2D t, SamplerState s, float2 uv, float2 flow, float flowSpeed)
{
    float time1 = frac(_Time.y * flowSpeed);
    float time2 = frac(_Time.y * flowSpeed + 0.5);
    float2 uv1 = uv - flow * time1;
    float2 uv2 = uv - flow * time2;
    float blend = abs((time1 - 0.5) * 2);
    real4 color1 = SAMPLE_TEXTURE2D(t, s, uv1);
    real4 color2 = SAMPLE_TEXTURE2D(t, s, uv2);

    return lerp(color1, color2, blend);
}

//Warp
void VertexWarp(inout float3 positionWS, inout float3 positionOS, float3 warpPosition, float warpIntensity, float warpRange)
{
    float dist = clamp(warpRange - distance(positionWS, warpPosition), 0, warpRange);
    float3 dir = positionWS - warpPosition;
    positionWS -= dir * dist * warpIntensity;
    positionOS = TransformWorldToObject(positionWS);
}

//Thickness -----------------------------
void VertexThickness(inout float3 positionWS, inout float3 positionOS, float3 normalOS, float thickness)
{
    positionOS = float3(positionOS.x + normalOS.x * thickness * 0.1, positionOS.y, positionOS.z + normalOS.z * thickness * 0.1);
    positionWS = TransformObjectToWorld(positionOS.xyz);
}

//Height
void VertexHeight(inout float3 positionWS, inout float3 positionOS, float length, float frequency, float magnitude, float time)
{
    float2 uv = positionWS.xz;
    float waveOffset = time * frequency * 0.1;
    float height = SimpleNoise(uv + waveOffset, length);
    height = Remap(height, float2(0, 1), float2(-1, 0)).r;
    float3 offset = float3(0, height * magnitude * 0.1, 0);;
    positionWS += offset;
    positionOS = TransformWorldToObject(positionWS);
}

//Wind
void VertexWind(inout float3 positionWS, inout float3 positionOS, float2 windDirection, float windSpeed, float windStrength, float windNoise, float bendRange, float time)
{
    float bend = bendRange * bendRange * windStrength;
    float bendNoise = SimpleNoise(positionWS.xz + time * windSpeed * windDirection, windNoise);
    float3 windDir = float3(_WindDir.x, 0, _WindDir.y);
    float3 wind = float3(bendNoise, 0, bendNoise);
    positionWS += wind * windDir * bend;
    positionOS = TransformWorldToObject(positionWS);
}

//Collision
void VertexCollision(inout float3 positionWS, inout float3 positionOS, float4 objectPos[MAX_OBJECTPOS_COUNT], float posCount, float intensity, float range)
{
    for (int i = 0; i < posCount; i++)
    {
        //objectPos[i] = float4(0, 0.4, 0, 1);
        // float noise = SimpleNoise(positionWS.xz, 10);
        float dist = clamp(objectPos[i].w - distance(objectPos[i].xyz, positionWS), 0, objectPos[i].w);
        float3 dir = normalize(positionWS - objectPos[i].xyz);
        positionWS.xz += dir.xz * dist * (range * range) * intensity;
        positionOS = TransformWorldToObject(positionWS);
    }
}
    