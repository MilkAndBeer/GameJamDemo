Shader "Custom/PointLight"
{
    Properties
    {
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _LightIntensity ("Light Intensity", Range(0, 10)) = 1
        _LightRange ("Light Range", Range(0, 1)) = 1
        [Toggle(_GlobalIntensity)] _GlobalIntensity ("Global Intensity", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "Queue"="Transparent"
            "IgnoreProjector" = "True"
        }
        
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _LightColor;
                half _LightIntensity;
                half _LightRange;
            CBUFFER_END

            CBUFFER_START(GlobalMaterial)
                half _GlobleLight;
            CBUFFER_END

            TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
            //TEXTURE2D_X(_CameraOpaqueTexture);              SAMPLER(sampler_CameraOpaqueTexture);

            float4 GetPositionWSFromDepth(float2 uv, float linearDepth)
            {
                float positionCZ = _ProjectionParams.y + (_ProjectionParams.z - _ProjectionParams.y) * linearDepth;
                float height = positionCZ * 2 / unity_CameraProjection._m11;
                float width = _ScreenParams.x / _ScreenParams.y * height;
                float positionCX = width * uv.x - width / 2;
                float positionCY = height * uv.y - height / 2;
                float4 positionC = float4(positionCX, positionCY, positionCZ, 1);
                
                return mul(unity_CameraToWorld, positionC);
            }

            float NormalDistribution(float x, float range)
            {
                return (1 / sqrt(2) * 3.1415926) * exp(-pow(x * (1 / range), 2) / 2);
            }

            struct Attributes
            {
                float3 positionOS : POSITION;
            };
            
            struct Varyings
            {
                float4 positionSS : TEXCOORD1;
                float4 positionCS : SV_POSITION;
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
                output.positionCS = vertexInput.positionCS;
                output.positionSS = ComputeScreenPos(output.positionCS);
                
                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                float2 positionSS = input.positionSS.xy / input.positionSS.w;
                //half4 opaque = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, UnityStereoTransformScreenSpaceTex(positionSS));
                float rawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(positionSS)).r;
                float linearDepth = Linear01Depth(rawDepth, _ZBufferParams);
                float3 positionWS = GetPositionWSFromDepth(positionSS, linearDepth).xyz;
                float3 pos = float3(UNITY_MATRIX_M[0].w, UNITY_MATRIX_M[1].w, UNITY_MATRIX_M[2].w);
                float dist = length(positionWS - pos);
                float light = NormalDistribution(dist, _LightRange) * _LightIntensity;
                half4 color = max(0, _LightColor * light);
                #if _GlobalIntensity
                    color *= _GlobleLight;
                #endif
                return color;
            }
        ENDHLSL
        
        Pass
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            Blend DstColor One
            ZWrite Off
            Cull Front
            ZTest Always
            // -------------------------------------

            HLSLPROGRAM
            
            // Shader Stages -----------------------
            #pragma vertex Vert
            #pragma fragment Frag
            // -------------------------------------
            #pragma shader_feature_local _GlobalIntensity
            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            // -------------------------------------

            ENDHLSL
        }
        
//        Pass
//        {
//            Name "PointLightDepthOnly"
//            Tags{"LightMode" = "DepthOnly"}
//
//            // Render State Commands ---------------
//            ColorMask R
//            ZWrite On
//            Cull Back
//            // -------------------------------------
//
//            HLSLPROGRAM
//
//            // -------------------------------------
//            // Shader Stages
//            #pragma vertex PointLightDepthOnlyVertex
//            #pragma fragment PointLightDepthOnlyFragment
//
//            // Universal Pipeline keywords ---------
//            // -------------------------------------
//            
//            // Unity defined keywords --------------
//            
//            // -------------------------------------
//            
//            // Material Keywords -------------------
//
//            // -------------------------------------
//            struct Attributes
//            {
//                float3 positionOS : POSITION;
//            };
//            
//            struct Varyings
//            {
//                float4 positionCS : SV_POSITION;
//            };
//
//            Varyings PointLightDepthOnlyVertex(Attributes input)
//            {
//                Varyings output;
//                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);
//                output.positionCS = vertexInput.positionCS;
//                
//                return output;
//            }
//
//            half4 PointLightDepthOnlyFragment(Varyings input) : SV_TARGET
//            {
//                return input.positionCS.z;
//            }
//            
//            ENDHLSL
//        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
