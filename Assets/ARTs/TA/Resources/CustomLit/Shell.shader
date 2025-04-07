Shader "Custom/Shell"
{
    Properties
    {
        _MainTex ("Base Map", 2D) = "white"{}
        _BaseColor ("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _EdgeColor ("Edge Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _EdgeWidth ("Edge Width", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "IgnoreProjector" = "True"
        }
        
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _EdgeColor;
                float _EdgeWidth;
                float4 _MainTex_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex);                SAMPLER(sampler_MainTex);
            TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
        ENDHLSL

        Pass
        {
            Name "SHELL"
            
            Tags 
            {
                "LightMode" = "UniversalForward"
            }
            
            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull Back
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
                float4 positionSS   : TEXCOORD0;
                float2 uv           : TEXCOORD1;
            };
            

            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionSS = ComputeScreenPos(output.positionCS);
                output.uv = input.uv;

                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                float3 offset = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 0.0) * _EdgeWidth;
                
                // float2 uv1 = input.uv + float2(0, 1) * _EdgeWidth * _MainTex_ST.xy;
                // float2 uv2 = input.uv + float2(0, -1) * _EdgeWidth * _MainTex_ST.xy;
                // float2 uv3 = input.uv + float2(-1, 0) * _EdgeWidth * _MainTex_ST.xy;
                // float2 uv4 = input.uv + float2(1, 0) * _EdgeWidth * _MainTex_ST.xy;

                float center = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, input.uv).r, _ZBufferParams);
                float up = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, input.uv + offset.zy).r, _ZBufferParams);
                float down = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, input.uv - offset.zy).r, _ZBufferParams);
                float left = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, input.uv - offset.xz).r, _ZBufferParams);
                float right = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, input.uv + offset.xz).r, _ZBufferParams);

                float edge = abs(left - center) + abs(right - center) + abs(up - center) + abs(down - center);

                half4 color = lerp(_BaseColor, _EdgeColor, saturate(edge));

                return color;
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
            
            ColorMask R
            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull Back
            
            HLSLPROGRAM
            
            #pragma vertex DepthVert
            #pragma fragment DepthFrag

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 texcoord     : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionSS   : TEXCOORD1;
                float4 positionCS   : SV_POSITION;

            };

            Varyings DepthVert(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                float3 positionOS = input.positionOS.xyz;
                float3 positionWS = TransformObjectToWorld(positionOS);
                
                output.uv = input.texcoord;
                output.positionSS = ComputeScreenPos(output.positionCS);
                output.positionCS = TransformWorldToHClip(positionWS);

                return output;
            }

            half DepthFrag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                half4 albedoAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half alpha = albedoAlpha.a * _BaseColor.a;

            #if defined _ALPHATEST
                clip(alpha - _Cutoff);
            #endif


            #if defined _FADE
                half fade = Dither(_FadeThreshold, input.positionSS / input.positionSS.w);
                clip(fade);
            #endif

                return input.positionCS.z;
            }
            ENDHLSL
        }
    }
}
