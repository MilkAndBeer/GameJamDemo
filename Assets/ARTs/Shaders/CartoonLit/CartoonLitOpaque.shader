Shader "CZL/CartoonLitOpaque"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap("Base Map", 2D) = "white" {}
        _DMSMap("DMS Map( B:Metallic A:Smoothness)", 2D) = "white" {}
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

    }
    SubShader
    {
        Tags{ "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            
            // Material Keywords -------------------
            #pragma shader_feature_local _EMISSION
            //--------------------------------------

            #include "CartoonLitInput.hlsl"
            #include "CartoonLitForwardPass.hlsl"

            ENDHLSL
        }
    }
}
