using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace InstancedIndirectGrass
{
    public class GrassInfo
    {
        public int grassGroupID;        //草类型分组ID
        public Vector3 worldPos;        //草的World位置
        public Matrix4x4 grassMatric;  //草的缩放
        public bool isCreated;      //是否已经创建
        public GameObject grassObj; //生成的草物体
        public Mesh grassMesh;      //使用草的网格
        public Material grassMat;   //显示材质
    }
}