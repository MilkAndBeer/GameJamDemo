Shader "Custom/ShadowCull"
{
    Properties
    {
        _Shadow ("Shadow Color", Color) = (0, 0, 0, 1)
    }
    
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "GlobalInput.hlsl"
            #include "CustomFunction.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _Shadow;
            CBUFFER_END
        
        ENDHLSL

        Pass
        {
            Name "ShadowCull"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            //ZWrite On

            HLSLPROGRAM

            #pragma target 3.0

            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            
            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _SHADOWS_SOFT
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex vert
            #pragma fragment frag

            struct Attributes
            {
                float4 positionOS: POSITION;
            };

            struct Varyings
            {
                float4 positionCS: SV_POSITION;
                float3 positionWS: TEXCOORD0;
            };


            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN): SV_Target
            {
                float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                
                half atten = mainLight.shadowAttenuation * mainLight.distanceAttenuation;;
                half alpha = _Shadow.a * saturate(1 - atten);

                //float shellThreshold = max(0.2, 1 - _ShellThreshold);
                float shadowEdge = atten * saturate(1 - atten);
                half3 shadowColor = lerp(_Shadow.rgb * _ShadowColor, _ShadowEdgeColor, shadowEdge);
                
                half4 shadow = half4(shadowColor, alpha);

                return shadow;
            }
            ENDHLSL
        }
    }
}