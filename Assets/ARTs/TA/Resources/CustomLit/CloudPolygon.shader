Shader "Custom/CloudPolygon"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _DarkColor ("Dark Color", Color) = (0, 0, 0, 1)
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimIntensity ("Rim Intensity", Range(0, 1)) = 0.5
        _RimFalloff ("Rim Falloff", Range(1, 10)) = 2
        _AOIntensity ("AO Intensity", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_NoiseParameter ("Noise_Foldout", float) = 1
        _NoiseIntensity ("Noise Intensity", Range(0, 1)) = 1
        _NoiseTiling ("Noise Tiling", Range(0, 3)) = 1
        _NoiseSpeed ("Noise Speed", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_OtherParameter ("Others_Foldout", float) = 1
        [Toggle(_RECEIVE_SHADOWS_OFF)] _DisableShadows("Shadows Off", Float) = 0
    }
    
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "ShadingModels.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
            half3 _BaseColor;
            half3 _DarkColor;
            half3 _RimColor;
            float _RimIntensity;
            float _RimFalloff;
            float _AOIntensity;
            float _NoiseIntensity;
            float _NoiseTiling;
            float _NoiseSpeed;
        CBUFFER_END
        
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            Name "POLYGONCLOUD"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            Cull Off
            ZWrite On
            ZTest LEqual
            // -------------------------------------

            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex Vert
            #pragma fragment Frag
            // -------------------------------------

            // Universal Pipeline keywords ---------

            // -------------------------------------

            // Material Keywords -------------------

            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            // -------------------------------------
            
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                half3  color        : COLOR;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                float3 viewDirWS                : TEXCOORD1;
                float3 positionWS               : TEXCOORD2;
                half3  color                    : TEXCOORD3;
                float3 normalWS                 : TEXCOORD4;
                
                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalOS = normalize(input.positionOS.xyz - float3(0, 0, 0));
                
                float time = fmod(_Time.y, 2e5);
                float speed = _NoiseSpeed * time;
                float3 offset = SimpleNoise3D(positionWS * _NoiseTiling + speed) * _NoiseIntensity;
                float3 positionOS = input.positionOS.xyz + normalOS * offset;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(normalOS);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = positionWS;
                output.viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                output.normalWS = normalInput.normalWS;
                output.uv = input.texcoord;
                output.color = input.color;

                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                Light mainLight = GetMainLight();
                half3 lightColor = mainLight.color;
                float3 L = normalize(mainLight.direction);
                float3 N = normalize(input.normalWS);
                float3 V = input.viewDirWS;

                float NdotL = dot(N, L) * 0.5 + 0.5;
                float NdotV = saturate(dot(N, V));

                float ao = lerp(1, 1 - input.color.r, _AOIntensity);
                half3 baseColor = lerp(_DarkColor, _BackColor, NdotL);

                float rim = pow(1 - NdotV, _RimFalloff);
                
                half3 color = lerp(baseColor, _RimColor, rim * _RimIntensity) * ao * lightColor;
                
                return half4(color, 1);
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State Commands ---------------
            Cull Off
            ZWrite On
            ZTest LEqual
            ColorMask R
            // -------------------------------------

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Shader Stages -----------------------
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            // -------------------------------------

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                //float3 normalWS                 : TEXCOORD1;
                //float3 positionWS               : TEXCOORD2;
                //float4 positionSS               : TEXCOORD3;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 normalOS = normalize(input.positionOS.xyz - float3(0, 0, 0));
                
                float time = fmod(_Time.y, 2e5);
                float speed = _NoiseSpeed * time;
                float3 offset = SimpleNoise3D(positionWS * _NoiseTiling + speed) * _NoiseIntensity;
                float3 positionOS = input.positionOS.xyz + normalOS * offset;

                positionWS = TransformObjectToWorld(positionOS);

                output.uv = input.texcoord;
                output.positionCS = TransformWorldToHClip(positionWS);
                //output.positionSS = ComputeScreenPos(output.positionCS);

                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

            #ifdef LOD_FADE_CROSSFADE
                LODFadeCrossFade(input.positionCS);
            #endif
                
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EBGame.SimpleShaderGUI"
}

