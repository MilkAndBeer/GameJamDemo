Shader "Blit/BlitDepth"
{
    Properties
    {
        
    }
    SubShader
    {
//        Cull Off
//        ZWrite Off
//        ZTest Always
//        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask R

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            Varyings vert(Attributes i) 
            {
                Varyings o = (Varyings)0;
                o.positionCS = TransformObjectToHClip(i.positionOS);
                o.uv = i.uv;
                return o;
            }

            half4 frag(Varyings i) : SV_TARGET
            {
                return half4(0, 0, 0, 0);
            }

            ENDHLSL
        }
    }
}
