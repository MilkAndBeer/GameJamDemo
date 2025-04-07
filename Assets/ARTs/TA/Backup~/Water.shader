Shader "Custom/Water"
{
    Properties 
    {
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _ShallowColor ("Shallow Color", Color) = (1, 1, 1, 1)
        _WaveColor ("Wave Color", Color) = (1, 1, 1, 1)
        _Blend ("Triplanner Blend", Float) = 3
        _DepthIntensity ("Depth Intensity", Range(0, 1)) = 1
        _DepthFalloff ("Depth Falloff", Range(0, 5)) = 1
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _IOR ("IOR", Range(0, 1)) = 0.5
        _Thickness ("Thickness", Range(0, 1)) = 0
        
        [Foldout(1, 2, 0, 1)]_Normal ("Normal_Foldout", float) = 1
        [NoScaleOffset] _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalIntensity ("Normal Intensity", Range(0, 3)) = 1
        _NormalScale ("Normal Scale", Range(0, 10)) = 1
        _NormalSpeed ("Normal Speed", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_Edge ("Edge_Foldout", float) = 1
        _EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeIntensity ("Edge Intensity", Range(0, 1)) = 1
        _EdgeDistance ("Edge Distance", Range(0, 1)) = 1
        _EdgeFalloff ("Edge Falloff", Range(0, 1)) = 1
        
        [Foldout(1, 2, 0, 1)]_Offset ("Offset_Foldout", float) = 1
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "white" {}
        _OffsetFrequency ("Offset Frequency", Range(0, 2)) = 1
        _OffsetLength ("Offset Length", Range(0, 10)) = 2
        _OffsetMagnitude ("Offset Magnitude", Range(0, 2)) = 0.5

        [Foldout(1, 2, 0, 1)]_Wave ("Wave_Foldout", float) = 1
        [NoScaleOffset] _WaveMap ("Wave Map", 2D) = "white" {}
        _WaveIntensity ("Wave Intensity", Range(0, 1)) = 1
        _WaveScale ("Wave Scale", Range(0, 10)) = 0.5
        _WaveSpeed ("Wave Speed", Range(0, 1)) = 0.5

        [Foldout(1, 2, 0, 1)]_Distorted ("Distorted_Foldout", float) = 1
        _DistortionIntensity ("Distortion Intensity", Range(0, 1)) = 1
        _DistortionScale ("Distortion Scale", Range(0, 20)) = 0.5
        _DistortionSpeed ("Distortion Speed", Range(0, 1)) = 0.5

        [Foldout(1, 2, 0, 1)]_Foam ("Foam_Foldout", float) = 1
        _FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
        _FoamThreshold ("Foam Threshold", Range(0, 2)) = 0
        _FoamSmooth ("Foam Smooth", Range(0, 2)) = 1
        _FoamIntensity ("Foam Intensity", Range(0, 1)) = 1
        
        [Foldout(2, 3, 0, 1)]_TopFoam ("TopFoam_Foldout", float) = 1
        [NoScaleOffset] _TopFoamMap ("Top Foam Map", 2D) = "white" {}
        _TopFoamScale ("Top Foam Scale", Range(0, 10)) = 1
        _TopFoamSpeed ("Top Foam Speed", Range(0, 1)) = 0.5
        _TopNoiseScale ("Top Noise Scale", Range(0, 50)) = 1
        _TopNoiseSpeed ("Top Noise Speed", Range(0, 1)) = 0.5
        _TopNoiseIntensity ("Top Noise Intensity", Range(0, 1)) = 1
        
        [Foldout(2, 3, 0, 1)]_FallFoam ("FallFoam_Foldout", float) = 1
        _FallFoamScale ("Fall Foam Scale", Range(0, 20)) = 1
        _FallFoamSpeed ("Fall Foam Speed", Range(0, 1)) = 0.5
        _FallNoiseScale ("Fall Noise Scale", Range(0, 10)) = 1
        _FallNoiseSpeed ("Fall Noise Speed", Range(0, 1)) = 0.5
        _FallNoiseIntensity ("Fall Noise Intensity", Range(0, 1)) = 1
        
        [Foldout(1, 2, 0, 1)]_Caustics ("Caustics_Foldout", float) = 1
        _CausticsColor ("Caustics Color", Color) = (1, 1, 1, 1)
        _SplitRGB ("Split RGB", Range(0, 0.1)) = 0.05
        [NoScaleOffset] _CausticsMap ("Caustics Map", 2D) = "white"{}
        _CausticsIntensity ("Caustics Intensity", Range(0, 20)) = 1
        _CausticsDistance ("Caustics Distance", Range(0, 5)) = 1
        _CausticsFalloff ("Caustics Falloff", Range(0, 5)) = 1
        _CausticsScale ("Caustics Scale", Range(0, 10)) = 1
        _CausticsSpeed ("Caustics Speed", Range(0, 1)) = 0.5

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
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            // -------------------------------------

            // Unity defined keywords --------------
            #pragma multi_compile _ _RAIN
            #pragma multi_compile _ _CLOUD
            #pragma multi_compile _ _MASKON
            // -------------------------------------
            
            // Material Keywords -------------------
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _EMISSION
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
    }

    CustomEditor "EBGame.SimpleShaderGUI"
}
