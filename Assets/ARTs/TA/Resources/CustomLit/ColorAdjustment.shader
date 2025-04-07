Shader "Hidden/Custom/ColorAdjustment"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
    }

    SubShader
    {
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "CustomFunction.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _BlitTexture_TexelSize;
            CBUFFER_END
            
                TEXTURE2D(_BlitTexture);
                SAMPLER(sampler_BlitTexture);

                uniform half3 _ColorFilter;
                uniform float _Hue;
			    uniform float _Contrast;
			    uniform float _Saturation;
			    uniform float _Lightness;

            struct Attributes
            {
                float2 uv			: TEXCOORD0;
            	uint vertexID		: SV_VertexID;
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

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
                output.uv = GetFullScreenTriangleTexCoord(input.vertexID);

                return output;
            }
            
            half4 frag(Varyings input) : SV_TARGET
            {
                half3 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, input.uv).rgb;

                color = min(color, 60);
                
                //Lightness
                color *= _Lightness;
                
                //Contrast
                color = saturate(Contrast(color, _Contrast));

                //Color Filter
                color *= _ColorFilter;

                color = max(color, 0);

                //HUE
                color = saturate(Hue(color, _Hue));
                
                //Saturation
                color = saturate(Saturation(color, _Saturation));
                
                color = max(color, 0);
                
                return half4(color, 1);
            }
        ENDHLSL

        ZTest Always Cull Off ZWrite Off

        Pass
        {
            NAME "COLOR ADJUSTMENT"

            HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
            ENDHLSL
        }
    }
    Fallback Off
}
