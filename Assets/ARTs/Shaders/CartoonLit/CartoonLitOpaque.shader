Shader "CZL/CartoonLitOpaque"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap("Base Map", 2D) = "white" {}

        [Foldout(1, 2, 0, 1)]_HSL("HSL_Foldout", float) = 1
        _H("Hue", Range(0, 100)) = 0
        _S("Saturation", Range(0, 5)) = 1
        _L("Lightness", Range(0, 5)) = 1
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

            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "CartoonLitInput.hlsl"
            #include "CartoonLitForwardPass.hlsl"

            ENDHLSL
        }
    }
}
