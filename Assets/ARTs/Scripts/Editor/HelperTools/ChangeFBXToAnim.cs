using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;
using Object = UnityEngine.Object;

namespace CToolsForEditor
{
    public class ChangeFBXToAnim : CToolsBaseEditorWindow
    {
        [MenuItem("Tools/CToolsPackage/ChangeFBXToAnim", false, 12)]
        public static void Init()
        {
            window = (ChangeFBXToAnim)GetWindowWithRect(typeof(ChangeFBXToAnim), new Rect(Screen.width / 2, Screen.height / 2, 600, 200));
            OpenWindow();
        }

        protected override void OnGUI()
        {
            base.OnGUI();
            pathLabelText = "Selected Path: ";
            if (GUI.Button(new Rect(10, 50, 200, 20), "通过FBXAnim生成新Anim"))
            {
                string[] guids;
                //Unity获取指定路径下的所有文件的GUID
                if (path.Split('.').Length == 1)
                {
                    guids = AssetDatabase.FindAssets("", new[] { path });
                }
                else
                {
                    guids = new[] { AssetDatabase.AssetPathToGUID(path) };
                }

                AssetDatabase.StartAssetEditing();
                //生成中间Anim
                FindFBXAnimAndCreateAnim(guids);
                AssetDatabase.StopAssetEditing();
                AssetDatabase.Refresh();
            }

            if (GUI.Button(new Rect(10, 75, 200, 20), "替换FBXAnim的引用到新Anim"))
            {
                string[] guids;
                //Unity获取指定路径下的所有文件的GUID
                if (path.Split('.').Length == 1)
                {
                    guids = AssetDatabase.FindAssets("", new[] { path });
                }
                else
                {
                    guids = new[] { AssetDatabase.AssetPathToGUID(path) };
                }

                AssetDatabase.StartAssetEditing();
                FindFBXAnimAndChangeAnim(guids);
                AssetDatabase.StopAssetEditing();
                AssetDatabase.Refresh();
            }

            if (GUI.Button(new Rect(10, 100, 200, 20), "删除旧的FBX"))
            {
                string[] guids;
                //Unity获取指定路径下的所有文件的GUID
                if (path.Split('.').Length == 1)
                {
                    guids = AssetDatabase.FindAssets("", new[] { path });
                }
                else
                {
                    guids = new[] { AssetDatabase.AssetPathToGUID(path) };
                }

                AssetDatabase.StartAssetEditing();
                RemoveFBXAnimed(guids);
                AssetDatabase.StopAssetEditing();
                AssetDatabase.Refresh();
            }

            if (GUI.Button(new Rect(10, 130, 590, 30), "一键优化Anim资源（选择的文件夹不能包含 Resources\\3DRole\\AnimatorController\\AnimCommon）"))
            {
                string[] guids;
                //Unity获取指定路径下的所有文件的GUID
                if (path.Split('.').Length == 1)
                {
                    guids = AssetDatabase.FindAssets("", new[] { path });
                }
                else
                {
                    guids = new[] { AssetDatabase.AssetPathToGUID(path) };
                }

                AssetDatabase.StartAssetEditing();
                AnimationCopyFromFBXAndOptimize(guids);
                AssetDatabase.StopAssetEditing();
                AssetDatabase.Refresh();
            }
        }

        #region 生成中间Anim
        private static void FindFBXAnimAndCreateAnim(string[] checkGUIDs)
        {
            int countProcess = 0;
            int countChanged = 0;
            Debug.Log("@@ checkGUIDs.Length: " + checkGUIDs.Length);
            foreach (var checkGUID in checkGUIDs)
            {
                countProcess++;
                string assetPath = AssetDatabase.GUIDToAssetPath(checkGUID);
                //Debug.Log("@@ assetPath:  " + assetPath);
                if (assetPath.EndsWith(".fbx") || assetPath.EndsWith(".FBX"))
                {
                    Object[] animationClips = AssetDatabase.LoadAllAssetsAtPath(assetPath);
                    //Debug.Log("@@ srcclip:  " + animationClips.Length);
                    for (int i = 0; i < animationClips.Length; i++)
                    {
                        AnimationClip srcclip = animationClips[i] as AnimationClip;
                        //Debug.Log("@@ srcclip:  " + srcclip);
                        countProcess++;
                        if (srcclip == null || srcclip.name.Contains("__preview"))
                        {
                            continue;
                        }
                        EditorUtility.DisplayProgressBar($"ChangedPath: {assetPath}", $"Updating Animation: {srcclip.name}", (float)countProcess / checkGUIDs.Length);
                        Seperate(assetPath, srcclip);
                        countChanged++;
                    }
                }
            }
            Debug.Log("Create Animation Over with Count: " + countChanged);
        }

