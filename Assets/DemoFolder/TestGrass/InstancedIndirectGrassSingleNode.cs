using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace InstancedIndirectGrass
{
    public class InstancedIndirectGrassSingleNode : MonoBehaviour
    {
        public int grassGroupID;        //草类型分组ID
        public bool isCreated;          //是否已经创建
        public GameObject grassObj;     //生成的草物体
        public Mesh grassMesh;         //草的网格
        public Material grassMat;       //草的材质

        public void SetGrassInfo(GrassInfo grassInfo)
        {
            grassGroupID = grassInfo.grassGroupID;
            isCreated = grassInfo.isCreated;
            grassObj = grassInfo.grassObj;
            grassMesh = grassInfo.grassMesh;
            grassMat = grassInfo.grassMat;
        }

        public GrassInfo GetGrassInfo()
        {
            GrassInfo grassInfo = new GrassInfo();
            grassInfo.grassGroupID = grassGroupID;
            grassInfo.isCreated = isCreated;
            grassInfo.grassObj = grassObj;
            grassInfo.grassMesh = grassMesh;
            grassInfo.grassMat = grassMat;
         
            return grassInfo;
        }
    }
}
