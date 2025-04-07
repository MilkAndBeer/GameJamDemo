Shader "Custom/StylizedShader"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_Mod ("Shading Mode_Foldout", float) = 1
        [KeywordEnum(Stylized, Basic, Hair)] _ShadingMode ("Shading Mode", Float) = 0
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
        [Toggle(_TRIPLANAR)] _TRIPLANAR ("Triplanar On/Off", Float) = 0
        [Space(10)]
        [NoScaleOffset] _BaseMap ("Albedo Map", 2D) = "white" {}
        [NoScaleOffset] _DMSMap ("DMS Map", 2D) = "white" {}
        
        [Space(10)]
        _Smoothness ("Smoothness", Range(0, 1)) = 1
        [Space(10)]
        _TriBlend ("Triplanar Blend", Range(0, 10)) = 3
        _Thickness ("Thickness", Range(0, 1)) = 0
        _TilingX ("Tiling X", Range(0, 3)) = 1
        _TilingY ("Tiling Y", Range(0, 3)) = 1
        _TilingOffsetX ("Tiling Offset X", Range(-1, 1)) = 0
        _TilingOffsetY ("Tiling Offset Y", Range(-1, 1)) = 0
        
        [Space(10)]
        [Toggle(_ALPHATEST_ON)] _EnableAlphaTest("Enable Alpha Cutoff", Float) = 0.0
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Space(10)]
        
        [Space(10)]
        [Foldout(1, 2, 0, 1)]_TopMapParameter ("Top_Foldout", float) = 1
        [Space(10)]
        [Toggle(_TOPMAP)] _TopMap("TopMap", Float) = 0
        [Space(10)]
        [NoScaleOffset] _TopBaseMap ("Top Albedo", 2D) = "white"{}
        [NoScaleOffset] _TopDMSMap ("Top DMS", 2D) = "white"{}
        [Space(10)]
        _TopTiling ("Tiling", Range(0, 2)) = 1
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
        
