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
    public ComputeShader csComputeShader;



    private void OnValueChangedWorked()
    {
        //Debug.Log("@@@@@@@@@ OnValueChangedWorked");
        Shader.SetGlobalFloat("_ShadowThreshold", shadowThreshold);
        Shader.SetGlobalFloat("_ShadowSmooth", shadowSmooth);
        Shader.SetGlobalFloat("_ShadowIntensity", shadowIntensity);
        Shader.SetGlobalTexture("_Ramp", shadowRamp);

        Shader.SetGlobalFloat("_Exposure", exposure);
        Shader.SetGlobalColor("_AmbientColor", ambientColor);

    }

    private ComputeBuffer csDataBuffer;
    [Button("设置全局数据")]
    public void SetSH()
    {
        if (cubeMap != null)
        {
            int degree = 3;
            int n = (degree + 1) * (degree + 1);
            Vector4[] coefs = new Vector4[n];

            csDataBuffer = new ComputeBuffer(coefs.Length, 16);
            int kernel = csComputeShader.FindKernel("CSMain");

            csComputeShader.SetBuffer(kernel, "RWSHBuffer", csDataBuffer);
            csComputeShader.SetTexture(kernel, "_CubeResource", cubeMap);
            csComputeShader.Dispatch(kernel, 16, 1, 1);

            Vector4[] SHArr = new Vector4[n];
            csDataBuffer.GetData(SHArr);

            csDataBuffer.Release();

            Shader.SetGlobalVectorArray("_SHData", SHArr);
        }
    }
}
