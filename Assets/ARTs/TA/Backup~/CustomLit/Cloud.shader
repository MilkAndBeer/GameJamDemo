Shader "Custom/Cloud"
{
    Properties
    {
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "white" {}
        _BrightColor ("Cloud Bright Color", Color) = (1, 1, 1, 1)
        _ShadowColor ("Cloud Shadow Color", Color) = (0, 0, 0, 1)
        _CloudAmount ("Cloud Amount", Range(0, 1)) = 1
        _CloudFalloff ("Cloud Falloff", Range(0, 1)) = 0.5
        _CloudNoiseScale ("Cloud Noise Scale", Range(0, 50)) = 1
        _CloudNoiseSpeed ("Cloud Noise Speed", Range(0, 1)) = 1
        _CloudNoiseIntensity ("Cloud Noise Intensity", Range(0, 1)) = 1
        _RimColor ("Cloud Rim Color", Color) = (1, 1, 1, 1)
        _RimStrength ("Rim Strength", Range(0, 3)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
            "IgnoreProjector" = "True"
        }

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "CloudLit"
            Tags
            {
                //"LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZWrite Off
            // -------------------------------------

            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            // -------------------------------------
            
            // Material Keywords
            
            //#pragma shader_feature_local _SUBSURFACE

            // Universal Pipeline keywords ---------
            #pragma multi_compile _ _FORWARD_PLUS
            // -------------------------------------
            
            // Unity defined keywords --------------

            // -------------------------------------

            #include "CloudLitInput.hlsl"
            #include "CloudForwardPass.hlsl"
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "EBGame.SimpleShaderGUI"
}
