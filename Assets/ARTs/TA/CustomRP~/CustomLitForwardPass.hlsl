#ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED

#include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"

struct Attributes
{
    float4 positionOS    : POSITION;
    float2 uv            : TEXCOORD0;
    float2 uv2           : TEXCOORD1;
    float4 normalOS      : NORMAL;
    float4 tangentOS     : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS    : SV_POSITION;
    float2 uv            : TEXCOORD0;
    float2 uv2           : TEXCOORD4;
    float4 tangentWS     : TEXCOORD1;
    float4 bitangentWS   : TEXCOORD2;
    float4 normalWS      : TEXCOORD3;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

InputData InitializeInputData(Varyings IN, half3 normalTS)
{
    InputData inputData = (InputData)0;

    float3 positionWS = float3(IN.normalWS.w, IN.tangentWS.w, IN.bitangentWS.w);
    inputData.positionWS = positionWS;
    inputData.positionCS = IN.positionCS;
    inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(positionWS);
                
    half3 normalWS = TransformTangentToWorld(normalTS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
    normalWS = NormalizeNormalPerVertex(normalWS);

    inputData.normalWS = normalWS;
                
    #if defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(positionWS);
    #else
    inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif
    
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

    return inputData;
}

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////

// Used in Standard (Physically Based) shader
Varyings LitPassVertex(Attributes IN)
{
    Varyings OUT;

    UNITY_SETUP_INSTANCE_ID(IN);
    UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
    
    float3 normal = normalize(IN.normalOS.xyz);
    float3 positionOS = IN.positionOS.xyz;
    positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
    
    float3 positionWS = TransformObjectToWorld(positionOS.xyz);

    
    //广告牌顶点偏移
    #ifdef _BILLBOARD
        float3 center = float3(0, 0, 0);
        float3 viewer = TransformWorldToObject(GetCameraPositionWS());
        float3 normalDir = viewer - center;
        normalDir.y = 0;
        normalDir = normalize(normalDir);

        float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
        float3 rightDir = normalize(cross(upDir, normalDir));
        upDir = normalize(cross(normalDir, rightDir));

        float3 centerOffset = IN.positionOS.xyz - center;
        float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset.z;

        positionWS = TransformObjectToWorld(localPos);
    #endif
    
    
    //风顶点偏移
    #ifdef _WIND
        float time = _Time.y * _WindSpeed;
        float windStrength = _WindSpeed * 2;
        float bend = Remap((sin(time * 0.2) + sin(time * 0.4)), float2(-1, 1), float2(windStrength * 0.1, 1)).r * windStrength * 0.01;
        float bendRange = smoothstep(_BendThreshold, _BendThreshold + _BendFalloff, IN.uv2.y);
    
        #ifdef  _WINDTYPE_DIRECTION
            float windNoise = SimpleNoise(positionWS.xz - time * 0.3, _WindDensity).r;
            windNoise *= _WindNoiseIntensity;
            float3 wind = float3(bend * _Direction.x, 0, bend * _Direction.z) * bendRange * windNoise;
        #endif
    
        #ifdef  _WINDTYPE_SWING
            float windNoise = SimpleNoise(positionWS.xz - time * 0.3, _WindDensity).r - 0.5;
            windNoise *= _WindNoiseIntensity;
            float3 wind = float3(bend * _Direction.x, 0, bend * _Direction.z) * bendRange * windNoise;
        #endif
    
        positionWS += wind;
    #endif


    //植物碰撞顶点偏移
    #ifdef _COLLISION
        for(int i = 0; i < MAX_POSITION_COUNT; i++)
        {
            float3 pos = float3(_ObjectArrayPos[i].x, _ObjectArrayPos[i].y + 0.2, _ObjectArrayPos[i].z);
            float dis = saturate(distance(pos, positionWS.xyz));
            float push = dis <= _CollisionRadius ? (1 - dis) * IN.uv2.y * _CollisionStrength : 0;
            push = smoothstep(0.2, 1, push);
            float3 direction = normalize(positionWS.xyz - pos);
            direction.y *= 0.5;
            positionWS.xyz += direction * push;
        }
    #endif
    
    VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz, IN.tangentOS);
    
    OUT.positionCS = TransformWorldToHClip(positionWS);
    
    OUT.normalWS = float4(normalInputs.normalWS, positionWS.x);
    OUT.tangentWS = float4(normalInputs.tangentWS, positionWS.y);
    OUT.bitangentWS = float4(normalInputs.bitangentWS, positionWS.z);
    OUT.uv = IN.uv;
    OUT.uv2 = IN.uv2;
    
    //float AO = SAMPLE_TEXTURE2D_LOD(_AOTex, sampler_AOTex, IN.uv3, 0).a;
    //OUT.AO = AO;
    
    return OUT;
}

SurfaceData InitializeSurfaceData(Varyings IN)
{
    SurfaceData surfaceData = (SurfaceData)0;

    float3 positionWS = float3(IN.normalWS.w, IN.tangentWS.w, IN.bitangentWS.w);
    float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
    Light mainLight = GetMainLight(shadowCoord);
    float3 lightDirWS = normalize(mainLight.direction);

    float2 uvX = positionWS.zy;
    float2 uvY = positionWS.xz;
    float2 uvZ = positionWS.xy;

    #ifdef _TRIPLANAR
        half2 uvTile = float2(_TilingX, _TilingY);
        half2 uvOffset = float2(_TilingOffsetX, _TilingOffsetY);
        half2 uvSideX = uvX * uvTile + uvOffset;
        half2 uvSideY = uvY * uvTile + uvOffset;
        half2 uvSideZ = uvZ * uvTile + uvOffset;

        //Triplanar Blend
        float3 blend = TriplanarBlend(IN.normalWS.xyz, _TriBlend);

        //Albedo采样
        half4 albedoX = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvSideX).rgba;
        half4 albedoY = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvSideY).rgba;
        half4 albedoZ = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvSideZ).rgba;

        //湿度遮罩
        float wetMaskX = albedoX.a;
        float wetMaskY = albedoY.a;
        float wetMaskZ = albedoZ.a;

        //DMS采样
        float4 DMSX = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvSideX).rgba;
        float4 DMSY = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvSideY).rgba;
        float4 DMSZ = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvSideZ).rgba;

        float3 bumpX = normalize(UnpackDerivativeHeight(float3(DMSX.xy, 1)));
        float3 bumpY = normalize(UnpackDerivativeHeight(float3(DMSY.xy, 1)));
        float3 bumpZ = normalize(UnpackDerivativeHeight(float3(DMSZ.xy, 1)));

        //顶面不同
        #ifdef _TOPMAP
            half2 uvTop = uvY * _TopTiling;
            half4 albedoTop = SAMPLE_TEXTURE2D(_TopBaseMap, sampler_TopBaseMap, uvTop).rgba;
            float wetMaskTop = albedoTop.a;
            float4 DMSTop = SAMPLE_TEXTURE2D(_TopDMSMap, sampler_TopDMSMap, uvTop).rgba;
            float3 bumpTop = normalize(UnpackDerivativeHeight(float3(DMSTop.xy, 1)));
            float top = saturate(dot(IN.normalWS.xyz, float3(0, 1, 0)));
            albedoY = lerp(albedoY, albedoTop, top);
            wetMaskY = lerp(wetMaskY, wetMaskTop, top);
            DMSY.zw = lerp(DMSY.zw, DMSTop.zw, top);
            bumpY = lerp(bumpY, bumpTop, top);
        #endif

        //Albedo混合
        half3 albedo = (albedoX.rgb * blend.x + albedoY.rgb * blend.y + albedoZ.rgb * blend.z) * _BaseColor.rgb;
        half alpha = 1;
        //湿度遮罩混合
        float wetMask = wetMaskX * blend.x + wetMaskY * blend.y + wetMaskZ * blend.z;

        //DMS混合
        float2 DMS = DMSX.zw * blend.x + DMSY.zw * blend.y + DMSZ.zw * blend.z;

        //法线混合
        half3 normalWS = TriplanarNormal(bumpX, bumpY, bumpZ, IN.normalWS.xyz, blend);
        half3 normalTS = TransformWorldToTangent(normalWS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
        normalTS = NormalizeNormalPerVertex(normalTS);

        half smoothness = DMS.y * _Smoothness;
        half metallic = DMS.x;
    #else
        half4 albedoAlpha = SampleAlbedoAlpha(IN.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
        half alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
        
        half3 albedo = albedoAlpha.rgb * _BaseColor.rgb;
    
        half4 DMS = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, IN.uv).rgba;
        half3 normalTS = normalize(UnpackDerivativeHeight(float3(DMS.xy, 1)));
        half3 normalWS = TransformTangentToWorld(normalTS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
        half smoothness = DMS.a * _Smoothness;
        half metallic = DMS.b;
    #endif

    surfaceData.albedo = albedo;
    surfaceData.alpha = alpha;



    surfaceData.normalTS = normalTS;
    surfaceData.smoothness = smoothness;
    surfaceData.metallic = metallic;
    surfaceData.occlusion = 1; 
    
    //头发
    #ifdef _SHADINGMODE_HAIR
        half4 hairMap = SAMPLE_TEXTURE2D(_HairShiftMap, sampler_HairShiftMap, IN.uv);
        half hairShift = hairMap.r - 0.5;
        half hairMask = hairMap.g;
        surfaceData.tangentWS = ShiftTangent(IN.bitangentWS.xyz, normalWS, hairShift * _HairShift);
        surfaceData.hairSpecExponent = _HairSpecExponent;
        surfaceData.hairSpecMask = hairMask * _HairMaskBlend;
    #endif

    //色相饱和度亮度
    float hue = Remap(_Hue, float2(0, 100), float2(0, 360)).x;
    surfaceData.albedo = Hue(surfaceData.albedo, hue);
    surfaceData.albedo = Saturation(surfaceData.albedo, _Saturation);
    surfaceData.albedo *= _Lightness;

    //SSS
    #ifdef _SSS
        float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
        float subsurface = max(dot(viewDirWS, -normalize(normalWS * _NormalInfluence + lightDirWS)), 0.001);
        float subsurfaceMask = lerp(1, SAMPLE_TEXTURE2D(_SSSMap, sampler_SSSMap, IN.uv).r, _SSSMaskBlend);
        half3 SSSColor = _SSSColor.rgb * pow(subsurface, _SSSPower) * _SSSIntensity * subsurfaceMask;
        surfaceData.albedo += SSSColor;
    #endif

    //风浪颜色
     #ifdef _STORM
         half time = _Time.y * _WindSpeed * 0.5;
         half noise = SimpleNoise(positionWS.xz - time * _Direction.xy, _WindDensity * 0.5).r;
         surfaceData.albedo = lerp(surfaceData.albedo, surfaceData.albedo * _WindColor, noise * IN.uv2.y);
     #endif

    //投射阴影
    #ifdef _PROJECTOR
        float3 tangent = normalize(cross(float3(lightDirWS.x, 0, lightDirWS.z), lightDirWS));
        float3 bitangent = normalize(cross(tangent, lightDirWS));
        float3 positionLS = mul(float3x3(tangent, bitangent, -lightDirWS), positionWS);
        float2 lightMaskUV = positionLS.xy;

        #ifdef _PROJECTORTYPE_TREE
            lightMaskUV = float2(lightMaskUV.x / _ProjectScale + sin(_Time.y * _WindSpeed * 0.5) * 0.02, lightMaskUV.y / _ProjectScale);
        #endif

        #ifdef _PROJECTORTYPE_CLOUD
            lightMaskUV = float2(lightMaskUV.x / _ProjectScale + _Time.y * _WindSpeed * 0.5 * 0.02, lightMaskUV.y / _ProjectScale);
        #endif

        float lightMaskNoise = SimpleNoise(lightMaskUV, 10);
        float lightMask = SAMPLE_TEXTURE2D(_projectMaskMap, sampler_projectMaskMap, lightMaskUV).r;
        float NdotL = max(saturate(dot(normalWS, lightDirWS)), 0.001);
        half3 lightMaskColor = lerp(_ProjectShadowColor.rgb, _ProjectLightColor.rgb, lightMask * NdotL * mainLight.shadowAttenuation * lightMaskNoise);

        surfaceData.albedo *= lightMaskColor + _ProjectBlend;
    #endif

    //雨水
    #ifdef _RAIN
        float3 upDir = float3(0, 1, 0);
        float3 downDir = float3(0, -1, 0);
        float upMask = saturate(dot(normalWS, upDir));
        float downMask = saturate(dot(normalWS, downDir));
        float rippleSpeed = _Time.y * _RippleSpeed;
        float flowSpeed = _Time.y * _FlowSpeed;

        float2 rippleUVX = positionWS.zy;
        float2 rippleUVY1 = Flipbook(positionWS.xz / _RippleScale, 2, 2, rippleSpeed);
        float2 rippleUVY2 = Flipbook(positionWS.xz / _RippleScale * 1.5, 4, 4, rippleSpeed);
        float2 rippleUVZ = positionWS.xy;

        float rippleAlpha1 = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, rippleUVY1).b;
        float rippleAlpha2 = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, rippleUVY2).b;
        float ripplesAlpha = (rippleAlpha1 + rippleAlpha2) * upMask;

        float rippleMask = Unity_Voronoi_float(positionWS.xz, rippleSpeed * 0.2, 3);
        ripplesAlpha = clamp(ripplesAlpha, 0, 1) * (1 - smoothstep(-0.5, 0.5, rippleMask));

        float rippleNoiseX = SAMPLE_TEXTURE2D(_RippleNoiseMap, sampler_RippleNoiseMap, rippleUVX).r * 0.03;
        float rippleNoiseZ = SAMPLE_TEXTURE2D(_RippleNoiseMap, sampler_RippleNoiseMap, rippleUVZ).r * 0.03;

        float4 rippleX = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, float2(rippleUVX.x, rippleUVX.y + flowSpeed) / _FlowScale + rippleNoiseX).rgba;
        float4 rippleZ = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, float2(rippleUVZ.x, rippleUVZ.y + flowSpeed) / _FlowScale + rippleNoiseZ).rgba;

        float3 rippleBumpX = normalize(UnpackDerivativeHeight(float3(rippleX.xy * _FlowBlend, 1)));

        float3 rippleBumpZ = normalize(UnpackDerivativeHeight(float3(rippleZ.xy * _FlowBlend, 1)));

        //Triplanar Blend
        float3 rippleBlend = TriplanarBlend(IN.normalWS.xyz, 10);

        //Blend Normal
        float3 rippleNormal = TriplanarNormal(rippleBumpX, normalTS, rippleBumpZ, IN.normalWS.xyz, rippleBlend);
        float3 rippleNormalTS = TransformWorldToTangent(rippleNormal, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
        rippleNormalTS = NormalBlend(rippleNormalTS, normalTS);
        rippleNormal = TransformTangentToWorld(rippleNormalTS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));

        normalWS = lerp(rippleNormal, normalWS, downMask);
        surfaceData.smoothness += _RainSmoothness;
        surfaceData.albedo = lerp(surfaceData.albedo, _RippleColor.rgb, ripplesAlpha * _RippleColorBlend);
    #endif

    //自发光
    #ifdef _EMISSION
        surfaceData.emission = SampleEmission(IN.uv, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_EmissionMap));
    #endif
    
    #ifdef _CASTSHADOW
        surfaceData.castShadow = 1;
    #endif
    
    //STYLIZED
    surfaceData.borderColor = ColorspaceRGBToLinear(_GlobalBorderColor.rgb);
    surfaceData.borderThreshold = _GlobalBorderThreshold;
    surfaceData.borderSmooth = _GlobalBorderSmooth;
    
    surfaceData.shadowColor = ColorspaceRGBToLinear(_GlobalShadowColor.rgb);
    surfaceData.shadowThreshold = _GlobalShadowThreshold;
    surfaceData.shadowSmooth = _GlobalShadowSmooth;
    
    surfaceData.reflectColor = ColorspaceRGBToLinear(_GlobalReflectColor.rgb);
    surfaceData.reflectThreshold = _GlobalReflectThreshold;
    surfaceData.reflectSmooth = _GlobalReflectSmooth;
    
    surfaceData.specThreshold = _GlobalSpecThreshold;
    surfaceData.specSmooth = _GlobalSpecSmooth;
    surfaceData.specIntensity = _GlobalSpecIntensity;
    surfaceData.specColor = ColorspaceRGBToLinear(_GlobalSpecColor.rgb);
    
    surfaceData.fresThreshold = _GlobalFresThreshold;
    surfaceData.fresSmooth = _GlobalFresSmooth;
    surfaceData.fresIntensity = _GlobalFresIntensity;
    surfaceData.fresColor = ColorspaceRGBToLinear(_GlobalFresColor.rgb);
    
    #ifdef _OVERRIDE
    
        surfaceData.borderColor = _BorderColor.rgb;
        surfaceData.borderThreshold = _BorderThreshold;
        surfaceData.borderSmooth = _BorderSmooth;
    
        surfaceData.shadowColor = _ShadowColor.rgb;
        surfaceData.shadowThreshold = _ShadowThreshold;
        surfaceData.shadowSmooth = _ShadowSmooth;
    
        surfaceData.reflectColor = _ReflectColor.rgb;
        surfaceData.reflectThreshold = _ReflectThreshold;
        surfaceData.reflectSmooth = _ReflectSmooth;
    
        surfaceData.specThreshold = _SpecThreshold;
        surfaceData.specSmooth = _SpecSmooth;
        surfaceData.specIntensity = _SpecIntensity;
        surfaceData.specColor = _SpecColor.rgb;
    
        surfaceData.fresThreshold = _FresThreshold;
        surfaceData.fresSmooth = _FresSmooth;
        surfaceData.fresIntensity = _FresIntensity;
        surfaceData.fresColor = _FresColor.rgb;
    
    #endif
    
    surfaceData.exposure = _Exposure;
    surfaceData.reflectExposure = lerp(0, _ReflectExposure, surfaceData.metallic);
    surfaceData.customSH = custom_SH;

    return surfaceData;
}

// Used in Standard (Physically Based) shader
half4 LitPassFragment(Varyings IN) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(IN);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

    SurfaceData surfaceData = InitializeSurfaceData(IN);
    InputData inputData = InitializeInputData(IN, surfaceData.normalTS);
    
    //颜色输出
    #ifdef _SHADINGMODE_STYLIZED
    half4 color = UniversalFragmentStylizedPBR(inputData, surfaceData);
    
    #elif _SHADINGMODE_BASIC
    half4 color = UniversalFragmentPBR(inputData, surfaceData);
        
    #elif _SHADINGMODE_HAIR
    half4 color = UniversalFragmentHairPBR(inputData, surfaceData);

    #endif

    color.rgb = MixFog(color.rgb, inputData.fogCoord);
    color.a = OutputAlpha(color.a, _Surface);

    //最终输出
    return color;
}

#endif
