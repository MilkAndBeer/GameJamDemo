using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using System;



#if UNITY_EDITOR
using UnityEditor;
#endif 

namespace InstancedIndirectGrass
{
    public class InstancedIndirectGrassCreateWithMesh : MonoBehaviour
    {
#if UNITY_EDITOR
        public Mesh grassMesh;
        public Material grassMat;
        public int pointDensity = 100; //点的数量
        [MinValue(0)]
        [MaxValue(1)]
        public float pointRandomRange = 1.0f; //点的随机范围
        [Tooltip("遮挡物高度容错范围")]
        public float maskObjHeight = 0.1f;
        [Tooltip("模型表面误差高度范围")]
        public float meshInaccuracy = 0.1f;

        [Space(10)]
        public Texture2D grassOnRT;
        public float scaleThreshold = 0.05f; //最小生成草的数量
        private float renderCamOrthographicSize;
        private Vector3 renderCamPos;

        public Dictionary<Vector3, GrassInfo> grassInfoDic = new Dictionary<Vector3, GrassInfo>();
        private List<Vector3> grassPosList = new List<Vector3>();

        private Bounds renderBound;

        [Button("Refresh Grass")]
        public void RefreshGrassOnGround()
        {
            if (grassOnRT != null)
                GetRenderCamInfo();
            //--------------------------------------------------------------------------------
            ClearAllGrass();
            GetCurrentPanelBounds();
            GeneratePointOnTopFace(renderBound);
        }

        private bool isRefreshOnFocus = false;
        private void OnFocus()
        {
            if (isRefreshOnFocus)
            {
                isRefreshOnFocus = false;
                InitGrassInfo();
            }
        }

        public void Update()
        {
#if UNITY_EDITOR
            if(Selection.activeObject == gameObject)
            {
                OnFocus();
            }
            else
            {
                isRefreshOnFocus = true; //失去焦点时，下次刷新
            }
#endif
            #region DebugDraw renderBound
            //renderBound.extents 中心点到角的向量
            Debug.DrawLine(renderBound.center, renderBound.center + renderBound.extents, Color.red);
            //renderBound.size从左下角到右上角的向量
            //得到左下角的位置
            Vector3 p2 = renderBound.center - renderBound.extents;
            Debug.DrawLine(p2, p2 + renderBound.size, Color.green);
            //renderBound.min
            Debug.DrawLine(renderBound.center, renderBound.min, Color.gray);
            //renderBound.max 
            Debug.DrawLine(renderBound.center, renderBound.max, Color.cyan);
            //后左下角
            Vector3 backBottomLeft2 = renderBound.min;
            ///后右下角
            Vector3 backBottomRight2 = backBottomLeft2 + new Vector3(renderBound.size.x, 0, 0);
            ///前左下角
            Vector3 forwardBottomLeft2 = backBottomLeft2 + new Vector3(0, 0, renderBound.size.z);
            ///前右下角
            Vector3 forwardBottomRight2 = backBottomLeft2 + new Vector3(renderBound.size.x, 0, renderBound.size.z);
            ///后右上角
            Vector3 backTopRight2 = backBottomLeft2 + new Vector3(renderBound.size.x, renderBound.size.y, 0);
            ///前左上角
            Vector3 forwardTopLeft2 = backBottomLeft2 + new Vector3(0, renderBound.size.y, renderBound.size.z);
            ///后左上角
            Vector3 backTopLeft2 = backBottomLeft2 + new Vector3(0, renderBound.size.y, 0);
            //前右上角
            Vector3 forwardTopRight2 = renderBound.max;

            Debug.DrawLine(renderBound.min, backBottomRight2, Color.blue);
            Debug.DrawLine(backBottomRight2, forwardBottomRight2, Color.blue);
            Debug.DrawLine(forwardBottomRight2, forwardBottomLeft2, Color.blue);
            Debug.DrawLine(forwardBottomLeft2, renderBound.min, Color.blue);

            Debug.DrawLine(renderBound.min, backTopLeft2, Color.blue);
            Debug.DrawLine(backBottomRight2, backTopRight2, Color.blue);
            Debug.DrawLine(forwardBottomRight2, renderBound.max, Color.blue);
            Debug.DrawLine(forwardBottomLeft2, forwardTopLeft2, Color.blue);

            Debug.DrawLine(backTopRight2, backTopLeft2, Color.blue);
            Debug.DrawLine(backTopLeft2, forwardTopLeft2, Color.blue);
            Debug.DrawLine(forwardTopLeft2, renderBound.max, Color.blue);
            Debug.DrawLine(renderBound.max, backTopRight2, Color.blue);
            #endregion
        }

