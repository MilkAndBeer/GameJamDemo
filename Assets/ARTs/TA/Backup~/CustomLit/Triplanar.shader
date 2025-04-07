Shader "Custom/Triplanar"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_Mod ("Shading Mode_Foldout", float) = 1
        [Enum(UnityEngine.Rendering.BlendOp)]  _BlendOp ("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("SrcBlend", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("DstBlend", Float) = 0
        [Enum(Off, 0, On, 1)]_ZWriteMode ("ZWriteMode", float) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("CullMode", float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode ("ZTestMode", Float) = 4
        
//        [Foldout(1, 2, 0, 1)]_StylizedParameter ("Stylized_Foldout", float) = 1
//        _Stylized ("Stylized", Range(0, 1)) = 1
        
        [Foldout(1, 2, 0, 1)]_HSL ("HSL_Foldout", float) = 1
        _H ("Hue", Range(0, 100)) = 0
        _S ("Saturation", Range(0, 5)) = 1
        _L ("Lightness", Range(0, 5)) = 1
        [Space(10)] 
        
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        [NoScaleOffset] _BaseMap ("Base Map", 2D) = "white" {}
        [NoScaleOffset] _DMSMap ("DMS Map", 2D) = "white" {}
        _Smoothness ("Smoothness", Range(0, 1)) = 0
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Normal ("Normal", Range(0, 1)) = 1
        //_SpecIntensity ("Specular Intensity", Range(1, 50)) = 1
        
        [Foldout(1, 2, 0, 1)]_TriplanarParameter ("Triplanar_Foldout", float) = 1
        _TriBlend ("Triplanar Blend", Range(0, 10)) = 3
        _UTilingXY ("U Tiling XY", Range(0, 3)) = 1
        _VTilingXY ("V Tiling XY", Range(0, 3)) = 1
        _UOffsetXY ("U Offset XY", Range(-1, 1)) = 0
        _VOffsetXY ("V Offset XY", Range(-1, 1)) = 0
        _UTilingZY ("U Tiling ZY", Range(0, 3)) = 1
        _VTilingZY ("V Tiling ZY", Range(0, 3)) = 1
        _UOffsetZY ("U Offset ZY", Range(-1, 1)) = 0
        _VOffsetZY ("V Offset ZY", Range(-1, 1)) = 0
        _UTilingXZ ("U Tiling XZ", Range(0, 3)) = 1
        _VTilingXZ ("V Tiling XZ", Range(0, 3)) = 1
        _UOffsetXZ ("U Offset XZ", Range(-1, 1)) = 0
        _VOffsetXZ ("V Offset XZ", Range(-1, 1)) = 0
        
        [Foldout(1, 2, 0, 1)]_TopParameter ("Top_Foldout", float) = 1         
        [Toggle(_TOP)] _Top("Enable Top", Float) = 0
        [NoScaleOffset] _TopBaseMap ("Top Albedo", 2D) = "white"{}
        [NoScaleOffset] _TopDMSMap ("Top DMS", 2D) = "white"{}
        _TopTiling ("Tiling", Range(0, 2)) = 1
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_BottomParameter ("Bottom_Foldout", float) = 1         
        [Toggle(_BOTTOM)] _Bottom("Enable Bottom", Float) = 0
        [NoScaleOffset] _BottomBaseMap ("Bottom Albedo", 2D) = "white"{}
        [NoScaleOffset] _BottomDMSMap ("Bottom DMS", 2D) = "white"{}
        _BottomTiling ("Tiling", Range(0, 2)) = 1
        [Space(10)]
        
        [Foldout(1, 2, 0, 1)]_ThicknessParameter ("Thickness_Foldout", float) = 1
        [Toggle(_THICKNESS)] _Thick ("Enable Thickness", Float) = 0
        _Thickness ("Thickness", Range(0, 1)) = 0
        
        [Foldout(1, 2, 0, 1)]_OtherParameter ("Others_Foldout", float) = 1
        [Toggle(_RECEIVE_SHADOWS_OFF)] _DisableShadows("Shadows Off", Float) = 0
    }
    SubShader
    {
        //Forward Pass
        Pass
        {
            Name "Triplanar"
            Tags 
            {
                "LightMode" = "UniversalForward"
            }
            
            // Render State Commands ---------------
            BlendOp [_BlendOp]
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWriteMode]
            ZTest [_ZTestMode]
            Cull [_CullMode]
            // -------------------------------------
            
            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex TriplanarVertex
            #pragma fragment TriplanarFragment
            // -------------------------------------

            // Universal Pipeline keywords ---------
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            // -------------------------------------

            // Unity defined keywords --------------
            #pragma multi_compile _ _RAIN
            #pragma multi_compile _ _SNOW
            #pragma multi_compile _ _CLOUD
            #pragma multi_compile _ _MASKON
            // -------------------------------------
            
            // Material Keywords -------------------
            #pragma shader_feature_local _TOP
            #pragma shader_feature_local _BOTTOM
            #pragma shader_feature_local _THICKNESS
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            // -------------------------------------

            #include "TriplanarInput.hlsl"
            #include "TriplanarPass.hlsl"
            
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
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull [_CullMode]
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
            
            // Material Keywords -------------------
            #pragma shader_feature_local _THICKNESS
            //#pragma shader_feature_local _DITHER
            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            // -------------------------------------

            #include "TriplanarInput.hlsl"
            #include "ShadowCasterPass.hlsl"

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
            ColorMask R
            BlendOp [_BlendOp]
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWriteMode]
            ZTest [_ZTestMode]
            Cull [_CullMode]
            // -------------------------------------

            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // Universal Pipeline keywords ---------

            // -------------------------------------
            
            // Unity defined keywords --------------

            // -------------------------------------
            
            // Material Keywords -------------------

            #pragma shader_feature_local _THICKNESS

            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            // -------------------------------------

            #include "TriplanarInput.hlsl"
            #include "DepthOnlyPass.hlsl"
            
            ENDHLSL
        }

//        Pass
//        {
//            Name "DepthNormals"
//            Tags
//            {
//                "LightMode" = "DepthNormals"
//            }
//
//            // -------------------------------------
//            // Render State Commands
//            ZWrite On
//            Cull [_CullMode]
//
//            HLSLPROGRAM
//
//            // -------------------------------------
//            // Shader Stages
//            #pragma vertex DepthNormalsVertex
//            #pragma fragment DepthNormalsFragment
//
//            // -------------------------------------
//            // Material Keywords
//            #pragma multi_compile _ _FADE
//            // -------------------------------------
//            
//            // Unity defined keywords
//            #pragma shader_feature_local _ALPHATEST
//            //#pragma shader_feature_local _DITHER
//            #pragma shader_feature_local _THICKNESS
//            #pragma shader_feature_local _HEIGHT
//            #pragma shader_feature_local _WIND
//            #pragma shader_feature_local _COLLISION
//            // -------------------------------------
//            
//            // Universal Pipeline keywords
//
//            //--------------------------------------
//            // GPU Instancing
//            #pragma multi_compile_instancing
//
//            // -------------------------------------
//            // Includes
//            #include "LitInput.hlsl"
//            #include "DepthNormalsPass.hlsl"
//            ENDHLSL
//        }
    }
    
    CustomEditor "EBGame.SimpleShaderGUI"
}