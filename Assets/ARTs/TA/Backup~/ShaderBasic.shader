Shader "Custom/BasicShader"
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
        //[Header(HSL)]
        
        [Foldout(1, 2, 0, 1)]_HSL ("HSL_Foldout", float) = 1
        [Space(10)]
        _Hue ("Hue", Range(0, 100)) = 0
        _Saturation ("Saturation", Range(0, 5)) = 1
        _Lightness ("Lightness", Range(0, 5)) = 1
        [Space(10)] 

        [Foldout(1, 2, 0, 1)]_Basic ("Basic_Foldout", float) = 1
        [Space(10)]
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [Space(10)]
        [NoScaleOffset] _BaseMap ("Albedo Map", 2D) = "white" {}
        [Space(10)]
        [Toggle(_DMS)] _DMS("DMS Map On/Off", Float) = 1
        [NoScaleOffset] _DMSMap ("DMS Map", 2D) = "white" {}
        
        [Space(10)]
        _Smoothness ("Smoothness", Range(0, 1)) = 1
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Tiling ("Tiling", Range(0, 5)) = 1
        [Space(10)]
        [Toggle(_ALPHATEST)] _AlphaTest("Alpha Clipping On/Off", Float) = 0
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Stylized ("Stylized_Foldout", float) = 1
        [Space(10)]
        
        [Foldout(2, 3, 0, 1)]_Diffuse ("Diffuse_Foldout", float) = 1
        [Toggle(_OVERRIDE)] _Override("Override On/Off", Float) = 0
        
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
        _SpecIntensity ("Specular Intensity", Range(0, 50)) = 1
        _SpecThreshold ("Specular Threshold", Range(0, 1)) = 0.5
        _SpecSmooth ("Specular Smooth", Range(0, 1)) = 0.5
        
        _FresColor ("Fresnel Color", Color) = (1, 1, 1, 1)
        _FresIntensity ("Fresnel Intensity", Range(0, 50)) = 1
        _FresThreshold ("Fresnel Threshold", Range(0, 1)) = 0.5
        _FresSmooth ("Fresnel Smooth", Range(0, 1)) = 0.5
        
        
