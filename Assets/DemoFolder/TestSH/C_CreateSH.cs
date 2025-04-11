using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class C_CreateSH : MonoBehaviour
{
    public ComputeShader CSShader;
    public Cubemap CubeMapResource;
    public Material SHRenderMat;
    private ComputeBuffer CSDataBuffer;


    void Start()
    {
        CreateSH();
    }

    private void CreateSH()
    {
        int degree = 3;
        int n = (degree + 1) * (degree + 1);
        Vector4[] coefs = new Vector4[n];

        CSDataBuffer = new ComputeBuffer(coefs.Length, 16);
        int kernel = CSShader.FindKernel("CSMain");

        CSShader.SetBuffer(kernel, "RWSHBuffer", CSDataBuffer);
        CSShader.SetTexture(kernel, "_CubeResource", CubeMapResource);

        CSShader.Dispatch(kernel, 16, 1, 1);

        Vector4[] Output = new Vector4[n];
        CSDataBuffer.GetData(Output);

        CSDataBuffer.Release();

        SHRenderMat.SetVectorArray("shData", Output);
        //SHRenderMat.SetVector("c0", Output[0]);
        //SHRenderMat.SetVector("c1", Output[1]);
        //SHRenderMat.SetVector("c2", Output[2]);
        //SHRenderMat.SetVector("c3", Output[3]);
        //SHRenderMat.SetVector("c4", Output[4]);
        //SHRenderMat.SetVector("c5", Output[5]);
        //SHRenderMat.SetVector("c6", Output[6]);
        //SHRenderMat.SetVector("c7", Output[7]);
        //SHRenderMat.SetVector("c8", Output[8]);
        //SHRenderMat.SetVector("c9", Output[9]);
        //SHRenderMat.SetVector("c10", Output[10]);
        //SHRenderMat.SetVector("c11", Output[11]);
        //SHRenderMat.SetVector("c12", Output[12]);
        //SHRenderMat.SetVector("c13", Output[13]);
        //SHRenderMat.SetVector("c14", Output[14]);
        //SHRenderMat.SetVector("c15", Output[15]);
    }

    void Update()
    {
        
    }
}
