Shader "Hidden/Custom/Sobel"
{
    Properties
    {
        _EdgeColor ("EdgeColor",Color) = (0,0,0,1)
        _Thickness ("Thickness", Float) = 1
        _DepthMultiplier ("Depth Multiplier", Float) = 1
        _NormalMultiplier ("Normal Multiplier", Float) = 1
    }
    SubShader
    {
        Tags
        {

            "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"
        }
   
        Pass
        {
            Name "OUTLINE"
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _EdgeColor;

            uint _Thickness;
            float _DepthMultiplier;
            float _NormalMultiplier;
            
            CBUFFER_END

            float4 _BlitTexture_TexelSize;
            float2 uvs[9];

            //TEXTURE2D(_MainTex);                            SAMPLER(sampler_MainTex);
            TEXTURE2D_X(_BlitTexture);                      SAMPLER(sampler_BlitTexture);
            TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
            //TEXTURE2D(_CameraNormalsTexture);               SAMPLER(sampler_CameraNormalsTexture);

            float4 SobelSample(Texture2D t, SamplerState s, float2 uv, float3 offset)
            {
                float4 pixelCenter = t.Sample(s, uv);
                float4 pixelLeft = t.Sample(s, uv - offset.xz);
                float4 pixelRight = t.Sample(s, uv + offset.xz);
                float4 pixelUp = t.Sample(s, uv + offset.zy);
                float4 pixelDown = t.Sample(s, uv - offset.zy);

                return abs(pixelLeft - pixelCenter) +
                    abs(pixelRight - pixelCenter) +
                    abs(pixelUp - pixelCenter) +
                    abs(pixelDown - pixelCenter);
            }

            float SobelDepth(float ldc, float ldl, float ldr, float ldu, float ldd)
            {
                return abs(ldl - ldc) +
                    abs(ldr - ldc) +
                    abs(ldu - ldc) +
                    abs(ldd - ldc);
            }

            float SobelSampleDepth(Texture2D t, SamplerState s, float2 uv, float3 offset)
            {
                float pixelCenter = LinearEyeDepth(t.Sample(s, uv).r, _ZBufferParams);
                float pixelLeft = LinearEyeDepth(t.Sample(s, uv - offset.xz).r, _ZBufferParams);
                float pixelRight = LinearEyeDepth(t.Sample(s, uv + offset.xz).r, _ZBufferParams);
                float pixelUp = LinearEyeDepth(t.Sample(s, uv + offset.zy).r, _ZBufferParams);
                float pixelDown = LinearEyeDepth(t.Sample(s, uv - offset.zy).r, _ZBufferParams);

                return SobelDepth(pixelCenter, pixelLeft, pixelRight, pixelUp, pixelDown);
            }

            struct Attributes
            {
                //float4 positionOS   :   POSITION;
                //float2 uv           :   TEXCOORD0;
                uint vertexID       :   SV_VertexID;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS   :   SV_POSITION;
                float2 uv           :   TEXCOORD0;
            };
            
            Varyings vert(Attributes input)
            {
                Varyings output;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                //VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
                output.uv = GetFullScreenTriangleTexCoord(input.vertexID);
                
                return output;
            }

            half4 frag(Varyings input) : SV_TARGET
            {
                float3 offset = float3(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y, 0.0) * _Thickness;
                half3 sceneColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, input.uv).rgb;

                float sobelDepth = SobelSampleDepth(_CameraDepthTexture, sampler_CameraDepthTexture, input.uv.xy, offset);
                sobelDepth = saturate(sobelDepth) * _DepthMultiplier;

                // float3 sobelNormalVec = SobelSample(_CameraNormalsTexture, sampler_CameraNormalsTexture, input.uv.xy, offset).rgb;
                // float sobelNormal = sobelNormalVec.x + sobelNormalVec.y + sobelNormalVec.z;
                // sobelNormal = sobelNormal * _NormalMultiplier;
                // sobelNormal = pow(sobelNormal, 10);
                //
                // float sobelOutline = saturate(max(sobelDepth, sobelNormal));
                
                half3 outlineColor = lerp(sceneColor, _EdgeColor.rgb * sceneColor, _EdgeColor.a);
                half3 color = lerp(sceneColor, outlineColor, sobelDepth);
                
                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}