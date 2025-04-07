Shader "Custom/FXShader"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendOp)]  _BlendOp  ("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0
        [Enum(Off, 0, On, 1)]_ZWriteMode ("ZWriteMode", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode ("ZTestMode", Float) = 4

        [Foldout(1, 2, 0, 1)]_Basic ("Basic_Foldout", float) = 1                       
        [Space(10)]
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [Space(10)]
        [NoScaleOffset] _BaseMap ("Albedo Map", 2D) = "white" {}
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        [NoScaleOffset] _FoamNoiseMap ("Foam Noise Map", 2D) = "white" {}
        _FoamNoiseScale ("Foam Noise Scale", Float) = 1
        _FoamSpeed ("Foam Speed", Float) = 1
        _FoamNoiseIntensity ("Foam Noise Intensity", Float) = 1
        
        [Space(10)]
        _Smoothness ("Smoothness", Range(0, 1)) = 1
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Tiling ("Tiling", Range(0, 5)) = 1
        [Space(10)]
        [Toggle(_ALPHATEST)] _AlphaTest("Alpha Clipping On/Off", Float) = 0
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        [Space(10)]

        [Foldout(1, 2, 0, 1)]_EmissionParameter ("Emission_Foldout", float) = 1
        [Toggle(_EMISSION)] _Emission("Emission On/Off", Float) = 0
        [NoScaleOffset] _EmissionMap ("Emission Map", 2D) = "white" {}
        [HDR] _EmissionColor ("Emission Color", Color) = (1, 1, 1)
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_Other ("Others_Foldout", float) = 1
        
        [Space(10)]
        [Toggle(_CASTSHADOW)] _CastShadow("Shadow On/Off", Float) = 1
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
            
            #include "CustomRP/CustomFunctions.hlsl"
            #include "CustomRP/Shading.hlsl"
            
            #pragma instancing_options procedural:setupGPUI
            #pragma multi_compile_instancing

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half4 _EmissionColor;
                half _Smoothness;
                half _Tiling;
                half _Cutoff;
                half _Metallic;
                half _FoamNoiseScale;
                half _FoamSpeed;
                half _FoamNoiseIntensity;
            CBUFFER_END

            CBUFFER_START(GlobalMaterial)
                half _Exposure;
                float4 custom_SH[7];
            CBUFFER_END


            //图像采样
            TEXTURE2D (_BaseMap);
            SAMPLER (sampler_BaseMap);

            TEXTURE2D (_NormalMap);
            SAMPLER (sampler_NormalMap);

            TEXTURE2D (_FoamNoiseMap);
            SAMPLER (sampler_FoamNoiseMap);
            
            #ifdef _EMISSION
                TEXTURE2D(_EmissionMap);
                SAMPLER(sampler_EmissionMap);
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
            #pragma shader_feature _ALPHATEST
            #pragma shader_feature _EMISSION
            #pragma shader_feature _CASTSHADOW
            //#pragma shader_feature _CULLMODE_CULLBACK _CULLMODE_CULLFRONT _CULLMODE_CULLOFF
            
			#pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _SHADOWS_SHADOWMASK

            //#pragma multi_compile_fragment _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _SHADOWS_SOFT
            

            struct Attributes
            {
                float4 positionOS    : POSITION;
                float2 uv            : TEXCOORD0;
                float4 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float2 uv            : TEXCOORD0;
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
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz, IN.tangentOS);
                
                OUT.positionCS = TransformWorldToHClip(positionWS);
                
                OUT.normalWS = float4(normalInputs.normalWS, positionWS.x);
                OUT.tangentWS = float4(normalInputs.tangentWS, positionWS.y);
                OUT.bitangentWS = float4(normalInputs.bitangentWS, positionWS.z);
                OUT.uv = IN.uv;
                
                return OUT;
            }

            DataInput InitializeDataInput(Varyings IN)
            {
                DataInput dataInput = (DataInput)0;
                
                float uvY = IN.uv.y;
                float foamOffset = _Time.y * _FoamSpeed;
                float foamNoise = SAMPLE_TEXTURE2D(_FoamNoiseMap, sampler_FoamNoiseMap, uvY * _FoamNoiseScale + foamOffset * 0.1).r * _FoamNoiseIntensity;

                half4 albedoAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv * _Tiling + foamNoise);
                
                dataInput.albedo = albedoAlpha.rgb * _BaseColor.rgb;
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
                
                float4 normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, IN.uv * _Tiling).rgba;
                dataInput.normalTS = normal.xyz;
                dataInput.N = TransformTangentToWorld(dataInput.normalTS, float3x3(IN.tangentWS.xyz, IN.bitangentWS.xyz, IN.normalWS.xyz));
                dataInput.N = NormalizeNormalPerVertex(dataInput.N);
                
                //自发光
                #ifdef _EMISSION
                    dataInput.emissive = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, IN.uv).rgb * _EmissionColor.rgb;
                #endif

                #ifdef _CASTSHADOW
                    dataInput.castShadow = 1;
                #endif
                
                dataInput.customSH = custom_SH;
                return dataInput;
            }
            
            half4 LitPassFragment(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

                DataInput dataInput = InitializeDataInput(IN);
                half3 color = ShadingBasic(dataInput);
                
                //自发光
                #ifdef _EMISSION
                    color += dataInput.emissive;
                #endif
                
                //最终输出
                return half4(color, dataInput.alpha);
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
