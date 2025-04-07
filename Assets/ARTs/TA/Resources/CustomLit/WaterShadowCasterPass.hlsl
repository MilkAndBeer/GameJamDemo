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
    float3 positionOS = input.positionOS.xyz;
    float3 positionWS = TransformObjectToWorld(positionOS);
    float time = fmod(_Time.y, 2e5);

    //Warp ----------------------------------
    VertexWarp(positionWS, positionOS, _WarpPosition, _WarpIntensity, _WarpRange);
    // --------------------------------------

    //Thickness ----------------------------------
    VertexThickness(positionWS, positionOS, input.normalOS.xyz, _Thickness);
    // -------------------------------------------
    
    //Offset
    VertexHeight(positionWS, positionOS, _OffsetLength, _OffsetFrequency, _OffsetMagnitude, time);

    float3 lightDirectionWS = _LightDirection;
    float3 normalWS = TransformObjectToWorldNormal(input.normalOS.xyz);
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
