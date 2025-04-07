Shader "Custom/WaterShader"
{
    Properties 
    {
        [Foldout(1, 2, 0, 1)]_Basic ("Basic_Foldout", float) = 1
        [Space(10)]
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _ShallowColor ("Shallow Color", Color) = (1, 1, 1, 1)
        _WaveColor ("Wave Color", Color) = (1, 1, 1, 1)
        [Space(10)]
        _BackBaseColor ("Back Base Color", Color) = (1, 1, 1, 1)
        _BackDeepColor ("Back Deep Color", Color) = (1, 1, 1, 1)
        [Space(10)]
        
        _Blend ("Triplanner Blend", Float) = 3
        _DepthIntensity ("Depth Intensity", Range(0, 1)) = 1
        _DepthFalloff ("Depth Falloff", Range(0, 5)) = 1
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Fresnel ("Fresnel", Range(0, 3)) = 1
        _IOR ("IOR", Float) = 1
        _Thickness ("Thickness", Range(0, 1)) = 0
        [Space(20)]
        
        [Foldout(1, 2, 0, 1)]_Normal ("Normal_Foldout", float) = 1
        [Space(10)]
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalIntensity ("Normal Intensity", Range(0, 3)) = 1
        _NormalScale ("Normal Scale", Range(0, 10)) = 1
        _NormalSpeed ("Normal Speed", Range(0, 1)) = 0.5
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Edge ("Edge_Foldout", float) = 1
        [Space(10)]
        _EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeIntensity ("Edge Intensity", Range(0, 1)) = 1
        _EdgeDistance ("Edge Distance", Range(0, 1)) = 1
        _EdgeFalloff ("Edge Falloff", Range(0, 1)) = 1
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Offset ("Offset_Foldout", float) = 1
        [Space(10)]
        _OffsetFrequency ("Offset Frequency", Range(0, 1)) = 1
        _OffsetLength ("Offset Frequency", Range(0, 10)) = 1
        _OffsetMagnitude ("Offset Magnitude", Range(0, 1)) = 1
        [Space(10)]

        [Foldout(1, 2, 0, 1)]_Wave ("Wave_Foldout", float) = 1
        [Space(10)]
        [NoScaleOffset] _WaveMap ("Wave Map", 2D) = "white" {}
        _WaveIntensity ("Wave Intensity", Range(0, 1)) = 1
        _WaveScale ("Wave Scale", Range(0, 10)) = 0.5
        _WaveSpeed ("Wave Speed", Range(0, 1)) = 0.5
        [Space(20)]

        [Foldout(1, 2, 0, 1)]_Distorted ("Distorted_Foldout", float) = 1
        [Space(20)]
        [NoScaleOffset] _DistortionMap ("Distortion Map", 2D) = "white" {}
        _DistortionIntensity ("Distortion Intensity", Range(0, 1)) = 1
        _DistortionScale ("Distortion Scale", Range(0, 20)) = 0.5
        _DistortionSpeed ("Distortion Speed", Range(0, 1)) = 0.5
        [Space(20)]

        [Foldout(1, 2, 0, 1)]_Foam ("Foam_Foldout", float) = 1
        [Space(20)]
        _FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
        _FoamThreshold ("Foam Threshold", Range(0, 2)) = 0
        _FoamSmooth ("Foam Smooth", Range(0, 2)) = 1
        _FoamIntensity ("Foam Intensity", Range(0, 1)) = 1
        [Space(10)]
        
        [Foldout(2, 3, 0, 1)]_TopFoam ("TopFoam_Foldout", float) = 1
        [NoScaleOffset] _TopFoamMap ("Top Foam Map", 2D) = "white" {}
        [Space(10)]
        _TopFoamScale ("Top Foam Scale", Range(0, 10)) = 1
        _TopFoamSpeed ("Top Foam Speed", Range(0, 1)) = 0.5
        [Space(10)]
        [NoScaleOffset] _TopNoiseMap ("Top Noise Map", 2D) = "white" {}
        _TopNoiseScale ("Top Noise Scale", Range(0, 10)) = 1
        _TopNoiseSpeed ("Top Noise Speed", Range(0, 1)) = 0.5
        _TopNoiseIntensity ("Top Noise Intensity", Range(0, 1)) = 1
        
        [Space(20)]
        [Foldout(2, 3, 0, 1)]_FallFoam ("FallFoam_Foldout", float) = 1
        [NoScaleOffset] _FallFoamMap ("Fall Foam Map", 2D) = "white" {}
        [Space(10)]
        _FallFoamScale ("Fall Foam Scale", Range(0, 10)) = 1
        _FallFoamSpeed ("Fall Foam Speed", Range(0, 1)) = 0.5
        [Space(10)]
        [NoScaleOffset] _FallNoiseMap ("Fall Noise Map", 2D) = "white" {}
        _FallNoiseScale ("Fall Noise Scale", Range(0, 10)) = 1
        _FallNoiseSpeed ("Fall Noise Speed", Range(0, 1)) = 0.5
        _FallNoiseIntensity ("Fall Noise Intensity", Range(0, 1)) = 1
        
        [Space(20)]
        [Foldout(2, 3, 0, 1)]_GeoFoam ("GeoFoam_Foldout", float) = 1
        _GeoDistance ("Geo Distance", Range(0, 1)) = 1
        _GeoFalloff ("Geo Falloff", Range(0, 2)) = 1
        _GeoFoamScale ("Geo Foam Scale", Range(0, 10)) = 1
        _GeoFoamSpeed ("Geo Foam Speed", Range(0, 1)) = 1
        _GeoNoiseScale ("Geo Noise Scale", Range(0, 10)) = 1
        _GeoNoiseIntensity ("Geo Noise Intensity", Range(0, 1)) = 1

        [Space(20)]
        [Foldout(1, 2, 0, 1)]_Caustics ("Caustics_Foldout", float) = 1
        [Space(10)]
        _CausticsColor ("Caustics Color", Color) = (1, 1, 1, 1)
        _SplitRGB ("Split RGB", Range(0, 0.1)) = 0.05
        [Space(10)]
        [NoScaleOffset] _CausticsMap ("Caustics Map", 2D) = "white"{}
        _CausticsIntensity ("Caustics Intensity", Range(0, 20)) = 1
        _CausticsDistance ("Caustics Distance", Range(0, 5)) = 1
        _CausticsFalloff ("Caustics Falloff", Range(0, 5)) = 1
        _CausticsScale ("Caustics Scale", Range(0, 10)) = 1
        _CausticsSpeed ("Caustics Speed", Range(0, 1)) = 0.5
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Stylized ("Stylized_Foldout", float) = 1
        [Space(10)]
        [Toggle(_OVERRIDE)] _Override("Override On/Off", Float) = 0
        
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
        _SpecIntensity ("Specular Intensity", Range(0, 50)) = 1
        _SpecThreshold ("Specular Threshold", Range(0, 1)) = 0.5
        _SpecSmooth ("Specular Smooth", Range(0, 1)) = 0.5
        
        _FresColor ("Fresnel Color", Color) = (1, 1, 1, 1)
        _FresIntensity ("Fresnel Intensity", Range(0, 50)) = 1
        _FresThreshold ("Fresnel Threshold", Range(0, 1)) = 0.5
        _FresSmooth ("Fresnel Smooth", Range(0, 1)) = 0.5
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Other ("其他属性_Foldout", float) = 1
    }
    
    Subshader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "RenderType" = "Opaque"
            "Queue" = "Transparent"
        }
        
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Plugins/GPUInstancer/Shaders/Include/GPUInstancerInclude.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "CustomRP/CustomFunctions.hlsl"

            #define MAX_POSITION_COUNT 20
        
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _ShallowColor;
                half4 _BackBaseColor;
                half4 _BackDeepColor;
        
                float _Blend;
                float _DepthIntensity;
                float _DepthFalloff;
                float _Smoothness;
                half _Fresnel;
                half _IOR;
                half _Thickness;
        
                half _OffsetFrequency;
                half _OffsetLength;
                half _OffsetMagnitude;

                half _NormalIntensity;
                half _NormalScale;
                half _NormalSpeed;

                half4 _EdgeColor;
                half _EdgeIntensity;
                half _EdgeDistance;
                half _EdgeFalloff;

                half4 _WaveColor;
                half _WaveScale;
                half _WaveSpeed;
                half _WaveIntensity;
        
                half _DistortionScale;
                half _DistortionSpeed;
                half _DistortionIntensity;
        
                half4 _FoamColor;
                half _FoamThreshold;
                half _FoamSmooth;
                half _FoamIntensity;
        
                half _TopFoamScale;
                half _TopFoamSpeed;

                half _TopNoiseScale;
                half _TopNoiseSpeed;
                half _TopNoiseIntensity;

                half _FallFoamScale;
                half _FallFoamSpeed;

                half _FallNoiseScale;
                half _FallNoiseSpeed;
                half _FallNoiseIntensity;

                half _GeoDistance;
                half _GeoFalloff;
                half _GeoFoamScale;
                half _GeoFoamSpeed;
                half _GeoNoiseScale;
                half _GeoNoiseIntensity;

                half4 _CausticsColor;
                half _SplitRGB;
                half _CausticsDistance;
                half _CausticsFalloff;
                half _CausticsIntensity;
                half _CausticsScale;
                half _CausticsSpeed;

                half4 _BorderColor;
                half _BorderThreshold;
                half _BorderSmooth;
                half4 _ShadowColor;
                half _ShadowThreshold;
                half _ShadowSmooth;
                half4 _ReflectColor;
                half _ReflectThreshold;
                half _ReflectSmooth;
                half4 _FresColor;
                half _FresThreshold;
                half _FresSmooth;
                half _FresIntensity;
                half4 _SpecColor;
                half _SpecThreshold;
                half _SpecSmooth;
                half _SpecIntensity;
            CBUFFER_END

            CBUFFER_START(GlobalMaterial)
                float4 _ObjectArrayPos[MAX_POSITION_COUNT];
                half _Exposure;
                half _ReflectExposure;

                half _DirLightIntensity;
        
                half4 _ProjectLightColor;
                half4 _ProjectShadowColor;
                half _ProjectBlend;
                half _ProjectScale;
        
                half _WindSpeed;
                half4 _Shadow;
                half4 _RippleColor;
                half _RippleSpeed;
                half _FlowSpeed;
                half _RippleScale;
                half _FlowScale;
                half _RippleBlend;
                half _FlowBlend;
                half _RippleColorBlend;
                half _FogBlend;
                half _FogFalloff;
                half _FogSpeed;
                half _FogNoiseScale;
                half4 _FogColor;
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

        //Sample Textures
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
        
            TEXTURE2D(_WaveMap);
            SAMPLER(sampler_WaveMap;)

            TEXTURE2D(_DistortionMap);
            SAMPLER(sampler_DistortionMap);

            TEXTURE2D(_TopFoamMap);
            SAMPLER(sampler_TopFoamMap);

            TEXTURE2D(_TopNoiseMap);
            SAMPLER(sampler_TopNoiseMap;)

            TEXTURE2D(_FallFoamMap);
            SAMPLER(sampler_FallFoamMap);

            TEXTURE2D(_FallNoiseMap);
            SAMPLER(sampler_FallNoiseMap;)
        
            TEXTURE2D(_CausticsMap);
            SAMPLER(sampler_CausticsMap);

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
        
        ENDHLSL
        
        Pass
        {
            Name "Front"
            Tags { "LightMode" = "UniversalForward" }

            ZWrite On
            Cull Back
            
            HLSLPROGRAM

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            //Material Keywords
            #pragma shader_feature _OVERRIDE
            
            #pragma multi_compile _ _PROJECTOR
            #pragma multi_compile _ _RAIN
            
			#pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _SHADOWS_SOFT
			#pragma multi_compile _SHADOWS_SHADOWMASK
            #pragma multi_compile _ _PROJECTOR
            #pragma multi_compile _ _PROJECTORTYPE_TREE _PROJECTORTYPE_CLOUD

            #pragma multi_compile_instancing

            #include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomSurfaceInput.hlsl"

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float2 uv            : TEXCOORD0;
                float4 color         : COLOR;
                float4 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float2 uv            : TEXCOORD0;
                float4 tangentWS     : TEXCOORD1;
                float4 bitangentWS   : TEXCOORD2;
                float4 normalWS      : TEXCOORD3;
                float4 positionSS    : TEXCOORD4;
                float  eyeDepth      : TEXCOORD5;
                float4 color         : COLOR;
            };

            Varyings LitPassVertex(Attributes IN)
            {
                Varyings OUT;
                
                float3 normal = normalize(IN.normalOS.xyz);
                float3 positionOS = IN.positionOS.xyz;
                positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
                
                float2 uv = TransformObjectToWorld(positionOS.xyz).xz;
                float waveOffset = _Time.y * _OffsetFrequency;
                float height = SimpleNoise(uv + waveOffset, _OffsetLength).r;
                height = Remap(height, float2(0, 1), float2(-1, 1)).r;
                float3 offset = height * _OffsetMagnitude * 0.1;

                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS.xyz + offset.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz, IN.tangentOS);

                OUT.positionCS = positionInputs.positionCS;
                float3 positionWS = positionInputs.positionWS;
                OUT.positionSS = ComputeScreenPos(positionInputs.positionCS);
                OUT.eyeDepth = -positionInputs.positionVS.z;

                OUT.normalWS = float4(normalInputs.normalWS, positionWS.x);
                OUT.tangentWS = float4(normalInputs.tangentWS, positionWS.y);
                OUT.bitangentWS = float4(normalInputs.bitangentWS, positionWS.z);
                
                OUT.uv = IN.uv;
                OUT.color = IN.color;
                
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

                return inputData;
            }

            SurfaceData InitializeSurfaceData(Varyings IN)
            {
                SurfaceData surfaceData = (SurfaceData)0;

                float3 positionWS = float3(IN.normalWS.w, IN.tangentWS.w, IN.bitangentWS.w);
                float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                float3 lightDir = normalize(mainLight.direction);
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                float2 uv = IN.positionSS.xy / IN.positionSS.w;

                float upMask = saturate(dot(half3(0, 1, 0), IN.normalWS));

                //Geo
                float geo = 0;
                for(int i = 0; i < MAX_POSITION_COUNT; i++)
                {
                    float distTemp = 1 - saturate(distance(_ObjectArrayPos[i].xyz, positionWS.xyz) * 0.5);
                    distTemp = smoothstep(_GeoDistance, _GeoDistance + _GeoFalloff, distTemp) * _ObjectArrayPos[i].w;
                    
                    geo += distTemp;
                }

                //Triplanar UVs
                float2 uvX = positionWS.zy;
                float2 uvY = positionWS.xz;
                float2 uvZ = positionWS.xy;

                 //Depth
                float sceneDepth = LinearEyeDepth(SampleSceneDepth(uv), _ZBufferParams);
                float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(IN.positionSS.z);
                float depthDifference = sceneDepth - surfaceDepth;
                float depth = saturate(depthDifference / _DepthFalloff) * _DepthIntensity;
                float edge = DepthFade(sceneDepth, IN.positionSS.w, _EdgeDistance, _EdgeFalloff) * _EdgeIntensity;
                //float causticsDepth = DepthFade(sceneDepth, IN.positionSS.w, _CausticsDistance, _CausticsFalloff) * _EdgeIntensity;

                //Time
                float waveSpeed = _Time.y * _WaveSpeed;
                float distortionSpeed = _Time.y * _DistortionSpeed;
                float normalSpeed = _Time.y * _NormalSpeed;
                float topFoamSpeed = _Time.y * _TopFoamSpeed;
                float topNoiseSpeed = _Time.y * _TopNoiseSpeed;
                float fallFoamSpeed = _Time.y * _FallFoamSpeed;
                float fallNoiseSpeed = _Time.y * _FallNoiseSpeed;
                float geoFoamSpeed = _Time.y * _GeoFoamSpeed;

                //Distorted
                float distortion1 = SAMPLE_TEXTURE2D(_DistortionMap, sampler_DistortionMap, uvY * (1 / _DistortionScale) + distortionSpeed).r;
                float distortion2 = SAMPLE_TEXTURE2D(_DistortionMap, sampler_DistortionMap, -uvY * (1 / _DistortionScale * 0.5) + distortionSpeed * 0.8).r;
                float distortion = saturate(distortion1 + distortion2) * _DistortionIntensity;

                //Wave
                float wave = saturate(SAMPLE_TEXTURE2D(_WaveMap, sampler_WaveMap, -uvY * (1 / _WaveScale) + waveSpeed - distortion)).r * _WaveIntensity;
                
                //Normal
                float3 normal1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvY * (1 / _NormalScale) + normalSpeed), _NormalIntensity);
                float3 normal2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, -uvY * (1 / _NormalScale * 0.6)  + normalSpeed * 0.8), _NormalIntensity * 0.8);
                float3 normal = normalize(normal1 + normal2);
                float3 blend = TriplanarBlend(IN.normalWS.xyz, _Blend);
                float3 normalTS = NormalizeNormalPerVertex(normal * blend.x + normal * blend.y + normal * blend.z);
                float3 normalWS = TriplanarNormal(normal, normal, normal, IN.normalWS.xyz, blend);
                
                //Foam
                float foamMask = smoothstep(_FoamThreshold, _FoamThreshold + _FoamSmooth, IN.color.x);

                float noiseY = SAMPLE_TEXTURE2D(_TopNoiseMap, sampler_TopNoiseMap, uvY * (1 / _TopNoiseScale) + topNoiseSpeed).r * _TopNoiseIntensity;
                float foamY = SAMPLE_TEXTURE2D(_TopFoamMap, sampler_TopFoamMap, IN.uv.yy * (1 / _TopFoamScale) + topFoamSpeed - noiseY).r;

                float geoNoise = SAMPLE_TEXTURE2D(_TopNoiseMap, sampler_TopNoiseMap, uvY * (1 / _GeoNoiseScale)).r * _GeoNoiseIntensity;
                float geoFoam = SAMPLE_TEXTURE2D(_TopFoamMap, sampler_TopFoamMap, float2(geo, geo) * (1 / _GeoFoamScale) + geoFoamSpeed - geoNoise).r;
                geoFoam = step(geoFoam, geo) * geo * upMask;
                
                float noiseX = SAMPLE_TEXTURE2D(_FallNoiseMap, sampler_FallNoiseMap, float2(uvX.x * (1 / _FallNoiseScale), uvX.y * (1 / _FallNoiseScale) + fallNoiseSpeed)).r * _FallNoiseIntensity;
                float foamX = SAMPLE_TEXTURE2D(_FallFoamMap, sampler_FallFoamMap, float2(uvX.x * (1 / _FallFoamScale), uvX.y * (1 / _FallFoamScale) + fallFoamSpeed - noiseX)).r;

                float noiseZ = SAMPLE_TEXTURE2D(_FallNoiseMap, sampler_FallNoiseMap, float2(uvZ.x * (1 / _FallNoiseScale), uvZ.y * (1 / _FallNoiseScale) + fallNoiseSpeed)).r * _FallNoiseIntensity;
                float foamZ = SAMPLE_TEXTURE2D(_FallFoamMap, sampler_FallFoamMap, float2(uvZ.x * (1 / _FallFoamScale), uvZ.y * (1 / _FallFoamScale) + fallFoamSpeed - noiseZ)).r;
                
                float foam = foamX * blend.x + foamY * blend.y + foamZ * blend.z;
                foam = step(foam, foamMask) * _FoamIntensity * foamMask + geoFoam;

                //Caustics
                float3 cameraDir = -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz);
                //float3 cameraDir = GetWorldSpaceViewDir(positionWS);
                float3 cameraPos = _WorldSpaceCameraPos;
                float3 causticsPos = viewDirWS / dot(viewDirWS, cameraDir) * sceneDepth + cameraPos;
                float NoL = saturate(dot(normalWS, lightDir));
                float shadow = lerp(0, 1, mainLight.shadowAttenuation * NoL);
                
                float3 tangent = normalize(cross(float3(lightDir.x, 0, lightDir.z), lightDir));
                float3 bitangent = normalize(cross(tangent, lightDir));
                
                float3 positionLS = mul(float3x3(tangent, bitangent, -lightDir), causticsPos);
                float2 causticsUV = positionLS.xy;
                
                float causticsSpeed = _Time.y * _CausticsSpeed;
                float causticsScale = 1 / _CausticsScale;
                
                half3 caustics1 = ColorSplit(_CausticsMap, sampler_CausticsMap, causticsUV, causticsScale, causticsSpeed, _SplitRGB);
                half3 caustics2 = ColorSplit(_CausticsMap, sampler_CausticsMap, -causticsUV, causticsScale, causticsSpeed, _SplitRGB);
                
                half3 caustics = min(caustics1, caustics2) * _CausticsColor.rgb * _DirLightIntensity * _CausticsIntensity;
                half causticsMask = shadow;

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
                
                //Refraction
                float2 uvOffset = Remap(wave, half2(0, 1), half2(-1, 1)).rg * _IOR;
                float2 refractionUV = (IN.positionSS.xy + uvOffset) / IN.positionSS.w;
                half3 refractionColor = SampleSceneColor(refractionUV);

                //Color
                half3 albedo = lerp(_ShallowColor.rgb, _BaseColor.rgb, depth);
                albedo = lerp(albedo, _WaveColor.rgb, wave);
                albedo = lerp(albedo, _EdgeColor.rgb, edge);
                albedo = lerp(albedo, _FoamColor.rgb, foam);

                //Emissive
                surfaceData.emission = lerp(refractionColor, 0, depth) + caustics * causticsMask;

                surfaceData.albedo = albedo;
                surfaceData.alpha = 1;
                surfaceData.normalTS = normalTS;
                surfaceData.smoothness = _Smoothness;
                surfaceData.metallic = 0;
                surfaceData.occlusion = 1;

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
                SurfaceData surfaceData = InitializeSurfaceData(IN);
                InputData inputData = InitializeInputData(IN, surfaceData.normalTS);

                half4 color = UniversalFragmentStylizedPBR(inputData, surfaceData);
                
                
                //Output
                return color;
            }

            ENDHLSL
        }
        
        Pass
        {
            Name "Back"
            Tags { "LightMode" = "UniversalForward" }

            ZWrite On
            Cull Front

            HLSLPROGRAM

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            //Material Keywords
            #pragma shader_feature _OVERRIDE
            #pragma multi_compile _ _PROJECTOR
            
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT
			#pragma multi_compile _ SHADOWS_SHADOWMASK

            #pragma multi_compile_instancing

            #include "Assets/ARTs/TA/Resources/CustomRP/CustomLighting.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomRP/CustomSurfaceInput.hlsl"

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float4 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float4 tangentWS     : TEXCOORD1;
                float4 bitangentWS   : TEXCOORD2;
                float4 normalWS      : TEXCOORD3;
            };


            Varyings LitPassVertex(Attributes IN)
            {
                Varyings OUT;

                //Wave Offset
                float3 normal = normalize(IN.normalOS.xyz);
                float3 positionOS = IN.positionOS.xyz;
                positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
                
                float2 uv = TransformObjectToWorld(positionOS.xyz).xz;
                float waveOffset = _Time.y * _OffsetFrequency;
                float height = SimpleNoise(uv + waveOffset, _OffsetLength).r;
                height = Remap(height, float2(0, 1), float2(-1, 1)).r;

                float3 offset = height * _OffsetMagnitude * 0.1;
                

                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS.xyz + offset.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(-IN.normalOS.xyz, IN.tangentOS);

                OUT.positionCS = positionInputs.positionCS;
                float3 positionWS = positionInputs.positionWS;

                OUT.normalWS = float4(normalInputs.normalWS, positionWS.x);
                OUT.tangentWS = float4(normalInputs.tangentWS, positionWS.y);
                OUT.bitangentWS = float4(normalInputs.bitangentWS, positionWS.z);
                
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

                return inputData;
            }

            SurfaceData InitializeSurfaceData(Varyings IN)
            {
                SurfaceData surfaceData = (SurfaceData)0;

                float3 positionWS = float3(IN.normalWS.w, IN.tangentWS.w, IN.bitangentWS.w);
                float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                float3 lightDir = normalize(mainLight.direction);
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                float2 uv = IN.positionSS.xy / IN.positionSS.w;

                float upMask = saturate(dot(half3(0, 1, 0), IN.normalWS));

                //Geo
                float geo = 0;
                for(int i = 0; i < MAX_POSITION_COUNT; i++)
                {
                    float distTemp = 1 - saturate(distance(_ObjectArrayPos[i].xyz, positionWS.xyz) * 0.5);
                    distTemp = smoothstep(_GeoDistance, _GeoDistance + _GeoFalloff, distTemp) * _ObjectArrayPos[i].w;
                    
                    geo += distTemp;
                }

                //Triplanar UVs
                float2 uvX = positionWS.zy;
                float2 uvY = positionWS.xz;
                float2 uvZ = positionWS.xy;

                 //Depth
                float sceneDepth = LinearEyeDepth(SampleSceneDepth(uv), _ZBufferParams);
                float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(IN.positionSS.z);
                float depthDifference = sceneDepth - surfaceDepth;
                float depth = saturate(depthDifference / _DepthFalloff) * _DepthIntensity;
                float edge = DepthFade(sceneDepth, IN.positionSS.w, _EdgeDistance, _EdgeFalloff) * _EdgeIntensity;
                //float causticsDepth = DepthFade(sceneDepth, IN.positionSS.w, _CausticsDistance, _CausticsFalloff) * _EdgeIntensity;

                //Time
                float waveSpeed = _Time.y * _WaveSpeed;
                float distortionSpeed = _Time.y * _DistortionSpeed;
                float normalSpeed = _Time.y * _NormalSpeed;
                float topFoamSpeed = _Time.y * _TopFoamSpeed;
                float topNoiseSpeed = _Time.y * _TopNoiseSpeed;
                float fallFoamSpeed = _Time.y * _FallFoamSpeed;
                float fallNoiseSpeed = _Time.y * _FallNoiseSpeed;
                float geoFoamSpeed = _Time.y * _GeoFoamSpeed;

                //Distorted
                float distortion1 = SAMPLE_TEXTURE2D(_DistortionMap, sampler_DistortionMap, uvY * (1 / _DistortionScale) + distortionSpeed).r;
                float distortion2 = SAMPLE_TEXTURE2D(_DistortionMap, sampler_DistortionMap, -uvY * (1 / _DistortionScale * 0.5) + distortionSpeed * 0.8).r;
                float distortion = saturate(distortion1 + distortion2) * _DistortionIntensity;

                //Wave
                float wave = saturate(SAMPLE_TEXTURE2D(_WaveMap, sampler_WaveMap, -uvY * (1 / _WaveScale) + waveSpeed - distortion)).r * _WaveIntensity;
                
                //Normal
                float3 normal1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uvY * (1 / _NormalScale) + normalSpeed), _NormalIntensity);
                float3 normal2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, -uvY * (1 / _NormalScale * 0.6)  + normalSpeed * 0.8), _NormalIntensity * 0.8);
                float3 normal = normalize(normal1 + normal2);
                float3 blend = TriplanarBlend(IN.normalWS.xyz, _Blend);
                float3 normalTS = NormalizeNormalPerVertex(normal * blend.x + normal * blend.y + normal * blend.z);
                float3 normalWS = TriplanarNormal(normal, normal, normal, IN.normalWS.xyz, blend);
                
                //Foam
                float foamMask = smoothstep(_FoamThreshold, _FoamThreshold + _FoamSmooth, IN.color.x);

                float noiseY = SAMPLE_TEXTURE2D(_TopNoiseMap, sampler_TopNoiseMap, uvY * (1 / _TopNoiseScale) + topNoiseSpeed).r * _TopNoiseIntensity;
                float foamY = SAMPLE_TEXTURE2D(_TopFoamMap, sampler_TopFoamMap, IN.uv.yy * (1 / _TopFoamScale) + topFoamSpeed - noiseY).r;

                float geoNoise = SAMPLE_TEXTURE2D(_TopNoiseMap, sampler_TopNoiseMap, uvY * (1 / _GeoNoiseScale)).r * _GeoNoiseIntensity;
                float geoFoam = SAMPLE_TEXTURE2D(_TopFoamMap, sampler_TopFoamMap, float2(geo, geo) * (1 / _GeoFoamScale) + geoFoamSpeed - geoNoise).r;
                geoFoam = step(geoFoam, geo) * geo * upMask;
                
                float noiseX = SAMPLE_TEXTURE2D(_FallNoiseMap, sampler_FallNoiseMap, float2(uvX.x * (1 / _FallNoiseScale), uvX.y * (1 / _FallNoiseScale) + fallNoiseSpeed)).r * _FallNoiseIntensity;
                float foamX = SAMPLE_TEXTURE2D(_FallFoamMap, sampler_FallFoamMap, float2(uvX.x * (1 / _FallFoamScale), uvX.y * (1 / _FallFoamScale) + fallFoamSpeed - noiseX)).r;

                float noiseZ = SAMPLE_TEXTURE2D(_FallNoiseMap, sampler_FallNoiseMap, float2(uvZ.x * (1 / _FallNoiseScale), uvZ.y * (1 / _FallNoiseScale) + fallNoiseSpeed)).r * _FallNoiseIntensity;
                float foamZ = SAMPLE_TEXTURE2D(_FallFoamMap, sampler_FallFoamMap, float2(uvZ.x * (1 / _FallFoamScale), uvZ.y * (1 / _FallFoamScale) + fallFoamSpeed - noiseZ)).r;
                
                float foam = foamX * blend.x + foamY * blend.y + foamZ * blend.z;
                foam = step(foam, foamMask) * _FoamIntensity * foamMask + geoFoam;

                //Caustics
                float3 cameraDir = -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz);
                //float3 cameraDir = GetWorldSpaceViewDir(positionWS);
                float3 cameraPos = _WorldSpaceCameraPos;
                float3 causticsPos = viewDirWS / dot(viewDirWS, cameraDir) * sceneDepth + cameraPos;
                float NoL = saturate(dot(normalWS, lightDir));
                float shadow = lerp(0, 1, mainLight.shadowAttenuation * NoL);
                
                float3 tangent = normalize(cross(float3(lightDir.x, 0, lightDir.z), lightDir));
                float3 bitangent = normalize(cross(tangent, lightDir));
                
                float3 positionLS = mul(float3x3(tangent, bitangent, -lightDir), causticsPos);
                float2 causticsUV = positionLS.xy;
                
                float causticsSpeed = _Time.y * _CausticsSpeed;
                float causticsScale = 1 / _CausticsScale;
                
                half3 caustics1 = ColorSplit(_CausticsMap, sampler_CausticsMap, causticsUV, causticsScale, causticsSpeed, _SplitRGB);
                half3 caustics2 = ColorSplit(_CausticsMap, sampler_CausticsMap, -causticsUV, causticsScale, causticsSpeed, _SplitRGB);
                
                half3 caustics = min(caustics1, caustics2) * _CausticsColor.rgb * _DirLightIntensity * _CausticsIntensity;
                half causticsMask = shadow;

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

                //Color
                half3 albedo = lerp(_ShallowColor.rgb, _BaseColor.rgb, depth);
                albedo = lerp(albedo, _WaveColor.rgb, wave);
                albedo = lerp(albedo, _EdgeColor.rgb, edge);
                albedo = lerp(albedo, _FoamColor.rgb, foam);

                surfaceData.albedo = albedo;
                surfaceData.alpha = 1;
                surfaceData.normalTS = normalTS;
                surfaceData.smoothness = _Smoothness;
                surfaceData.metallic = 0;
                surfaceData.occlusion = 1;

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
                SurfaceData surfaceData = InitializeSurfaceData(IN);
                InputData inputData = InitializeInputData(IN, surfaceData.normalTS);

                half4 color = UniversalFragmentStylizedPBR(inputData, surfaceData);
                
                
                //Output
                return color;
            }
            
            ENDHLSL   
        }
        
        Pass 
        {
			Name "DepthOnly"
			Tags {"LightMode" = "DepthOnly"}
 
			ZWrite On
			//ColorMask 0
            Cull Off

            HLSLPROGRAM

            //#include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"

            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // GPU Instancing
            #pragma multi_compile_instancing


            // Unity defined keywords
			#pragma multi_compile_fog


            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings DepthOnlyVertex(Attributes IN)
            {
                Varyings OUT;

                float3 normal = normalize(IN.normalOS.xyz);
                float3 positionOS = IN.positionOS.xyz;
                positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);

                float4 offset = float4(0, sin(_OffsetFrequency * _Time.y + IN.positionOS.x * _OffsetLength + IN.positionOS.y * _OffsetLength + IN.positionOS.z * _OffsetLength), 0, 0) * _OffsetMagnitude * 0.01;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS.xyz + offset.xyz);
                OUT.positionCS = positionInputs.positionCS;

                return OUT;
            }

            float4 DepthOnlyFragment(Varyings IN) : SV_TARGET
            {
                return 0;
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
                
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
                
                OUT.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _MainLightPosition.xyz));
                //OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = normalWS;
                
                return OUT;
            }

            float4 ShadowPassFragment(Varyings IN) : SV_Target
            {
                return 0;
            }
            
			ENDHLSL
		}
    }
    CustomEditor "EBGame.SimpleShaderGUI"
}