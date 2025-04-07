Shader "Hidden/Custom/PreDepthSave"
{
  HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
	
	TEXTURE2D(_CameraDepthTexture);
    SAMPLER(sampler_CameraDepthTexture);

	struct Attributes
	{
		float3 vertex   : POSITION;
	};

	struct v2f {
		float4	vertex : SV_POSITION;
        //float4 screenPos : TEXCOORD0;
	};

    v2f vert (Attributes v)
	{
		v2f o;
		o.vertex = TransformObjectToHClip(v.vertex); //到裁切空间
		//o.screenPos = ComputeScreenPos(o.vertex);    //屏幕空间的齐次坐标
		return o;
	}
			
	float4 frag (v2f i) : SV_Target
	{
		//深度渲染不需要
		return half4(0, 0, 0, 1);

		//float2 screenPos = i.screenPos.xy / i.screenPos.w; //屏幕空间的坐标
		//float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenPos).r; //采样深度
		//float depthValue = Linear01Depth(depth, _ZBufferParams);    //转换深度到0-1区间灰度值
        //return float4(depthValue, depthValue, depthValue, 1.0); //返回显示灰度颜色
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
