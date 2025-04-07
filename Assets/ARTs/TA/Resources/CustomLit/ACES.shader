Shader "Hidden/Custom/ACES"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    	
        }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"

            struct Attributes
            {
                //float4 positionOS	: POSITION;
                float2 uv			: TEXCOORD0;
            	uint vertexID		: SV_VertexID;
            };

            struct Varyings
            {
                float4 positionCS	: SV_POSITION;
            	float2 uv			: TEXCOORD0;
            	//float3 positionWS	: TEXCOORD1;
            };
            
            //loat4 _MainTex_ST;

            TEXTURE2D_X(_BlitTexture);                      SAMPLER(sampler_BlitTexture);

            uniform float _FilmSlope;// = 0.91;
			uniform float _FilmToe;// = 0.53;
			uniform float _FilmShoulder;// = 0.23;
			uniform float _FilmBlackClip;// = 0;
			uniform float _FilmWhiteClip;// = 0.035;

            static const float3x3 ACESInputMat =
            	{
            		{0.59719, 0.35458, 0.04823},
            		{0.07600, 0.90834, 0.01566},
            		{0.02840, 0.13383, 0.83777}
            	};

				static const float3x3 ACESOutputMat =
				{
					{1.60475, -0.53108, -0.07367},
					{-0.10208, 1.10813, -0.00605},
					{-0.00327, -0.07276, 1.07602}
				};

            float3 RRTAndODTFit(float3 v)
            {
            	float3 a = v * (v + 0.0245786) - 0.000090537;
            	float3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
            	return a / b;
            }

            float3 ACESFitted(float3 color)
            {
	            color = mul(ACESInputMat, color);
            	color = RRTAndODTFit(color);
            	color = mul(ACESOutputMat, color);
            	color = saturate(color);
            	return color;
            }
            

            Varyings vert (Attributes input)
            {
                Varyings output;
            	
            	// output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
            	// output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
            	// output.uv = TRANSFORM_TEX(input.uv, _MainTex);

            	output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID);
                output.uv = GetFullScreenTriangleTexCoord(input.vertexID);

                return output;
            }

			static const float e = 2.71828;
            
            
            float3 AcesTonemap_UE4(float3 aces)
			{
				// "Glow" module constants
			    const float RRT_GLOW_GAIN = 0.05;
			    const float RRT_GLOW_MID = 0.08;
			 
			    float saturation = rgb_2_saturation(aces);
			    float ycIn = rgb_2_yc(aces);
			    float s = sigmoid_shaper((saturation - 0.4) / 0.2);
			    float addedGlow = 1.0 + glow_fwd(ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);
			    aces *= addedGlow;
			 
			    const float RRT_RED_SCALE = 0.82;
			    const float RRT_RED_PIVOT = 0.03;
			    const float RRT_RED_HUE = 0.0;
			    const float RRT_RED_WIDTH = 135.0;
			 
			    // --- Red modifier --- //
			    float hue = rgb_2_hue(aces);
			    float centeredHue = center_hue(hue, RRT_RED_HUE);
			    float hueWeight;
			    {
			        hueWeight = smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / RRT_RED_WIDTH));
			        hueWeight *= hueWeight;
			    }
			    //float hueWeight = Square( smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / RRT_RED_WIDTH)) );
			 
			    aces.r += hueWeight * saturation * (RRT_RED_PIVOT - aces.r) * (1.0 - RRT_RED_SCALE);
			 
			    // Use ACEScg primaries as working space
			    float3 acescg = max(0.0, ACES_to_ACEScg(aces));
			 
			    // Pre desaturate
			    acescg = lerp(dot(acescg, AP1_RGB2Y).xxx, acescg, 0.96);
			 
			    const half ToeScale = 1 + _FilmBlackClip - _FilmToe;
			    const half ShoulderScale = 1 + _FilmWhiteClip - _FilmShoulder;
			 
			    const float InMatch = 0.18;
			    const float OutMatch = 0.18;
			 
			    float ToeMatch;
			    if (_FilmToe > 0.8)
			    {
			        // 0.18 will be on straight segment
			        ToeMatch = (1 - _FilmToe - OutMatch) / _FilmSlope + log10(InMatch);
			    }
			    else
			    {
			        // 0.18 will be on toe segment
			 
			        // Solve for ToeMatch such that input of InMatch gives output of OutMatch.
			        const float bt = (OutMatch + _FilmBlackClip) / ToeScale - 1;
			        ToeMatch = log10(InMatch) - 0.5 * log((1 + bt) / (1 - bt)) * (ToeScale / _FilmSlope);
			    }
			 
			    float StraightMatch = (1 - _FilmToe) / _FilmSlope - ToeMatch;
			    float ShoulderMatch = _FilmShoulder / _FilmSlope - StraightMatch;
			 
			    half3 LogColor = log10(acescg);
			    half3 StraightColor = _FilmSlope * (LogColor + StraightMatch);
			 
			    half3 ToeColor = (-_FilmBlackClip) + (2 * ToeScale) / (1 + exp((-2 * _FilmSlope / ToeScale) * (LogColor - ToeMatch)));
			    half3 ShoulderColor = (1 + _FilmWhiteClip) - (2 * ShoulderScale) / (1 + exp((2 * _FilmSlope / ShoulderScale) * (LogColor - ShoulderMatch)));
			 
			    ToeColor = LogColor < ToeMatch ? ToeColor : StraightColor;
			    ShoulderColor = LogColor > ShoulderMatch ? ShoulderColor : StraightColor;
			 
			    half3 t = saturate((LogColor - ToeMatch) / (ShoulderMatch - ToeMatch));
			    t = ShoulderMatch < ToeMatch ? 1 - t : t;
			    t = (3 - 2 * t)*t*t;
			    half3 linearCV = lerp(ToeColor, ShoulderColor, t);
			 
			    // Post desaturate
			    linearCV = lerp(dot(float3(linearCV), AP1_RGB2Y), linearCV, 0.93);
			 
			    // Returning positive AP1 values
			    //return max(0, linearCV);
			 
			    // Convert to display primary encoding
			    // Rendering space RGB to XYZ
			    float3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);
			 
			    // Apply CAT from ACES white point to assumed observer adapted white point
			    XYZ = mul(D60_2_D65_CAT, XYZ);
			 
			    // CIE XYZ to display primaries
			    linearCV = mul(XYZ_2_REC709_MAT, XYZ);
			 
			    linearCV = saturate(linearCV); //Protection to make negative return out.
			 
			    return linearCV;
			}
			/////////////////SWS_UE4_ACES_END/////////////////
			///
			///
			float3 AcesTonemap_Unity(float3 aces)
			{
				#if TONEMAPPING_USE_FULL_ACES

				    float3 oces = RRT(aces);
				    float3 odt = ODT_RGBmonitor_100nits_dim(oces);
				    return odt;

				#else

				    // --- Glow module --- //
				    float saturation = rgb_2_saturation(aces);
				    float ycIn = rgb_2_yc(aces);
				    float s = sigmoid_shaper((saturation - 0.4) / 0.2);
				    float addedGlow = 1.0 + glow_fwd(ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);
				    aces *= addedGlow;

				    // --- Red modifier --- //
				    float hue = rgb_2_hue(aces);
				    float centeredHue = center_hue(hue, RRT_RED_HUE);
				    float hueWeight;
				    {
				        //hueWeight = cubic_basis_shaper(centeredHue, RRT_RED_WIDTH);
				        hueWeight = smoothstep(0.0, 1.0, 1.0 - abs(2.0 * centeredHue / RRT_RED_WIDTH));
				        hueWeight *= hueWeight;
				    }

				    aces.r += hueWeight * saturation * (RRT_RED_PIVOT - aces.r) * (1.0 - RRT_RED_SCALE);

				    // --- ACES to RGB rendering space --- //
				    float3 acescg = max(0.0, ACES_to_ACEScg(aces));

				    // --- Global desaturation --- //
				    //acescg = mul(RRT_SAT_MAT, acescg);
				    acescg = lerp(dot(acescg, AP1_RGB2Y).xxx, acescg, RRT_SAT_FACTOR.xxx);

				    // Luminance fitting of *RRT.a1.0.3 + ODT.Academy.RGBmonitor_100nits_dim.a1.0.3*.
				    // https://github.com/colour-science/colour-unity/blob/master/Assets/Colour/Notebooks/CIECAM02_Unity.ipynb
				    // RMSE: 0.0012846272106
				#if defined(SHADER_API_SWITCH) // Fix floating point overflow on extremely large values.
				    const float a = 2.785085 * 0.01;
				    const float b = 0.107772 * 0.01;
				    const float c = 2.936045 * 0.01;
				    const float d = 0.887122 * 0.01;
				    const float e = 0.806889 * 0.01;
				    float3 x = acescg;
				    float3 rgbPost = ((a * x + b)) / ((c * x + d) + e/(x + FLT_MIN));
				#else
				    const float a = 2.785085;
				    const float b = 0.107772;
				    const float c = 2.936045;
				    const float d = 0.887122;
				    const float e = 0.806889;
				    float3 x = acescg;
				    float3 rgbPost = (x * (a * x + b)) / (x * (c * x + d) + e);
				#endif

				    // Scale luminance to linear code value
				    // float3 linearCV = Y_2_linCV(rgbPost, CINEMA_WHITE, CINEMA_BLACK);

				    // Apply gamma adjustment to compensate for dim surround
				    float3 linearCV = darkSurround_to_dimSurround(rgbPost);

				    // Apply desaturation to compensate for luminance difference
				    //linearCV = mul(ODT_SAT_MAT, color);
				    linearCV = lerp(dot(linearCV, AP1_RGB2Y).xxx, linearCV, ODT_SAT_FACTOR.xxx);

				    // Convert to display primary encoding
				    // Rendering space RGB to XYZ
				    float3 XYZ = mul(AP1_2_XYZ_MAT, linearCV);

				    // Apply CAT from ACES white point to assumed observer adapted white point
				    XYZ = mul(D60_2_D65_CAT, XYZ);

				    // CIE XYZ to display primaries
				    linearCV = mul(XYZ_2_REC709_MAT, XYZ);

				    return linearCV;

				#endif
			}


            half3 AcesTonemap_Custom(float3 aces)
            {
            	
	            return ACESFitted(aces);
            }
            

            half4 frag (Varyings input) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_BlitTexture, input.uv);
            	//float3 aces = unity_to_ACES(color.xyz);
                //half3 ACE_Col = AcesTonemap_Unity(aces);
            	half3 ACE_Col = AcesTonemap_Custom(color.rgb);
				half3 finalCol = ACE_Col;
				color = float4(finalCol,1);
            	
                return color;
            }
            ENDHLSL
        }
    }
}