//        [Space(10)]
//        [Foldout(1, 2, 0, 1)]_SecondParameter ("Second Surface_Foldout", float) = 1
//        [Space(10)]
//        [Toggle(_SECOND)] _Second("Second Surface On/Off", Float) = 0
//        [Space(10)]
//        [NoScaleOffset] _SecondBaseMap ("Albedo", 2D) = "white" {}
//        [NoScaleOffset] _SecondDMSMap ("DMS", 2D) = "white" {}
//        [Space(10)]
//        _SecondScale ("Tiling", Range(0, 2)) = 1
//        _SecondBendThreshold ("Threshold", range(0, 1)) = 0
//        _SecondBendFalloff ("Falloff", range(0, 2)) = 1
        
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
            #include "Assets/Plugins/GPUInstancer/Shaders/Include/GPUInstancerInclude.cginc"

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
        
                half _TriBlend;
                half _Thickness;
                half _TilingX;
                half _TilingY;
                half _TilingOffsetX;
                half _TilingOffsetY;
        
                half _SpecThreshold;
                half _SpecSmooth;
                half _SpecIntensity;
                half _Cutoff;
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

                half _TopTiling;
        
                // half _SecondScale;
                // half _SecondBendThreshold;
                // half _SecondBendFalloff;
        
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
        
            TEXTURE2D (_DMSMap);
            SAMPLER (sampler_DMSMap);

            #ifdef _SSS
                TEXTURE2D (_SSSMap);
                SAMPLER (sampler_SSSMap);
            #endif

            #ifdef _TOPMAP
                TEXTURE2D(_TopBaseMap);
                SAMPLER(sampler_TopBaseMap);
                TEXTURE2D(_TopDMSMap);
                SAMPLER(sampler_TopDMSMap);
            #endif


            // #ifdef _SECOND
            //     TEXTURE2D (_SecondBaseMap);
            //     SAMPLER (sampler_SecondBaseMap);
            //     TEXTURE2D (_SecondDMSMap);
            //     SAMPLER (sampler_SecondDMSMap);
            // #endif

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
            #pragma shader_feature _TRIPLANAR
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _BILLBOARD
            #pragma shader_feature _LIGHT
            #pragma shader_feature _TOPMAP
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

            
            //#include "Assets/ARTs/TA/Resources/CustomRP/Functions.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomSurfaceInput.hlsl"
            
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
                
                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 8);
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
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

            InputData InitializeInputData(Varyings IN, half3 normalWS)
            {
                InputData inputData = (InputData)0;

                float3 positionWS = float3(IN.normalWS.w, IN.tangentWS.w, IN.bitangentWS.w);
                inputData.positionWS = positionWS;
                inputData.positionCS = IN.positionCS;
                inputData.viewDirectionWS = GetWorldSpaceNormalizeViewDir(positionWS);
                
                // half3 normalWS = TransformTangentToWorld(normalTS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                // normalWS = NormalizeNormalPerVertex(normalWS);

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
                surfaceData.normalWS = normalWS;
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
            
            half4 LitPassFragment(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                SurfaceData surfaceData = InitializeSurfaceData(IN);
                InputData inputData = InitializeInputData(IN, surfaceData.normalWS);

                
                //颜色输出
                #ifdef _SHADINGMODE_STYLIZED
                    half4 color = UniversalFragmentStylizedPBR(inputData, surfaceData);
                
                #elif _SHADINGMODE_BASIC
                    half4 color = UniversalFragmentPBR(inputData, surfaceData);
                    
                #elif _SHADINGMODE_HAIR
                    half4 color = UniversalFragmentHairPBR(inputData, surfaceData);

                #endif

                //最终输出
                return color;
            }

            ENDHLSL
        }

        
        Pass
        {
            Name "GBUFFER"
            Tags { "LightMode" = "UniversalGBuffer" }

            BlendOp [_BlendOp]
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWriteMode]
            ZTest [_ZTestMode]
            Cull [_CullMode]

            HLSLPROGRAM
            
            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment
            
            //Material Keywords
            #pragma shader_feature _TRIPLANAR
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _BILLBOARD
            #pragma shader_feature _LIGHT
            // #pragma shader_feature _SECOND
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
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

            //#pragma multi_compile_fragment _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _SHADOWS_SOFT

            
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomSurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
            
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
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            
            Varyings LitGBufferPassVertex(Attributes IN)
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

                return inputData;
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

                #ifdef _SHADINGMODE_HAIR
                    half4 hairMap = SAMPLE_TEXTURE2D(_HairShiftMap, sampler_HairShiftMap, IN.uv);
                    half hairShift = hairMap.r - 0.5;
                    half hairMask = hairMap.g;
                    surfaceData.tangentWS = ShiftTangent(IN.bitangentWS.xyz, normalWS, hairShift * _HairShift);
                    surfaceData.hairSpecExponent = _HairSpecExponent;
                    surfaceData.hairSpecMask = hairMask * _HairMaskBlend;
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
            
            FragmentOutput LitGBufferPassFragment(Varyings IN)
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                SurfaceData surfaceData = InitializeSurfaceData(IN);
                InputData inputData = InitializeInputData(IN, surfaceData.normalTS);

                BRDFData brdfData;
                InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

                Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
                MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
                
                half3 color = StylizedGlobalIllumination(brdfData, surfaceData, inputData.bakedGI, surfaceData.occlusion, inputData.positionWS,
                                                        inputData.normalWS, inputData.viewDirectionWS, saturate(mainLight.direction));
                
                //颜色输出
                #ifdef _SHADINGMODE_STYLIZED
                    FragmentOutput output = BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color, surfaceData.occlusion);
                
                #elif _SHADINGMODE_BASIC
                    FragmentOutput output = BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color, surfaceData.occlusion);
                    
                #elif _SHADINGMODE_HAIR
                    FragmentOutput output = BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color, surfaceData.occlusion);

                #endif

                //最终输出
                return output;
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
			
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"
			
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

			//#include "Assets/ARTs/TA/Resources/CustomRP/Functions.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"
            //#include "Assets/ARTs/TA/Resources/CustomRP/CustomSurfaceInput.hlsl"

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
            
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"
            //#include "Assets/ARTs/TA/Resources/CustomRP/CustomSurfaceInput.hlsl"
            
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
    //CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShader"
    CustomEditor "EBGame.SimpleShaderGUI"
}
