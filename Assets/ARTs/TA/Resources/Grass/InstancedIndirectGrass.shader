Shader "Custom/SingleGrass"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_Basic ("Basic_Foldout", float) = 1
        _BaseColorTexture("_BaseColorTexture", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _GroundColor("Ground Color", Color) = (0.5,0.5,0.5)
        _Threshold ("Threshold", Range(0, 1)) = 0.5
        _Smooth ("Smooth", Range(0, 1)) = 0.5
        _Random ("Random Color", Range(0, 100)) = 0
        _RandomSize ("Random Size", Range(0, 50)) = 10
        //[NoScaleOffset] _BaseMap("Base Map", 2D) = "white" {}

        [Foldout(1, 2, 0, 1)]_Shape ("Shape_Foldout", float) = 1
        _Height ("Height", Float) = 1
        _HeightMin ("Height Min", Range(0, 1)) = 0
        _HeightMax ("Height Max", Range(0, 1)) = 1
        _Width ("Width", Float) = 1
        _WidthMin ("Width Min", Range(0, 1)) = 0
        _WidthMax ("Width Max", Range(0, 1)) = 1
        _Noise ("Scale Noise", Float) = 5

        [Foldout(1, 2, 0, 1)]_Wind ("Wind_Foldout", float) = 1
        _BendStrength ("Bend Strength", Range(0, 1)) = 0.5
        _BendThreshold ("Bend Threshold", Range(0, 1)) = 0.5
        _BendSmooth ("Bend Smooth", Range(0, 1)) = 0.5
        _BendNoise ("Bend Noise", Range(0, 50)) = 20
        
        [Foldout(1, 2, 0, 1)]_CollisionParameter ("Collision_Foldout", float) = 1
        _ColIntensity ("Collision Intensity", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_Other ("Other_Foldout", float) = 1
        _RandomNormal("Random Normal", Float) = 0.15
        [Toggle(_RECEIVE_SHADOWS_OFF)] _DisableShadows("Shadows Off", Float) = 0

        //make SRP batcher happy
        [HideInInspector]_PivotPosWS("_PivotPosWS", Vector) = (0,0,0,0)
        [HideInInspector]_BoundSize("_BoundSize", Vector) = (1,1,0)
        [HideInInspector]_GrassGroupID("_GrassGroupID", int) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomLit/ShadingModels.hlsl"
            #include "Assets/ARTs/TA/Resources/CustomLit/LitFunction.hlsl"

            TEXTURE2D(_BaseMap);               SAMPLER(sampler_BaseMap);
            TEXTURE2D(_BaseColorTexture);      SAMPLER(sampler_BaseColorTexture);
            
            CBUFFER_START(UnityPerMaterial)
                float3 _PivotPosWS;
                float2 _BoundSize;
                float4 _BaseColorTexture_ST;

                float _Noise;
                float _Height;          float _HeightMin;           float _HeightMax;
                float _Width;           float _WidthMin;            float _WidthMax;

                //Color
                float _Threshold;           float _Smooth;          float _Random;                   float _RandomSize;
            
                //Wind
                float _BendNoise;       float _BendStrength;        float _BendThreshold;           float _BendSmooth;

                //Collision
                float _ColIntensity;

                half3 _BaseColor;
                half3 _GroundColor;

                float3 _LightDirection;
                float3 _LightPosition;

                half _RandomNormal;

                StructuredBuffer<float3> _AllInstancesTransformBuffer;
                StructuredBuffer<uint> _VisibleInstanceOnlyTransformIDBuffer;
                StructuredBuffer<uint> _VisibleInstanceClassOffsetBuffer;
                int _GrassGroupIDIndex;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS               : POSITION;
                float2 uv                       : TEXCOORD0;
                float3 normalOS                 : NORMAL;
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
                perGrassPivotPosWS = tempOffsetMaxIndex > tempIndex ? perGrassPivotPosWS : float3(-1000, -1000, -100);

                //Random Size
                float noise = SimpleNoise(perGrassPivotPosWS.xz, _Noise);
                float perGrassHeight = lerp(_Height * _HeightMin, _Height * max(_HeightMin, _HeightMax), noise);
                float perGrassWidth = lerp(_Width * _WidthMin, _Width * max(_WidthMin, _WidthMax), noise);

                //get "is grass stepped" data(bending) from RT
                //float2 grassBendingUV = ((perGrassPivotPosWS.xz - _PivotPosWS.xz) / _BoundSize) * 0.5 + 0.5;//claculate where is this grass inside bound (can optimize to 2 MAD)
                //float stepped = tex2Dlod(_GrassBendingRT, float4(grassBendingUV, 0, 0)).x;

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

                //per grass height scale
                positionOS.y *= perGrassHeight;

                //camera distance scale (make grass width larger if grass is far away to camera, to hide smaller than pixel size triangle flicker)        
                float3 viewWS = _WorldSpaceCameraPos - perGrassPivotPosWS;
                float ViewWSLength = length(viewWS);
                positionOS += cameraTransformRightWS * input.positionOS.x * max(0, ViewWSLength * 0.0225);
                

                //move grass posOS -> posWS
                float3 positionWS = positionOS + perGrassPivotPosWS;


                //wind animation (biilboard Left Right direction only sin wave)            
                /*float wind = 0;
                wind += (sin(_Time.y * _WindAFrequency + perGrassPivotPosWS.x * _WindATiling.x + perGrassPivotPosWS.z * _WindATiling.y)*_WindAWrap.x+_WindAWrap.y) * _WindAIntensity; //windA
                wind += (sin(_Time.y * _WindBFrequency + perGrassPivotPosWS.x * _WindBTiling.x + perGrassPivotPosWS.z * _WindBTiling.y)*_WindBWrap.x+_WindBWrap.y) * _WindBIntensity; //windB
                wind += (sin(_Time.y * _WindCFrequency + perGrassPivotPosWS.x * _WindCTiling.x + perGrassPivotPosWS.z * _WindCTiling.y)*_WindCWrap.x+_WindCWrap.y) * _WindCIntensity; //windC
                wind *= input.positionOS.y; //wind only affect top region, don't affect root region
                float3 windOffset = cameraTransformRightWS * wind; //swing using billboard left right direction
                positionWS.xyz += windOffset;*/
                
                float time = fmod(_Time.y, 2e5);

                //Wind
                VertexWind(positionWS, positionOS, _WindDir, _WindSpeed, _WindStrength, _WindNoise, input.uv.y, time);

                //Collision
                VertexCollision(positionWS, positionOS, _ObjectArrayPos, _PosCount, _ColIntensity, input.uv.y);

                return positionWS;
            }
            
        ENDHLSL

        Pass
        {
            Name "GRASS"
            
            Cull Back //use default culling because this shader is billboard 
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
                float4 positionCS               : SV_POSITION;
                half3  color                    : COLOR;
                float2 staticLightmapUV         : TEXCOORD5;
            };

            Varyings vert(Attributes input, uint instanceID : SV_InstanceID)
            {
                Varyings output = (Varyings)0;

                float3 positionWS = GetPositionWS(input, instanceID);
                
                float3 N = TransformObjectToWorldNormal(input.normalOS, true);
                OUTPUT_LIGHTMAP_UV(input.uv, unity_LightmapST, output.staticLightmapUV.xy);

                CustomData customData = (CustomData)0;
                
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
                
                half3 baseColorTex = SAMPLE_TEXTURE2D_LOD(_BaseColorTexture, sampler_BaseColorTexture, TRANSFORM_TEX(positionWS.xz, _BaseColorTexture), 0).rgb;//tex2Dlod(_BaseColorTexture, float4(TRANSFORM_TEX(positionWS.xz,_BaseColorTexture),0,0)).rgb;

                output.color = color * baseColorTex;

                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return half4(input.color, 1);
            }
            ENDHLSL
        }

