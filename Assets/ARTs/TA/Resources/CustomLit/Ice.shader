Shader "Custom/Ice"
{
    Properties
    {
        _TopColor ("Top Color", Color) = (1, 1, 1, 1)
        _BottomColor ("Bottom Color", Color) = (0, 0, 0, 1)
        
        _Reflection ("_Reflection", Range(0, 1)) = 0
        _RimStrength ("Rim Strength", Range(0, 3)) = 0.5
    }
    
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
        half3 _TopColor;
        half3 _BottomColor;
        float _Reflection;
        float _RimStrength;
        CBUFFER_END
        
    ENDHLSL

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" }

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            Name "Ice"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            Cull Back
            ZWrite On
            ZTest LEqual
            // -------------------------------------

            HLSLPROGRAM

            #include "ShadingModels.hlsl"

            // Shader Stages -----------------------
            #pragma vertex Vert
            #pragma fragment Frag
            // -------------------------------------
            

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                float3 viewDirWS                : TEXCOORD1;
                float3 positionWS               : TEXCOORD2;
                float4 positionSS               : TEXCOORD3; 
                float3 normalWS                 : TEXCOORD4;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D_X(_PlanarReflectionTexture);          SAMPLER(sampler_PlanarReflectionTexture);

            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.positionSS = ComputeScreenPos(vertexInput.positionCS);
                output.viewDirWS = GetWorldSpaceNormalizeViewDir(output.positionWS);
                output.normalWS = normalInput.normalWS;
                output.uv = input.texcoord;

                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light light = GetMainLight(shadowCoord);

                float3 pos = saturate(input.positionWS - TransformObjectToWorld(float3(0, 0, 0))) + 0.4;
                float rim = saturate(dot(normalize(input.viewDirWS), input.normalWS));
                float softRim = 1 - rim;
                float hardRim = round(softRim);
                float innerRim = 1.5 + rim;

                half3 baseColor = _TopColor * pow(innerRim, 0.7) * lerp(_BottomColor, _TopColor, pos.y);
                half3 emission = _TopColor * lerp(hardRim, softRim, pos.x + pos.y) * (_RimStrength * pos.y);
                float2 uv = input.positionSS.xy / input.positionSS.w;
                half3 reflection = SAMPLE_TEXTURE2D_X(_PlanarReflectionTexture, sampler_PlanarReflectionTexture, uv).rgb * _Reflection;

                half3 color = (baseColor + reflection + emission) * light.color * light.shadowAttenuation * light.distanceAttenuation;
    
                return half4(color, 1);
            }
            
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "EBGame.SimpleShaderGUI"
}
