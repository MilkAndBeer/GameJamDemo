Shader "Custom/GrassBendingRTPrePassPS"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            // With SRP we introduced a new "RenderPipeline" tag in Subshader. This allows you to create shaders
            // that can match multiple render pipelines. If a RenderPipeline tag is not set it will match
            // any render pipeline. In case you want your subshader to only run in URP, set the tag to
            // "UniversalRenderPipeline"
            "RenderPipeline" = "UniversalRenderPipeline"
        }
        
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }

        Pass
        {
            Cull Off
            ZTest Always
            Blend Zero SrcColor

            Tags 
            {
                "LightMode" = "GrassBending"
            }
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            CBUFFER_END

            TEXTURE2D(_MainTex);               SAMPLER(sampler_MainTex);

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                half4  color        : COLOR;
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                half4  color        : COLOR;
                float4 positionCS   : SV_POSITION;
            };

            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;
                output.color = input.color;
                return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * input.color;
                return color;
            }
            ENDHLSL
        }
    }
}
