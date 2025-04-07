Shader "Custom/Edge"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_HSL ("HSL_Foldout", float) = 1
        _H ("Hue", Range(0, 100)) = 0
        _S ("Saturation", Range(0, 5)) = 1
        _L ("Lightness", Range(0, 5)) = 1
        [Space(10)] 
        
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        [NoScaleOffset] _DMSMap ("DMS Map", 2D) = "white" {}
        _Tiling ("Tiling", Range(0, 3)) = 1
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Normal ("Normal", Range(0, 1)) = 1
        
        [Foldout(1, 2, 0, 1)]_EdgeParameter ("Edge_Foldout", float) = 1
        [NoScaleOffset] _EdgeBaseMap ("Edge Base Map", 2D) = "white" {}
        [NoScaleOffset] _EdgeDMSMap ("Edge DMS Map", 2D) = "white" {}
        _EdgeSmoothness ("Edge Smoothness", Range(0, 1)) = 0
        _EdgeMetallic ("Edge Metallic", Range(0, 1)) = 0
        _EdgeNormal ("Edge Normal", Range(0, 1)) = 1
        _Cutoff ("Alpha", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_BlendParameter ("Blend_Foldout", float) = 1
        _BlendCut ("Blend Cut", Range(0, 1)) = 0.5
        _BlendSoftness ("Blend Softness", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_OtherParameter ("Others_Foldout", float) = 1
        [Toggle(_RECEIVE_SHADOWS_OFF)] _DisableShadows("Shadows Off", Float) = 0
    }
    
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "ShadingModels.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
            //HSL
            half _H;                            half _S;                            half _L;
            //Basic
            half _Metallic;                     half _Smoothness;                   half _Normal;                   float _Tiling;
            half _EdgeMetallic;                 half _EdgeSmoothness;               half _EdgeNormal;               half  _Cutoff;
            //Blend
            half _BlendCut;                     half _BlendSoftness;
        CBUFFER_END

        TEXTURE2D(_BaseMap);                    SAMPLER(sampler_BaseMap);
        TEXTURE2D(_DMSMap);                     SAMPLER(sampler_DMSMap);
        TEXTURE2D(_EdgeBaseMap);                SAMPLER(sampler_EdgeBaseMap);
        TEXTURE2D(_EdgeDMSMap);                 SAMPLER(sampler_EdgeDMSMap);
        
    ENDHLSL

    SubShader
    {
        Tags
        { "RenderPipeline" = "UniversalPipeline" }

        // ------------------------------------------------------------------
        Pass
        {
            Name "EDGE"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            ZWrite On
            ZTest LEqual
            Cull Back
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
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            // -------------------------------------

            // Unity defined keywords --------------
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ _RAIN
            #pragma multi_compile _ _SNOW
            #pragma multi_compile _ _CLOUD
            #pragma multi_compile _ _MASKON
            // -------------------------------------

            // Material Keywords -------------------
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
                float4 tangentOS    : TANGENT;
                float2 texcoord     : TEXCOORD0;
                float2 texcoord1    : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                float3 positionOS               : TEXCOORD1;
                float4 normalWS                 : TEXCOORD3;
                float4 tangentWS                : TEXCOORD5;
                float4 bitangentWS              : TEXCOORD6;
                float2 staticLightmapUV         : TEXCOORD7;

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

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
                output.positionCS = vertexInput.positionCS;
                output.positionOS = input.positionOS.xyz;
                output.tangentWS = float4(normalInput.tangentWS, vertexInput.positionWS.x);
                output.bitangentWS = float4(normalInput.bitangentWS, vertexInput.positionWS.y);
                output.normalWS = float4(normalInput.normalWS, vertexInput.positionWS.z);
                output.uv.xy = input.texcoord;

                OUTPUT_LIGHTMAP_UV(input.texcoord1.xy, unity_LightmapST, output.staticLightmapUV.xy);

                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                CustomData customData = (CustomData)0;

                float3 positionWS = float3(input.tangentWS.w, input.bitangentWS.w, input.normalWS.w);
                float4 shadowCoord = TransformWorldToShadowCoord(positionWS);
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                float3x3 tbn = float3x3(input.tangentWS.xyz, input.bitangentWS.xyz, input.normalWS.xyz);

                //Base
                float2 uv = positionWS.xz * _Tiling;
                half3 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rgb;

                float hue = Remap(_H, float2(0, 100), float2(0, 360)).x;
                baseColor = saturate(Hue(baseColor, hue));
                baseColor = saturate(Saturation(baseColor, _S));
                baseColor *= _L;

                half4 baseDMS = SAMPLE_TEXTURE2D(_DMSMap, sampler_DMSMap, uv);
                half baseMetallic = baseDMS.b * _Metallic;
                half baseSmoothness = baseDMS.a * _Smoothness;
                float3 baseNormalTS = normalize(UnpackDerivativeHeight(float3(baseDMS.rg, 1)));
                float3 baseNormalWS = normalize(TransformTangentToWorld(baseNormalTS, tbn));

                //Edge
                half4 edgeMap = SAMPLE_TEXTURE2D(_EdgeBaseMap, sampler_EdgeBaseMap, input.uv);
                half3 edgeColor = edgeMap.rgb;
                
                half alpha = edgeMap.a;
                clip(alpha - _Cutoff);

                half4 edgeDMS = SAMPLE_TEXTURE2D(_EdgeDMSMap, sampler_EdgeDMSMap, input.uv);
                half edgeMetallic = edgeDMS.b * _EdgeMetallic;
                half edgeSmoothness = edgeDMS.a * _EdgeSmoothness;
                float3 edgeNormalTS = normalize(UnpackDerivativeHeight(float3(edgeDMS.rg, 1)));
                float3 edgeNormalWS = normalize(TransformTangentToWorld(edgeNormalTS, tbn));

                //Blend
                half blend = LinearStep(_BlendCut, _BlendCut + _BlendSoftness, 1 - input.uv.y);
                baseColor = lerp(baseColor, edgeColor, blend);
                half smoothness = lerp(baseSmoothness, edgeSmoothness, blend);
                half metallic = lerp(baseMetallic, edgeMetallic, blend);
                float3 normalWS = lerp(baseNormalWS, edgeNormalWS, blend);

                //CustomData
                customData.baseColor = baseColor;
                customData.smoothness = smoothness;
                customData.perRoughness = 1.0 - customData.smoothness;
                customData.roughness = max(customData.perRoughness * customData.perRoughness, 0.0078125);
                customData.specular = 1;
                customData.metallic = metallic;
                customData.normalWS = lerp(NormalizeNormalPerPixel(input.normalWS.xyz), normalWS, _Normal);
                customData.positionWS = positionWS;
                customData.viewDirWS = viewDirWS;
                customData.shadowCoord = shadowCoord;
                customData.staticLightmapUV = input.staticLightmapUV;

                half3 color = DefaultShading(customData, _Exposure);
                
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
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

                output.uv = input.texcoord;
                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
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
                output.uv = input.texcoord;
                output.positionCS = TransformWorldToHClip(positionWS);

                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EBGame.SimpleShaderGUI"
}

