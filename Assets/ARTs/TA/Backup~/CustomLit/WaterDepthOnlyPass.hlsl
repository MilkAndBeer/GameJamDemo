struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
};

Varyings WaterDepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    float3 positionWS = vertexInput.positionWS;

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
    
    output.positionCS = TransformWorldToHClip(positionWS);

    return output;
}

half WaterDepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    return input.positionCS.z;
}

