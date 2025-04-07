Shader "Custom/Water"
{
    Properties 
    {
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _WaveColor ("Wave Color", Color) = (1, 1, 1, 1)
        _ShallowColor ("Shallow Color", Color) = (1, 1, 1, 1)
        _DepthThreshold ("Depth Threshold", Range(0, 1)) = 0.5
        _DepthSmooth ("Depth Smooth", Range(0, 2)) = 0.5
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _ReflectionIntensity ("Reflection Intensity", Range(0, 1)) = 0.5
        _IOR ("IOR", Range(0, 1)) = 0.5
        _Thickness ("Thickness", Range(0, 1)) = 0
        
        [Foldout(1, 2, 0, 1)]_Flow ("Flow_Foldout", float) = 1
        [NoScaleOffset] _FlowMap ("Flow Map", 2D) = "white" {}
        _FlowIntensity ("Flow Intensity", Range(0, 1)) = 1
        _FlowScale ("Flow Scale", Range(0, 10)) = 1
        _FlowSpeed ("Flow Speed", Range(0, 1)) = 0.5
        _FlowDir ("Flow Direction", Vector) = (1, 0, 0, 0)

        [Foldout(1, 2, 0, 1)]_Wave ("Wave_Foldout", float) = 1
        [NoScaleOffset] _WaveMap ("Wave Map", 2D) = "white" {}
        //_WaveIntensity ("Wave Intensity", Range(0, 1)) = 1
        _WaveScale ("Wave Scale", Range(0, 10)) = 1
        _WaveSpeed ("Wave Speed", Range(0, 1)) = 0.5
        _WaveDir ("Wave Direction", Vector) = (1, 0, 0, 0)
        [NoScaleOffset] _FallMap ("Fall Map", 2D) = "white" {}
        _FallScale ("Fall Scale", Range(0, 20)) = 1
        _FallSpeed ("Fall Speed", Range(0, 3)) = 0.5
        
        //[NoScaleOffset] _DistortionMap ("Distortion Map", 2D) = "white" {}

        [Foldout(1, 2, 0, 1)]_Foam ("Foam_Foldout", float) = 1
        _FoamIntensity ("Foam Intensity", Range(0, 1)) = 1
        _FoamNoiseIntensity ("Foam Noise Intensity", Range(0, 1)) = 1
        _FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _FoamMap ("Foam Map", 2D) = "white" {}
        [Toggle(_EDGEFOAM)] _EdgeFoam("Edge Foam On", Float) = 0
        _FoamThreshold ("Foam Threshold", Range(0, 1)) = 0
        _FoamSmooth ("Foam Smooth", Range(0, 2)) = 1
        _FoamStep ("Foam Step", Range(0, 1)) = 0.5
        _FoamScale ("Foam Scale", Range(0, 10)) = 1
        _FoamSpeed ("Foam Speed", Range(0, 1)) = 0.1
        
//        _EdgeScale ("Edge Scale", Range(0, 10)) = 1
//        _EdgeSpeed ("Edge Speed", Range(0, 1)) = 0.1
//        _EdgeFoamThreshold ("Edge Foam Threshold", Range(0, 1)) = 1
//        _EdgeFoamSmooth ("Edge Foam Smooth", Range(0, 2)) = 1
//        _EdgeStep ("Edge Step", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_Caustics ("Caustics_Foldout", float) = 1
        //_CausticsColor ("Caustics Color", Color) = (1, 1, 1, 1)
        _SplitRGB ("Split RGB", Range(0, 0.1)) = 0.05
        [NoScaleOffset] _CausticsMap ("Caustics Map", 2D) = "white"{}
        _CausticsIntensity ("Caustics Intensity", Range(0, 20)) = 1
        _CausticsScale ("Caustics Scale", Range(0, 10)) = 1
        _CausticsSpeed ("Caustics Speed", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_Height ("Height_Foldout", float) = 1
        _OffsetFrequency ("Offset Frequency", Range(0, 2)) = 1
        _OffsetLength ("Offset Length", Range(0, 10)) = 2
        _OffsetMagnitude ("Offset Magnitude", Range(0, 2)) = 0.5

        [Foldout(1, 2, 0, 1)]_Other ("Other_Foldout", float) = 1
        [Toggle(_RECEIVE_SHADOWS_OFF)] _ReceiveShadows("Receive Shadows Off", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "Water"
            Tags{"LightMode" = "UniversalForward"}

            // Render State Commands ---------------
            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull Back
            // -------------------------------------

            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex WaterVertex
            #pragma fragment WaterFragment
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
            #pragma multi_compile _ _CLOUD
            #pragma multi_compile _ _MASKON
            // -------------------------------------
            
            // Material Keywords -------------------
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _EDGEFOAM
            //--------------------------------------
            
            #include "WaterLitInput.hlsl"
            #include "WaterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "WaterShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            // Render State Commands ---------------
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back
            // -------------------------------------

            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex WaterShadowVertex
            #pragma fragment WaterShadowFragment
            // -------------------------------------
            
            // Universal Pipeline keywords ---------
            // -------------------------------------
            
            // Material Keywords -------------------
            
            // -------------------------------------
            
            #include "WaterLitInput.hlsl"
            #include "WaterShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "WaterDepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            // Render State Commands ---------------
            ColorMask R
            ZWrite On
            Cull Back
            // -------------------------------------

            HLSLPROGRAM

            // -------------------------------------
            // Shader Stages
            #pragma vertex WaterDepthOnlyVertex
            #pragma fragment WaterDepthOnlyFragment

            // Universal Pipeline keywords ---------
            // -------------------------------------
            
            // Unity defined keywords --------------
            
            // -------------------------------------
            
            // Material Keywords -------------------

            // -------------------------------------
            
            #include "WaterLitInput.hlsl"
            #include "WaterDepthOnlyPass.hlsl"
            ENDHLSL
        }

//        Pass
//        {
//            Name "Meta"
//            Tags
//            {
//                "LightMode" = "Meta"    
//            }
//            
//            HLSLPROGRAM
//
//            // Shader Stages -----------------------
//            #pragma vertex MetaVertex
//            #pragma fragment MetaFragmentLit
//            
//            // Render State Commands ---------------
//            // -------------------------------------
//            
//            // Material Keywords -------------------
//            #pragma shader_feature_local _ALPHATEST
//            #pragma shader_feature_local _EMISSION
//            // -------------------------------------
//
//            #include "WaterLitInput.hlsl"
//            #include "WaterMetaPass.hlsl"
//
//            ENDHLSL
//        }
    }

    CustomEditor "EBGame.SimpleShaderGUI"
}