//        [Foldout(2, 3, 0, 1)]_Brush ("Brush_Foldout", float) = 1
//        _BorderBrushStrength ("Border Brush Strength", Range(0, 1)) = 0
//        _ShadowBrushStrength ("Shadow Brush Strength", Range(0, 1)) = 0
//        _ReflectBrushStrength ("Reflect Brush Strength", Range(0, 1)) = 0
//        _BrushScale ("Brush Scale", Range(0, 10)) = 4
//        [Space(10)]

        [Foldout(1, 2, 0, 1)]_EmissionParameter ("Emission_Foldout", float) = 1
        [Toggle(_EMISSION)] _Emission("Emission On/Off", Float) = 0
        [NoScaleOffset] _EmissionMap ("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor ("Emission Color", Color) = (1, 1, 1)
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_LightParameter ("Is it a light source_Foldout", float) = 1
        [Toggle(_LIGHT)] _Light("Light Source", Float) = 0
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Subsurface ("Subsurface Scattering_Foldout", float) = 1
        [Space(10)]
        [Toggle(_SSS)] _SSS("Subsurface On/Off", Float) = 0
        [Space(10)]
        _SSSColor ("Subsurface Color", Color) = (1, 1, 1, 1)
        [Space(10)]
        [NoScaleOffset] _SSSMap ("Subsurface Map", 2D) = "white" {}
        _SSSMaskBlend ("Subsurface Blend", Range(0, 1)) = 1
        _NormalInfluence ("Normal Influence", Range(0, 1)) = 0.5
        _SSSPower ("Subsurface Power", Range(0, 5)) = 1
        _SSSIntensity ("Subsurface Intensity", Range(0, 10)) = 1
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Hair ("Hair_Foldout", float) = 1
//        _HairColor1 ("Hair Base Color", Color) = (1, 1, 1, 1)
//        _HairColor2 ("Hair Dark Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _HairShiftMap ("Hair Shift Map", 2D) = "white" {}
        _HairShift ("Hair Shift", Range(-10, 10)) = 1
        _HairMaskBlend ("Hair Mask Blend", Range(0, 1)) = 1
        _HairSpecExponent ("Hair Specular Exponent", Range(1, 512)) = 100
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Ani ("Anisotropic_Foldout", float) = 1 
        [NoScaleOffset] _AnisoFlowMap ("Anisotropic FlowMap", 2D) = "white" {}
        _AnisoDir ("Anisotropic Direction", Range(0, 500)) = 0
        _Anisotropy ("Anisotropy", Range(0, 1)) = 0
        
        [Foldout(1, 2, 0, 1)]_Cheek ("Cheek_Foldout", float) = 1
        _CheekColor ("Cheek Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _CheekMap ("Cheek Map", 2D) = "white" {}
        _CheekBlend ("Cheek Blend", Range(0, 1)) = 0
        
        [Foldout(1, 2, 0, 1)]_Makeup ("Makeup_Foldout", float) = 1
        [NoScaleOffset] _MakeupMap ("Cheek Map", 2D) = "white" {}
        _MakeupBlend ("Cheek Blend", Range(0, 1)) = 0
        
        [Foldout(1, 2, 0, 1)]_WindParameter ("Wind_Foldout", float) = 1
        [Space(10)]
        [Toggle(_WIND)] _Wind("Wind On/Off", Float) = 0
        [Space(10)]
        [KeywordEnum(Direction, Swing)] _WindType ("Wind Type", Float) = 0
        //_Direction ("Wind Direction", vector) = (0, 0, 0, 0)
        //_WindSpeed ("Wind Speed", Float) = 1
        _WindDensity ("Wind Density", Float) = 1
        _WindNoiseIntensity ("WindNoise Intensity", Range(0, 10)) = 1
        _BendThreshold ("Bend Threshold", Range(0, 1)) = 0
        _BendFalloff ("Bend Falloff", Range(0, 2)) = 1
        [Toggle(_STORM)] _Storm("Storm On/Off", Float) = 0
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_CollisionParameter ("Collision_Foldout", float) = 1
        [Toggle(_COLLISION)] _Collision("Collision On/Off", Float) = 0
        _CollisionStrength ("Collision Strength", Range(0, 1)) = 0
        _CollisionRadius ("Collision Radius", Range(0, 1)) = 0
        
        [Space(10)]
        [Foldout(1, 2, 0, 1)]_SecondParameter ("Second Surface_Foldout", float) = 1
        [Space(10)]
        [Toggle(_SECOND)] _Second("Second Surface On/Off", Float) = 0
        [Space(10)]
        [NoScaleOffset] _SecondBaseMap ("Albedo", 2D) = "white" {}
        [NoScaleOffset] _SecondDMSMap ("DMS", 2D) = "white" {}
        [Space(10)]
        _SecondScale ("Tiling", Range(0, 2)) = 1
        _SecondBendThreshold ("Threshold", range(0, 1)) = 0
        _SecondBendFalloff ("Falloff", range(0, 2)) = 1
        
        [Space(10)]
        [Foldout(1, 2, 0, 1)]_BillboardParameter ("Billboard_Foldout", float) = 1
        [Space(10)]
        [Toggle(_BILLBOARD)] _Billboard("Billboard On/Off", Float) = 0
        
        [Space(10)]
        [Foldout(1, 2, 0, 1)]_Other ("Others_Foldout", float) = 1
        
        [Space(10)]
        [Toggle(_CASTSHADOW)] _CastShadow("Shadow On/Off", Float) = 1
//      [KeywordEnum(CullOff, CullFront, CullBack)] _CullMode ("Cull Mode", Float) = 2
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
            #include "Assets/Plugins/GPUInstancer/Shaders/Include/GPUInstancerInclude.cginc"
        
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomFunctions.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomRP/Shading.hlsl"

            #define MAX_POSITION_COUNT 20
            
            #pragma instancing_options procedural:setupGPUI
            #pragma multi_compile_instancing

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half4 _SpecColor;
                half4 _FresColor;
                half4 _EmissionColor;
                half _Smoothness;
                half _Tiling;
                half _SpecThreshold;
                half _SpecSmooth;
                half _SpecIntensity;
                half _Cutoff;
                half _Metallic;
                half _FresThreshold;
                half _FresSmooth;
                half _FresIntensity;
                half _Hue;
                half _Saturation;
                half _Lightness;
                half _WindDensity;
                half _BendThreshold;
                half _BendFalloff;
                half _WindNoiseIntensity;
                half _SecondScale;
                half _SecondBendThreshold;
                half _SecondBendFalloff;
                half4 _SSSColor;
                half _SSSMaskBlend;
                half _NormalInfluence;
                half _SSSPower;
                half _SSSIntensity;
                half _TangentShift;
                
                half _CollisionStrength;
                half _CollisionRadius;
        
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

                // half4 _HairColor1;
                // half4 _HairColor2;
                half _HairSpecExponent;
                half _HairShadowDistance;
                half _HairShift;
                half _HairMaskBlend;
                half _HairDirection;

                half4 _CheekColor;
                half _CheekBlend;
        
                half _MakeupBlend;
        
                half _AnisoDir;
                half _Anisotropy;
            CBUFFER_END

            CBUFFER_START(GlobalMaterial)
                float4 _ObjectArrayPos[MAX_POSITION_COUNT];
        
                half _WindSpeed;
                float4 _Direction;
                half _Exposure;
                half _ReflectExposure;
                half4 _BackLightColor;
                half _BackLightHeight;
                //float4 _CollisionPos;
                //half _CollisionRadius;
                half4 _WindColor;
        
                half4 _ProjectLightColor;
                half4 _ProjectShadowColor;
                half _ProjectBlend;
                half _ProjectScale;
        
                half4 _RippleColor;
                half _RippleSpeed;
                half _FlowSpeed;
                half _RippleScale;
                half _FlowScale;
                half _RippleBlend;
                half _FlowBlend;
                half _RippleColorBlend;
                half _RainSmoothness;
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


            //图像采样
            TEXTURE2D (_BaseMap);
            SAMPLER (sampler_BaseMap);

            TEXTURE2D (_AOTex);
            SAMPLER (sampler_AOTex);

            TEXTURE2D(_CheekMap);
            SAMPLER (sampler_CheekMap);

            TEXTURE2D (_MakeupMap);
            SAMPLER (sampler_MakeupMap);
 
 
            // TEXTURE2D (_BrushMap);
            // SAMPLER (sampler_BrushMap);
        
            #ifdef _DMS
                TEXTURE2D (_DMSMap);
                SAMPLER (sampler_DMSMap);
            #endif

            #ifdef _SSS
                TEXTURE2D (_SSSMap);
                SAMPLER (sampler_SSSMap);
            #endif

            #ifdef _SECOND
                TEXTURE2D (_SecondBaseMap);
                SAMPLER (sampler_SecondBaseMap);
                TEXTURE2D (_SecondDMSMap);
                SAMPLER (sampler_SecondDMSMap);
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
                TEXTURE2D(_RippleMaskMap);
                SAMPLER(sampler_RippleMaskMap);
            #endif
            
            #ifdef _EMISSION
                TEXTURE2D(_EmissionMap);
                SAMPLER(sampler_EmissionMap);
            #endif

            #ifdef _SHADINGMODE_HAIR
                TEXTURE2D(_HairShiftMap);
                SAMPLER(sampler_HairShiftMap);
            #endif

            #ifdef _SHADINGMODE_ANISOTROPIC
                TEXTURE2D(_AnisoFlowMap);
                SAMPLER(sampler_AnisoFlowMap);
            #endif
        
        ENDHLSL

        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            BlendOp [_BlendOp]
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWriteMode]
            ZTest [_ZTestMode]
            Cull [_CullMode]

            HLSLPROGRAM
            
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            

            //Material Keywords
            #pragma shader_feature _DMS
            #pragma shader_feature _ALPHATEST
            #pragma shader_feature _EMISSION
            #pragma shader_feature _BILLBOARD
            #pragma shader_feature _LIGHT
            #pragma shader_feature _SECOND
            #pragma shader_feature _WIND
            #pragma shader_feature _COLLISION
            #pragma shader_feature _STORM
            #pragma shader_feature _SSS
            #pragma shader_feature _SHADINGMODE_STYLIZED _SHADINGMODE_BASIC _SHADINGMODE_HAIR _SHADINGMODE_ANISOTROPIC
            #pragma shader_feature _CASTSHADOW
            #pragma shader_feature _WINDTYPE_DIRECTION _WINDTYPE_SWING
            #pragma shader_feature _OVERRIDE
            //#pragma shader_feature _CULLMODE_CULLBACK _CULLMODE_CULLFRONT _CULLMODE_CULLOFF
            
			#pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _SHADOWS_SHADOWMASK
            #pragma multi_compile _ _PROJECTOR
            #pragma multi_compile _ _PROJECTORTYPE_TREE _PROJECTORTYPE_CLOUD
            #pragma multi_compile _ _RAIN

            //#pragma multi_compile_fragment _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _SHADOWS_SOFT
            

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float2 uv            : TEXCOORD0;
                float2 uv2           : TEXCOORD1;
                //float2 uv3           : TEXCOORD2;
                float4 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float2 uv            : TEXCOORD0;
                float2 uv2           : TEXCOORD4;
                //float  AO            : TEXCOORD5;
                float4 tangentWS     : TEXCOORD1;
                float4 bitangentWS   : TEXCOORD2;
                float4 normalWS      : TEXCOORD3;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            
            Varyings LitPassVertex(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);

                
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

            DataInput InitializeDataInput(Varyings IN)
            {
                DataInput dataInput = (DataInput)0;

                half4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv * _Tiling);
                
                half3 albedo = albedoAlpha.rgb * _BaseColor.rgb;
                half cheekMask = SAMPLE_TEXTURE2D(_CheekMap, sampler_CheekMap, IN.uv).r;
                albedo = lerp(albedo, _CheekColor.rgb, _CheekBlend * cheekMask);

                half4 makeup = SAMPLE_TEXTURE2D(_MakeupMap, sampler_MakeupMap, IN.uv).rgba;
                half3 makeupColor = makeup.rgb;
                half makeupMask = makeup.a;

                dataInput.albedo = lerp(albedo, makeupColor, makeupMask * _MakeupBlend);
                dataInput.alpha = albedoAlpha.a * _BaseColor.a;
                
                #ifdef _ALPHATEST
                    clip(dataInput.alpha - _Cutoff);
                #endif
                
                dataInput.smoothness = _Smoothness;
                dataInput.metallic = _Metallic;
                dataInput.occlusion = 1;
                dataInput.positionWS = float3(IN.normalWS.w, IN.tangentWS.w, IN.bitangentWS.w);
                dataInput.N = normalize(IN.normalWS.xyz);
                dataInput.normalTS = TransformWorldToTangent(dataInput.N, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                dataInput.shadowCoord = TransformWorldToShadowCoord(dataInput.positionWS);
                dataInput.light = GetMainLight(dataInput.shadowCoord);
                dataInput.L = SafeNormalize(dataInput.light.direction.xyz);
                dataInput.V = GetWorldSpaceNormalizeViewDir(dataInput.positionWS);
                dataInput.exposure = _Exposure;
                dataInput.reflectExposure = _ReflectExposure;
                

                #ifdef _DMS
                    float4 DMS = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, IN.uv * _Tiling).rgba;
                    dataInput.normalTS = normalize(UnpackDerivativeHeight(float3(DMS.xy, 1)));
                    dataInput.N = TransformTangentToWorld(dataInput.normalTS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                    dataInput.N = NormalizeNormalPerVertex(dataInput.N);
                
                    dataInput.smoothness = DMS.a * _Smoothness;
                    dataInput.metallic = DMS.b;
                #endif

                #ifdef _SHADINGMODE_HAIR
                    // dataInput.albedo = lerp(_HairColor2.rgb, _HairColor1.rgb, saturate(albedoAlpha.rgb));
                    half4 hairMap = SAMPLE_TEXTURE2D(_HairShiftMap, sampler_HairShiftMap, IN.uv);
                
                    half hairShift = hairMap.r - 0.5;
                    half hairMask = hairMap.g;
                    dataInput.T = ShiftTangent(IN.bitangentWS.xyz, dataInput.N, hairShift * _HairShift);
                    dataInput.hairSpecExponent = _HairSpecExponent;
                    dataInput.hairSpecMask = hairMask * _HairMaskBlend;
                #endif

                #ifdef _SHADINGMODE_ANISOTROPIC
                    float2 anisoUV = IN.uv;
                    half3 anisoFlow = SAMPLE_TEXTURE2D(_AnisoFlowMap, sampler_AnisoFlowMap, anisoUV).rgb;
                    dataInput.anisotropy = _Anisotropy;
                    SampleAnisoTangent(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz, dataInput.N, anisoFlow, _AnisoDir, dataInput.T, dataInput.B);
                #endif
                
                //色相饱和度亮度
                float hue = Remap(_Hue, float2(0, 100), float2(0, 360)).x;
                dataInput.albedo = Hue(dataInput.albedo, hue);
                dataInput.albedo = Saturation(dataInput.albedo, _Saturation);
                dataInput.albedo *= _Lightness;

                //自发光
                #ifdef _EMISSION
                    dataInput.emissive = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, IN.uv).rgb * _EmissionColor.rgb;
                #endif
                
                //第二层材质混合
                #ifdef _SECOND
                    float2 uvX = dataInput.positionWS.zy;
                    float2 uvY = dataInput.positionWS.xz;
                    float2 uvZ = dataInput.positionWS.xy;
                
                    float3 albedoX = SAMPLE_TEXTURE2D(_SecondBaseMap, sampler_SecondBaseMap, uvX * _SecondScale).rgb;
                    float3 albedoY = SAMPLE_TEXTURE2D(_SecondBaseMap, sampler_SecondBaseMap, uvY * _SecondScale).rgb;
                    float3 albedoZ = SAMPLE_TEXTURE2D(_SecondBaseMap, sampler_SecondBaseMap, uvZ * _SecondScale).rgb;
                
                    float4 DMSX = SAMPLE_TEXTURE2D(_SecondDMSMap,sampler_SecondDMSMap, uvX * _SecondScale).rgba;
                    float4 DMSY = SAMPLE_TEXTURE2D(_SecondDMSMap,sampler_SecondDMSMap, uvY * _SecondScale).rgba;
                    float4 DMSZ = SAMPLE_TEXTURE2D(_SecondDMSMap,sampler_SecondDMSMap, uvZ * _SecondScale).rgba;
                
                    float3 bumpX = normalize(UnpackDerivativeHeight(float3(DMSX.xy, 1)));
                    float3 bumpY = normalize(UnpackDerivativeHeight(float3(DMSY.xy, 1)));
                    float3 bumpZ = normalize(UnpackDerivativeHeight(float3(DMSZ.xy, 1)));

                    //Triplanar Blend
                    float3 blend = TriplanarBlend(IN.normalWS.xyz, 3);

                    float3 albedo2 = albedoX * blend.x + albedoY * blend.y + albedoZ * blend.z;
                    float smoothness2 = (DMSX * blend.x + DMSY * blend.y + DMSZ * blend.z).a * _Smoothness;
                    float metallic2 = (DMSX * blend.x + DMSY * blend.y + DMSZ * blend.z).b * _Metallic;
                    float3 normalWS2 = TriplanarNormal(bumpX, bumpY, bumpZ, IN.normalWS.xyz, blend);
                
                    //Blend
                    float blend2 = smoothstep(_SecondBendThreshold, _SecondBendThreshold + _SecondBendFalloff, IN.uv2.y);
                    dataInput.albedo = lerp(albedo2, dataInput.albedo, blend2);
                    dataInput.smoothness = lerp(smoothness2, dataInput.smoothness, blend2);
                    dataInput.metallic = lerp(metallic2, dataInput.metallic, blend2);
                    dataInput.N = lerp(normalWS2, dataInput.N, blend2);
                    dataInput.normalTS = TransformWorldToTangent(dataInput.N, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                #endif

                #ifdef _CASTSHADOW
                    dataInput.castShadow = 1;
                #endif

                //雨水法线粗糙度
                #ifdef _RAIN
                    float3 upDir = float3(0, 1, 0);
                    float3 downDir = float3(0, -1, 0);
                    float upMask = saturate(dot(dataInput.N, upDir));
                    float downMask = saturate(dot(dataInput.N, downDir));
                    float rippleSpeed = _Time.y * _RippleSpeed;
                    float flowSpeed = _Time.y * _FlowSpeed;

                    float2 rippleUVX = dataInput.positionWS.zy;
                    float2 rippleUVY1 = Flipbook(dataInput.positionWS.xz / _RippleScale, 2, 2, rippleSpeed);
                    float2 rippleUVY2 = Flipbook(dataInput.positionWS.xz / _RippleScale * 1.5, 4, 4, rippleSpeed);
                    float2 rippleUVZ = dataInput.positionWS.xy;

                    float rippleAlpha1 = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, rippleUVY1).b;
                    float rippleAlpha2 = SAMPLE_TEXTURE2D(_RippleMap, sampler_RippleMap, rippleUVY2).b;
                    float ripplesAlpha = (rippleAlpha1 + rippleAlpha2) * upMask;
                
                    float rippleMask = Unity_Voronoi_float(dataInput.positionWS.xz, rippleSpeed * 0.2, 3);
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
                    float3 rippleNormal = TriplanarNormal(rippleBumpX, dataInput.normalTS, rippleBumpZ, IN.normalWS.xyz, rippleBlend);
                    float3 rippleNormalTS = TransformWorldToTangent(rippleNormal, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                    rippleNormalTS = NormalBlend(rippleNormalTS, dataInput.normalTS);
                    rippleNormal = TransformTangentToWorld(rippleNormalTS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                
                    dataInput.N = lerp(rippleNormal, dataInput.N, downMask);
                    dataInput.smoothness = dataInput.smoothness + _RainSmoothness;
                    dataInput.albedo = lerp(dataInput.albedo, _RippleColor.rgb, ripplesAlpha * _RippleColorBlend);
                #endif

                //广告牌
                #ifdef _BILLBOARD
                    dataInput.smoothness = 0.1;
                    dataInput.N = dataInput.L;
                #endif
                
                dataInput.customSH = custom_SH;
                
                // half3 brushX = SAMPLE_TEXTURE2D(_BrushMap, sampler_BrushMap, uvX * 1 / _GlobalBrushScale).rgb;
                // half3 brushY = SAMPLE_TEXTURE2D(_BrushMap, sampler_BrushMap, uvY * 1 / _GlobalBrushScale).rgb;
                // half3 brushZ = SAMPLE_TEXTURE2D(_BrushMap, sampler_BrushMap, uvZ * 1 / _GlobalBrushScale).rgb;

                // float3 blendBrush = TriplanarBlend(IN.normalWS.xyz, 3);
                //
                // dataInput.brush = brushX * blendBrush.x + brushY * blendBrush.y + brushZ * blendBrush.z;
                //
                // dataInput.brushStrength = half3(_GlobalBorderBrushStrength, _GlobalShadowBrushStrength, _GlobalReflectBrushStrength);

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

                return dataInput;
            }
            
            half4 LitPassFragment(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                DataInput dataInput = InitializeDataInput(IN);

                //颜色输出
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
                
                 //SSS
                 #ifdef _SSS
                     float3 viewDirWS = GetWorldSpaceNormalizeViewDir(dataInput.positionWS);
                     float subsurface = max(dot(viewDirWS, -normalize(dataInput.N * _NormalInfluence + dataInput.L)), 0.001);
                     float subsurfaceMask = lerp(1, SAMPLE_TEXTURE2D(_SSSMap, sampler_SSSMap, IN.uv).r, _SSSMaskBlend);
                     half3 SSSColor = _SSSColor.rgb * pow(subsurface, _SSSPower) * _SSSIntensity * subsurfaceMask;
                     color += SSSColor;
                 #endif
                
                
                 //背光
                 #ifdef _BACKLIGHT
                     float3 backLightDir = float3(-dataInput.L.x, _BackLightHeight, -dataInput.L.z);
                     float3 backLambert = saturate(dot(backLightDir, IN.normalWS.xyz));
                     color = lerp(color, color * _BackLightColor.rgb, backLambert);
                 #endif
                
                 //风浪颜色
                 #ifdef _STORM
                     half time = _Time.y * _WindSpeed * 0.5;
                     half noise = SimpleNoise(dataInput.positionWS.xz - time * _Direction.xy, _WindDensity * 0.5).r;
                     color = lerp(color, color * _WindColor.rgb, noise * IN.uv2.y);
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
                     
                     float lightMaskNoise = SimpleNoise(lightMaskUV, 10);
                     float lightMask = SAMPLE_TEXTURE2D(_projectMaskMap, sampler_projectMaskMap, lightMaskUV).r;
                     float NdotL = max(saturate(dot(dataInput.N, dataInput.L)), 0.001);
                     half3 lightMaskColor = lerp(_ProjectShadowColor.rgb, _ProjectLightColor.rgb, lightMask * NdotL * dataInput.light.shadowAttenuation * lightMaskNoise);
                
                     color = color * (lightMaskColor + _ProjectBlend);
                 #endif
                
                // color = Blend_Overlay(color, IN.AO, _AOBlend);
                // float AO = smoothstep(0, _AORange, IN.AO);
                // color = lerp(color, color * AO, _AOBlend);

                //最终输出
                return half4(color, dataInput.alpha);
                //return color;
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
			#pragma shader_feature _COLLISION

			// Universal Pipeline Keywords
			#pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
			
			#pragma shader_feature _WINDTYPE_DIRECTION _WINDTYPE_SWING

            #pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float4 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
                float2 uv            : TEXCOORD0;
                float2 uv2           : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float3 normalWS      : TEXCOORD3;
                float2 uv            : TEXCOORD0; 
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings ShadowPassVertex(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);   

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);

                #ifdef _BILLBOARD
                    float3 center = float3(0, 0, 0);
                    float3 viewer = TransformWorldToObject(GetCameraPositionWS());
                    float3 normalDir = viewer - center;
                    normalDir.y = 0;
                    normalDir = normalize(normalDir);

                    float3 upDir = float3(0, 1, 0);
                    float3 rightDir = normalize(cross(upDir, normalDir));
                    upDir = normalize(cross(normalDir, rightDir));

                    float3 centerOffset = IN.positionOS.xyz - center;
                    float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset.z;

                    positionWS = TransformObjectToWorld(localPos);
                #endif

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
                
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _MainLightPosition.xyz));
                
                OUT.positionCS = positionCS;
                OUT.normalWS = normalWS;
                OUT.uv = IN.uv;
                
                return OUT;
            }

            float4 ShadowPassFragment(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                float alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv).a;
                #ifdef _ALPHATEST
                    clip(alpha - _Cutoff);
                #endif
                
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
            #pragma shader_feature _BILLBOARD
            #pragma shader_feature _WIND
			#pragma shader_feature _COLLISION

			#pragma shader_feature _WINDTYPE_DIRECTION _WINDTYPE_SWING

			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float2 uv            : TEXCOORD0;
                float2 uv2           : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float2 uv            : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings DepthOnlyVertex(Attributes IN)
            {
                Varyings OUT;

                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);   

                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);

                #ifdef _BILLBOARD
                    float3 center = float3(0, 0, 0);
                    float3 viewer = TransformWorldToObject(GetCameraPositionWS());
                    float3 normalDir = viewer - center;
                    normalDir.y = 0;
                    normalDir = normalize(normalDir);

                    float3 upDir = float3(0, 1, 0);
                    float3 rightDir = normalize(cross(upDir, normalDir));
                    upDir = normalize(cross(normalDir, rightDir));

                    float3 centerOffset = IN.positionOS.xyz - center;
                    float3 localPos = center + rightDir * centerOffset.x + upDir * centerOffset.y + normalDir * centerOffset.z;

                    positionWS = TransformObjectToWorld(localPos);
                #endif

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
                
                OUT.positionCS = TransformWorldToHClip(positionWS);
                OUT.uv = IN.uv;
                
                return OUT;
            }

            float4 DepthOnlyFragment(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                float alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv).a;
                #ifdef _ALPHATEST
                    clip(alpha - _Cutoff);
                #endif
                
                return half4(0, 0, 0, alpha);
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : TEXCOORD1;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            
            Varyings DepthNormalsVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output); 

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
                UNITY_SETUP_INSTANCE_ID(input);
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
