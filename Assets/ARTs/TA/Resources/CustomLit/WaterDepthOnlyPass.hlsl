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
    float3 positionOS = input.positionOS.xyz;
    float time = fmod(_Time.y, 2e5);

    //Warp ----------------------------------
    VertexWarp(positionWS, positionOS, _WarpPosition, _WarpIntensity, _WarpRange);
    // --------------------------------------

    //Thickness ----------------------------------
    VertexThickness(positionWS, positionOS, input.normalOS.xyz, _Thickness);
    // -------------------------------------------
    
    //Wave ---------------------------------------
    VertexHeight(positionWS, positionOS, _OffsetLength, _OffsetFrequency, _OffsetMagnitude, time);
    // -------------------------------------------
    
    output.positionCS = TransformWorldToHClip(positionWS);

    return output;
}

half WaterDepthOnlyFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    return input.positionCS.z;
}