        private void InitGrassInfo()
        {
            grassInfoDic.Clear();
            grassPosList.Clear();
            Dictionary<Vector3, GrassInfo> tempGrassInfoDic = new Dictionary<Vector3, GrassInfo>();
            for (int i = transform.childCount - 1; i >= 0; i--) 
            {
                Transform childTrans = transform.GetChild(i);
                if(childTrans.GetComponent<InstancedIndirectGrassSingleNode>() != null)
                {
                    GrassInfo grassInfo = childTrans.GetComponent<InstancedIndirectGrassSingleNode>().GetGrassInfo();
                    Vector3 tempKeyPos = grassInfo.worldPos;
                    if(!tempGrassInfoDic.ContainsKey(tempKeyPos))
                    { 
                        tempGrassInfoDic.Add(tempKeyPos, grassInfo);
                        grassPosList.Add(tempKeyPos);
                    }
                    else
                    {
                        DestroyImmediate(childTrans.gameObject);
                    }
                }
            }
            grassInfoDic = tempGrassInfoDic;
        }
        private void GetCurrentPanelBounds()
        {
            renderBound = transform.GetTransformWorldBounds();
        }
        private void GeneratePointOnTopFace(Bounds bounds)
        {
            //计算顶面的尺寸
            Vector3 vecMin = renderBound.min + new Vector3(0, renderBound.size.y, 0);
            float width = renderBound.max.x - vecMin.x;
            float length = renderBound.max.z - vecMin.z;
            
            //根据宽度和高度的比例，找到最接近的行数和列数
            double ratio = (double)width / length;
            int divisionsX = (int)Math.Sqrt(pointDensity * ratio);
            int divisionsY = (int)Math.Sqrt(pointDensity / ratio);
            //调整分割数量，确保总分割数量正确
            if(divisionsX * divisionsY < pointDensity)
            {
                divisionsX++;
            }
            if(divisionsX * divisionsY < pointDensity)
            {
                divisionsY++;
            }
            float subWidth = width / divisionsX; //子矩形的宽度
            float subHeight = length / divisionsY; //子矩形的高度

            float limitation = 0.5f * pointRandomRange;
            for(int y = 0; y < divisionsY; y++)
            {
                for (int x = 0; x < divisionsX; x++)
                {
                    Vector3 randomPoint = new Vector3(
                        vecMin.x + x * subWidth + subWidth * 0.5f + limitation * UnityEngine.Random.Range(-subWidth, subWidth),
                        vecMin.y,
                        vecMin.z + y * subHeight + subHeight * 0.5f + limitation * UnityEngine.Random.Range(-subHeight, subHeight)
                        );
                    randomPoint.y += maskObjHeight;
                    GetPointOnSurface(randomPoint);
                }
            }
        }
        private void GetPointOnSurface(Vector3 point)
        {
            RaycastHit hitInfo;
            if(Physics.Raycast(point, Vector3.down, out hitInfo, 100f))
            {
                if(hitInfo.collider != null && hitInfo.collider.gameObject == gameObject
                    && !hitInfo.collider.isTrigger)
                {
                    //判断是否在模型表面
                    Vector3 hitPoint = hitInfo.point;
                    if(hitPoint.y > renderBound.max.y + meshInaccuracy || hitPoint.y < renderBound.max.y - meshInaccuracy)
                    {
                        return;
                    }
                    CreateByPosGrass(hitInfo.point);
                }
            }
        }
        private void CreateByPosGrass(Vector3 position)
        {
            float grassScale = 1;
            if (grassOnRT != null)
            {
                grassScale = GetScalePixelOnPos(position);
                if (grassScale < scaleThreshold)
                    return;
            }

            if(grassMesh == null)
            {
                Debug.LogError("grassMesh is null");
                return;
            }
            Vector3 localPos = position - transform.position;
            if(grassInfoDic.ContainsKey(localPos))
            {
                Debug.LogError("已经存在该位置的草");
                return;
            }

            GrassInfo grassInfo = new GrassInfo();
            grassInfo.grassMesh = grassMesh;
            grassInfo.grassMat = grassMat;

            GameObject tempObj = new GameObject(grassInfo.grassMesh.name);
            tempObj.AddComponent<MeshFilter>().sharedMesh = grassInfo.grassMesh;
            tempObj.AddComponent<MeshRenderer>().sharedMaterial = grassInfo.grassMat;
            Transform tempTrans = tempObj.transform;
            tempTrans.localScale = Vector3.one * grassScale;
            tempTrans.parent = transform;
            tempTrans.position = position;

            grassInfo.grassObj = tempObj;
            grassInfo.worldPos = tempTrans.position;
            grassInfo.grassMatric = Matrix4x4.TRS(tempTrans.position, tempTrans.rotation, tempTrans.GetGlobalScale());
            grassInfo.isCreated = true;

            tempObj.AddComponent<InstancedIndirectGrassSingleNode>().SetGrassInfo(grassInfo);
            Vector3 tempKeyPos = grassInfo.worldPos;
            if (!grassInfoDic.ContainsKey(tempKeyPos))
            {
                grassInfoDic.Add(tempKeyPos, grassInfo);
                grassPosList.Add(tempKeyPos);
            }
            else
            {
                Debug.LogError("已经存在该位置的草");
                DestroyImmediate(tempObj);
            }
        }
        private void ClearAllGrass()
        {
            for (int i = transform.childCount - 1; i >= 0; i--)
            {
                Transform childTrans = transform.GetChild(i);
                if (childTrans.GetComponent<InstancedIndirectGrassSingleNode>() != null)
                {
                    DestroyImmediate(childTrans.gameObject);
                }
            }
            grassInfoDic.Clear();
            grassPosList.Clear();
        }

