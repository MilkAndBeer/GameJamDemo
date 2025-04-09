using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;

public class GlobalSetting : MonoBehaviour
{
    [Range(0f, 1f)]
    [OnValueChanged("OnValueChangedWorked")]
    public float shadowThreshold = 0.5f;
    [Range(0f, 1f)]
    [OnValueChanged("OnValueChangedWorked")]
    public float shadowSmooth = 0.01f;
    [Range(0f, 1f)]
    [OnValueChanged("OnValueChangedWorked")]
    public float shadowIntensity = 0.5f;

    [OnValueChanged("OnValueChangedWorked")]
    public Texture shadowRamp;

    //--------------------------------
    [OnValueChanged("OnValueChangedWorked")]
    [Range(0f, 1f)]
    public float exposure = 1f;
    [OnValueChanged("OnValueChangedWorked")]
    public Color ambientColor = Color.white;
    [OnValueChanged("OnValueChangedWorked")]
    public Cubemap cubeMap;

    private void OnValueChangedWorked()
    {
        //Debug.Log("@@@@@@@@@ OnValueChangedWorked");
        Shader.SetGlobalFloat("_ShadowThreshold", shadowThreshold);
        Shader.SetGlobalFloat("_ShadowSmooth", shadowSmooth);
        Shader.SetGlobalFloat("_ShadowIntensity", shadowIntensity);
        Shader.SetGlobalTexture("_Ramp", shadowRamp);

        Shader.SetGlobalFloat("_Exposure", exposure);
        Shader.SetGlobalColor("_AmbientColor", ambientColor);

        if (cubeMap != null)
        {
            Vector4[] SHArr = new Vector4[9];
            SHArr = GetSHInCubemap();
            Shader.SetGlobalVectorArray("_SH", SHArr);
        }
    }


    private Vector4[] GetSHInCubemap()
    {
        SphericalHarmonicsL2 sh = new SphericalHarmonicsL2();
        sh.Clear();
        //遍历Cubemap的六个面，并将每个像素的颜色添加到SH中
        AddCubemapToSH(cubeMap, ref sh);

        Vector4[] shArray = new Vector4[9];
        for(int i = 0; i < 9; i++)
        {
            shArray[i] = GetSHCoefficients(sh, i);
        }

        return shArray;
    }

    private Vector4 GetSHCoefficients(SphericalHarmonicsL2 sh, int index)
    {
        // 计算SH系数
        Vector4 coeff = new Vector4(sh[index, 0], sh[index, 1], sh[index, 2], sh[index, 3]);
        return coeff;
    }

    private void AddCubemapToSH(Cubemap cubeMap, ref SphericalHarmonicsL2 sh)
    {
        Color color;
        Vector3 dir;
        for (int faceIndex = 0; faceIndex < 6; faceIndex++)
        {
            CubemapFace face = (CubemapFace)faceIndex;
            for (int y = 0; y < cubeMap.height; y++)
            {
                for (int x = 0; x < cubeMap.width; x++)
                {
                    // 获取 Cubemap 像素颜色
                    color = cubeMap.GetPixel(face, x, y);

                    // 根据像素坐标计算方向向量
                    float u = x / (float)cubeMap.width;
                    float v = y / (float)cubeMap.height;
                    dir = GetDirectionVector(face, u, v);

                    //添加方向光到SH
                    sh.AddDirectionalLight(dir, color.linear, 1);
                }
            }
        }
    }

    private Vector3 GetDirectionVector(CubemapFace face, float u, float v)
    {
        switch (face)
        {
            case CubemapFace.PositiveX: return new Vector3(1, -v * 2 + 1, -u * 2 + 1); // Positive X
            case CubemapFace.NegativeX: return new Vector3(-1, -v * 2 + 1, u * 2 - 1); // Negative X
            case CubemapFace.PositiveY: return new Vector3(u * 2 - 1, 1, v * 2 - 1);   // Positive Y
            case CubemapFace.NegativeY: return new Vector3(u * 2 - 1, -1, -v * 2 + 1); // Negative Y
            case CubemapFace.PositiveZ: return new Vector3(u * 2 - 1, -v * 2 + 1, 1);  // Positive Z
            case CubemapFace.NegativeZ: return new Vector3(-u * 2 + 1, -v * 2 + 1, -1); // Negative Z
            default: return Vector3.zero;
        }
    }
}
