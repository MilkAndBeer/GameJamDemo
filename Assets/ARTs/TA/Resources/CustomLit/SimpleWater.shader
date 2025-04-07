Shader "Custom/SimpleWater"
{
    Properties
    {
        [Foldout(1, 2, 0, 1)]_BasicParameter ("Basic_Foldout", float) = 1
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _ShallowColor ("Shallow Color", Color) = (1, 1, 1, 1)
        _Wave ("Wave Color Blend", Range(0, 1)) = 0.5
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _Specular ("Specular", Range(0, 1)) = 1
        _Alpha ("Alpha", Range(0, 1)) = 0.5
        _IOR ("IOR", Range(0, 1)) = 0.1
        
        [Foldout(1, 2, 0, 1)]_DepthParameter ("Depth_Foldout", float) = 1
        _Depth ("Depth", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_ReflectionParameter ("Reflection_Foldout", float) = 1
        _Reflection ("Reflection", Range(0, 1)) = 0.5
        [NoScaleOffset] _RefCubeMap ("Reflection Cube Map", Cube) = "_Skybox" {}
        
        [Foldout(1, 2, 0, 1)]_HeightParameter ("Height_Foldout", float) = 1
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "white" {}
        _HeightDir ("Height Direction", Vector) = (1, 0, 0, 0)
        _Height ("Height Intensity", Range(0, 5)) = 0.5
        _HeightScale ("Height Scale", Range(0, 1)) = 0.5
        _HeightSpeed ("Height Speed", Range(0, 1)) = 0.5
        [NoScaleOffset] _SideHeightMap ("Side Height Map", 2D) = "white" {}
        _SideHeight ("Side Height Intensity", Range(0, 5)) = 0.5
        _SideHeightScale ("Side Height Scale", Range(0, 1)) = 0.5
        _SideHeightSpeed ("Side Height Speed", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_FoamParameter ("Foam_Foldout", float) = 1
        _FoamColor ("Foam Color", Color) = (1, 1, 1, 1)
        _FoamIntensity ("Foam Intensity", Range(0, 1)) = 0.5
        
        [NoScaleOffset] _TopFoamMap ("Top Foam Map", 2D) = "white" {}
        _TopFoamCut ("Top Foam Cut", Range(0, 1)) = 0.5
        _TopFoamScale ("Top Foam Scale", Range(0, 2)) = 0.5
        _TopFoamSpeed ("Top Foam Speed", Range(0, 1)) = 0.5
        _TopNoiseIntensity ("Top Noise Intensity", Range(0, 1)) = 0.5
        
        [NoScaleOffset] _FallFoamMap ("Fall Foam Map", 2D) = "white" {}
        _FallFoamCut ("Fall Foam Cut", Range(0, 1)) = 0.5
        _FallFoamScale ("Fall Foam Scale", Range(0, 2)) = 0.5
        _FallFoamSpeed ("Fall Foam Speed", Range(0, 2)) = 0.5
        _FallNoiseIntensity ("Fall Noise Intensity", Range(0, 1)) = 0.1
        
        [Foldout(1, 2, 0, 1)]_Caustics ("Caustics_Foldout", float) = 1
        _SplitRGB ("Split RGB", Range(0, 0.1)) = 0.05
        [NoScaleOffset] _CausticsMap ("Caustics Map", 2D) = "white"{}
        _CausticsIntensity ("Caustics Intensity", Range(0, 20)) = 1
        _CausticsScale ("Caustics Scale", Range(0, 10)) = 1
        _CausticsSpeed ("Caustics Speed", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_Sparkling ("Sparkling_Foldout", float) = 1
        [HDR] _SparkColor ("Sparkling Color", Color) = (1, 1, 1, 1)
        _SparkScale ("Sparkling Scale", Range(0, 50)) = 5
        _SparkSpeed ("Sparkling Speed", Range(0, 3)) = 1
        _SparkCut ("Sparkling Cut", Range(0, 1)) = 0.5
        
        [Foldout(1, 2, 0, 1)]_Offset ("Offset_Foldout", float) = 1
        _WaveSpeed ("Wave Speed", Range(0, 3)) = 0.5
        _WaveTiling ("Wave Tiling", Range(0, 20)) = 5
        _WaveIntensity ("Wave Intensity", Range(0, 1)) = 1
        
        [Foldout(1, 2, 0, 1)]_OtherParameter ("Others_Foldout", float) = 1
        [Toggle(_RECEIVE_SHADOWS_OFF)] _DisableShadows("Shadows Off", Float) = 0
    }
    
    HLSLINCLUDE
    
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "ShadingModels.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
            half3 _BaseColor;
            half3 _ShallowColor;
            half  _Wave;
            half  _Smoothness;
            half  _Specular;
            half  _Alpha;
            half  _IOR;
            half  _Depth;
            half  _Height;
            float2 _HeightDir;
            float _HeightScale;
            float _HeightSpeed;
            half  _SideHeight;
            float _SideHeightScale;
            float _SideHeightSpeed;
            half  _FoamIntensity;
            half3 _FoamColor;
            half  _FoamRange;
            half  _TopFoamCut;
            float _TopFoamScale;
            float _TopFoamSpeed;
            half  _TopNoiseIntensity;
            float _FallFoamScale;
            float _FallFoamSpeed;
            half  _FallFoamCut;
            half  _FallNoiseIntensity;
            half  _Reflection;
            half  _SplitRGB;
            float _CausticsIntensity;
            float _CausticsScale;
            float _CausticsSpeed;
            float _WaveSpeed;
            float _WaveTiling;
            float _WaveIntensity;
            half3 _SparkColor;
            float _SparkScale;
            float _SparkSpeed;
            half  _SparkCut;
        CBUFFER_END

        TEXTURE2D(_HeightMap);                          SAMPLER(sampler_HeightMap);
        TEXTURE2D(_SideHeightMap);                      SAMPLER(sampler_SideHeightMap);
        TEXTURE2D(_TopFoamMap);                         SAMPLER(sampler_TopFoamMap);
        TEXTURE2D(_FallFoamMap);                        SAMPLER(sampler_FallFoamMap);
        TEXTURECUBE(_RefCubeMap);                       SAMPLER(sampler_RefCubeMap);
        TEXTURE2D_X_FLOAT(_CameraDepthTexture);         SAMPLER(sampler_CameraDepthTexture);
        TEXTURE2D_X(_CameraOpaqueTexture);              SAMPLER(sampler_CameraOpaqueTexture);
        TEXTURE2D(_CausticsMap);                        SAMPLER(sampler_CausticsMap);
        
    ENDHLSL

    SubShader
    {
        Tags
        { "RenderPipeline" = "UniversalPipeline" "Queue" = "Transparent" }

        // ------------------------------------------------------------------
        Pass
        {
            Name "SIMPLEWATER"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State Commands ---------------
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            Cull Back
            // -------------------------------------

            HLSLPROGRAM

            // Shader Stages -----------------------
            #pragma vertex Vert
            #pragma fragment Frag
            // -------------------------------------

            // Universal Pipeline keywords ---------
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            // -------------------------------------

            // Material Keywords -------------------
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            // -------------------------------------
            
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                //half3  color        : COLOR;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                float3 positionWS               : TEXCOORD1;
                float4 positionSS               : TEXCOORD2;
                float3 normalWS                 : TEXCOORD3;
                float2 staticLightmapUV         : TEXCOORD4;
                //half3  color                    : COLOR;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings Vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float time = fmod(_Time.y, 2e5);
                float3 positionOS = input.positionOS.xyz;
                float3 positionWS = TransformObjectToWorld(positionOS);
                float waveOffset = time * _WaveSpeed;
                float height = SimpleNoise3D(positionWS * _WaveTiling + waveOffset);
                height = Remap(height, float2(0, 1), float2(-1, 1)).r;
                float3 offset = float3(height * _WaveIntensity * 0.5, 0, height * _WaveIntensity * 0.5); 
                positionWS += offset;
                positionOS = TransformWorldToObject(positionWS);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(positionOS);
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
                output.positionCS = vertexInput.positionCS;
                output.positionWS = vertexInput.positionWS;
                output.positionSS = ComputeScreenPos(vertexInput.positionCS);
                output.normalWS = normalInput.normalWS;
                output.uv = input.texcoord;
                //output.color = input.color;

                OUTPUT_LIGHTMAP_UV(input.texcoord1.xy, unity_LightmapST, output.staticLightmapUV.xy);

                return output;
            }

            half4 Frag(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                CustomData customData = (CustomData)0;

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light light = GetMainLight(shadowCoord);
                float3 lightDirWS = normalize(light.direction);
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);

                //Depth
                float2 positionSS = input.positionSS.xy / input.positionSS.w;
                float sceneDepthEye = LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, positionSS).r, _ZBufferParams);
                float depth = saturate(sceneDepthEye - input.positionSS.w);
                float depth01 = 1 - saturate(depth / _Depth);
                
                //Time
                float time = fmod(_Time.y, 2e5);

                //UV
                float2 uvX = input.positionWS.zy;
                float2 uvY = input.positionWS.xz;
                float2 uvZ = input.positionWS.xy;
                float3 blend = TriplanarBlend(input.normalWS, 3);

                //Distortion
                float2 heightOffset = time * _HeightSpeed * _HeightDir;
                float heightY = SAMPLE_TEXTURE2D(_HeightMap, sampler_HeightMap, uvY * _HeightScale + heightOffset).x;

                float2 fallOffset = float2(0, time * _SideHeightSpeed);
                float2 fallScale = float2(_SideHeightScale, _SideHeightScale * 0.1);
                
                float heightX = SAMPLE_TEXTURE2D(_SideHeightMap, sampler_SideHeightMap, uvX * fallScale + fallOffset).x * 5;
                float heightZ = SAMPLE_TEXTURE2D(_SideHeightMap, sampler_SideHeightMap, uvZ * fallScale + fallOffset).x * 5;
                
                float height = heightX * blend.x * _SideHeight + heightY * blend.y * _Height + heightZ * blend.z * _SideHeight;

                float waveBlend = heightX * blend.x + heightY * blend.y + heightZ * blend.z;

                //Normal
                float3 normalWS = HeightToNormal(height);

                //Reflection
                float3 r = reflect(-viewDirWS, normalWS);
                half3 reflection = SAMPLE_TEXTURECUBE(_RefCubeMap, sampler_RefCubeMap, r).rgb;

                //Refraction
                float refNoise = (height - 0.5) * 2;
                half3 refraction = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, positionSS + refNoise * depth01 * _IOR * 0.1).rgb;
                
                //Foam
                half3 foamMask = saturate(dot(normalWS.y, saturate(input.normalWS.y) + 0.3)) * blend;
                //half edge = step(depth, _FoamRange);
                
                half topFoamMask = 1 - saturate(depth / _TopFoamCut);
                float2 topFoamOffset = time * _TopFoamSpeed * _HeightDir;
                //half topFoamMask = step(depth, _TopFoamCut);
                
                half foamYMap = SAMPLE_TEXTURE2D(_TopFoamMap, sampler_TopFoamMap, uvY * _TopFoamScale + topFoamOffset).r;
                half foamY = step(1 - topFoamMask, lerp(topFoamMask, foamYMap, _TopNoiseIntensity));

                float2 fallFoamScale = float2(_FallFoamScale, _FallFoamScale * 0.1);
                float2 fallFoamOffset = float2(0, time * _FallFoamSpeed);

                
                half sideFoamMask = 1 - saturate(depth / _FallFoamCut);

                half foamMaskX = saturate(sideFoamMask + foamMask.x * _FallFoamCut * 10);
                half foamXMap = SAMPLE_TEXTURE2D(_FallFoamMap, sampler_FallFoamMap, uvX * fallFoamScale + fallFoamOffset + heightY * _FallNoiseIntensity).x;
                half foamX = step(1 - foamMaskX, foamXMap);

                half foamMaskZ = saturate(sideFoamMask + foamMask.z * _FallFoamCut * 10);
                half foamZMap = SAMPLE_TEXTURE2D(_FallFoamMap, sampler_FallFoamMap, uvZ * fallFoamScale + fallFoamOffset + heightY * _FallNoiseIntensity).x;
                //foamZ = 1 - saturate(foamZ / _FallFoamRange);
                //foamZ = step(foamZ, _FallFoamRange);
                //half foamZ = LinearStep(_FallFoamCut, _FallFoamCut + _FallFoamSoftness, foamZMap * depth);
                half foamZ = step(1 - foamMaskZ, foamZMap);
                
                half foam = foamX * blend.x + foamY * blend.y + foamZ * blend.z;
                

                //Caustics
                half3 cameraDir = -1 * mul(UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2]).xyz;
                half3 cameraPos = _WorldSpaceCameraPos;
                half3 causticsPos = viewDirWS / dot(viewDirWS, cameraDir) * sceneDepthEye + cameraPos;
                float NoL = saturate(dot(normalWS, lightDirWS));
                float shadow = light.shadowAttenuation * NoL;
                
                float3x3 tran = float3x3(float3(cos(120), 0, -sin(120)), float3(0, 1, 0), float3(sin(120), 0, cos(120)));
                float3 tangent = mul(tran, half3(0, 0, -1));
                float3 bitangent = normalize(cross(tangent, -lightDirWS));
                tangent = normalize(cross(-lightDirWS, bitangent));
                
                float3 positionLS = mul(float3x3(tangent, bitangent, lightDirWS), causticsPos);
                float2 causticsUV = positionLS.xy;

                float causticsOffset = time * _CausticsSpeed * 0.1;
                half3 caustics1 = ColorSplit(_CausticsMap, sampler_CausticsMap, causticsUV, 1 / _CausticsScale, causticsOffset, _SplitRGB);
                half3 caustics2 = ColorSplit(_CausticsMap, sampler_CausticsMap, -causticsUV, 1 / _CausticsScale, causticsOffset, _SplitRGB);
                
                half3 caustics = min(caustics1, caustics2) * _CausticsIntensity;
                float causticsMask = shadow;

                //Emissive
                half sparkMask = Voronoi_float(uvY, time * _SparkSpeed, _SparkScale);
                half spark = step(_SparkCut, sparkMask * heightY * blend.y);

                //BaseColor
                half3 baseColor = lerp(_BaseColor, _ShallowColor, saturate(max(depth01, waveBlend * _Wave)));
                baseColor += reflection * _Reflection;
                baseColor = lerp(baseColor, refraction, depth01 * (1 - _Alpha));
                baseColor = lerp(baseColor, baseColor + caustics * causticsMask, depth01);
                //baseColor = lerp(baseColor, _FoamColor, foam * foamMask * _FoamIntensity);
                baseColor += _FoamColor * foam * _FoamIntensity; 

                //CustomData
                customData.baseColor = baseColor + spark * _SparkColor;
                customData.smoothness = _Smoothness;
                customData.perRoughness = 1.0 - customData.smoothness;
                customData.roughness = max(customData.perRoughness * customData.perRoughness, 0.0078125);
                customData.specular = _Specular * spark;
                customData.normalWS = normalWS;
                customData.positionWS = input.positionWS;
                customData.viewDirWS = viewDirWS;
                customData.shadowCoord = shadowCoord;
                customData.staticLightmapUV = input.staticLightmapUV;
                //customData.emission = spark * _SparkColor;
                half3 color = DefaultShading(customData, _Exposure);
                
                return half4(color, 1);
            }
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
            Cull Off
            ZWrite On
            ZTest LEqual
            ColorMask 0
            // -------------------------------------

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Shader Stages -----------------------
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            // -------------------------------------

            // Unity defined keywords --------------
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            // -------------------------------------

            float3 _LightDirection;
            float3 _LightPosition;
            
            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                //float3 normalWS                 : TEXCOORD1;
                //float3 positionWS               : TEXCOORD2;
                //float4 positionSS               : TEXCOORD3;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);

                #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                    float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                #else
                    float3 lightDirectionWS = _LightDirection;
                #endif

                float time = fmod(_Time.y, 2e5);
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float waveOffset = time * _WaveSpeed;
                float height = SimpleNoise3D(positionWS * _WaveTiling + waveOffset);
                height = Remap(height, float2(0, 1), float2(-1, 1)).r;
                float3 offset = float3(height * _WaveIntensity * 0.5, 0, height * _WaveIntensity * 0.5); 
                positionWS += offset;
                
                float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

                output.uv = input.texcoord;
                output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

                return output;
            }

            half4 ShadowPassFragment(Varyings input) : SV_TARGET
            {
                return 0;
            }
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
            Cull Off
            ZWrite On
            ZTest LEqual
            ColorMask R
            // -------------------------------------

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            // Shader Stages -----------------------
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            // -------------------------------------

            // GPU Instancing ----------------------
            #pragma multi_compile_instancing
            // -------------------------------------

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv                       : TEXCOORD0;
                //float3 normalWS                 : TEXCOORD1;
                //float3 positionWS               : TEXCOORD2;
                //float4 positionSS               : TEXCOORD3;

                float4 positionCS               : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                float time = fmod(_Time.y, 2e5);
                float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
                float waveOffset = time * _WaveSpeed;
                float height = SimpleNoise3D(positionWS * _WaveTiling + waveOffset);
                height = Remap(height, float2(0, 1), float2(-1, 1)).r;
                float3 offset = float3(height * _WaveIntensity * 0.5, 0, height * _WaveIntensity * 0.5); 
                positionWS += offset;
                
                output.uv = input.texcoord;
                output.positionCS = TransformWorldToHClip(positionWS);

                return output;
            }

            half4 DepthOnlyFragment(Varyings input) : SV_TARGET
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                
                return input.positionCS.z;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "EBGame.SimpleShaderGUI"
}

