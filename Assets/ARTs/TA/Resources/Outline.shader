Shader "Custom/OutlineShader"
{
    Properties
    {
        [HDR]_OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _Thickness ("Outline Thickness", Range(0, 1)) = 1
        //        _DitherSize ("Dither Size", Range(1, 10)) = 1
//        _DitherThreshold ("Dither Threshold", Range(0, 1)) = 0.5
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
        
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        CBUFFER_START(UnityPerMaterial)
            half4 _OutlineColor;
            half _Thickness;
        CBUFFER_END

        CBUFFER_START(GlobalMaterial)
            half _OutlineAlpha;
        CBUFFER_END

        ENDHLSL

        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "UniversalForward" }
            
//            Blend SrcAlpha OneMinusSrcAlpha
//            ZTest Off
            
            Stencil
            {
                Ref 1
                Comp NotEqual
                Pass Keep
            }

            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment

            #pragma multi_compile_instancing

            //Dither
            float Dither(half In, float4 ScreenPosition)
            {
                float2 uv = ScreenPosition.xy * _ScreenParams.xy;
                float DITHER_THRESHOLDS[16] =
                {
                    1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
                    13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
                    4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
                    16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
                };
                uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
                return In - DITHER_THRESHOLDS[index];
            }


            struct Attributes
            {
                float4 positionOS    : POSITION;
                float3 normalOS      : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float3 positionWS    : TEXCOORD0;
                float4 positionSS    : TEXCOORD2;
                half3 normalWS       : TEXCOORD1;
            };
            
            Varyings OutlinePassVertex(Attributes input)
            {
                Varyings output;

                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                
                float3 normalVS = mul((float3x3)UNITY_MATRIX_IT_MV, input.normalOS.xyz);
                float2 offset = mul((float2x2)UNITY_MATRIX_P, normalVS.xy);

                output.positionCS.xy += offset * _Thickness * 0.01;
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS.xyz);
                output.positionSS = ComputeScreenPos(output.positionCS);
                
                return output;
            }

            half4 OutlinePassFragment(Varyings input) : SV_Target
            {
                half dither = Dither(_OutlineAlpha, input.positionSS / input.positionSS.w);
                clip(dither);
                return half4(_OutlineColor.rgb, 1);
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "Cut"
            Tags { "LightMode" = "UniversalForward" }
            
            ColorMask 0
            ZWrite Off
            ZTest Off
            
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            HLSLPROGRAM

            #pragma vertex OutlinePassVertex
            #pragma fragment OutlinePassFragment

            #pragma multi_compile_instancing


            struct Attributes
            {
                float4 positionOS    : POSITION;
            };

            struct Varyings
            {
                float4 positionCS    : SV_POSITION;
                float4 positionSS    : TEXCOORD0;
            };
            
            Varyings OutlinePassVertex(Attributes input)
            {
                Varyings output;
                
                VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS.xyz);

                output.positionCS = posInputs.positionCS;
                //output.positionSS = ComputeScreenPos(posInputs.positionCS);
                output.positionSS = posInputs.positionNDC;
           
                return output;
            }

            half4 OutlinePassFragment(Varyings input) : SV_Target
            {
                return 0;
            }
            
            ENDHLSL
        }

    }
}