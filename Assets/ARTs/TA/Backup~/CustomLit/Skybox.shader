Shader "Custom/Skybox"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_Sky ("Sky_Foldout", float) = 1
        _SkyColor ("Sky Color", Color) = (1, 1, 1, 1)
        _SkyRange ("Sky Range", Range(0, 1)) = 0.5
        _SkyFalloff ("Sky Falloff", Range(0, 1)) = 0.5
        _HorizonColor ("Horizon Color", Color) = (0.5, 0.5, 0.5, 1)
        _GroundColor ("Ground Color", Color) = (0, 0, 0, 1)
        _GroundRange("Ground Range", Range(0, 1)) = 0.5
        _GroundFalloff ("Ground Falloff", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_Sun ("Sun_Foldout", float) = 1
        _SunColor ("Sun Color", Color) = (1, 1, 1, 1)
        _SunIntensity ("Sun Intensity", Range(0, 20)) = 1
        _SunSize ("Sun Size", Range(0, 1)) = 0.1
        _SunFalloff ("Sun Falloff", Range(0, 1)) = 0.5
        _SunBloomColor ("Sun Bloom Color", Color) = (1, 1, 1, 1)
        _SunBloomIntensity ("Sun Bloom Intensity", Range(0, 1)) = 1
        _SunBloomRange ("Sun Bloom Range", Range(0, 1)) = 0
        _SunBloomFalloff ("Sun Bloom Falloff", Range(0, 1)) = 1
        
        [Foldout(1, 2, 0, 1)]_Moon ("Moon_Foldout", float) = 1
        _MoonColor ("Moon Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset]_MoonMap ("Moon Map", Cube) = "white"{}
        _MoonIntensity ("Moon Intensity", Range(0, 20)) = 1
        _MoonSize ("Moon Size", Range(0, 1)) = 0.1
        _MoonFalloff ("Moon Falloff", Range(0, 1)) = 0.5
        _MoonBlock ("Moon Block", Range(0, 1)) = 0.1
        _MoonBloomColor ("Moon Bloom Color", Color) = (1, 1, 1, 1)
        _MoonBloomIntensity ("Moon Bloom Intensity", Range(0, 1)) = 1
        _MoonBloomRange ("Moon Bloom Range", Range(0, 1)) = 0
        _MoonBloomFalloff ("Moon Bloom Falloff", Range(0, 1)) = 1

        [Foldout(1, 2, 0, 1)]_Star ("Star_Foldout", float) = 1
        _StarIntensity ("Star Intensity", Range(0, 1)) = 0
        [NoScaleOffset]_StarMap ("Star Map", Cube) = "white"{}
        
        //[NoScaleOffset] _MoonCubeMap ("Moon Cube Map", Cube) = "black" {}
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Geometry"
            "IgnoreProjector" = "True"
        }

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "SkyLit"
            Tags
            {
                //"LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            Cull Off
            ZWrite Off

            HLSLPROGRAM

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            // -------------------------------------
            // Material Keywords
            
            //#pragma shader_feature_local _SUBSURFACE

            // -------------------------------------
            // Universal Pipeline keywords
            
            // -------------------------------------
            // Unity defined keywords

            //--------------------------------------
            // GPU Instancing
            
            #include "SkyboxForwardPass.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "EBGame.SimpleShaderGUI"
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