        private static void Seperate(string srcclipPath, AnimationClip srcclip)
        {
            string dstDirPath = Path.GetDirectoryName(srcclipPath) + "/" + "Anims";
            if (!Directory.Exists(dstDirPath))
            {
                Directory.CreateDirectory(dstDirPath);
            }

            string dstPath = CToolsGlobalFunction.GetRelativePath(dstDirPath) + "/" + srcclip.name + ".anim";
            AnimationClip dstclip = AssetDatabase.LoadAssetAtPath<AnimationClip>(dstPath);
            bool isNew = false;
            if (dstclip != null)
            {
                dstclip.ClearCurves();
            }
            else
            {
                isNew = true;
                dstclip = new AnimationClip();
            }
            EditorUtility.CopySerialized(srcclip, dstclip);
            if (isNew)
                AssetDatabase.CreateAsset(dstclip, dstPath);
            else
                EditorUtility.SetDirty(dstclip);
        }
        #endregion

        #region 替换FBXAnim的引用到新Anim
        private static void FindFBXAnimAndChangeAnim(string[] checkGUIDs)
        {
            int countProcess = 0;
            int countChanged = 0;
            //Debug.Log("@@ checkGUIDs.Length: " + checkGUIDs.Length);
            List<string> srcGUIDs = new List<string>();
            Dictionary<string, string> dstGUIDDic = new Dictionary<string, string>(); //OriginGUID+名称为索引

            foreach (var checkGUID in checkGUIDs)
            {
                countProcess++;
                string assetPath = AssetDatabase.GUIDToAssetPath(checkGUID);
                if (assetPath.EndsWith(".fbx") || assetPath.EndsWith(".FBX"))
                {
                    Object[] animationClips = AssetDatabase.LoadAllAssetsAtPath(assetPath);
                    for (int i = 0; i < animationClips.Length; i++)
                    {
                        AnimationClip srcclip = animationClips[i] as AnimationClip;
                        //AnimationClip srcclip = AssetDatabase.LoadAssetAtPath<AnimationClip>(assetPath);
                        countProcess++;
                        if (srcclip == null || srcclip.name.Contains("__preview"))
                        {
                            continue;
                        }
                        EditorUtility.DisplayProgressBar($"ChangedPath: {assetPath}", $"Updating Animation: {srcclip.name}", (float)countProcess / checkGUIDs.Length);

                        string tempDrtPath = CToolsGlobalFunction.GetRelativePath($"{Path.GetDirectoryName(assetPath)}/Anims/{srcclip.name}.anim");
                        ChangeAnimCollectedData(assetPath, tempDrtPath, srcclip, ref srcGUIDs, ref dstGUIDDic);
                        countChanged++;
                    }
                }
            }
            ChangeGUIDs(srcGUIDs, dstGUIDDic);
            Debug.Log("Changed Animation Over with Count: " + countChanged);
        }

        private static void ChangeAnimCollectedData(string fbxAnimPath, string drtPath, AnimationClip animationClip, ref List<string> srcGUIDs, ref Dictionary<string, string> dstGUIDDic)
        {
            string tempSrcGUID = AssetDatabase.AssetPathToGUID(fbxAnimPath);
            string tempDrtGUID = AssetDatabase.AssetPathToGUID(drtPath);
            if (!srcGUIDs.Contains(tempSrcGUID))
                srcGUIDs.Add(tempSrcGUID);
            dstGUIDDic.Add(tempSrcGUID + "#" + animationClip.name, tempDrtGUID);
        }

