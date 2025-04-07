float3 _LightDirection;
float3 _LightPosition;

struct Attributes
{
    float4 positionOS    : POSITION;
    float4 normalOS      : NORMAL;
};

struct Varyings
{
    float4 positionCS    : SV_POSITION;
};

float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS.xyz);
    
    //Offset
    float3 normal = normalize(input.normalOS.xyz);
    float3 positionOS = input.positionOS.xyz;
    positionOS = float3(positionOS.x + normal.x * _Thickness * 0.1, positionOS.y, positionOS.z + normal.z * _Thickness * 0.1);
    float2 uv = positionWS.xz;
    float waveOffset = _Time.y * _OffsetFrequency;
    float height = SimpleNoise(uv + waveOffset, _OffsetLength).r;
    height = Remap(height, float2(0, 1), float2(-1, 1)).r;
    float3 offset = height * _OffsetMagnitude * 0.1;
    positionWS += offset;
    positionOS = TransformWorldToObject(positionWS);

    float3 lightDirectionWS = _LightDirection;
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

    return positionCS;
}

Varyings WaterShadowVertex(Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input);

    output.positionCS = GetShadowPositionHClip(input);
    return output;
}

half4 WaterShadowFragment(Varyings input) : SV_TARGET
{
    return 0;
}
