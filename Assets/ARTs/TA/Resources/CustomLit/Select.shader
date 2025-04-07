Shader "Custom/Select"
{
    Properties
    {
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        _Tiling ("Tiling", Range(0, 10)) = 1
        _Speed ("Speed", Range(0, 1)) = 0.1
        _Color1 ("Outline Color", Color) = (1, 1, 1, 1)
        _Color2 ("Outline Color", Color) = (0, 0, 0, 1)
        _Alpha ("Alpha", Range(0, 1)) = 0.5
    }
    
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "ShadingModels.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
            half3 _Color1;
            half3 _Color2;
            float _Tiling;
            float _Speed;
            half _Alpha;
        CBUFFER_END
        
        TEXTURE2D(_BaseMap);                SAMPLER(sampler_BaseMap);
        
    ENDHLSL

    SubShader
    {
        Tags{ "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent"}
        
        Pass
        {
            Name "SELECT"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float3 viewDirWS                : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float4 positionSS               : TEXCOORD2;
                float3 normalWS                 : TEXCOORD3;

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

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.positionSS = ComputeScreenPos(vertexInput.positionCS);
                output.viewDirWS = GetWorldSpaceNormalizeViewDir(output.positionWS);
                output.normalWS = normalInput.normalWS;

                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float time = fmod(_Time.y, 2e5);
                float2 uv = float2(input.positionSS.x, input.positionSS.y);
                float2 offset = float2(-time * _Speed, time * _Speed);
                float mask = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv * _Tiling + offset).r;
                half3 baseColor = lerp(_Color2, _Color1, mask);

                Light mainLight = GetMainLight();
                float3 L = normalize(mainLight.direction);
                float3 N = input.normalWS;
                float NdotL = saturate(dot(N, L));
                half3 color = baseColor + NdotL;
    
                return half4(color, _Alpha);
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

            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
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

                output.positionCS = TransformWorldToHClip(positionWS);
                //output.positionSS = ComputeScreenPos(output.positionCS);

                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EBGame.SimpleShaderGUI"
}