        private static void ChangeGUIDs(List<string> originGUIDs, Dictionary<string, string> updateGUIDDic)
        {
            string[] allAssetGUIDs = AssetDatabase.FindAssets("t:Object", new[] { "Assets" });
            //string[] allAssetGUIDs = AssetDatabase.FindAssets("t:Scene", new[] { "Assets/screen/" });

            Dictionary<string, HashSet<string>> inverseReferenceHashMap = new Dictionary<string, HashSet<string>>();
            for (int i = 0; i < originGUIDs.Count; i++)
            {
                inverseReferenceHashMap[originGUIDs[i]] = new HashSet<string>();
            }

            int scanProgress = 0;
            int referencesCount = 0;

            foreach (var assetGUID in allAssetGUIDs)
            {
                scanProgress++;
                string path = AssetDatabase.GUIDToAssetPath(assetGUID);
                string[] dependencies = AssetDatabase.GetDependencies(path);
                foreach (var dependency in dependencies)
                {
                    EditorUtility.DisplayProgressBar("ChangeGUIDs", "Scaning dependencies...", (float)scanProgress / allAssetGUIDs.Length);
                    var dependencyGUID = AssetDatabase.AssetPathToGUID(dependency);

                    if (inverseReferenceHashMap.ContainsKey(dependencyGUID))
                    {
                        inverseReferenceHashMap[dependencyGUID].Add(path);

                        string metaPath = AssetDatabase.GetTextMetaFilePathFromAssetPath(path);
                        inverseReferenceHashMap[dependencyGUID].Add(metaPath);
                        referencesCount++;
                    }
                }
            }

            Dictionary<string, int> updatedAssets = new Dictionary<string, int>();
            int referencesProgress = 0;
            for (int i = 0; i < originGUIDs.Count; i++)
            {
                //foreach(var originGUID in originGUIDs) {
                try
                {
                    string originGUID = originGUIDs[i];
                    int countReplaced = 0;
                    HashSet<string> referencePaths = inverseReferenceHashMap[originGUID];
                    foreach (var referencePath in referencePaths)
                    {
                        referencesProgress++;
                        EditorUtility.DisplayProgressBar(title: "ChangeGUIDs", info: "Updating dependencies...", (float)referencesProgress / referencesCount);
                        if (CToolsGlobalFunction.IsDirectory(referencePath)) continue;
                        string contents = File.ReadAllText(referencePath);
                        if (!contents.Contains(originGUID)) continue;

                        string updateGUID = "";

                        if (referencePath.Contains(".controller"))
                        {
                            AnimatorController animatorController = AssetDatabase.LoadAssetAtPath<AnimatorController>(referencePath);
                            if (animatorController == null) continue;
                            AnimatorControllerLayer[] layers = animatorController.layers;
                            for (int j = 0; j < layers.Length; j++)
                            {
                                AnimatorStateMachine stateMachine = layers[j].stateMachine;
                                List<ChildAnimatorState> childAnimatorStates = new List<ChildAnimatorState>();
                                GetAllAnimatorStateInController(stateMachine, ref childAnimatorStates);

                                for (int k = 0; k < childAnimatorStates.Count; k++)
                                {
                                    AnimatorState state = childAnimatorStates[k].state;
                                    if (state.motion == null) continue;
                                    string motionGUID = AssetDatabase.AssetPathToGUID(AssetDatabase.GetAssetPath(state.motion));
                                    if (motionGUID == originGUID)
                                    {
                                        updateGUID = updateGUIDDic[originGUID + "#" + state.motion.name];
                                        state.motion = AssetDatabase.LoadAssetAtPath<AnimationClip>(AssetDatabase.GUIDToAssetPath(updateGUID));
                                    }
                                }
                            }
                        }
                        else
                        {
                            string metaPath = AssetDatabase.GetTextMetaFilePathFromAssetPath(AssetDatabase.GUIDToAssetPath(originGUID));
                            Dictionary<long, string> internalIDWithNameDic = new Dictionary<long, string>();
                            internalIDWithNameDic.Clear();
                            GetFBXAnimData(metaPath, ref internalIDWithNameDic);
                            if (internalIDWithNameDic.Count > 0)
                            {
                                //Debug.Log("@#@0 internalIDWithNameDic.Count: " + internalIDWithNameDic.Count);
                                //获取需要替换的数据
                                foreach (var internalID in internalIDWithNameDic.Keys)
                                {
                                    updateGUID = updateGUIDDic[originGUID + "#" + internalIDWithNameDic[internalID]];

                                    string srcClipStr = $"fileID: {internalID}, guid: {originGUID}, type: 3";
                                    string dstClipStr = $"fileID: 7400000, guid: {updateGUID}, type: 2";
                                    if (internalID == 0) { srcClipStr = $@"fileID:\s*\d+\s*,\s*guid:\s*{originGUID}\s*,\s*type:\s*3"; }
                                    //Debug.Log("@#@1 srcClipStr: " + srcClipStr);
                                    //Debug.Log("@#@2 dstClipStr: " + dstClipStr);

                                    if (updateGUID == "")
                                    {
                                        string path = AssetDatabase.GUIDToAssetPath(originGUID);
                                        Debug.LogError($"path:{path} originGUID:{originGUID} ChangeGUIDs Error: updateGUID is null");
                                        continue;
                                    }

                                    contents = Regex.Replace(contents, srcClipStr, dstClipStr);
                                }
                            }
                            else
                            {
                                foreach (var key in updateGUIDDic.Keys)
                                {
                                    if (key.Contains(originGUID))
                                    {
                                        updateGUID = updateGUIDDic[key];
                                        break;
                                    }
                                }

                                if (updateGUID == "")
                                {
                                    string path = AssetDatabase.GUIDToAssetPath(originGUID);
                                    Debug.LogError($"path:{path} originGUID:{originGUID} ChangeGUIDs Error: updateGUID is null");
                                    continue;
                                }

                                //string tempfileID = @"fileID:\s+\d+";
                                string srcClipStr = $@"fileID:\s*\d+\s*,\s*guid:\s*{originGUID}\s*,\s*type:\s*3";
                                string dstClipStr = $"fileID: 7400000, guid: {updateGUID}, type: 2";

                                contents = Regex.Replace(contents, srcClipStr, dstClipStr);
                            }

                            File.WriteAllText(referencePath, contents);
                        }

                        countReplaced++;
                    }

                    updatedAssets.Add(AssetDatabase.GUIDToAssetPath(originGUID), countReplaced);
                }
                catch (System.Exception e)
                {
                    Debug.LogError("ChangeGUIDs Error: " + e.Message);
                }
                finally
                {
                    EditorUtility.ClearProgressBar();
                }

                //if (updatedAssets.Count > 0)
                //{
                //    foreach (var updatedAsset in updatedAssets)
                //    {
                //        Debug.Log($"ChangeGUIDs: {updatedAsset.Key} - {updatedAsset.Value} references updated");
                //    }
                //}
            }
        }

