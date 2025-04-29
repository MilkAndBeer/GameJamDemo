Shader "EB/Env/GrassBlendGround"
{
    Properties
    {
        //Grass Base Transform
        [Foldout(1, 2, 0, 1)]_Shape ("Shape_Foldout", float) = 1
        _Height ("Height", Float) = 1
        _HeightMin ("Height Min", Range(0, 1)) = 0
        _HeightMax ("Height Max", Range(0, 1)) = 1
        _Width ("Width", Float) = 1
        _WidthMin ("Width Min", Range(0, 1)) = 0
        _WidthMax ("Width Max", Range(0, 1)) = 1
        _RotationStrength("Rotation Strength", Range(0, 1)) = 0.5
        _RotationAxis("Rotation Axis", Vector) = (0, 1, 0, 0) // 默认绕Y轴旋转

        //Grass Base Color
        [Space(10)]
        _BaseColorRampTexture("BaseColor Ramp Texture", 2D) = "white" {}
        _BaseRampTexture("BaseRamp Texture", 2D) = "white" {}
        _RampPowOffset("Ramp Pow Offset", Range(-1, 1)) = 0.5
        _RampPowStrength("Ramp Pow Strength", float) = 2
        _BaseRampNormalTexture("BaseRamp Normal Texture", 2D) = "bump" {}

        _NormalIntensity("Normal Intensity", Range(0, 1)) = 1

        _ScaleNoise ("Scale Noise", Float) = 5
        _NoiseSample ("Noise Sample", float) = 1

        //Wind
        [Space(10)]
        [Toggle(_WIND)]_GrassWindOn("Wind On", float) = 0
        _WindBlendRange("Wind Blend Range", float) = 0.5
        _WindGrassHeight("Wind Grass Height", Range(0.1, 0.5)) = 0.1
        _WindGrassSpeed("Wind Grass Speed", float) = 1
        _WindNoiseRamp("Wind Noise Ramp", 2D) = "white" {}
        _GrassWindDir("Wind Direction", Vector) = (0, 0, 1, 0)
        _GrassWindSpeed("Wind Speed", float) = 0.1

        //Collision
        [Space(10)]
        [Toggle(_COLLISION)]_GrassCollisionOn("Collision On", float) = 0
        _ColIntensity ("Collision Intensity", Range(0, 1)) = 0.5
        _ColRange ("Collision Range", float) = 0.5

        ////HSL
        // _H ("Hue", Range(0, 100)) = 0
        // _S ("Saturation", Range(0, 5)) = 1
        // _L ("Lightness", Range(0, 5)) = 1

        //Ramp
        [Space(10)]
        [Toggle(_OVERRIDE)] _Override("Enable Override", Float) = 0
        [NoScaleOffset] _SingleRamp ("Ramp Map", 2D) = "white" {}
        
        //Billboard
        [Space(10)]
        [Toggle(_BILLBOARD)] _BillboardOn("Bollboard On", float) = 0
        _BillboardHeightIntensity("Billboard Height Intensity", Range(0, 1)) = 0.5
        _BillboardMaxAngle("Billboard Max Angle", Range(0, 180)) = 45
        _MaxTiltAngle("Max Tilt Angle", Range(0, 90)) = 45

        //地形融合
        [Space(10)]
        [Toggle(_GROUNDMIX)]_GroundMixOn("GroundMix On", float) = 0
        //_GroundColorTexture("GroundColor Texture", 2D) = "white" {}
        //_GroundHeightTexture("GroundHeight Texture", 2D) = "black" {}
        //_GroundCamPos("GroundCam Pos", Vector) = (0, 0, 0, 0)
        //_GroundColorCameraSize("GroundColor Camera Size", float) = 5
        _GroundColorBlendIntensity("GroundColorBlendIntensity", float) = 0.5
        _GroundColorBlendHeight("_GroundColorBlendHeight", float) = 0.25
       
    }

    SubShader
    {
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        //----------Global Keywords----------------
        #pragma multi_compile _ _WIND
        #pragma multi_compile _ _COLLISION
        #pragma multi_compile _ _BILLBOARD
        #pragma multi_compile _ _INSTANCE_ON
        #pragma multi_compile _ _GROUNDMIX

        //----------Feature Keywords---------------
        #pragma shader_feature_local _OVERRIDE

        TEXTURE2D(_BaseColorRampTexture);      SAMPLER(sampler_BaseColorRampTexture);
        TEXTURE2D(_BaseRampTexture);      SAMPLER(sampler_BaseRampTexture);
        TEXTURE2D(_BaseRampNormalTexture);      SAMPLER(sampler_BaseRampNormalTexture);
        TEXTURE2D(_WindNoiseRamp);      SAMPLER(sampler_WindNoiseRamp);

        TEXTURE2D(_GroundColorTexture);
        SAMPLER(sampler_GroundColorTexture);
        TEXTURE2D(_GroundHeightTexture);
        SAMPLER(sampler_GroundHeightTexture);

        #ifdef _OVERRIDE
        TEXTURE2D(_SingleRamp);
        #endif

        float4 _GroundCamPos;
        float _GroundColorCameraSize;
        float _GroundColorCamFarPlane;

        CBUFFER_START(UnityPerMaterial)
        float4 _BaseColorRampTexture_ST;
        float4 _BaseRampTexture_ST;
        float4 _BaseRampNormalTexture_ST;
        float4 _WindNoiseRamp_ST;
        
        //float4 _GroundCamPos;
        //float _GroundColorCameraSize;
        //float _GroundColorCamFarPlane;
        //float _GroundH;
        //float _GroundS;
        //float _GroundL;

        float _BillboardHeightIntensity;
        float _BillboardMaxAngle; // 最大旋转角度
        float _MaxTiltAngle; // 最大倾斜角度
        float _NormalIntensity;
        float4 _HighLightColor;

        float _Shape;
        float _Height;
        float _HeightMin;
        float _HeightMax;
        float _Width;
        float _WidthMin;
        float _WidthMax;
        float _RotationStrength;
        float4 _RotationAxis;
        
        //Collision
        float _ColIntensity;
        float _ColRange;

        //Wind
        float _WindBlendRange;
        float _WindGrassHeight;
        float _WindGrassSpeed;
        float4 _GrassWindDir;
        float _GrassWindSpeed;

        float _RampPowOffset;
        float _RampPowStrength;
        
        float _ScaleNoise;
        float _NoiseSample;

        float _GroundColorBlendIntensity;
        float _GroundColorBlendHeight;
        CBUFFER_END

        #ifndef UNITY_PI
        #define UNITY_PI 3.14159265358979323846
        #endif

        ENDHLSL

      
        Pass
        {
            Name "Basic"
            Tags { "LightMode" = "UniversalForward" }

            Cull Off

            HLSLPROGRAM
            // Shader Stages -----------------------
            #pragma vertex BasicVertex
            #pragma fragment BasicFragment
            #pragma multi_compile_instancing
            // -------------------------------------

            // Universal Pipeline keywords ---------
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "../Common/CustomCommonFunction.hlsl"
            #include "../Common/GlobalInput.hlsl"

            struct a2v
            {
                float4 positionOS : POSITION;
                float4 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float2 noiseXY : TEXCOORD2;
                float4 testColorShow : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            //Texture2DArray

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _InstanceGrassPos)
            UNITY_INSTANCING_BUFFER_END(Props)
//--------------------------------- Function ---------------------------------

            // 构建绕任意轴的旋转矩阵
            float4x4 CreateRotationMatrix(float3 axis, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float oc = 1.0 - c;

                return float4x4(
                    oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.x * axis.z + axis.y * s,  0,
                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0,
                    oc * axis.x * axis.z - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,          0,
                    0,                                  0,                                  0,                                  1
                );
            }

            // 四元数旋转辅助函数
            float3 RotatePointAroundPivot(float3 originPoint, float4 quat)
            {
                float3 p = originPoint - float3(0, 0, 0); // 假设绕原点旋转
                float3 result = originPoint;
                float3 u = quat.xyz;
                float s = quat.w;
                result = 2.0 * dot(u, p) * u + (s * s - dot(u, u)) * p + 2.0 * s * cross(u, p);
                return result;
            }

            // 伪随机数生成函数
            float rand(float3 co)
            {
                return frac(sin(dot(co ,float3(12.9898,78.233,53.539))) * 43758.5453);
            }

            half3 RampShadowColor(float3 baseColor, float3 worldPos, float4 shadowCoord)
            {
                Light light = GetMainLight(shadowCoord);
                
                float3 L = normalize(light.direction);
                float att = saturate(light.shadowAttenuation * light.distanceAttenuation);
                float3 N = float3(0, 1, 0);
                float3 V = normalize(GetWorldSpaceNormalizeViewDir(worldPos));
                
                float NdotL = max(0, dot(N, L));
                float NdotV = max(0, dot(N, V));

                float halfLambert = dot(N, L) * 0.5 + 0.5;

                half3 lightColor = light.color;

                float shadowArea = LinearStep(_ShadowThreshold - _ShadowSmooth, _ShadowThreshold + _ShadowSmooth, halfLambert * att);
                shadowArea = saturate(shadowArea + (1 - _ShadowIntensity));
                
                float2 shadowUV = float2(shadowArea, 0.5);
                half3 shadowRamp = (half3)1;      
                #ifdef _OVERRIDE
                    shadowRamp = SAMPLE_TEXTURE2D(_SingleRamp, sampler_LinearClamp, shadowUV).rgb;
                #else
                    shadowRamp = SAMPLE_TEXTURE2D(_Ramp, sampler_LinearClamp, float4(shadowUV, 0, 0)).rgb;
                #endif
                
                half3 diffuse = baseColor * lightColor * shadowRamp;

                return saturate(diffuse);
            }
    
            //Wind
            void VertexWind(float3 objectPositionWS, inout float3 positionOS, float2 windDirection, float windSpeed, float windStrength, float windNoise, float bendRange, float time)
            {
                float2 posUV = objectPositionWS.xz;
                posUV += time * windSpeed * 1.1 * windDirection;
                float4 noiseRamp = SAMPLE_TEXTURE2D_LOD(_WindNoiseRamp, sampler_WindNoiseRamp, TRANSFORM_TEX(posUV, _WindNoiseRamp), 0);

                float3 positionWS = TransformObjectToWorld(positionOS);
                float bend = bendRange * windStrength * abs(sin(time * windSpeed)) * noiseRamp.r;
                float bendNoise = SimpleNoise(positionWS.xz + time * windSpeed * windDirection, windNoise) * windStrength;
                bend += bendNoise;

                float3 windDir = float3(_GrassWindDir.x, 0, _GrassWindDir.y);
                float3 wind = float3(bend, 0, bend);
                positionWS += wind * windDir * bend * saturate(positionOS.y * (1 - _WindGrassHeight));
                positionOS = TransformWorldToObject(positionWS);

                ////--@@@@@@@@@@@@@@
                //return bend.rrr;

            }

            // Collision
            void VertexCollision(inout float3 positionOS, float3 objectPositionWS, float4 objectPos[MAX_OBJECTPOS_COUNT], float posCount, float intensity, float range)
            {
                float3 positionWS = TransformObjectToWorld(positionOS);

                for(int i = 0; i < posCount; i++)
                {
                    float3 objPosXZ = float3(objectPos[i].x, 0, objectPos[i].z);
                    float3 positionWSXZ = float3(positionWS.x, 0, positionWS.z);

                    //范围 + 位置
                    float dist = clamp(objectPos[i].w - distance(objPosXZ, positionWSXZ), 0, objectPos[i].w);
                    float3 dir = normalize(positionWSXZ - objPosXZ);
                    
                    positionWS.xz += dir.xz * range * dist * intensity * 8.5f * saturate(positionOS.y * (1 - _WindGrassHeight));
                    positionWS.y -= dist * (positionWS.y - objectPositionWS.y);//dir.y * dist * range * (intensity * 10) * saturate(positionOS.y * (1 - _WindGrassHeight));
                    positionOS = TransformWorldToObject(positionWS);
                }
            }
            
            //Scale Height
            float GetNoiseRamp(float3 objectPositionWS)
            {
                float2 posUV = objectPositionWS.xz;
                //posUV.y = objectPositionWS.z < 0 ? objectPositionWS.z : abs(1 - objectPositionWS.z);

                float2 normalUV = TRANSFORM_TEX(posUV, _BaseRampNormalTexture);
                float3 normalOS = UnpackNormal(SAMPLE_TEXTURE2D_LOD(_BaseRampNormalTexture, sampler_BaseRampNormalTexture, normalUV, 0));
                normalOS = normalize(float3(normalOS.x, -normalOS.z, normalOS.y));

                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
        
                float LdotN = max(0.001f, dot(normalOS, -lightDir));
                ////--@@@@@@@
                //return LdotN.rrr;
                float2 noiseUV = TRANSFORM_TEX(posUV, _BaseRampTexture);
                float noise = SAMPLE_TEXTURE2D_LOD(_BaseRampTexture, sampler_BaseRampTexture, noiseUV, 0).r;
                
                float tempPowerValue = saturate(pow(abs(noise + _RampPowOffset), _RampPowStrength));
                
                tempPowerValue = lerp(tempPowerValue, LdotN * tempPowerValue, _NormalIntensity);//LdotN;
                
                //防止亮度过曝过低
                tempPowerValue = clamp(0.005f, 0.995f, tempPowerValue);


                return tempPowerValue;
            }

            void VertexScaleHeight(inout float3 positionOS, float3 objectPositionWS, float noise)
            {
                float perGrassHeight = lerp(_Height * _HeightMin, _Height * _HeightMax, noise * _ScaleNoise);
                float perGrassWidth = lerp(_Width * _WidthMin, _Width * _WidthMax, noise);
                float3 temposOS = positionOS;
                #ifdef _BILLBOARD
                    //rotation(make grass LookAt() camera just like a billboard)
                    //=========================================
                    float3 camPos = _WorldSpaceCameraPos;
                    float3 toCamDir = normalize(_WorldSpaceCameraPos - objectPositionWS);

                    // 限制Y轴的倾斜角度
                    float maxCosTheta = cos(radians(_MaxTiltAngle));
                    float cosTheta = dot(normalize(toCamDir), float3(0, 1, 0));
                    if (cosTheta < maxCosTheta)
                    {
                        toCamDir.y = sqrt(1 - maxCosTheta * maxCosTheta);
                    }

                    float3 upDir = float3(0, 1, 0);

                    // 生成随机角度
                    float randomSeed = 0.5f;
                    float randomAngleX = radians(rand(objectPositionWS + float3(randomSeed, 0, 0)) * _BillboardMaxAngle - _BillboardMaxAngle / 2);
                    float randomAngleZ = radians(rand(objectPositionWS + float3(0, randomSeed, 0)) * _BillboardMaxAngle - _BillboardMaxAngle / 2);

                    // 构造旋转矩阵
                    float3x3 rotationX = float3x3(
                        1, 0, 0,
                        0, cos(randomAngleX), -sin(randomAngleX),
                        0, sin(randomAngleX), cos(randomAngleX)
                    );

                    float3x3 rotationZ = float3x3(
                        cos(randomAngleZ), 0, sin(randomAngleZ),
                        0, 1, 0,
                        -sin(randomAngleZ), 0, cos(randomAngleZ)
                    );

                    // 应用旋转到摄像机方向
                    float3 rotatedDir = mul(rotationX, mul(rotationZ, toCamDir));

                    // 构造最终的旋转矩阵
                    float3 newRight = normalize(cross(rotatedDir, upDir));
                    float3 newUp = normalize(cross(newRight, rotatedDir));

                    //Expand Billboard (billboard Left+right)
                    temposOS = positionOS.x * newRight * perGrassWidth;//random width from posXZ, min 0.1
                    //Expand Billboard (billboard Up)
                    temposOS += positionOS.y * newUp * _BillboardHeightIntensity;
                    temposOS.y *= perGrassHeight;

                    //// 构造旋转矩阵
                    //float3 axis = cross(upDir, newDir);
                    //float angle = acos(dot(upDir, newDir));
                    //float4 q = float4(axis * sin(angle / 2), cos(angle / 2));
                    //temposOS = RotatePointAroundPivot(temposOS, q);
                #else
                    temposOS.xz *= perGrassWidth;
                    temposOS.y *= perGrassHeight;
                    
                    //Random Size
                    float noiseSimple = SimpleNoise(objectPositionWS.xz, _NoiseSample);
                    float angle = noiseSimple * _RotationStrength * UNITY_PI * 2;
                    // 构建旋转矩阵并应用到UV坐标
                    float4x4 rotationMatrix = CreateRotationMatrix(_RotationAxis.xyz, angle);
                    temposOS = mul(rotationMatrix, float4(temposOS, 0)).xyz;
                #endif

                positionOS = temposOS;
            }

//----------------------------------------------------------------------------

            v2f BasicVertex(a2v v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                float4 instanceGrassPos = UNITY_ACCESS_INSTANCED_PROP(Props, _InstanceGrassPos);
                
#ifndef _INSTANCE_ON
                
#endif

                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
               
                // 使用 unity_ObjectToWorld 矩阵的第四列获取物体的世界位置
                float3 objectPositionWS = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz + instanceGrassPos.xyz;
                
                float noise = GetNoiseRamp(objectPositionWS);
                
                float3 positionOS = v.positionOS.xyz;
 
                //实现草的碰撞
                #ifdef _COLLISION
                    VertexCollision(positionOS, objectPositionWS, _ObjectArrayPos, _PosCount, _ColIntensity, _ColRange);
                #endif
                //旋转和缩放
                VertexScaleHeight(positionOS, objectPositionWS, noise);

                //实现草的风动
                #if defined _WIND
                    VertexWind(objectPositionWS, positionOS, _WindDir, _WindSpeed, _WindStrength, _WindNoise, _WindBlendRange, _Time.y * _WindGrassSpeed); 
                #endif

                o.positionCS = TransformObjectToHClip(positionOS);
                o.uv = v.uv;
                o.positionWS = TransformObjectToWorld(positionOS);
                o.noiseXY = float2(noise.r, positionOS.y);
                //o.shadowCoord = TransformWorldToShadowCoord(positionWS); 精度不够

                return o;
            }

            float4 BasicFragment(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                ////--@@@@@@@@@@@
                //return i.testColorShow;
                
                // 使用 unity_ObjectToWorld 矩阵的第四列获取物体的世界位置
                float3 objectPositionWS = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
                float tempPowerValue = i.noiseXY.x;
                float tempObjPosY = i.noiseXY.y;

                //---------------------
                half4 finalColor = half4(1, 1, 1, 1);
#ifdef _GROUNDMIX
                float3 groundCamPos = _GroundCamPos.xyz;
                float2 posUV = (i.positionWS.xz - groundCamPos.xz) * (0.5f/_GroundColorCameraSize) + 0.5f;
                
                half4 groundColor = SAMPLE_TEXTURE2D(_GroundColorTexture, sampler_GroundColorTexture, posUV);
                half4 groundHeightTex = SAMPLE_TEXTURE2D(_GroundHeightTexture, sampler_GroundHeightTexture, posUV);
                
                //获取地形高度
                float tempOn = groundHeightTex.b == 1? 1 : -1;
                float groundHeight = groundHeightTex.r * 255 + groundHeightTex.g;
                groundHeight *= tempOn;

                //获取地形高度
                float tempHeight = i.positionWS.y - groundHeight;
                float blendHeight = tempHeight / _GroundColorBlendHeight;
                blendHeight -= _GroundColorBlendIntensity;

                //实现颜色渐变
                float4 baseColorX = SAMPLE_TEXTURE2D(_BaseColorRampTexture, sampler_BaseColorRampTexture, float2(tempPowerValue, 0.5f));
                float4 baseColorY = SAMPLE_TEXTURE2D(_BaseColorRampTexture, sampler_BaseColorRampTexture, float2(tempObjPosY, 0.5f));
                 
                float4 baseColor = lerp(baseColorX, baseColorY, tempObjPosY);

                finalColor = lerp(groundColor, baseColor, saturate(blendHeight));
                
                if((abs(groundHeightTex.r) + abs(groundHeightTex.g)) < 0.001f) finalColor = baseColor;
#else
                //实现颜色渐变
                float4 baseColor = SAMPLE_TEXTURE2D(_BaseColorRampTexture, sampler_BaseColorRampTexture, float2(tempPowerValue, 0.5f));
                finalColor = baseColor;
#endif

                //Shadow Ramp
                float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS);
                finalColor.rgb = RampShadowColor(finalColor.rgb, objectPositionWS, shadowCoord);

                return finalColor;
            }

            ENDHLSL
        }

        
    }

    CustomEditor "SimpleShaderGUI"
}
