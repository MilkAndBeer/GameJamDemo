Shader "Hidden/Custom/Bloom"
{
    HLSLINCLUDE
        #pragma exclude_renderers gles

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

        float4 _BlitTexture_TexelSize;

        TEXTURE2D_X(_SourceTexLowMip);
        float4 _SourceTexLowMip_TexelSize;

        // CBUFFER_START(UnityPerMaterial)
        //      // x: scatter, y: clamp, z: threshold (linear), w: threshold knee
        //     
        // CBUFFER_END

        float4 _Params;
        half _Offset;
        float4 _Bloom_Params;
        
        #define Scatter             _Params.x
        #define ClampMax            _Params.y
        #define Threshold           _Params.z
        #define ThresholdKnee       _Params.w
        #define BloomIntensity          _Bloom_Params.x
        #define BloomTint               _Bloom_Params.yzw

        half4 EncodeHDR(half3 color)
        {
            half4 outColor = half4(color, 1.0);

        #if UNITY_COLORSPACE_GAMMA
            return half4(sqrt(outColor.xyz), outColor.w); // linear to γ
        #else
            return outColor;
        #endif
        }

        half3 DecodeHDR(half4 color)
        {
        #if UNITY_COLORSPACE_GAMMA
            color.xyz *= color.xyz; // γ to linear
        #endif

            return color.xyz;
        }

        half4 FragPrefilter(Varyings input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            float2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);

#if defined(SUPPORTS_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            UNITY_BRANCH if (_FOVEATED_RENDERING_NON_UNIFORM_RASTER)
            {
                uv = RemapFoveatedRenderingLinearToNonUniform(uv);
            }
#endif

            half3 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv).xyz;

            // User controlled clamp to limit crazy high broken spec
            color = min(ClampMax, color);

            // Thresholding
            half brightness = Max3(color.r, color.g, color.b);
            half softness = clamp(brightness - Threshold + ThresholdKnee, 0.0, 2.0 * ThresholdKnee);
            softness = (softness * softness) / (4.0 * ThresholdKnee + 1e-4);
            half multiplier = max(brightness - Threshold, softness) / max(brightness, 1e-4);
            color *= multiplier;

            // Clamp colors to positive once in prefilter. Encode can have a sqrt, and sqrt(-x) == NaN. Up/Downsample passes would then spread the NaN.
            color = max(color, 0);
            return EncodeHDR(color);
        }

        //#Up Sample
        half3 Upsample(float2 uv)
        {
            half3 highMip = DecodeHDR(SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv));
            half3 lowMip = DecodeHDR(SAMPLE_TEXTURE2D_X(_SourceTexLowMip, sampler_LinearClamp, uv));

            return lerp(highMip, lowMip, Scatter);
        }

        half4 FragUpsample(Varyings input) : SV_Target
        {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            half3 color = Upsample(UnityStereoTransformScreenSpaceTex(input.texcoord));
            return EncodeHDR(color);
        }

        //# Bloom Combine
	    half4 FragCombine(Varyings input): SV_Target
	    {
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
            half2 uv = UnityStereoTransformScreenSpaceTex(input.texcoord);

		    half3 baseColor = DecodeHDR(SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv));
		    half3 bloomColor = DecodeHDR(SAMPLE_TEXTURE2D(_SourceTexLowMip, sampler_LinearClamp, uv));
		    half3 finalColor = baseColor.rgb + bloomColor.rgb * BloomTint * BloomIntensity;
		    return EncodeHDR(finalColor);
	    }

        //# down KawaseBlur Sample
        struct v2f_DownSample
	    {
		    float4 vertex: SV_POSITION;
		    float2 uv: TEXCOORD0;
		    float4 uv01: TEXCOORD1;
		    float4 uv23: TEXCOORD2;
	    };

        v2f_DownSample Vert_DownSample(Attributes input)
	    {
		    v2f_DownSample o;

            #if SHADER_API_GLES
                float4 pos = input.positionOS;
                float2 uv  = input.uv;
            #else
                float4 pos = GetFullScreenTriangleVertexPosition(input.vertexID);
                float2 uv  = GetFullScreenTriangleTexCoord(input.vertexID);
            #endif

            o.vertex = pos;
		
		    _BlitTexture_TexelSize *= 0.5;
		    o.uv = uv;
		    o.uv01.xy = uv - _BlitTexture_TexelSize.xy * float2(1.0 + _Offset, 1.0 + _Offset);//top right
		    o.uv01.zw = uv + _BlitTexture_TexelSize.xy * float2(1.0 + _Offset, 1.0 + _Offset);//bottom left
		    o.uv23.xy = uv - float2(_BlitTexture_TexelSize.x, -_BlitTexture_TexelSize.y) * float2(1.0 + _Offset, 1.0 + _Offset);//top left
		    o.uv23.zw = uv + float2(_BlitTexture_TexelSize.x, -_BlitTexture_TexelSize.y) * float2(1.0 + _Offset, 1.0 + _Offset);//bottom right
		
		    return o;
	    }

        half4 Frag_DownSample(v2f_DownSample i): SV_Target
	    {
		    half3 sum = DecodeHDR(SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, i.uv)) * 4;
		    sum += DecodeHDR(SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, i.uv01.xy));
		    sum += DecodeHDR(SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, i.uv01.zw));
		    sum += DecodeHDR(SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, i.uv23.xy));
		    sum += DecodeHDR(SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, i.uv23.zw));

		    return EncodeHDR(sum * 0.125);
	    }

    ENDHLSL

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100
        ZTest Always ZWrite Off Cull Off

        Pass
        {
            Name "Bloom Prefilter"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FragPrefilter
            ENDHLSL
        }

        Pass 
        {
            Name "Bloom Kawase Down Sample"
            HLSLPROGRAM
                #pragma vertex Vert_DownSample
                #pragma fragment Frag_DownSample
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Upsample"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FragUpsample
            ENDHLSL
        }

        Pass
        {
            Name "Bloom Combine"

            HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment FragCombine
            ENDHLSL
        }
    }
}
