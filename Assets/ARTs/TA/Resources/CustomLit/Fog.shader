Shader "Hidden/Custom/LayeredFog"
{
    Properties
    {
        [HideInInspector]_MainTex ("Base (RGB)", 2D) = "white" { }

//        [Toggle(USE_DISTANCE_FOG)]_UseDistanceFog ("Use Distance", Float) = 0
//        [Toggle(USE_DISTANCE_FOG_ON_SKY)]_UseDistanceFogOnSky ("Use Distance Fog On Sky", Float) = 0
//
//        [Space]
//        _Near ("Near", Float) = 0
//        _Far ("Far", Float) = 100
//
//        [Space]
//        _DistanceFogIntensity ("Distance Fog Intensity", Range(0, 1)) = 1
//
//        [Space(25)]
//        [Toggle(USE_HEGHT_FOG)]_UseHeightFog ("Use Height", Float) = 0
//        [Toggle(USE_HEGHT_FOG_ON_SKY)]_UseHeightFogOnSky ("Use Height Fog On Sky", Float) = 0
//
//        [Space]
//        _LowWorldY ("Low", Float) = 0
//        _HighWorldY ("High", Float) = 10
//
//        [Space]
//        _HeightFogIntensity ("Height Fog Intensity", Range(0, 1)) = 1
//
//        [Space(25)]
//        _DistanceHeightBlend ("Distance / Height blend", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        LOD 200

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            // The DeclareDepthTexture.hlsl file contains utilities for sampling the
            // Camera depth texture.
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "GlobalInput.hlsl"
            #include "CustomFunction.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            TEXTURE2D_X(_BlitTexture);                      SAMPLER(sampler_BlitTexture);
            //float4 _CameraColorTexture_TexelSize;
            

            sampler2D _DistanceLUT;
            float _Near;
            float _Far;
            half _UseDistanceFog;
            half _UseDistanceFogOnSky;

            sampler2D _HeightLUT;
            float _LowWorldY;
            float _HighWorldY;
            half _UseHeightFog;
            half _UseHeightFogOnSky;

            float _DistanceFogIntensity;
            float _HeightFogIntensity;
            float _DistanceHeightBlend;

            float _NoiseIntensity;
            float _NoiseScale;
            float _NoiseDistanceEnd;
            float3 _NoiseSpeed;

            #define ALMOST_ONE 0.999

            // Z buffer depth to linear 0-1 depth
            // Handles orthographic projection correctly
            float Linear01Depth(float z)
            {
                float isOrtho = unity_OrthoParams.w;
                float isPers = 1.0 - unity_OrthoParams.w;
                z *= _ZBufferParams.x;
                return (1.0 - isOrtho * z) / (isPers * z + _ZBufferParams.y);
            }
     
            float LinearEyeDepth(float z)
            {
                return rcp(_ZBufferParams.z * z + _ZBufferParams.w);
            }
     
            float SampleDepth(float2 uv)
            {
                #if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
					return SAMPLE_TEXTURE2D_ARRAY(_CameraDepthTexture, sampler_CameraDepthTexture, uv, unity_StereoEyeIndex).r;
                #else
                return SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, uv);
                #endif
            }

            // float4 mod289( float4 x )
            // {
            //     return x - floor(x * (1.0 / 289.0)) * 289.0;
            // }
            //
            // float4 perm( float4 x )
            // {
            //     return mod289(((x * 34.0) + 1.0) * x);
            // }

            // float SimpleNoise3D( float3 p )
            // {
            //     float3 a = floor(p);
            //     float3 d = p - a;
            //     d = d * d * (3.0 - 2.0 * d);
            //     float4 b = a.xxyy + float4(0.0, 1.0, 0.0, 1.0);
            //     float4 k1 = perm(b.xyxy);
            //     float4 k2 = perm(k1.xyxy + b.zzww);
            //     float4 c = k2 + a.zzzz;
            //     float4 k3 = perm(c);
            //     float4 k4 = perm(c + 1.0);
            //     float4 o1 = frac(k3 * (1.0 / 41.0));
            //     float4 o2 = frac(k4 * (1.0 / 41.0));
            //     float4 o3 = o2 * d.z + o1 * (1.0 - d.z);
            //     float2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);
            //     return o4.y * d.y + o4.x * (1.0 - d.y);
            // }

            half4 Fog(float2 uv, float3 pos)
            {
                half4 original = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, uv);

                const float depthPacked = SampleDepth(uv);
                //const float depthEye = LinearEyeDepth(depthPacked);
                const float depthCameraPlanes = Linear01Depth(depthPacked);
                const float depthAbsolute = _ProjectionParams.y + (_ProjectionParams.z - _ProjectionParams.y) * depthCameraPlanes;
                const float depthFogPlanes = saturate((depthAbsolute - _Near) / (_Far - _Near));
                const float isSky = step(ALMOST_ONE, depthCameraPlanes);

                half4 distanceFog = tex2D(_DistanceLUT, float2(depthFogPlanes, 0.5));
                distanceFog.a *= step(isSky, _UseDistanceFogOnSky);
                distanceFog.a *= _UseDistanceFog * _DistanceFogIntensity;

                //const float3 positionWS = pos * depthEye + _WorldSpaceCameraPos;
                // const float heightUV = saturate((worldPos.y - _LowWorldY) / (_HighWorldY - _LowWorldY));
                // float4 heightFog = tex2D(_HeightLUT, float2(heightUV, 0.5));
                // heightFog.a *= step(isSky, _UseHeightFogOnSky);
                // heightFog.a *= _UseHeightFog * _HeightFogIntensity;
                //
                // float fogBlend = _DistanceHeightBlend;
                // if (!_UseDistanceFog) fogBlend = 1.0;
                // if (!_UseHeightFog) fogBlend = 0.0;
                // const float4 fog = lerp(distanceFog, heightFog, fogBlend);
                //
                //float3 uvw = pos * (1.0 / max(0.1, _NoiseScale)) + _NoiseSpeed * _TimeParameters.x * 2.0;
                //float noise = SimpleNoise3D(uvw);
                float noise = SimpleNoise(pos.xz + _WindSpeed * _Time.y * 1.5, 1.0 / max(0.1, _NoiseScale));
                //noise = noise * 0.5 + 0.5;   // scale and offset(0.5, 0.5)
                
                // noise distance mask
                float nosieDistanceMask = saturate((distance(pos , _WorldSpaceCameraPos) - _NoiseDistanceEnd) / (0.0 - _NoiseDistanceEnd));
                noise = lerp(1, noise, nosieDistanceMask * _NoiseIntensity);

                half4 final = lerp(original, distanceFog, distanceFog.a * noise);
                final.a = original.a;

                return final;
                //return half4(depthFogPlanes, depthFogPlanes, depthFogPlanes, 1);
            }

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv			    : TEXCOORD0;
            	uint vertexID		    : SV_VertexID;
            };

            struct Varyings
            {
                float2 uv               : TEXCOORD0;
                float3 positionWS       : TEXCOORD1;
                float4 positionSS       : TEXCOORD2;
                // float viewSpaceZ        : TEXCOORD3;
                float4 positionNDC      : TEXCOORD4;
                float4 positionCS       : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
                
                output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.positionNDC.xy = float2(output.positionCS.x, output.positionCS.y * _ProjectionParams.x) + output.positionCS.w;
                output.positionNDC.zw = output.positionCS.zw;
                output.uv = GetFullScreenTriangleTexCoord(input.vertexID);
                
                output.positionSS = ComputeScreenPos(output.positionCS);

                //output.worldSpaceDir = GetWorldSpaceViewDir(input.positionOS.xyz);
                //output.viewSpaceZ = mul(UNITY_MATRIX_V, float4(output.worldSpaceDir, 0.0)).z;

                return output;
            }

            half4 frag(Varyings input): SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

                float2 positionNDC = input.positionSS.xy / input.positionNDC.w;

                // Sample the depth from the Camera depth texture.
                #if UNITY_REVERSED_Z
                    real depth = SampleDepth(positionNDC);
                #else
                    // Adjust Z to match NDC for OpenGL ([-1, 1])
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(positionNDC));
                #endif

                // Reconstruct the world space positions.
                float3 positionWS = ComputeWorldSpacePosition(positionNDC, depth, UNITY_MATRIX_I_VP);

                half4 color = Fog(input.uv, positionWS);

                return color;
            }

            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL

        }
    }
    FallBack "Diffuse"
}