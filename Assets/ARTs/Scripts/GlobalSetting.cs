using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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


    private void OnValueChangedWorked()
    {
        //Debug.Log("@@@@@@@@@ OnValueChangedWorked");
        Shader.SetGlobalFloat("_ShadowThreshold", shadowThreshold);
        Shader.SetGlobalFloat("_ShadowSmooth", shadowSmooth);
        Shader.SetGlobalFloat("_ShadowIntensity", shadowIntensity);
    }

}
