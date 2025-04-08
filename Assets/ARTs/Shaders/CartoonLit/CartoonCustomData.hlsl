#ifndef CARTOONCUSTOMDATA
#define CARTOONCUSTOMDATA

struct CartoonCustomData
{
    half3 baseColor;
    half baseAlpha;
};

CartoonCustomData GetDefaultCartoonCustomData()
{
    CartoonCustomData data;
    data.baseColor = half3(0, 0, 0);
    data.baseAlpha = 1;
    
    return data;
}

#endif