        private static void GetAllAnimatorStateInController(AnimatorStateMachine stateMachine, ref List<ChildAnimatorState> childAnimatorStates)
        {
            ChildAnimatorState[] states = stateMachine.states;
            childAnimatorStates.AddRange(states);

            foreach (var subStateMachine in stateMachine.stateMachines)
            {
                GetAllAnimatorStateInController(subStateMachine.stateMachine, ref childAnimatorStates);
            }
        }

        private static void GetFBXAnimData(string fbxMetaPath, ref Dictionary<long, string> internalIDWithNameDic)
        {
            string originFileContents = File.ReadAllText(fbxMetaPath);
            int startPoint = originFileContents.IndexOf("clipAnimations:");
            int endPoint = originFileContents.IndexOf("isReadable:");
            if (endPoint > startPoint && startPoint > 0 && endPoint > 0)
            {
                originFileContents = originFileContents.Substring(startPoint, endPoint - startPoint);
                string[] nameGetArr = originFileContents.Split("name: ");

                List<string> animClipNameList = new List<string>();
                List<long> animClipInternalID = new List<long>();
                for (int indexName = 1; indexName < nameGetArr.Length; indexName++)
                {
                    //string tempName = nameGetArr[indexName].Split("takeName").GetValue(0).ToString();
                    string tempName = Regex.Split(nameGetArr[indexName], @"\s+takeName").GetValue(0).ToString();
                    animClipNameList.Add(tempName);
                }

                string[] internalIDGetArr = originFileContents.Split("internalID: ");
                for (int indexInternalID = 1; indexInternalID < internalIDGetArr.Length; indexInternalID++)
                {
                    //long tempInternalID = Convert.ToInt64(internalIDGetArr[indexInternalID].Split("firstFrame").GetValue(0));
                    long tempInternalID = Convert.ToInt64(Regex.Split(internalIDGetArr[indexInternalID], @"\s+firstFrame").GetValue(0));
                    animClipInternalID.Add(tempInternalID);
                }
                if (animClipNameList.Count == animClipInternalID.Count)
                {
                    for (int i = 0; i < animClipNameList.Count; i++)
                    {
                        internalIDWithNameDic.Add(animClipInternalID[i], animClipNameList[i]);
                    }
                }
            }
        }
        #endregion

