Shader "Custom/S_RenderSH"
{
    Properties
    {
       
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //float4 c0;
            //float4 c1;
            //float4 c2;
            //float4 c3;
            //float4 c4;
            //float4 c5;
            //float4 c6;
            //float4 c7;
            //float4 c8;
            //float4 c9;
            //float4 c10;
            //float4 c11;
            //float4 c12;
            //float4 c13;
            //float4 c14;
            //float4 c15;
            float4 shData[16];

            #define PI 3.14159265358
            #define Y0(v) (1.0 / 2.0) * sqrt(1.0 / PI)
            #define Y1(v) sqrt(3.0 / (4.0 * PI)) * v.z
            #define Y2(v) sqrt(3.0 / (4.0 * PI)) * v.y
            #define Y3(v) sqrt(3.0 / (4.0 * PI)) * v.x
            #define Y4(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.x * v.z
            #define Y5(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.z * v.y
            #define Y6(v) 1.0 / 4.0 * sqrt(5.0 / PI) * (-v.x * v.x - v.z * v.z + 2 * v.y * v.y)
            #define Y7(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.y * v.x
            #define Y8(v) 1.0 / 4.0 * sqrt(15.0 / PI) * (v.x * v.x - v.z * v.z)
            #define Y9(v) 1.0 / 4.0 * sqrt(35.0 / (2.0 * PI)) * (3 * v.x * v.x - v.z * v.z) * v.z
            #define Y10(v) 1.0 / 2.0 * sqrt(105.0 / PI) * v.x * v.z * v.y
            #define Y11(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.z * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
            #define Y12(v) 1.0 / 4.0 * sqrt(7 / PI) * v.y * (2 * v.y * v.y - 3 * v.x * v.x - 3 * v.z * v.z)
            #define Y13(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.x * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
            #define Y14(v) 1.0 / 4.0 * sqrt(105.0 / PI) * (v.x * v.x - v.z * v.z) * v.y
            #define Y15(v) 1.0 / 4.0 * sqrt(35.0 / (2 * PI)) * (v.x * v.x - 3 * v.z * v.z) * v.x
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 v = i.normal.xyz;
                v = normalize(v);
                float4 approx =
                    shData[0] * Y0(v) +    //c0 * Y0(v) +
                    shData[1] * Y1(v) +    //c1 * Y1(v) +
                    shData[2] * Y2(v) +    //c2 * Y2(v) +
                    shData[3] * Y3(v) +    //c3 * Y3(v) +
                    shData[4] * Y4(v) +     //c4 * Y4(v) + 
                    shData[5] * Y5(v) +     //c5 * Y5(v) + 
                    shData[6] * Y6(v) +     //c6 * Y6(v) + 
                    shData[7] * Y7(v) +     //c7 * Y7(v) + 
                    shData[8] * Y8(v) +    //c8 * Y8(v) +
                    shData[9] * Y9(v) +    //c9 * Y9(v) +
                    shData[10] * Y10(v) +    //c10 * Y10(v) +
                    shData[11] * Y11(v) +    //c11 * Y11(v) +
                    shData[12] * Y12(v) +    //c12 * Y12(v) +
                    shData[13] * Y13(v) +    //c13 * Y13(v) +
                    shData[14] * Y14(v) +    //c14 * Y14(v) +
                    shData[15] * Y15(v)    //c15 * Y15(v)
                    ;
                return half4(approx.rgb, 1);
            }
            ENDCG
        }
    }
}
