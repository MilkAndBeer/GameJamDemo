Shader "Hidden/Custom/TiltShift"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // _GoldenRot ("Golden Rot", Vector) = (0, 0, 0, 0)
        // _CenterOffset ("Center Offset", Float) = 0.0
    }

    SubShader
    {
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _MainTex_TexelSize;
            CBUFFER_END

                float3 _MaskParams;
                float4 _BlurParams;

                half4 _GoldenRot;
            
                TEXTURE2D(_MainTex);
                SAMPLER(sampler_MainTex);
            
                #define _CenterOffset _MaskParams.x
                #define _Area _MaskParams.y
                #define _Spread _MaskParams.z

                #define _Iteration _BlurParams.x
                #define _BlurSize _BlurParams.y
                #define _PixelSize 1 / _BlurParams.zw

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                half2 uv : TEXCOORD0;
            };

            struct Varyings_Mask
            {
                float4 positionCS : SV_POSITION;
                half2 uv : TEXCOORD0;
            };

            half TiltShiftMask(half2 uv)
            {
                half centerY = uv.y * 2.0 - 1.0 + _CenterOffset;    // [0, 1] -> [-1, 1]
                return pow(abs(centerY * _Area), _Spread);
            }

            half4 KawaseBlur(TEXTURE2D_PARAM(tex, samplerTex), float2 uv, float2 texelSize, half pixelOffset)
            {
                half4 o = 0;
                o += SAMPLE_TEXTURE2D(tex, samplerTex, uv + float2(pixelOffset +0.5, pixelOffset +0.5) * texelSize);
                o += SAMPLE_TEXTURE2D(tex, samplerTex, uv + float2(-pixelOffset -0.5, pixelOffset +0.5) * texelSize);
                o += SAMPLE_TEXTURE2D(tex, samplerTex, uv + float2(-pixelOffset -0.5, -pixelOffset -0.5) * texelSize);
                o += SAMPLE_TEXTURE2D(tex, samplerTex, uv + float2(pixelOffset +0.5, -pixelOffset -0.5) * texelSize);
                return o * 0.25;
            }

            Varyings vert_tiltshift(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;

                return output;
            }

            // half4 frag_tiltshift_mask_only(Varyings_Mask input) : SV_TARGET
            // {
            //     return saturate(TiltShiftMask(input.uv));
            // }

            half4 frag_tiltshift_bokeh(Varyings input) : SV_TARGET
            {
                //  half2x2 rot = half2x2(_GoldenRot);
                //  half4 accumulator = 0.0;
                //  half4 divisor = 0.0;
                //
                //  half r = 1.0;
                //  half2 angle = half2(0.0, _BlurSize * saturate(TiltShiftMask(input.uv)));
                //
                //  for (int j = 0; j < _Iteration; j ++)
                //  {
                //      r += 1.0 / r;
                //      angle = mul(rot, angle);
                //      half4 bokeh = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, float2(input.uv + _PixelSize * (r - 1.0) * angle));
                //      accumulator += bokeh * bokeh;
                //      divisor += bokeh;
                //  }
                // return saturate(accumulator / divisor);
                
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half4 blurColor = KawaseBlur(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), input.uv, _MainTex_TexelSize.xy, _BlurSize);
                color = lerp(color, blurColor, saturate(TiltShiftMask(input.uv)));
                return color;
            }
        ENDHLSL

        ZTest Always Cull Off ZWrite Off

//        Pass
//        {
//            NAME "TILT_SHIFT_MASK_ONLY"
//
//            HLSLPROGRAM
//                #pragma fragmentoption ARB_precision_hint_fastest
//
//                #pragma vertex vert_tiltshift
//                #pragma fragment frag_tiltshift_mask_only
//            ENDHLSL
//        }

        Pass
        {
            NAME "TILT_SHIFT_BOKEH"

            HLSLPROGRAM
                #pragma fragmentoption ARB_precision_hint_fastest

                #pragma vertex vert_tiltshift
                #pragma fragment frag_tiltshift_bokeh
            ENDHLSL
        }
    }
    Fallback Off
}
