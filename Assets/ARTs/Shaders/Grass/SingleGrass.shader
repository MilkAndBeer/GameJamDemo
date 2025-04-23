Shader "Custom/SingleGrass"
{
	Properties
	{
		[Foldout(1, 2, 0, 1)]_Basic("Basic_Foldout", float) = 1
		_BaseColorTexture("BaseColorTexture", 2D) = "white" {}
		_BaseColor("Base Color", Color) = (1, 1, 1, 1)
		_GroundColor("Ground Color", Color) = (0.5, 0.5, 0.5, 1)
		_Threshold("Threshold", Range(0, 1)) = 0.5
		_Smooth("Smooth", Range(0, 1)) = 0.5
		_RandomIntensity("Random Intensity", Range(0, 100)) = 0
		_RandomSize("Random Size", Range(0, 50)) = 10
        //[NoScaleOffset] _BaseMap("Base Map", 2D) = "white" {}

		[Foldout(1, 2, 0, 1)]_Shape("Shape_Foldout", float) = 1
		_Height("Height", Float) = 1
		_HeightMin("Height Min", Range(0, 1)) = 0
		_HeightMax("Height Max", Range(0, 1)) = 1
		_Width("Width", Float) = 1
		_WidthMin("Width Min", Range(0, 1)) = 0
		_WidthMax("Width Max", Range(0, 1)) = 1
		_Noise("Scale Noise", Float) = 5

		[Foldout(1, 2, 0, 1)]_Collision("Collision_Foldout", float) = 1
		_ColInstensity("Collision Intensity", Range(0, 1)) = 0
	
		[Foldout(1, 2, 0, 1)]_Other("Other_Foldout", float) = 1
		_RandomNormal("Random Normal", Float) = 0.15
		[Toggle(_RECEIVE_SHADOWS_OFF)]_DisableShadows("Shadows Off", Float) = 0

	}

	SubShader
	{
		Tags{"RenderType" = "Opaque"}

		HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

		TEXTURE2D(_BaseMap);			SAMPLER(sampler_BaseMap);
		TEXTURE2D(_BaseColorTexture);	SAMPLER(sampler_BaseColorTexture);

		CBUFFER_START(UnityPerMaterial)
			float3 _PivotPosWS;
			float2 _BoundSize;
			float4 _BaseColorTexture_ST;

			float _Noise;
			float _Height;		float _HeightMin;		float _HeightMax;
			float _Width;		float _WidthMin;		float _WidthMax;

			//COLOR
			float _Threshold;		float _Smooth;		float _Random;		float _RandomSize;

			//Wind
			float _BendNoise;		float _BendStrength;	float _BendThreshold;	float _BendSmooth;

			//Collision
			float _ColInstensity;

			half3 _BaseColor;
			half3 _GroundColor;

			float3 _LightDirection;
			float3 _LightPosition;

			half _RandomNormal;

			StructuredBuffer<float3> _AllInstancesTransformBuffer;
			StructuredBuffer<uint>	_VisibleInstanceOnlyTransformIDBuffer;
		CBUFFER_END

		struct Attributes
		{
			float4 positionOS	: POSITION;
			float2 uv			: TEXCOORD0;	
			float3 normalOS		: NORMAL;
		};

		float3 GetPositionWS(Attributes input, uint instanceID : SV_InstanceID)
		{
			float3 perGrassPivotPosWS = _AllInstancesTransformBuffer[_VisibleInstanceOnlyTransformIDBuffer[instanceID]];

			//Random Size
			float noise = SimpleNoise(perGrassPivotPosWS.xz, _Noise);
			float perGrassHeight = lerp(_Height * _HeightMin, _Height * max(_HeightMin, _HeightMax), noise);
			float perGrassWidth = lerp(_Width * _WidthMin, _Width * max(_WidthMin, _WidthMax), noise);
		
            //rotation(make grass LookAt() camera just like a billboard)
            //=========================================
            float3 cameraTransformRightWS = UNITY_MATRIX_V[0].xyz;//UNITY_MATRIX_V[0].xyz == world space camera Right unit vector
            float3 cameraTransformUpWS = UNITY_MATRIX_V[1].xyz;//UNITY_MATRIX_V[1].xyz == world space camera Up unit vector
            float3 cameraTransformForwardWS = -UNITY_MATRIX_V[2].xyz;//UNITY_MATRIX_V[2].xyz == -1 * world space camera Forward unit vector
			
            //Expand Billboard (billboard Left+right)
            float3 positionOS = input.positionOS.x * cameraTransformRightWS * perGrassWidth;//random width from posXZ, min 0.1
            //Expand Billboard (billboard Up)
            positionOS += input.positionOS.y * cameraTransformUpWS;
            //=========================================
			
			//per grass height Scale
			positionOS.y *= perGrassHeight;
			
            //camera distance scale (make grass width larger if grass is far away to camera, to hide smaller than pixel size triangle flicker)        
            float3 viewWS = _WorldSpaceCameraPos - perGrassPivotPosWS;
            float ViewWSLength = length(viewWS);
            positionOS += cameraTransformRightWS * input.positionOS.x * max(0, ViewWSLength * 0.0225);

            //move grass posOS -> posWS
            float3 positionWS = positionOS + perGrassPivotPosWS;               
			
			//TODO Wind And Collision

			return positionWS;
		}
		ENDHLSL
	
		Pass
		{
			Name "GRASS"

			Cull Off
			ZTest LEqual
            ZWrite On
            
            Tags { "LightMode" = "UniversalForward" }

			HLSLPROGRAM
			#pragma vertex vert 
			#pragma fragment frag
			
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            // -------------------------------------
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

			struct Varyings
			{
				float4 positionCS		: SV_POSITION;
				half3 color				: COLOR;	
				float2 staticLightmapUV : TEXCOORD5;
			};

			Varyings vert(Attributes input, uint instanceID : SV_InstanceID)
			{
				Varyings output = (Varyings)0;

				float3 positionWS = GetPositionWS(input, instanceID);

				float3 N = TransformObjectToWorldNormal(input.normalOS, true);
				OUTPUT_LIGHTMAP_UV(input.uv, unity_LightmapST, output.staticLightmapUV.xy);

				CustomData customData = GetDefaultCustomData();
				customData.ramp = _Ramp;

				half3 baseColor = lerp(_GroundColor.rgb, _BaseColor.rgb, LinearStep(_Threshold - _Smooth, _Threshold + _Smooth, input.uv.y));
				float random = SimpleNoise(positionWS.xz, _RandomSize) * _Random;
				float hue = Remap(random, float2(0, 100), float2(0, 360)).x;
				baseColor = saturate(Hue(baseColor, hue));

				customData.baseColor = baseColor;
				customData.alpha = 1;
				customData.perRoughness = 1;
				customData.roughness = 1;
                customData.normalWS = N;
                customData.viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                customData.positionWS = positionWS;
                customData.shadowCoord = TransformWorldToShadowCoord(positionWS);
                customData.staticLightmapUV = output.staticLightmapUV;

				half3 color = DefaultShading(customData, _Exposure);
				output.positionCS = TransformWorldToHClip(positionWS);
				half3 baseColorTex = SAMPLE_TEXTURE2D_LOD(_BaseColorTexture, sampler_BaseColorTexture, TRANSFORM_TEX(positionWS.xz, _BaseColorTexture), 0).rgb;
				output.color = color * baseColorTex;

				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				return half4(input.color, 1);
			}

			ENDHLSL
		}
		
	}

}