        #region 删除旧的FBXAnim
        public static void RemoveFBXAnimed(string[] checkGUIDs)
        {
            int countProcess = 0;
            int countChanged = 0;
            foreach (var checkGUID in checkGUIDs)
            {
                countProcess++;
                string assetPath = AssetDatabase.GUIDToAssetPath(checkGUID);
                if (assetPath.EndsWith(".fbx") || assetPath.EndsWith(".FBX"))
                {
                    if (assetPath.Contains("@Skin")) continue;

                    #region 判断检查是否存在动画片段文件
                    Object[] animationClips = AssetDatabase.LoadAllAssetsAtPath(assetPath);
                    bool isRemove = false;
                    for (int i = 0; i < animationClips.Length; i++)
                    {
                        AnimationClip srcclip = animationClips[i] as AnimationClip;
                        countProcess++;
                        if (srcclip == null || srcclip.name.Contains("__preview"))
                        {
                            continue;
                        }
                        isRemove = true;
                    }
                    if (!isRemove) continue;
                    #endregion

                    EditorUtility.DisplayProgressBar("Remove FBXAnim", $"Remove : {assetPath}", (float)countProcess / checkGUIDs.Length);
                    bool removeSucess = AssetDatabase.DeleteAsset(assetPath);
                    if (removeSucess) countChanged++;
                }
            }
        }

        #endregion

        #region 优化选中文件夹中的所有Anim
        private static void AnimationCopyFromFBXAndOptimize(string[] guids)
        {
            int countProcess = 0;
            int countChanged = 0;

            List<string> animFBXList = new List<string>();
            List<string> srcGUIDs = new List<string>();
            Dictionary<string, string> dstGUIDDic = new Dictionary<string, string>(); //OriginGUID+名称为索引

            #region 生成新的Anim资源
            foreach (var checkGUID in guids)
            {
                countProcess++;
                string assetPath = AssetDatabase.GUIDToAssetPath(checkGUID);
                if (assetPath.Contains("Resources\\3DRole\\AnimatorController\\AnimCommon") ||
                    assetPath.Contains("Resources/3DRole/AnimatorController/AnimCommon")) continue;
                Debug.Log("@@ assetPath:  " + assetPath);
                if (assetPath.EndsWith(".fbx") || assetPath.EndsWith(".FBX"))
                {
                    Object[] animationClips = AssetDatabase.LoadAllAssetsAtPath(assetPath);
                    //Debug.Log("@@ srcclip:  " + animationClips.Length);
                    for (int i = 0; i < animationClips.Length; i++)
                    {
                        AnimationClip srcclip = animationClips[i] as AnimationClip;
                        //Debug.Log("@@ srcclip:  " + srcclip);
                        countProcess++;
                        if (srcclip == null || srcclip.name.Contains("__preview"))
                        {
                            continue;
                        }
                        EditorUtility.DisplayProgressBar($"ChangedPath: {assetPath}", $"Updating Animation: {srcclip.name}", (float)countProcess / guids.Length);
                        //Create
                        Seperate(assetPath, srcclip);
                        animFBXList.Add(assetPath);
                        //Change
                        string tempDrtPath = CToolsGlobalFunction.GetRelativePath($"{Path.GetDirectoryName(assetPath)}/Anims/{srcclip.name}.anim");
                        ChangeAnimCollectedData(assetPath, tempDrtPath, srcclip, ref srcGUIDs, ref dstGUIDDic);
               
                        countChanged++;
                    }
                }
            }

            #endregion

            #region 查找所用引用旧FBXAnim资源Hash表并替换
            //string tempDrtPath = CToolsGlobalFunction.GetRelativePath($"{Path.GetDirectoryName(assetPath)}/Anims/{srcclip.name}.anim");
            //ChangeAnimCollectedData(assetPath, tempDrtPath, srcclip, ref srcGUIDs, ref dstGUIDDic);
            ChangeGUIDs(srcGUIDs, dstGUIDDic);
            Debug.Log("Changed Animation Over with Count: " + countChanged);
            #endregion

            #region 删除旧FBXAnim资源
            countProcess = 0;
            countChanged = 0;
            for (int i = 0; i < animFBXList.Count; i++)
            {
                countProcess++;
                string assetPath = animFBXList[i];
                if (assetPath.Contains("@Skin")) continue;
                #region 判断检查是否存在动画片段文件
                Object[] animationClips = AssetDatabase.LoadAllAssetsAtPath(assetPath);
                bool isRemove = false;
                for (int j = 0; j < animationClips.Length; j++)
                {
                    AnimationClip srcclip = animationClips[j] as AnimationClip;
                    countProcess++;
                    if (srcclip == null || srcclip.name.Contains("__preview"))
                    {
                        continue;
                    }
                    isRemove = true;
                }
                if (!isRemove) continue;
                #endregion
                EditorUtility.DisplayProgressBar("Remove FBXAnim", $"Remove : {assetPath}", (float)countProcess / guids.Length);
                bool removeSucess = AssetDatabase.DeleteAsset(assetPath);
                if (removeSucess) countChanged++;
            }
            Debug.Log("Remove FBXAnimation with Count: " + countChanged);
            #endregion

        }
        #endregion
    }
}