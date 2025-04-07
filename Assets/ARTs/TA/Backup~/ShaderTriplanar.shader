    Shader "Custom/TriplanarShader"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_Mod ("Shading Mode_Foldout", float) = 1
        [KeywordEnum(Stylized, Basic, Hair, Anisotropic)] _ShadingMode ("Shading Mode", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)]  _BlendOp  ("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0
        [Enum(Off, 0, On, 1)]_ZWriteMode ("ZWriteMode", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode ("ZTestMode", Float) = 4
        
        [Foldout(1, 2, 0, 1)]_HSL ("色相\饱和度\亮度_Foldout", float) = 1
        [Space(10)]
        _Hue ("Hue (色相)", Range(0, 100)) = 0
        _Saturation ("Saturation (饱和度)", Range(0, 5)) = 1
        _Lightness ("Lightness (亮度)", Range(0, 5)) = 1
        [Space(10)]

        [Foldout(1, 2, 0, 1)]_Basic ("基础属性_Foldout", float) = 1
        [Space(10)]
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _BaseMap ("Albedo (反照率)", 2D) = "white" {}
        [Space(10)]
        [NoScaleOffset] _DMSMap ("DMS (导数/金属性/光泽度)", 2D) = "white" {}
        [Space(10)]
        _TilingX ("Tiling X", Range(0, 3)) = 1
        _TilingY ("Tiling Y", Range(0, 3)) = 1
        _TilingOffsetX ("Tiling Offset X", Range(-1, 1)) = 0
        _TilingOffsetY ("Tiling Offset Y", Range(-1, 1)) = 0
        _Blend ("Blend (边缘融合)", Range(0, 10)) = 3
        _Thickness ("Thickness (顶点偏移厚度)", Range(0, 1)) = 0
        [Space(10)]
        _Metallic ("Metallic (金属性)", Range(0, 1)) = 0
        _Smoothness ("Smoothness (光泽度)", Range(0, 1)) = 0.5
        _NormalIntensity ("Normal Intensity (法线强度)", Range(0, 3)) = 1
        
        [Space(10)]
        [Foldout(1, 2, 0, 1)]_TopMapParameter ("顶面属性_Foldout", float) = 1
        [Space(10)]
        [Toggle(_TOPMAP)] _TopMap("TopMap (开启顶面材质)", Float) = 0
        [Space(10)]
        [NoScaleOffset] _TopBaseMap ("Albedo (反照率)", 2D) = "white"{}
        [NoScaleOffset] _TopDMSMap ("DMS (导数/金属性/光泽度)", 2D) = "white"{}
        [Space(10)]
        _TopTiling ("Tiling (贴图重复率)", Range(0, 2)) = 1
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Stylized ("Stylized_Foldout", float) = 1
        [Space(10)]
        [Toggle(_OVERRIDE)] _Override("Override On/Off", Float) = 0
        //[NoScaleOffset] _RampMap ("Ramp Map", 2D) = "white" {}
        [Foldout(2, 3, 0, 1)]_Diffuse ("Diffuse_Foldout", float) = 1
        _BorderColor ("Borderline Color", Color) = (0.5, 0.5, 0.5, 1)
        _BorderThreshold ("Borderline Threshold", Range(0, 1)) = 0.5
        _BorderSmooth ("Borderline Smooth", Range(0, 1)) = 0.5
        
        _ShadowColor ("Shadow Color", Color) = (0, 0, 0, 1)
        _ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
        _ShadowSmooth ("Shadow Smooth", Range(0, 1)) = 0.5
        
        _ReflectColor ("Reflect Color", Color) = (0, 0, 0, 1)
        _ReflectThreshold ("Reflect Threshold", Range(0, 1)) = 0.5
        _ReflectSmooth ("Reflect Smooth", Range(0, 1)) = 0.5
        
        [Foldout(2, 3, 0, 1)]_Reflect ("Reflect_Foldout", float) = 1
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecIntensity ("Specular Intenstiy", Range(0, 50)) = 1
        _SpecThreshold ("Specular Threshold", Range(0, 1)) = 0.5
        _SpecSmooth ("Specular Smooth", Range(0, 1)) = 0.5
        
        _FresColor ("Fresnel Color", Color) = (1, 1, 1, 1)
        _FresIntensity ("Fresnel Intenstiy", Range(0, 50)) = 1
        _FresThreshold ("Fresnel Threshold", Range(0, 1)) = 0.5
        _FresSmooth ("Fresnel Smooth", Range(0, 1)) = 0.5
        
        
//        [Foldout(2, 3, 0, 1)]_Brush ("Brush_Foldout", float) = 1
//        _BorderBrushStrength ("Border Brush Strength", Range(0, 1)) = 0
//        _ShadwoBrushStrength ("Shadow Brush Strength", Range(0, 1)) = 0
//        _ReflectBrushStrength ("Reflect Brush Strength", Range(0, 1)) = 0
//        _BrushScale ("Brush Scale", Range(0, 10)) = 4
//        [Space(10)]

        
        [Foldout(1, 2, 0, 1)]_Lights ("其他光照属性_Foldout", float) = 1
        [Space(10)]
        [Foldout(2, 3, 0, 1)]_EmissionParameter ("自发光_Foldout", float) = 1
        [Toggle(_EMISSION)] _Emission("Emission (开启自发光)", Float) = 0
        [HDR] _EmissionColor ("Emission Color", Color) = (1, 1, 1)
        [Space(10)]
        [NoScaleOffset] _EmissionMap ("Emission Map", 2D) = "white" {}
        
        [Space(10)]
        [Foldout(1, 2, 0, 1)]_Other ("其他属性_Foldout", float) = 1
        [Space(10)]
        [KeywordEnum(CullOff, CullFront, CullBack)] _CullMode ("Cull Mode", Float) = 2
    

        
        
        //        [Space(20)]
//        [Header(RAIN PARAMETER)]
//        [Space(20)]
//        [Toggle(_RAIN)] _Rain("Rain", Float) = 0
//        [NoScaleOffset] _RippleMap ("Ripples Map", 2D) = "white" {}
//        [NoScaleOffset] _RippleNoiseMap ("Ripples Noise Map", 2D) = "white" {}
//        _RippleSpeed ("Ripples Speed", Float) = 1
//        _RippleScale ("Ripples Scale", Float) = 1
//        _RippleStep ("Ripples Step", Range(0, 1)) = 1
//        _RippleBlend ("Ripples Blend", Range(0, 1)) = 1
//        [HDR] _RippleColor ("Ripples Color", Color) = (1, 1, 1, 1)

//        [Space(20)]
//        [Header(BACKLIGHT PARAMETER)]
//        [Space(20)]
//        [Toggle(_BACKLIGHT)] _BackLight("Back Light", Float) = 0
        //[HDR] _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        
//        [Space(20)]
//        [Header(PROJECTOR PARAMETER)]
//        [Space(20)]
//        [Toggle(_PROJECTOR)] _Projector("Projector On", Float) = 0
    }


    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        #include "Assets/ARTs/TA/Resources/CustomRP/CustomFunctions.hlsl"
        #include "Assets/ARTs/TA/Resources/CustomRP/Shading.hlsl"

        #pragma instancing_options procedural:setupGPUI
        #pragma multi_compile_instancing
        
        
        CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half4 _SpecColor;
            half4 _FresColor;
            half _NormalScale;
            half _TopNormalScale;
            half _Smoothness;
            half _Metallic;
            half _NormalIntensity;
            half _Blend;
            half _TilingX;
            half _TilingY;
            half _Cutoff;
            half _TopTiling;
            half _FresThreshold;
            half _FresSmooth;
            half _FresIntensity;
            half _Thickness;
            half _Hue;
            half _Saturation;
            half _Lightness;
            half4 _EmissionColor;
            half _TilingOffsetX;
            half _TilingOffsetY;
            half _SpecThreshold;
            half _SpecSmooth;
            half _SpecIntensity;
            half4 _BorderColor;
            half _BorderThreshold;
            half _BorderSmooth;
            half4 _ShadowColor;
            half _ShadowThreshold;
            half _ShadowSmooth;
            half4 _ReflectColor;
            half _ReflectThreshold;
            half _ReflectSmooth;
            half _BorderBrushStrength;
            half _ShadowBrushStrength;
            half _ReflectBrushStrength;
            half _BrushScale;
        CBUFFER_END

        CBUFFER_START(GlobalMaterial)
            half _Exposure;
            half _ReflectExposure;
            half4 _ProjectLightColor;
            half4 _ProjectShadowColor;
            half _ProjectBlend;
            half _ProjectScale;
            half _WindSpeed;
            half4 _RippleColor;
            half _RippleSpeed;
            half _FlowSpeed;
            half _RippleScale;
            half _FlowScale;
            half _RippleBlend;
            half _FlowBlend;
            half _RippleColorBlend;
            half _RainSmoothness;
            half _FogNoiseScale;
            half4 _GlobalBorderColor;
            half _GlobalBorderThreshold;
            half _GlobalBorderSmooth;
            half4 _GlobalShadowColor;
            half _GlobalShadowThreshold;
            half _GlobalShadowSmooth;
            half4 _GlobalReflectColor;
            half _GlobalReflectThreshold;
            half _GlobalReflectSmooth;
            half4 _GlobalSpecColor;
            half _GlobalSpecIntensity;
            half _GlobalSpecThreshold;
            half _GlobalSpecSmooth;
            half4 _GlobalFresColor;
            half _GlobalFresIntensity;
            half _GlobalFresThreshold;
            half _GlobalFresSmooth;
            
            half _AOBlend;
            half _AORange;
            float4 custom_SH[7];
        CBUFFER_END

        ENDHLSL

        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            //Material Keywords
            #pragma shader_feature _TOPMAP
            #pragma shader_feature _EMISSION
            #pragma shader_feature _OVERRIDE
            #pragma shader_feature _SHADINGMODE_STYLIZED _SHADINGMODE_BASIC _SHADINGMODE_HAIR _SHADINGMODE_ANISOTROPIC
            
			#pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _SHADOWS_SOFT
			#pragma multi_compile _SHADOWS_SHADOWMASK
            #pragma multi_compile _ _PROJECTOR
            #pragma multi_compile _ _PROJECTORTYPE_TREE _PROJECTORTYPE_CLOUD
            #pragma multi_compile _ _RAIN
            #pragma multi_compile _ _FOG

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float2 uv            : TEXCOORD0;
                //float2 uv3           : TEXCOORD2;
                float4 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float2 uv            : TEXCOORD0;
                //float  AO            : TEXCOORD4;
                float4 tangentWS     : TEXCOORD1;
                float4 bitangentWS   : TEXCOORD2;
                float4 normalWS      : TEXCOORD3;
            };

            TEXTURE2D (_BaseMap);
            SAMPLER (sampler_BaseMap);
            
            TEXTURE2D(_DMSMap);
            SAMPLER(sampler_DMSMap);

            // TEXTURE2D (_AOTex);
            // SAMPLER (sampler_AOTex);
            
            TEXTURE2D (_BrushMap);
            SAMPLER (sampler_BrushMap);

            #ifdef _TOPMAP
                TEXTURE2D(_TopBaseMap);
                SAMPLER(sampler_TopBaseMap);
                TEXTURE2D(_TopDMSMap);
                SAMPLER(sampler_TopDMSMap);
            #endif

            #ifdef _EMISSION
                TEXTURE2D(_EmissionMap);
                SAMPLER(sampler_EmissionMap);
            #endif

            #ifdef _PROJECTOR
                TEXTURE2D(_projectMaskMap);
                SAMPLER(sampler_projectMaskMap);
            #endif

            #ifdef _RAIN
                TEXTURE2D(_RippleMap);
                SAMPLER(sampler_RippleMap);
                TEXTURE2D(_RippleNoiseMap);
                SAMPLER(sampler_RippleNoiseMap);
            #endif
            

            Varyings LitPassVertex(Attributes IN)
            {
                Varyings OUT;

                float3 normal = normalize(IN.normalOS.xyz);
                float3 positionOS = IN.positionOS.xyz;
                positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz, IN.tangentOS);

                OUT.positionCS = positionInputs.positionCS;
                float3 positionWS = positionInputs.positionWS;
                
                OUT.normalWS = float4(normalInputs.normalWS, positionWS.x);
                OUT.tangentWS = float4(normalInputs.tangentWS, positionWS.y);
                OUT.bitangentWS = float4(normalInputs.bitangentWS, positionWS.z);

                //float AO = SAMPLE_TEXTURE2D_LOD(_AOTex, sampler_AOTex, IN.uv3, 0).a;
                
                OUT.uv = IN.uv;
                //OUT.AO = AO;
                
                return OUT;
            }

            DataInput InitializeDataInput(Varyings IN)
            {
                DataInput dataInput = (DataInput)0;

                dataInput.positionWS = float3(IN.normalWS.w, IN.tangentWS.w, IN.bitangentWS.w);
                //dataInput.positionWS = mul(float4(dataInput.positionWS, 1), UNITY_MATRIX_I_M).xyz;

                //Triplanar UVs
                half2 uvX = dataInput.positionWS.zy;
                half2 uvY = dataInput.positionWS.xz;
                half2 uvZ = dataInput.positionWS.xy;
                half2 uvTile = float2(_TilingX, _TilingY);
                half2 uvOffset = float2(_TilingOffsetX, _TilingOffsetY);
                half2 uvSideX = uvX * uvTile + uvOffset;
                half2 uvSideY = uvY * uvTile + uvOffset;
                half2 uvSideZ = uvZ * uvTile + uvOffset;

                //Triplanar Blend
                float3 blend = TriplanarBlend(IN.normalWS.xyz, _Blend);

                //Albedo采样
                half4 albedoX = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvSideX).rgba * _BaseColor.rgba;
                half4 albedoY = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvSideY).rgba * _BaseColor.rgba;
                half4 albedoZ = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uvSideZ).rgba * _BaseColor.rgba;

                //湿度遮罩
                float wetMaskX = albedoX.a;
                float wetMaskY = albedoY.a;
                float wetMaskZ = albedoZ.a;
             
                //DMS采样
                float4 DMSX = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvSideX).rgba;
                float4 DMSY = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvSideY).rgba;
                float4 DMSZ = SAMPLE_TEXTURE2D(_DMSMap,sampler_DMSMap, uvSideZ).rgba;

                float3 bumpX = normalize(UnpackDerivativeHeight(float3(DMSX.xy * _NormalIntensity, 1)));
                float3 bumpY = normalize(UnpackDerivativeHeight(float3(DMSY.xy * _NormalIntensity, 1)));
                float3 bumpZ = normalize(UnpackDerivativeHeight(float3(DMSZ.xy * _NormalIntensity, 1)));

                //顶面不同
                #ifdef _TOPMAP
                    half2 uvTop = uvY * _TopTiling;
                    half4 albedoTop = SAMPLE_TEXTURE2D(_TopBaseMap, sampler_TopBaseMap, uvTop).rgba;
                    float wetMaskTop = albedoTop.a;
                    float4 DMSTop = SAMPLE_TEXTURE2D(_TopDMSMap, sampler_TopDMSMap, uvTop).rgba;
                    float3 bumpTop = normalize(UnpackDerivativeHeight(float3(DMSTop.xy * _NormalIntensity, 1)));
                    float top = saturate(dot(IN.normalWS.xyz, float3(0, 1, 0)));
                    albedoY = lerp(albedoY, albedoTop, top);
                    wetMaskY = lerp(wetMaskY, wetMaskTop, top);
                    DMSY.zw = lerp(DMSY.zw, DMSTop.zw, top);
                    bumpY = lerp(bumpY, bumpTop, top);
                #endif

                //Albedo混合
                dataInput.albedo = albedoX.rgb * blend.x + albedoY.rgb * blend.y + albedoZ.rgb * blend.z;

                //湿度遮罩混合
                float wetMask = wetMaskX * blend.x + wetMaskY * blend.y + wetMaskZ * blend.z;

                //DMS混合
                float2 DMS = DMSX.zw * blend.x + DMSY.zw * blend.y + DMSZ.zw * blend.z;

                //法线混合
                dataInput.N = TriplanarNormal(bumpX, bumpY, bumpZ, IN.normalWS.xyz, blend);
                
                dataInput.smoothness = DMS.y * _Smoothness;
                dataInput.metallic = DMS.x * _Metallic;

                dataInput.shadowCoord = TransformWorldToShadowCoord(dataInput.positionWS);
                dataInput.light = GetMainLight(dataInput.shadowCoord);
                dataInput.L = SafeNormalize(dataInput.light.direction);
                dataInput.V = GetWorldSpaceNormalizeViewDir(dataInput.positionWS);
                dataInput.exposure = _Exposure;
                dataInput.reflectExposure = _ReflectExposure;
                
                #ifdef _EMISSION
                    dataInput.emissive = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, IN.uv).rgb * _EmissionColor.rgb;
                #endif

                //色相饱和度亮度
                float hue = Remap(_Hue, float2(0, 100), float2(0, 360)).x;
                dataInput.albedo.rgb = Hue(dataInput.albedo.rgb, hue);
                dataInput.albedo.rgb = Saturation(dataInput.albedo.rgb, _Saturation);
                dataInput.albedo.rgb *= _Lightness;

                //雨水法线粗糙度
                #ifdef _RAIN
                    float3 upDir = float3(0, 1, 0);
                    float upMask = saturate(dot(dataInput.N, upDir));
                
                    float rippleSpeed = _Time.y * _RippleSpeed;
                    float flowSpeed = _Time.y * _FlowSpeed;
                
                    float2 rippleUVY1 = Flipbook(uvY / _RippleScale, 2, 2, rippleSpeed);
                    float2 rippleUVY2 = Flipbook(uvY / _RippleScale * 1.5, 4, 4, rippleSpeed);

                    float rippleAlpha1 = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, rippleUVY1).b;
                    float rippleAlpha2 = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, rippleUVY2).b;
                    float ripplesAlpha = (rippleAlpha1 + rippleAlpha2) * upMask;
                
                    float rippleMask = Unity_Voronoi_float(uvY, rippleSpeed * 0.2, 3);
                    ripplesAlpha = clamp(ripplesAlpha, 0, 1) * (1 - smoothstep(-0.5, 0.5, rippleMask));

                    float rippleNoiseX = SAMPLE_TEXTURE2D(_RippleNoiseMap, sampler_RippleNoiseMap, uvX).r * 0.03;
                    float rippleNoiseZ = SAMPLE_TEXTURE2D(_RippleNoiseMap, sampler_RippleNoiseMap, uvZ).r * 0.03;
                
                    float4 rippleX = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, float2(uvX.x, uvX.y + flowSpeed) / _FlowScale + rippleNoiseX).rgba;
                    float4 rippleZ = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, float2(uvZ.x, uvZ.y + flowSpeed) / _FlowScale + rippleNoiseZ).rgba;

                    float3 rippleBumpX = normalize(UnpackDerivativeHeight(float3(rippleX.xy * _FlowBlend, 1)));
                    float3 rippleBumpZ = normalize(UnpackDerivativeHeight(float3(rippleZ.xy * _FlowBlend, 1)));

                    bumpX = float3(bumpX.xy + rippleBumpX.xy, 1);
                    bumpZ = float3(bumpZ.xy + rippleBumpZ.xy, 1);

                    wetMask = lerp(0, wetMask, _RainSmoothness);
                    float3 normalTS = TransformWorldToTangent(IN.normalWS.xyz, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                    bumpY = lerp(bumpY, normalTS, wetMask);

                    //Triplanar Blend
                    float3 rippleBlend = TriplanarBlend(IN.normalWS.xyz, 5);
                    
                
                    //Blend Normal
                    dataInput.N = TriplanarNormal(bumpX, bumpY, bumpZ, IN.normalWS.xyz, rippleBlend);
                    
                    dataInput.smoothness = dataInput.smoothness + wetMask;
                    dataInput.albedo = lerp(dataInput.albedo, _RippleColor.rgb, ripplesAlpha * _RippleColorBlend);
                #endif
                
                dataInput.occlusion = 1;
                dataInput.customSH = custom_SH;
                
                dataInput.borderColor = ColorspaceRGBToLinear(_GlobalBorderColor.rgb);
                dataInput.borderThreshold = _GlobalBorderThreshold;
                dataInput.borderSmooth = _GlobalBorderSmooth;

                dataInput.shadowColor = ColorspaceRGBToLinear(_GlobalShadowColor.rgb);
                dataInput.shadowThreshold = _GlobalShadowThreshold;
                dataInput.shadowSmooth = _GlobalShadowSmooth;

                dataInput.reflectColor = ColorspaceRGBToLinear(_GlobalReflectColor.rgb);
                dataInput.reflectThreshold = _GlobalReflectThreshold;
                dataInput.reflectSmooth = _GlobalReflectSmooth;

                dataInput.specThreshold = _GlobalSpecThreshold;
                dataInput.specSmooth = _GlobalSpecSmooth;
                dataInput.specIntensity = _GlobalSpecIntensity;
                dataInput.specColor = ColorspaceRGBToLinear(_GlobalSpecColor.rgb);
                
                dataInput.fresThreshold = _GlobalFresThreshold;
                dataInput.fresSmooth = _GlobalFresSmooth;
                dataInput.fresIntensity = _GlobalFresIntensity;
                dataInput.fresColor = ColorspaceRGBToLinear(_GlobalFresColor.rgb);

                #ifdef _OVERRIDE
                
                    dataInput.borderColor = _BorderColor.rgb;
                    dataInput.borderThreshold = _BorderThreshold;
                    dataInput.borderSmooth = _BorderSmooth;
                
                    dataInput.shadowColor = _ShadowColor.rgb;
                    dataInput.shadowThreshold = _ShadowThreshold;
                    dataInput.shadowSmooth = _ShadowSmooth;
                
                    dataInput.reflectColor = _ReflectColor.rgb;
                    dataInput.reflectThreshold = _ReflectThreshold;
                    dataInput.reflectSmooth = _ReflectSmooth;

                    dataInput.specThreshold = _SpecThreshold;
                    dataInput.specSmooth = _SpecSmooth;
                    dataInput.specIntensity = _SpecIntensity;
                    dataInput.specColor = _SpecColor.rgb;
                
                    dataInput.fresThreshold = _FresThreshold;
                    dataInput.fresSmooth = _FresSmooth;
                    dataInput.fresIntensity = _FresIntensity;
                    dataInput.fresColor = _FresColor.rgb;
                
                #endif


                dataInput.castShadow = 1;
                
                return dataInput;
            }

            half4 LitPassFragment(Varyings IN) : SV_Target
            {
                DataInput dataInput = InitializeDataInput(IN);
                
                #ifdef _SHADINGMODE_STYLIZED
                    half3 color = ShadingStylized(dataInput);
                
                #elif _SHADINGMODE_BASIC
                    half3 color = ShadingBasic(dataInput);
                    
                #elif _SHADINGMODE_HAIR
                    half3 color = ShadingHair(dataInput);
                
                #elif _SHADINGMODE_ANISOTROPIC
                    half3 color = ShadingAniso(dataInput);
                #endif
                
                //自发光
                #ifdef _EMISSION
                    color += dataInput.emissive;
                #endif
                
                //投射阴影
                #ifdef _PROJECTOR
                    float3 tangent = normalize(cross(float3(dataInput.L.x, 0, dataInput.L.z), dataInput.L));
                    float3 bitangent = normalize(cross(tangent, dataInput.L));
                    float3 positionLS = mul(float3x3(tangent, bitangent, -dataInput.L), dataInput.positionWS);
                    float2 lightMaskUV = positionLS.xy;
                
                    #ifdef _PROJECTORTYPE_TREE
                        lightMaskUV = float2(lightMaskUV.x / _ProjectScale + sin(_Time.y * _WindSpeed * 0.5) * 0.02, lightMaskUV.y / _ProjectScale);
                    #endif

                    #ifdef _PROJECTORTYPE_CLOUD
                        lightMaskUV = float2(lightMaskUV.x / _ProjectScale + _Time.y * _WindSpeed * 0.5 * 0.02, lightMaskUV.y / _ProjectScale);
                    #endif

                    half3 upDir = saturate(dot(dataInput.N, half3(0, 1, 0)));
                    float lightMaskNoise = SimpleNoise(lightMaskUV, 10);
                    float lightMask = SAMPLE_TEXTURE2D(_projectMaskMap, sampler_projectMaskMap, lightMaskUV).r;
                    lightMask = lerp(1, lightMask, upDir);
                    float NdotL = max(saturate(dot(dataInput.N, dataInput.L)), 0.001);
                    half3 lightMaskColor = lerp(_ProjectShadowColor.rgb, _ProjectLightColor.rgb, lightMask * NdotL * dataInput.light.shadowAttenuation * lightMaskNoise);

                    color = color * (lightMaskColor + _ProjectBlend);
                    //color = upDir;
                #endif
                
                //color = Blend_Overlay(color, IN.AO, _AOBlend);
                //float AO = smoothstep(0, _AORange, IN.AO);
                //color = lerp(color, color * AO, _AOBlend);
                
                
                //最终输出
                return half4(color, 1);
                //return half4(IN.AO, 1);
            }

            ENDHLSL
        }
        
        Pass 
        {
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual

			HLSLPROGRAM

			// Material Keywords
			#pragma shader_feature _ALPHATEST
            #pragma shader_feature _BILLBOARD
            #pragma shader_feature _WIND

			// Universal Pipeline Keywords
			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float4 normalOS      : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float3 normalWS      : TEXCOORD3;
            };

            Varyings ShadowPassVertex(Attributes IN)
            {
                Varyings OUT;
                
                float3 normal = normalize(IN.normalOS.xyz);
                float3 positionOS = IN.positionOS.xyz;
                positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
                
                float3 positionWS = TransformObjectToWorld(positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
                
                OUT.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _MainLightPosition.xyz));
                
                OUT.normalWS = normalWS;
                
                return OUT;
            }

            float4 ShadowPassFragment(Varyings IN) : SV_Target
            {
                return 0;
            }

			ENDHLSL
		}

        Pass
        {
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			//ColorMask 0
			ZWrite On
			ZTest LEqual

			HLSLPROGRAM

			// Material Keywords
			#pragma shader_feature _ALPHATEST

			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float3 normalOS      : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
            };

            Varyings DepthOnlyVertex(Attributes IN)
            {
                Varyings OUT;
                
                float3 normal = normalize(IN.normalOS.xyz);
                float3 positionOS = IN.positionOS.xyz;
                positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS.xyz);

                OUT.positionCS = positionInputs.positionCS;
                
                return OUT;
            }

            float4 DepthOnlyFragment(Varyings IN) : SV_Target
            {
                return 0;
            }
			ENDHLSL
        }
        
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull Back

            HLSLPROGRAM
            
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST
            #pragma shader_feature _EMISSION
            #pragma shader_feature _BILLBOARD
            #pragma shader_feature _WIND
			#pragma shader_feature _COLLISION

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 normal     : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 texcoord   : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : TEXCOORD1;
                float2 uv         : TEXCOORD0;
            };
            
            
            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                output.uv         = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal.xyz, input.tangentOS);

                half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
                output.normalWS = half3(normalInput.normalWS);
                #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
                    float sign = input.tangentOS.w * float(GetOddNegativeScale());
                    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
                #endif

                #if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
                    output.tangentWS = tangentWS;
                #endif

                #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
                    half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
                    output.viewDirTS = viewDirTS;
                #endif

                return output;
            }


            half4 DepthNormalsFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                //Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);

                #if defined(_GBUFFER_NORMALS_OCT)
                    float3 normalWS = normalize(input.normalWS);
                    float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms
                    float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
                    half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
                    return half4(packedNormalWS, 0.0);
                #else
                    float2 uv = input.uv;
                    #if defined(_PARALLAXMAP)
                        #if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
                            half3 viewDirTS = input.viewDirTS;
                        #else
                            half3 viewDirTS = GetViewDirectionTangentSpace(input.tangentWS, input.normalWS, input.viewDirWS);
                        #endif
                        ApplyPerPixelDisplacement(viewDirTS, uv);
                    #endif

                    #if defined(_NORMALMAP) || defined(_DETAIL)
                        float sgn = input.tangentWS.w;      // should be either +1 or -1
                        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
                        float3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);

                        #if defined(_DETAIL)
                            half detailMask = SAMPLE_TEXTURE2D(_DetailMask, sampler_DetailMask, uv).a;
                            float2 detailUv = uv * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
                            normalTS = ApplyDetailNormal(detailUv, normalTS, detailMask);
                        #endif

                        float3 normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
                    #else
                        float3 normalWS = input.normalWS;
                    #endif

                    return half4(NormalizeNormalPerPixel(normalWS), 0.0);
                #endif
            }
            ENDHLSL
        }
    }
    CustomEditor "EBGame.SimpleShaderGUI"
}