//        Pass
//        {
//            Name "ShadowCaster"
//            Tags
//            {
//                "LightMode" = "ShadowCaster"
//            }
//            
//            // Render State Commands ---------------
//            ZWrite On
//            ZTest LEqual
//            ColorMask 0
//            Cull Back
//            // -------------------------------------
//            
//            HLSLPROGRAM
//
//            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
//
//            // Shader Stages -----------------------
//            #pragma vertex ShadowPassVertex
//            #pragma fragment ShadowPassFragment
//            // -------------------------------------
//
//            // Universal Pipeline keywords ---------
//            
//            // -------------------------------------
//
//            // Unity defined keywords --------------
//            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
//            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
//            // -------------------------------------
//
//            struct Varyings
//            {
//                float4 positionCS               : SV_POSITION;
//            };
//
//            Varyings ShadowPassVertex(Attributes input, uint instanceID : SV_InstanceID)
//            {
//                Varyings output;
//                
//                float3 positionWS = GetPositionWS(input, instanceID);
//
//                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
//                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
//                #else
//                    float3 lightDirectionWS = _LightDirection;
//                #endif
//                
//                float3 N = TransformObjectToWorldNormal(input.normalOS, true);
//                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, N, lightDirectionWS));
//
//                return output;
//            }
//
//            half4 ShadowPassFragment(Varyings input) : SV_Target
//            {
//                return 0;
//            }
//
//            ENDHLSL
//        }
        
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
    CustomEditor "EBGame.SimpleShaderGUI"
}