        #region 读取灰度图信息，判断是否生成
        private void GetRenderCamInfo()
        {
            string grassOnInfo = grassOnRT.name;
            string[] grassOnInfoGroups = grassOnInfo.Split('_');
            int grassOnInfoLength = grassOnInfoGroups.Length;
            renderCamPos = CZLGlobalFunction.GetVector3FromString(grassOnInfoGroups[grassOnInfoLength - 1 - 2], grassOnInfoGroups[grassOnInfoLength - 1 - 1], grassOnInfoGroups[grassOnInfoLength - 1]);
            renderCamOrthographicSize = int.Parse(grassOnInfoGroups[grassOnInfoLength - 1 - 3]);
        }
        private float GetScalePixelOnPos(Vector3 pos)
        {
            float camScreenSize = renderCamOrthographicSize * 2;
            //读取指定位置的像素值,判定是否有草 和 草的大小Scale的读取
            Vector3 diffPosVec = pos - renderCamPos;
            float diffPosX = diffPosVec.x;
            float diffPosZ = diffPosVec.z;
            float uvU = diffPosX / camScreenSize + 0.5f;
            float uvV = diffPosZ / camScreenSize + 0.5f;
            if (uvU < 0 || uvU > 1 || uvV < 0 || uvV > 1)
            {
                Debug.LogError("uv坐标超出范围");
                return 0;
            }

            //读取RenderTexture的像素值
            int x = (int)(uvU * grassOnRT.width);
            int y = (int)(uvV * grassOnRT.height);

            Color pixelColor = grassOnRT.GetPixel(x, y);

            return pixelColor.r;
        }
        #endregion

        #region 外部调用接口
        public void InitGrassMesh()
        {
            InitGrassInfo();
        }
        public void CreateGrassToMeshByPos(Vector3 position)
        {
            CreateByPosGrass(position);
        }
        public void RemoveGrassOnMeshWithBrushByPos(Vector3 position, float brushSize)
        {
            for(int i = grassPosList.Count - 1; i >= 0; i--)
            {
                Vector3 tempPos = grassPosList[i];
                //// 使用Matrix4x4来计算局部位置在世界坐标系下的位置
                //Matrix4x4 parentToWorld = transform.localToWorldMatrix;
                //Vector3 tempPosWorld = parentToWorld.MultiplyPoint(tempPos);
                float distance = Vector3.Distance(position, tempPos);
                if(distance < brushSize)
                {
                    DestroyImmediate(grassInfoDic[tempPos].grassObj);
                    grassInfoDic.Remove(tempPos);
                    grassPosList.RemoveAt(i);
                }
            }
        }

        public List<GrassInfo> GetAllMeshGrassInfo()
        {
            List<GrassInfo> grassInfoList = new List<GrassInfo>();
            for (int i = 0; i < grassPosList.Count; i++) 
            {
                Vector3 tempPos = grassPosList[i];
                if(grassInfoDic.ContainsKey(tempPos)) 
                    grassInfoList.Add(grassInfoDic[tempPos]);
                else
                {
                    Debug.LogError($"grassInfosDic is not contain key， grassInfosDic.Count：{grassInfoDic.Count}  grassPosList.Count: {grassPosList.Count}");
                }
            }

            return grassInfoList;
        }

        public void RefreshAllMeshGrassInfo(List<GrassInfo> grassInfos)
        {
            for (int i = 0; i < grassInfos.Count; i++)
            {
                GrassInfo grassInfo = grassInfos[i];
                grassInfoDic[grassInfo.worldPos] = grassInfo;
            }
            //刷新节点
            for (int i = transform.childCount - 1; i >= 0; i--)
            {
                Transform child = transform.GetChild(i);
                InstancedIndirectGrassSingleNode grassNode = child.GetComponent<InstancedIndirectGrassSingleNode>();
                //TODO
            }

        }
        #endregion
#endif
    }
}
