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

		[Foldout(1, 2, 0, 1)]_Wind("Wind_Foldout", float) = 1
		_BendStrength("Bend Strength", Range(0, 1)) = 0.5
		_BendThreshold("Bend Threshold", Range(0, 1)) = 0.5
		_BendSmooth("Bend Smooth", Range(0, 1)) = 0.5
		_BendNoise("Bend Noise", Range(0, 50)) = 20

		[Foldout(1, 2, 0, 1)]_Collision("Collision_Foldout", float) = 1
		_ColInstensity("Collision Intensity", Range(0, 1)) = 0
	
		[Foldout(1, 2, 0, 1)]_Other("Other_Foldout", float) = 1
		_RandomNormal("Random Normal", Float) = 0.15
		[Toggle(_RECEIVE_SHADOWS_OFF)]_DisableShadows("Shadows Off", Float) = 0

		//make SRP batcher happy
		[HideInInspector] _PivotPosWS("_PivotPosWS", Vector) = (0, 0, 0, 0)
		[HideInInspector] _BoundSize("_BoundSize", Vector) = (1, 1, 0)
		[HideInInspector] _GrassGroupID("_GrassGroupID", int) = 0
	}

	SubShader
	{
		Tags{"RenderType" = "Opaque"}

		HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		//#include "../Common/CustomCommonFunction.hlsl"
		#include "../CartoonLit/CartoonCustomData.hlsl"
		#include "../CartoonLit/CartoonShadingModels.hlsl"

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
			StructuredBuffer<uint> _VisibleInstanceClassOffsetBuffer;
			int _GrassGroupIDIndex;
		CBUFFER_END

		struct Attributes
		{
			float4 positionOS	: POSITION;
			float2 uv			: TEXCOORD0;	
			float3 normalOS		: NORMAL;
		};

		float3 GetPositionWS(Attributes input, uint instanceID : SV_InstanceID)
		{
			uint tempIndex = _VisibleInstanceOnlyTransformIDBuffer[instanceID];
			float3 perGrassPivotPosWS = _AllInstancesTransformBuffer[tempIndex];//we pre-transform to posWS in C# now
			uint tempOffsetMinIndex = _VisibleInstanceClassOffsetBuffer[_GrassGroupIDIndex];
			uint tempOffsetMaxIndex = _VisibleInstanceClassOffsetBuffer[_GrassGroupIDIndex + 1];
			//start from pivot posWS
			perGrassPivotPosWS = tempIndex >= tempOffsetMinIndex ? perGrassPivotPosWS : float3(-1000, -1000, -100);
			//end from pivot posWS
			perGrassPivotPosWS = tempOffsetMinIndex > tempIndex ? perGrassPivotPosWS : float3(-1000, -1000, -100);

			//Random Size
			float noise = SimpleNoise(perGrassPivotPosWS.xz, _Noise);
			float perGrassHeight = lerp(_Height * _HeightMin, _Height * max(_HeightMin, _HeightMax), noise);
			float perGrassWidth = lerp(_Width * _WidthMin, _Width * max(_WidthMin, _WidthMax), noise);

			//rotation(make grass LookAt() camera just like a billboard)
            //=========================================
			float3 cameraTransformRightWS = UNITY_MATRIX_V[0].xyz;//UNITY_MATRIX_V[0].xyz == world space camera Right unit vector
            float3 cameraTransformUpWS = UNITY_MATRIX_V[1].xyz;//UNITY_MATRIX_V[1].xyz == world space camera Up unit vector
            float3 cameraTransformForwardWS = -UNITY_MATRIX_V[2].xyz;//UNITY_MATRIX_V[2].xyz == -1 * world space camera Forward unit vector
		
			float3 positionOS = input.positionOS.x * cameraTransformRightWS * perGrassWidth;
			positionOS += input.positionOS.y * cameraTransformUpWS;
			positionOS.y *= perGrassHeight;
			
            //camera distance scale (make grass width larger if grass is far away to camera, to hide smaller than pixel size triangle flicker)  
			float3 viewWS = _WorldSpaceCameraPos - perGrassPivotPosWS;
			float viewWSLength = length(viewWS);
			positionOS += cameraTransformRightWS * input.positionOS.x * max(0, viewWSLength * 0.0225);

			float3 positionWS = positionOS + perGrassPivotPosWS;

			float time = fmod(_Time.y, 2e5);

			//TODO Wind or Collision


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

				CartoonCustomData customData = GetDefaultCartoonCustomData();
				//customData.ramp = _Ramp;

				half3 baseColor = lerp(_GroundColor.rgb, _BaseColor.rgb, LinearStep(_Threshold - _Smooth, _Threshold + _Smooth, input.uv.y));
				float random = SimpleNoise(positionWS.xz, _RandomSize) * _Random;
				float hue = Remap(random, float2(0, 100), float2(0, 360)).x;
				baseColor = saturate(Hue(baseColor, hue));

				customData.baseColor = baseColor;
				customData.baseAlpha = 1;
				customData.perRoughness = 1;
				customData.roughness = 1;
                customData.normalWS = N;
                customData.viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                customData.positionWS = positionWS;
                customData.shadowCoord = TransformWorldToShadowCoord(positionWS);
                customData.staticLightmapUV = output.staticLightmapUV;

				//--@@@@@@@@@@@
				//half3 color = DefaultShading(customData);
				half3 color = baseColor;

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
		
		//---------------DepthOnly------------------
		Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
            
            // Render State Commands ---------------
            ColorMask R
            ZWrite On
            ZTest LEqual
            Cull Back
            // -------------------------------------
            
            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            // -------------------------------------

            // Universal Pipeline keywords ---------
            
            // -------------------------------------

            // Unity defined keywords --------------
            // -------------------------------------

            struct Varyings
            {
                float4 positionCS               : SV_POSITION;
            };

            Varyings ShadowPassVertex(Attributes input, uint instanceID : SV_InstanceID)
            {
                Varyings output;
                
                float3 positionWS = GetPositionWS(input, instanceID);
                output.positionCS = TransformWorldToHClip(positionWS);

                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_Target
            {
                return input.positionCS.z;
            }

            ENDHLSL
        }
	}

}