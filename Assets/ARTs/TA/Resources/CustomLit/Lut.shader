Shader "Hidden/Custom/Lut"
{
    Properties
    {
       [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
       [HideInInspector] _LutTex ("lutTex", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Name "LUT"
            
            Cull Off
            ZWrite Off
            ZTest Always
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct Attributes
            {
            	uint vertexID		    : SV_VertexID;
            };

            struct Varyings
            {
                float2 uv               : TEXCOORD0;
                float4 positionCS       : SV_POSITION;
            };

            TEXTURE2D_X(_BlitTexture);                      SAMPLER(sampler_BlitTexture);
            TEXTURE2D_X(_LutTex);                           SAMPLER(sampler_LutTex);
            
            //TEXTURE2D_X(_LutMaskTex);                       SAMPLER(sampler_LutMaskTex);
            // sampler2D _LutTex;
            // sampler2D _LutMaskTex;
            //float4 _MainTex_ST;
            
            Varyings vert (Attributes input)
            {
                    Varyings output;
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                    output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
                    output.uv  = GetFullScreenTriangleTexCoord(input.vertexID);
            	
                    return output;
            }

            half4 frag (Varyings input) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D_LOD(_BlitTexture, sampler_BlitTexture, input.uv, 0);

				// half Bcolor = col.b * 63;
				// float2 quad1;
				//
				// quad1.y = floor(floor(Bcolor) / 8);
				// quad1.x = floor(Bcolor) - (quad1.y * 8);
				//
				// float2 quad2;
				// quad2.y = ceil(floor(Bcolor) / 8);
				// quad2.x = ceil(Bcolor) - (quad2.y * 8);
				//
				// float2 uv1;
				// float2 uv2;
				//
				// uv1.x = ((quad1.x) * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * col.r);
				// uv1.y = 1 - (((quad1.y) * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * col.g));
				//
				// uv2.x = ((quad2.x) * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * col.r);
				// uv2.y = 1 - (((quad2.y) * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * col.g));
				//
				// half4 col1 = SAMPLE_TEXTURE2D_LOD(_LutTex, sampler_LutTex, uv1, 0);
				// half4 col2 = SAMPLE_TEXTURE2D_LOD(_LutTex, sampler_LutTex, uv2, 0);
    
				// col.rgb = lerp(col1.rgb,col2.rgb, frac(Bcolor));

            	float u = floor(color.b * 15.0) / 15.0 * 240.0;
			    u = floor(color.r * 15.0) / 15.0 * 15.0 + u;
			    u /= 255.0;

			    float v = floor(color.g * 15.0);
			    v /= 15.0;

			    half4 left = SAMPLE_TEXTURE2D(_LutTex, sampler_LutTex, float2(u, v));

            	u = ceil(color.b * 15.0) / 15.0 * 240.0;
			    u = ceil(color.r * 15.0) / 15.0 * 15.0 + u;
			    u /= 255.0;

			    v = ceil(color.g * 15.0) / 15.0;

			    half4 right = SAMPLE_TEXTURE2D(_LutTex, sampler_LutTex, float2(u, v));

            	color = lerp(left, right, frac(color * 15));
            	
                return color;
            }
            
            ENDHLSL
        }
    }
}