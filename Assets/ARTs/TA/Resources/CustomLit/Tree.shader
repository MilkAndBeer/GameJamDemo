Shader "Custom/Tree"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        _Normal ("Normal", Range(0, 1)) = 1
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
        _TopColor ("Top Color", Color) = (1, 1, 1, 1)
        _BottomColor ("Bottom Color", Color) = (0, 0, 0, 1)
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimOffset ("Rim Offset", Range(0, 1)) = 1
        
        [Foldout(1, 2, 0, 1)] _SubsurfaceParameter ("Subsurface_Foldout", float) = 1
        _SubsurfaceRimColor ("Subsurface Color", Color) = (1, 1, 1, 1)
        _SubsurfaceRimIntensity ("Subsurface Intensity", Range(0, 1)) = 1
        _SubsurfaceRimFalloff ("Subsurface Falloff", Range(0, 10)) = 2
        
        [Foldout(1, 2, 0, 1)]_OtherParameter ("Others_Foldout", float) = 1
        [Toggle(_WIND)] _Wind ("Wind On", Float) = 1
        [Toggle(_RECEIVE_SHADOWS_OFF)] _DisableShadows("Shadows Off", Float) = 0
    }
    
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "ShadingModels.hlsl"
        #if defined(LOD_FADE_CROSSFADE)
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/LODCrossFade.hlsl"
        #endif
        
        CBUFFER_START(UnityPerMaterial)
            float _Normal;
            float _Cutoff;
            half3 _TopColor;
            half3 _BottomColor;
            half3 _RimColor;
            float _RimOffset;
            half3 _SubsurfaceRimColor;
            float _SubsurfaceRimIntensity;
            float _SubsurfaceRimFalloff;
        CBUFFER_END
        
        TEXTURE2D(_BaseMap);                SAMPLER(sampler_BaseMap);
        TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
        
    ENDHLSL

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            Name "Tree"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            Cull Off
            ZWrite On
            ZTest LEqual
            // -------------------------------------

            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex Vert
            #pragma fragment Frag
            // -------------------------------------

            // Universal Pipeline keywords ---------
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            // -------------------------------------

            // Material Keywords -------------------
            #pragma shader_feature_local _WIND
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            // -------------------------------------
            
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float3 color        : COLOR;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                float3 viewDirWS                : TEXCOORD1;
                float3 positionWS               : TEXCOORD2;
                //float3 N                        : TEXCOORD3;
                //float4 positionSS               : TEXCOORD4;
                float3 normalWS                 : TEXCOORD5;
                float2 staticLightmapUV         : TEXCOORD6;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float3 positionOS = input.positionOS.xyz;
                float3 positionWS = TransformObjectToWorld(positionOS);

            #if defined _WIND
                float time = fmod(_Time.y, 2e5);
                float bendNoise = SimpleNoise(positionWS.xz + time * _WindSpeed * _WindDir, _WindNoise) - 0.5;
                float3 windDir = float3(_WindDir.x, 0, _WindDir.y);
                float3 wind = float3(bendNoise, 0, bendNoise);
                positionWS += wind * windDir * _WindStrength * input.texcoord.y;
                positionOS = TransformWorldToObject(positionWS);
            #endif
                
                float3 normalOS = (input.color - 0.5) * 2;
                normalOS = float3(-normalOS.x, normalOS.z, -normalOS.y);
                normalOS = lerp(input.normalOS.xyz, normalize(normalOS), _Normal);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(normalOS);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = positionWS;
                //output.N = normalize(positionOS - float3(0, _CenterOffset, 0));
                //output.positionSS = ComputeScreenPos(vertexInput.positionCS);
                output.viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                output.normalWS = normalInput.normalWS;
                output.uv = input.texcoord;
                
                // float NdotV = 1 - abs(dot(output.normalWS, output.viewDirWS));
                // NdotV = smoothstep(0.2, 1, NdotV);
                // float3 offset = -output.viewDirWS * NdotV * _FadeThreshold;
                // output.positionWS += offset;
                // output.positionCS = TransformWorldToHClip(output.positionWS);

                OUTPUT_LIGHTMAP_UV(input.texcoord1.xy, unity_LightmapST, output.staticLightmapUV.xy);

                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                CustomData customData = (CustomData)0;
                
                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
                //half3 baseColor = half3(baseMap.rgb);
                float alpha = baseMap.r;
                clip(alpha - _Cutoff);
                
                customData.baseColor = _TopColor;
                customData.secondColor = _BottomColor;
                customData.alpha = alpha;
                customData.perRoughness = 1;
                customData.roughness = 1;
                customData.shadowCoord = shadowCoord;
                customData.subsurfaceColor = _SubsurfaceRimColor;
                customData.subsurfaceIntensity = _SubsurfaceRimIntensity;
                customData.subsurfaceFalloff = _SubsurfaceRimFalloff;
                customData.normalWS = input.normalWS;
                customData.positionWS = input.positionWS;
                customData.staticLightmapUV = input.staticLightmapUV;
                customData.viewDirWS = input.viewDirWS;
                
                //Rim
                float2 rimUV = float2(input.positionCS.x / _ScreenParams.x, input.positionCS.y / _ScreenParams.y);
                float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V, customData.normalWS));
                float2 rimOffsetUV = rimUV + normalVS.xy * _RimOffset * 0.01;
                float screenDepth = SAMPLE_TEXTURE2D_LOD(_CameraDepthTexture, sampler_CameraDepthTexture, rimUV, 0).r;
                float offsetDepth = SAMPLE_TEXTURE2D_LOD(_CameraDepthTexture, sampler_CameraDepthTexture, rimOffsetUV, 0).r;
                float depth1 = Linear01Depth(screenDepth, _ZBufferParams);
                float depth2 = Linear01Depth(offsetDepth, _ZBufferParams);
                float depthDif = depth2 - depth1;
                
                customData.rimMask = step(0.01, depthDif);
                customData.rimColor = _RimColor;
                
                half3 color = TreeShading(customData, _Exposure);
    
                return half4(color, 1);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State Commands ---------------
            Cull Off
            ZWrite On
            ZTest LEqual
            ColorMask 0
            // -------------------------------------

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Shader Stages -----------------------
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            // -------------------------------------

            // Unity defined keywords --------------
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            // -------------------------------------
            #pragma shader_feature_local _WIND

            float3 _LightDirection;
            float3 _LightPosition;
            
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                //float3 normalWS                 : TEXCOORD1;
                //float3 positionWS               : TEXCOORD2;
                //float4 positionSS               : TEXCOORD3;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

            #if defined _WIND
                float time = fmod(_Time.y, 2e5);
                float bendNoise = SimpleNoise(positionWS.xz + time * _WindSpeed * _WindDir, _WindNoise) - 0.5;
                float3 windDir = float3(_WindDir.x, 0, _WindDir.y);
                float3 wind = float3(bendNoise, 0, bendNoise);
                positionWS += wind * windDir * _WindStrength;
            #endif
                
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

                output.uv = input.texcoord;
                //output.normalWS = normalize(input.positionOS.xyz - float3(0, _CenterOffset, 0));
                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
                //output.positionSS = ComputeScreenPos(output.positionCS);
                //output.positionWS = positionWS;

                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                float alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).r;
                clip(alpha - _Cutoff);

            #ifdef LOD_FADE_CROSSFADE
                LODFadeCrossFade(input.positionCS);
            #endif
                
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State Commands ---------------
            Cull Off
            ZWrite On
            ZTest LEqual
            ColorMask R
            // -------------------------------------

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Shader Stages -----------------------
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            // -------------------------------------

            #pragma shader_feature_local _WIND

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            // -------------------------------------

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                //float3 normalWS                 : TEXCOORD1;
                //float3 positionWS               : TEXCOORD2;
                //float4 positionSS               : TEXCOORD3;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

            #if defined _WIND
                float time = fmod(_Time.y, 2e5);
                float bendNoise = SimpleNoise(positionWS.xz + time * _WindSpeed * _WindDir, _WindNoise) - 0.5;
                float3 windDir = float3(_WindDir.x, 0, _WindDir.y);
                float3 wind = float3(bendNoise, 0, bendNoise);
                positionWS += wind * windDir * _WindStrength;
            #endif
                
                output.uv = input.texcoord;
                output.positionCS = TransformWorldToHClip(positionWS);
                //output.positionSS = ComputeScreenPos(output.positionCS);

                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                float alpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).r;
                clip(alpha - _Cutoff);

            #ifdef LOD_FADE_CROSSFADE
                LODFadeCrossFade(input.positionCS);
            #endif
                
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EBGame.SimpleShaderGUI"
}

