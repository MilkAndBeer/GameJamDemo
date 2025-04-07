Shader"Custom/CloudVolume"
{
	Properties
	{
		_MainTex("MainTex",Color) = (1,1,1,1)
		_Noise3D("Noise3D",3D) = ""{}
		_NoiseScale("NoiseScale",Range(0.0,200.0)) = 1
		_Speed("Speed",Range(0.0,20.0)) = 1
		_ColorTint("Color",Color) = (0.9,0.9,0.9,0.9)
		_AlphaClip("AlphaClipping",Range(-1,1.0)) = 0.5
		_AlphaBlend("AlphaBlend",Range(0.0,1.0)) = 0.5
		_LargeWaves("LargeCloud",Range(0.0,1.0)) = 0.5
		_MiddleWaves("MiddleCloud",Range(0.0,1.0)) = 0.3
		_SmallWaves("SmallCloud",Range(0.0,1.0)) = 0.1
		_BaseColor("_BaseColor",Color) = (1,1,1,1)
		_BackSssStrength("Scattering",Range(0,1)) = 0.1
		_Edgesize("EdgaFadeSize",Range(0,100)) = 50
	}
	SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"IgnoreProjector" = "True"

			
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		
		HLSLINCLUDE

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Assets/ARTs/TA/Resources/CustomLit/CustomFunction.hlsl"

			uniform TEXTURE2D(_MainTex);
			uniform SAMPLER(sampler_MainTex);
			  //TEXTURE3D(_Noise3D);
			  //SAMPLER(sampler_Noise3D);

			  //Define variable
			UNITY_INSTANCING_BUFFER_START(pro)

			//UNITY_DEFINE_INSTANCED_PROP(float4,_BaseColor)
			UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
			UNITY_DEFINE_INSTANCED_PROP(float, _Offsets)
			UNITY_DEFINE_INSTANCED_PROP(float, _CloudScale)
			
			UNITY_INSTANCING_BUFFER_END(pro)
			
			CBUFFER_START(UnityPerMaterial)
				float4 _Noise_ST;
				float _NoiseScale;
				float _Speed;
				float4 _ColorTint;
				float _AlphaClip;
				float _LargeWaves;
				float _MiddleWaves;
				float _SmallWaves;
				float alpha;
				float _BackSssStrength;
				uniform float _EdgeFade[100];
				uniform float _Edgesize;
				float4 _BaseColor;
			CBUFFER_END
		ENDHLSL
		
		Pass
		{
			Tags{"LightMode" = "UniversalForward"}
			
			Blend SrcAlpha OneMinusSrcAlpha
			Zwrite Off
			Cull Off
			
			HLSLPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_instancing
		 	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
		 	#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
		 	#pragma multi_compile _ _SHADOWS_SOFT
			
			sampler3D _Noise3D;
			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);

			float4 _MainTex_ST;

			// float remap(float original_value, float original_min, float original_max, float new_min, float new_max)
		   // {
			  //  return new_min + (((original_value - original_min) / (original_max - original_min)) * (new_max - new_min));
		   // }

				   //梯度clip
		  ///float4 weatherMap = tex3D(_Noise3D, IN.uvw);
			   // float heightPercent = (rayPos.y - _boundsMin.y) / size.y;//计算一个梯度值
			   // float heightGradient = saturate(remap(heightPercent, 0.0, weatherMap.r, 1, 0));
				//return heightGradient;

			struct Attributes
			{
				float4 positionOS			: POSITION;
				float3 normalOS				: NORMAL;
				float2 uv					: TEXCOORD0;
				half4  color				: COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct Varings
			{
				float4 positionCS			: SV_POSITION;
				float2 uv					: TEXCOORD0;
				float3 positionWS			: TEXCOORD1;
				float3 viewDirWS			: TEXCOORD2;
				float3 normalWS				: TEXCOORD3;
				float3 uvw					: TEXCOORD4;
				float4 shadowcoord			: TEXCOORD5;
				float4 positionOS			: TEXCOORD6;
				half4  color				: COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			Varings vert(Attributes IN)
			{
				Varings OUT;

				//uint instanceID = IN.instanceID;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_TRANSFER_INSTANCE_ID(IN,OUT);


				OUT.positionOS = IN.positionOS;
				OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
				OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
				OUT.shadowcoord = TransformWorldToShadowCoord(OUT.positionWS);
	
			   	OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
			   	OUT.viewDirWS = GetCameraPositionWS() - OUT.positionWS;
			   	OUT.uvw = OUT.positionWS.xyz;
			   	OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.color = IN.color;
				
				return OUT;
			}

			float4 frag(Varings IN) :SV_Target
			{
			   //Sampler 3D noise and flow UV
				UNITY_SETUP_INSTANCE_ID(IN);
		
				float3 FlowUVW = IN.uvw / _NoiseScale + (_Time.xyz / 3) * _Speed * float3(1, 1, 1);
				
				//float4 samplerColor = tex3D(_Noise3D, FlowUVW);
				float4 samplerColor = SimpleNoise3D(FlowUVW);
				float alpahtest = samplerColor.a;

				float4 samplerColorNoise = tex3D(_Noise3D, IN.uvw + samplerColor.b * 0.2);

				float AlphaTint = _LargeWaves * samplerColor.r + _MiddleWaves * samplerColor.b + _SmallWaves * samplerColor.g;///MaxGB*1.5;
				clamp(AlphaTint, 0.0, 1.0);
				float clipValue = AlphaTint - UNITY_ACCESS_INSTANCED_PROP(pro, _Cutoff);

		  		float Boundsize = max(0, max(IN.positionOS.x, IN.positionOS.z));
		  		float distanceRP = min(_Edgesize ,sqrt(pow(IN.positionOS.z,2) + pow(IN.positionOS.x,2)));
		  		float edgeWeight = distanceRP / _Edgesize;
		  		clipValue *= 1 - edgeWeight;
		
		  		clip(clipValue);
				//ambient
				half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//mix RGB R for the main ,b for the middle waves , c for the small Waves
				// Smooth the cloud
		 		samplerColor.a = saturate(samplerColor.r + _MiddleWaves * samplerColor.b + _SmallWaves * samplerColor.g);
		 		float SmoothedA = smoothstep(0, 1 - UNITY_ACCESS_INSTANCED_PROP(pro, _Cutoff), samplerColor.a);
		 		//shadow the cloud
		 		//Compute the light
		 		Light light = GetMainLight(IN.shadowcoord);
				
		 		float3 offsetUV = float3((IN.uvw.xz + 0 * light.direction.xz) / _NoiseScale , IN.uvw.y) +(_Time.xyz / 3) * _Speed * half3(1, 1, 1);;
		 		
		 		float4 samplerColorB = tex3D(_Noise3D, offsetUV);
		 		float AlphaTintB = (_LargeWaves * samplerColorB.r + _MiddleWaves * samplerColorB.b + _SmallWaves * samplerColorB.g); ///MaxGB*1.5;
		 		clamp(AlphaTint, 0.0, 1.0);
		
		 		float shadow =  samplerColor.a - AlphaTintB;
		   	
		 		half NdotL = max(0, dot(IN.normalWS, light.direction));
		 		half smoothNdotL = saturate(pow(NdotL, 2 - UNITY_ACCESS_INSTANCED_PROP(pro, _Cutoff)));
		
		 		half3 backLitDir =  normalize(light.direction);
		 		half backSSS = saturate(dot(normalize(IN.viewDirWS), -backLitDir)) * _BackSssStrength * smoothNdotL;

		 		half3 diffuse = samplerColor.a * _ColorTint.rgb * shadow * light.color * light.shadowAttenuation * backSSS ;
		   	
		 		half3 color = _ColorTint.rgb + ambient;
		   	
				return float4(color, clipValue);
			}
			ENDHLSL
		}

		/*Pass
		{

			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}
			
			Cull off
			Zwrite On
			ZTest LEqual

			HLSLPROGRAM
			
		   	#pragma vertex vertshadow
		   	#pragma fragment fragshadow 
		   	
			struct Attributes
			{
			  float4 positionOS : POSITION;
			  float3 normalOS:NORMAL;
			  float2 uv : TEXCOORD;
			  half4 color:COLOR;

			};
		   	
			struct Varings
			{
			  float4 positionCS : SV_POSITION;
			  float2 uv : TEXCOORD;
			  float3 positionWS:TEXCOORD1;
			  float3 viewDirWS:TEXCOORD2;
			  float3 normalWS:TEXCOORD3;
			  float4 shadowcoord:TEXCOORD4;
			};
		   	
			Varings vertshadow (Attributes IN)
		   	{
				Varings Out;
				
				Out.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
				Light MainLight = GetMainLight(Out.shadowcoord);
				float normalWS = TransformObjectToWorldNormal(IN.normalOS.xyz);
				Out.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, MainLight.direction));

				return Out;
			}
		   	
			float fragshadow(Varings IN) :SV_TARGET
		   	{
				float alpha = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.uv).b;
				clip(alpha - _Cutoff);
		   		
				return 0;
			}	
			ENDHLSL
		}*/
	}
}