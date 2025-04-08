#ifndef CARTOONCUSTOMDATA
#define CARTOONCUSTOMDATA

struct CartoonCustomData
{
    half3 baseColor;
    half baseAlpha;
    half3 emission;
};

CartoonCustomData GetDefaultCartoonCustomData()
{
    CartoonCustomData data;
    data.baseColor = half3(0, 0, 0);
    data.baseAlpha = 1;
    data.emission = half3(0, 0, 0);
    
    return data;
}

#endif
