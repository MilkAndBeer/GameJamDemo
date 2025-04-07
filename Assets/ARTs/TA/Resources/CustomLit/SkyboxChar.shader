Shader "Custom/SkyboxChar"
{
    Properties
    {
        [HDR] _TopColor ("Top Color", Color) = (1, 1, 1, 1)
        [HDR] _BottomColor ("Bottom Color", Color) = (0, 0, 0, 1)
        _Threshold ("Threshold", Range(0, 1)) = 0.5
        _Smooth ("Smooth", Range(0, 1)) = 0.5
        
        [Toggle(_TEX)] _Texture ("Enable Texture", Float) = 0
        [NoScaleOffset] _BackMap ("Background Map", 2D) = "white"{}
        _Tiling ("Tiling", Float) = 1
        _Speed ("Speed", Float) = 0
        _Horizontal ("Horizontal", Range(-1, 1)) = 1
        _Vertical ("Vertical", Range(-1, 1)) = 0
        [HDR] _DetailColor ("Detail Color", Color) = (1, 1, 1, 1)
        _DetailBlend ("Detail Blend", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Geometry"
            "IgnoreProjector" = "True"
        }
        
        Pass
        {
            Name "CharLit"
            Tags
            {
                //"LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            Cull Off
            ZWrite Off

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            half3 _TopColor;
            half3 _BottomColor;
            half _Threshold;
            half _Smooth;
            half3 _DetailColor;
            half _DetailBlend;
            half _Tiling;
            float _Speed;
            float _Horizontal;
            float _Vertical;
            CBUFFER_END

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #pragma shader_feature_local _TEX

            struct Attributes
            {
                float4 positionOS   : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS               : SV_POSITION;
                float4 positionSS               : TEXCOORD0;
                float3 positionVS               : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            #if defined _TEX
                TEXTURE2D(_BackMap);                SAMPLER(sampler_BackMap);
            #endif
            
            Varyings LitPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                output.positionSS = ComputeScreenPos(vertexInput.positionCS);
                output.positionCS = vertexInput.positionCS;
                output.positionVS = vertexInput.positionVS;
                
                return output;
            }

            half4 LitPassFragment(Varyings input) : SV_Target
            {
                float2 positionSS = input.positionSS.xy / input.positionSS.w;
                float backGround = smoothstep(_Threshold - _Smooth, _Threshold + _Smooth, positionSS.y);
                //float backGround = (1 - positionSS.x) * positionSS.y;
                //half3 color = lerp(_BottomColor, _TopColor, backGround);

                #if defined _TEX
                    float2 uv = -input.positionVS.xy / input.positionVS.z;
                    float time = fmod(_Time.y, 2e5);
                    float2 offset = float2(_Speed * time * _Horizontal, -_Speed * time * _Vertical);
                    half backMask = SAMPLE_TEXTURE2D(_BackMap, sampler_BackMap, uv * _Tiling - offset).r;
                    half3 backColor = lerp(_BottomColor, _TopColor, backGround);
                    half3 color = lerp(backColor, _DetailColor.rgb, backMask * _DetailBlend);
                #else
                    half3 color = lerp(_BottomColor, _TopColor, backGround);
                #endif
                
                return half4(color, 1);
            }
            
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
