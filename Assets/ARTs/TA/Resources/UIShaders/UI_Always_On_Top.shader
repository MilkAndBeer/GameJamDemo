// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/UI_Always_On_Top"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        [Toggle(_BILLBOARD)] _Billboard ("Billboard On", Float) = 0
        _Scale ("Scale", Float) = 0.2
        _MinShowScale ("MinShowScale", Float) = 0.5
	    _MaxShowScale ("MaxShowScale", Float) = 2.5
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent+100"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
             "DisableBatching" = "True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Back
        Lighting Off
        ZWrite true
        ZTest Off
        Blend One OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            #pragma shader_feature _BILLBOARD

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                half4  mask : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float _UIMaskSoftnessX;
            float _UIMaskSoftnessY;
            float _Scale;
            float _MinShowScale;
            float _MaxShowScale;

            float map(float s, float a1, float a2, float b1, float b2)
		    {
			    return b1 + (s-a1)*(b2-b1)/(a2-a1);
		    }

            v2f vert(appdata_t v)
            {
                v2f OUT;

                
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                float4 vPosition = UnityObjectToClipPos(v.vertex);
                float3 positionWS = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                float3 localPos = v.vertex.xyz;

                #ifdef _BILLBOARD
                    //vPosition = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0)) + float4(v.vertex.x, v.vertex.y, 0.0, 0.0));
                    

                   float relativeScaler = distance(unity_ObjectToWorld._m03_m13_m23, _WorldSpaceCameraPos);
                   relativeScaler = min(max(relativeScaler * _Scale, _MinShowScale), _MaxShowScale);
                   float4 viewSpaceOrigin = mul( UNITY_MATRIX_MV, float4( 0.0, 0.0, 0.0, 1.0));
                   float4 scaledVertexLocalPos = float4( v.vertex.x, v.vertex.y, 0.0, 0.0) * relativeScaler;
                   vPosition = mul( UNITY_MATRIX_P, viewSpaceOrigin + scaledVertexLocalPos);



                    //// extract world pivot position from object to world transform matrix
                    //float3 worldPos = unity_ObjectToWorld._m03_m13_m23;

                    //// extract x and y scale from object to world transform matrix
                    //float2 scale = float2(
                    //    length(unity_ObjectToWorld._m00_m10_m20),
                    //    length(unity_ObjectToWorld._m01_m11_m21)
                    //    );

                    //// transform pivot position into view space
                    //float4 viewPos = mul(UNITY_MATRIX_V, float4(worldPos, 1.0));

                    //// apply transform scale to xy vertex positions
                    //float2 vertex = v.vertex.xy * scale;

                    //// multiply by view depth for constant view size scaling
                    //vertex *= viewPos.z;

                    //// divide by perspective projection matrix [1][1] if you don't want camera FOV to displayed size
                    //// the * 0.5 is to make a default quad with a scale of 1 be exactly the height of the view
                    //vertex /= UNITY_MATRIX_P._m11 * 0.5;

                    //// along with the perspective projection divide by screen height if you want the scale to be in screen pixels
                    //// vertex /= _ScreenParams.y;

                    //// add vertex positions to view position pivot
                    //viewPos.xy += vertex;

                    //// transform into clip space
                    //vPosition = mul(UNITY_MATRIX_P, viewPos);
                #endif

                
           
                OUT.worldPosition = float4(positionWS, 0);
                //OUT.vertex = UnityObjectToClipPos(localPos);
                OUT.vertex = vPosition;

                float2 pixelSize = vPosition.w;
                pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

                float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
                float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                OUT.mask = half4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                half4 color = IN.color * (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);
				//float fade = smoothstep(16, 15, distance(_WorldSpaceCameraPos.xyz, IN.worldPosition.xyz));

                #ifdef UNITY_UI_CLIP_RECT
                half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
                color.a *= m.x * m.y;
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                color.rgb *= color.a;
                //color *= fade;

                return color;
            }
        ENDCG
        }
    }
}
