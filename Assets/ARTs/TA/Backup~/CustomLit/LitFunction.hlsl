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

//Ripple----------------------------------------
void Ripple(sampler2D rippleMap, float3 positionWS, float3 normalWS, inout half3 baseColor)
{
    float time = fmod(_Time.y, 2e5);
    float upDir = saturate(dot(half3(0, 1, 0), normalWS));
    float rippleNoise = Voronoi_float(positionWS.xz, time * 5, 4);
    float rainAmount = Remap(_RainAmount, float2(0, 1), float2(0, 0.3)).x;
    float rippleRange = smoothstep(1 - rainAmount - 0.5, 1 - rainAmount + 0.5, rippleNoise) * upDir;

    float2 rippleUV = Flipbook(positionWS.xz / _RippleScale, 4, 4, time * _RippleSpeed);
    half rippleMask = tex2D(rippleMap, rippleUV).r;
    half ripple = saturate(rippleRange * rippleMask);
    
    baseColor = lerp(baseColor, _RippleColor.rgb, ripple * _RippleStrength);
}
//----------------------------------------------

//Snow-----------------------------------------
void Snow(sampler2D albedoMap, sampler2D DMSMap, float3 positionWS, inout float3 normalWS, float3x3 tbn, float snow, inout half3 baseColor, inout half smoothness, inout half metallic)
{
    half2 snowUV = positionWS.xz;
    half up = saturate(dot(half3(0, 1, 0), normalWS));
        
    half4 snowAlbedo = tex2D(albedoMap, snowUV * (1 / _SnowScale));
    half4 snowDMS = tex2D(DMSMap, snowUV * (1 / _SnowScale));

    half3 snowColor = snowAlbedo.rgb;
    
    half snowMask = smoothstep(1 - _SnowAmount - 0.2, 1 - _SnowAmount + 0.2, snowAlbedo.a) * up;
     
    half3 snowNormal = normalize(UnpackDerivativeHeight(half3(snowDMS.rg, 1)));
    half snowMetallic = snowDMS.b;
    half snowSmoothness = snowDMS.a * 0.5;
        
    half3 snowNormalWS = NormalizeNormalPerVertex(TransformTangentToWorld(snowNormal, tbn));

    baseColor = lerp(baseColor, snowColor, snowMask * snow);
    metallic = lerp(metallic, snowMetallic, snowMask * snow);
    smoothness = lerp(smoothness, snowSmoothness, snowMask * snow);
    normalWS = lerp(normalWS, snowNormalWS, snowMask * snow);
}
//---------------------------------------------

// //Project--------------------------------------
// #if defined _PROJECT
//     half3x3 tran = half3x3(half3(cos(120), 0, -sin(120)), half3(0, 1, 0), half3(sin(120), 0, cos(120)));
//     half3 tangent = mul(tran, half3(0, 0, -1));
//     half3 bitangent = normalize(cross(tangent, -lightDirWS));
//     tangent = normalize(cross(-lightDirWS, bitangent));
//     float3 positionLS = mul(half3x3(tangent, bitangent, lightDirWS), positionWS);
//     float2 lightMaskUV = positionLS.xy;
//
//     half project = saturate(1 - SAMPLE_TEXTURE2D(_projectMaskMap, sampler_projectMaskMap, lightMaskUV / _ProjectScale).r);
//     customData.project = smoothstep(_ProjectThreshold - _ProjectSmooth, _ProjectThreshold + _ProjectSmooth, project);
// #else
//     customData.project = 1;
// #endif
// //---------------------------------------------

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