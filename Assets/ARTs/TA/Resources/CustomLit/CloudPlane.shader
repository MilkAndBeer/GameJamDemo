Shader "Custom/CloudPlane"
{
    Properties
    {
        _PlaneBrightColor ("Cloud Bright Color", Color) = (1, 1, 1, 1)
        _PlaneShadowColor ("Cloud Shadow Color", Color) = (0, 0, 0, 1)
        _PlaneDepth ("Cloud Depth", Range(0, 1)) = 1
        _PlaneScale ("Cloud Scale", Range(0, 10)) = 1
        _PlaneSpeed ("Cloud Speed", Range(0, 1)) = 1
        _PlaneThreshold ("Cloud Threshold", Range(0, 1)) = 0.5
        _PlaneFalloff ("Cloud Falloff", Range(0, 1)) = 0.5
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
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
            Name "CloudPlaneLit"
            Tags
            {
                //"LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZWrite On

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            // -------------------------------------
            // Material Keywords
            
            //#pragma shader_feature_local _SUBSURFACE

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _FORWARD_PLUS
            // -------------------------------------
            
            // Unity defined keywords

            //--------------------------------------

            #include "CloudPlaneLitInput.hlsl"
            #include "CloudPlaneForwardPass.hlsl"
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "EBGame.SimpleShaderGUI"
}
