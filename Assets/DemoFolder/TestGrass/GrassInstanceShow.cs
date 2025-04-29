using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace InstancedIndirectGrass
{
    public class GrassInstanceShow : MonoBehaviour
    {
        public Mesh mesh;
        public Material material;

        public void Start()
        {
            if (material != null)
            {
                HideAllTransChild();
                CoreUtils.SetKeyword(material, "_INSTANCE_ON", true);
            }
        }

        private void OnEnable()
        {
            if (material != null)
                CoreUtils.SetKeyword(material, "_INSTANCE_ON", true);
        }
        private void OnDisable()
        {
            if (material != null)
                CoreUtils.SetKeyword(material, "_INSTANCE_ON", false);
        }


        private void Update()
        {
            GrassShow();
        }

        private void OnDestroy()
        {
            if (material != null)
                CoreUtils.SetKeyword(material, "_INSTANCE_ON", false);
        }

        private void HideAllTransChild()
        {
            for (int i = 0; i < transform.childCount; i++)
            {
                transform.GetChild(i).gameObject.SetActive(false);
            }
        }

        List<Vector4> grassPosList = new List<Vector4>();
        List<Matrix4x4> matrices = new List<Matrix4x4>();
        private void GrassShow()
        {
            if (mesh == null || material == null)
            {
                return;
            }

            MaterialPropertyBlock mpb = new MaterialPropertyBlock();
            int grassCount = transform.childCount;
            if (grassCount == 0) return;
            if (grassPosList.Count != grassCount)
            {
                grassPosList.Clear();
                matrices.Clear();
                for (int i = 0; i < grassCount; i++)
                {
                    Transform grassTrans = transform.GetChild(i);
                    grassPosList.Add(grassTrans.position);

                    //更新变换矩阵
                    matrices.Add(Matrix4x4.TRS(grassTrans.position, grassTrans.rotation, grassTrans.GetGlobalScale()));
                }
            }

            mpb.SetVectorArray("_InstanceGrassPos", grassPosList.ToArray());

            //使用DrawMeshInstanced绘制实例
            Graphics.DrawMeshInstanced(mesh, 0, material, matrices.ToArray(), grassPosList.Count, mpb);
        }


    }
}
