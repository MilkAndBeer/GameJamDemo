Shader "Hidden/Custom/PreHeightSave"
{
  HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	
	struct Attributes
	{
		float3 positionOS  : POSITION;
	};

	struct v2f {
		float4	vertex : SV_POSITION;
		float	depth : TEXCOORD2;
	};

    v2f vert (Attributes input)
	{
		v2f o;
		o.vertex = TransformObjectToHClip(input.positionOS);
		o.depth =TransformObjectToWorld(input.positionOS).y;
		return o;
	}
			
	float4 frag (v2f i) : SV_Target
	{
		float tempDepth = abs(i.depth);//
		float tempOn = i.depth >= 0 ? 1 : 0;
		//将255米的高度压缩到0-1写入r，每一米内的高度写入b，复原时r*255+b就是实际高度
		return float4(floor(tempDepth)/255, frac(tempDepth), tempOn, 1);
	}
  ENDHLSL

  SubShader
  {
      Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "LightMode" = "UniversalForward" }
      Pass
      {
		  Blend One Zero
		  ZWrite On
		  ZTest LEqual
		  Offset 0,0
		  Cull Back

          HLSLPROGRAM
              #pragma vertex vert
              #pragma fragment frag
          ENDHLSL
      }
  }
}
