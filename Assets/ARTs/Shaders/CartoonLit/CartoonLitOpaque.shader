Shader "CZL/CartoonLitOpaque"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_BaseParameter("Base_Foldout", float) = 1
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap("Base Map", 2D) = "white" {}
        
        [Foldout(1, 2, 0, 1)]_DMSMapParameter("DMSMap_Foldout", float) = 1
        [Toggle(_DMSMAPON)]_DMSMapOn("Enable DMSMap", Float) = 0
        _DMSMap("DMS Map(RG:Normal B:Metallic A:Smoothness)", 2D) = "white" {}
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Metallic("Metallic", Range(0, 1)) = 0
        _Normal("Normal", Range(0, 1)) = 1

        [Foldout(1, 2, 0, 1)]_HSL("HSL_Foldout", float) = 1
        _H("Hue", Range(0, 100)) = 0
        _S("Saturation", Range(0, 5)) = 1
        _L("Lightness", Range(0, 5)) = 1

        [Foldout(1, 2, 0, 1)]_EmissionParameter("Emission_Foldout", float) = 1
        [Toggle(_EMISSION)]_Emission("Enable Emission", Float) = 0
        [Toggle(_ISLIGHT)]_IsLight("Is Light", Float) = 0
        [NoScaleOffset] _EmissionMap("Emission Map", 2D) = "while" {}
        _EmissionStrength("Emission Intensity", Range(0, 10)) = 1
        _EmissionColor("Emission Color", Color) = (1, 1, 1)
        _EmissionBakedIntensity("Emission Baked Intensity", Range(0, 10)) = 1

        ////Blending State
        //_Surface("__surface", Float) = 0.0
        //_BlendMode("__blend", Float) = 0.0
        //_Cull("__cull", Float) = 2.0
        //[ToggleUI] _AlphaClip("__alphaClip", Float) = 0.0
        //[HideInInspector] _SrcBlend("__src", Float) = 1.0
        //[HideInInspector] _DstBlend("__dst", Float) = 0.0
        //[HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        //[HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        //[HideInInspector] _ZWrite("__zw", Float) = 1.0
        //[HideInInspector] _BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1.0
        //[HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0
    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            //// -------------------------------------
            //// Render State Commands
            //Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            //ZWrite[_ZWrite]
            //Cull[_Cull]
            //AlphaToMask[_AlphaToMask]
            //// -------------------------------------

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // Universal Pipeline keywords ---------
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            //--------------------------------------
            
            // Unity defined keywords --------------
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            //--------------------------------------

            // Material Keywords -------------------
            #pragma shader_feature_local _DMSMAPON
            #pragma shader_feature_local _EMISSION
            //--------------------------------------

            #include "CartoonLitInput.hlsl"
            #include "CartoonLitForwardPass.hlsl"

            ENDHLSL
        }
        
        //Shadow
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

    }

    CustomEditor "CZLShader.SimpleShaderGUI"
}
