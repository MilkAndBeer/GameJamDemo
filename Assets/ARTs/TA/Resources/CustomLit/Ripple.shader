Shader "Custom/Ripple"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        _XTiling ("X Tiling", Range(0, 3)) = 1
        _YTiling ("Y Tiling", Range(0, 3)) = 1
        _Speed ("Speed", Range(0, 3)) = 0.5
        _Threshold ("Threshold", Range(0, 1)) = 0.5
        _Cut ("Cut", Range(0, 1)) = 0.5
        _Softness ("Softness", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_OtherParameter ("Others_Foldout", float) = 1
        [Toggle(_RECEIVE_SHADOWS_OFF)] _DisableShadows("Shadows Off", Float) = 0
    }
    
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "ShadingModels.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
            half3 _BaseColor;
            float _XTiling;
            float _YTiling;
            float _Speed;
            half  _Threshold;
            half  _Cut;
            half  _Softness;
        CBUFFER_END

        TEXTURE2D(_BaseMap);                          SAMPLER(sampler_BaseMap);
        
    ENDHLSL

    SubShader
    {
        Tags
        { "RenderPipeline" = "UniversalPipeline" "Queue" = "Overlay"}

        // ------------------------------------------------------------------
        Pass
        {
            Name "RIPPLE"
            Tags
            {
                "LightMode" = "UniversalForward"
                
            }

            // Render State Commands ---------------
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
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
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
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
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float3 normalWS                 : TEXCOORD3;
                float2 staticLightmapUV         : TEXCOORD4;

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
                output.positionWS = vertexInput.positionWS;
                output.normalWS = normalInput.normalWS;
                output.uv = input.texcoord;

                OUTPUT_LIGHTMAP_UV(input.texcoord1.xy, unity_LightmapST, output.staticLightmapUV.xy);

                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                CustomData customData = (CustomData)0;

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
                
                //Time
                float time = fmod(_Time.y, 2e5);
                float2 uv = float2(input.uv.x * _XTiling, input.uv.y * _YTiling - time * _Speed);
                half2 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).rg;
                half ripple = step(_Threshold, min(baseMap.r, baseMap.g));
                half3 baseColor = _BaseColor * ripple;
                half alpha = LinearStep(_Cut, _Cut + _Softness, saturate(1 - input.uv.y)) * ripple;
                
                //CustomData
                customData.baseColor = baseColor;
                customData.smoothness = 0;
                customData.perRoughness = 1.0 - customData.smoothness;
                customData.roughness = max(customData.perRoughness * customData.perRoughness, 0.0078125);
                customData.normalWS = input.normalWS;
                customData.positionWS = input.positionWS;
                customData.viewDirWS = viewDirWS;
                customData.shadowCoord = shadowCoord;
                customData.staticLightmapUV = input.staticLightmapUV;
                
                half3 color = DefaultShading(customData, _Exposure);
                
                return half4(color, alpha);
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EBGame.SimpleShaderGUI"
}

