using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;
using UnityEngine.Events;

namespace AnalyzeAssetBundleTool
{
    /// <summary>
    /// AB 文件分析器
    /// </summary>
    public static class AssetBundleFilesAnalyze
    {
        #region 对外接口
        /// <summary>
        /// 自定义分析依赖
        /// </summary>
        public static System.Func<string, List<AssetBundleFileInfo>> analyzeCustomDepend;

        /// <summary>
        /// 分析的时候，也导出资源
        /// </summary>
        public static bool analyzeExport { get; set; }

        /// <summary>
        /// 分析的时候，只分析场景，这需要播放运行才能分析场景
        /// </summary>
        public static bool analyzeOnlyScene { get; set; }
        #endregion

        #region 内部实现
        private static List<AssetBundleFileInfo> sAssetBundleFileInfos;
        private static Dictionary<long, AssetFileInfo> sAssetFileInfos;
        private static AssetBundleFilesAnalyzeScene sAnalyzeScene;

        public static UnityAction analyzeCompleted;

        /// <summary>
        /// 获取所有的 AssetBundle 文件信息
        /// </summary>
        /// <returns></returns>
        public static List<AssetBundleFileInfo> GetAllAssetBundleFileInfos()
        {
            return sAssetBundleFileInfos;
        }

        public static AssetBundleFileInfo GetAssetBundleFileInfo(string name)
        {
            return sAssetBundleFileInfos.Find(x => x.name == name);
        }

        /// <summary>
        /// 获取所有的 Asset 文件信息
        /// </summary>
        /// <returns></returns>
        public static Dictionary<long, AssetFileInfo> GetAllAssetFileInfo()
        {
            return sAssetFileInfos;
        }

        public static AssetFileInfo GetAssetFileInfo(long guid)
        {
            if (sAssetFileInfos == null)
                sAssetFileInfos = new Dictionary<long, AssetFileInfo>();

            AssetFileInfo info;
            if (!sAssetFileInfos.TryGetValue(guid, out info))
            {
                info = new AssetFileInfo { guid = guid };
                sAssetFileInfos.Add(guid, info);
            }
            return info;
        }

        public static void Clear()
        {
            if (sAssetBundleFileInfos != null)
            {
                sAssetBundleFileInfos.Clear();
                sAssetBundleFileInfos = null;
            }
            if (sAssetFileInfos != null)
            {
                sAssetFileInfos.Clear();
                sAssetFileInfos = null;
            }
            sAnalyzeScene = null;

            EditorUtility.UnloadUnusedAssetsImmediate();
            System.GC.Collect();
        }

        public static bool Analyze(string directoryPath)
        {
            if (!Directory.Exists(directoryPath))
            {
                Debug.LogError("指定的目录不存在: " + directoryPath);
                return false;
            }

            if (analyzeCustomDepend != null)
                sAssetBundleFileInfos = analyzeCustomDepend(directoryPath);
            if (sAssetBundleFileInfos == null)
                sAssetBundleFileInfos = AnalyzeManifestDepend(directoryPath);
            if (sAssetBundleFileInfos == null)
            {
                sAssetBundleFileInfos = AnalyzAllFiles(directoryPath);
            }
            if (sAssetBundleFileInfos == null)
            {
                return false;
            }

            sAnalyzeScene = new AssetBundleFilesAnalyzeScene();
            AnalyzeBundleFiles(sAssetBundleFileInfos);
            sAnalyzeScene.Analyze();
            if (!sAnalyzeScene.IsAnalyzing())
            {
                if (analyzeCompleted != null)
                {
                    analyzeCompleted.Invoke();
                }
            }

            return true;
        }

        /// <summary>
        /// 分析Unity方式的依赖构成
        /// </summary>
        /// <param name="directoryPath"></param>
        /// <returns></returns>
        private static List<AssetBundleFileInfo> AnalyzeManifestDepend(string directoryPath)
        {
            string manifestName = Path.GetFileName(directoryPath);
            string manifestPath = Path.Combine(directoryPath, manifestName);
            if (!File.Exists(manifestPath))
            {
                Debug.LogWarning(manifestPath + " is not exists! Use AnalyzAllFiles ...");
                return null;
            }

            AssetBundle manifestAB = AssetBundle.LoadFromFile(manifestPath);

            if (!manifestAB)
            {
                Debug.LogError(manifestPath + " ab load faild!");
                return null;
            }

            List<AssetBundleFileInfo> infos = new List<AssetBundleFileInfo>();
            AssetBundleManifest assetBundleManifest = manifestAB.LoadAsset<AssetBundleManifest>("assetbundlemanifest");
            var bundles = assetBundleManifest.GetAllAssetBundles();
            foreach (var bundle in bundles)
            {
                string path = Path.Combine(directoryPath, bundle);
                AssetBundleFileInfo info = new AssetBundleFileInfo
                {
                    name = bundle,
                    path = path,
                    rootPath = directoryPath,
                    size = new FileInfo(path).Length,
                    directDepends = assetBundleManifest.GetDirectDependencies(bundle),
                    allDepends = assetBundleManifest.GetAllDependencies(bundle)
                };
                infos.Add(info);
            }
            manifestAB.Unload(true);
            return infos;
        }

        /// <summary>
        /// 直接递归所有文件
        /// </summary>
        /// <param name="directoryPath"></param>
        /// <returns></returns>
        private static List<AssetBundleFileInfo> AnalyzAllFiles(string directoryPath)
        {
            List<AssetBundleFileInfo> infos = new List<AssetBundleFileInfo>();
            string bom = "Unity";
            char[] flag = new char[5];
            string[] files = Directory.GetFiles(directoryPath, "*", SearchOption.AllDirectories);
            int fileCount = files.Length;
            for (int i = 0; i < fileCount; i++)
            {
                string file = files[i];
                using (StreamReader streamReader = new StreamReader(file))
                {
                    if (streamReader.Read(flag, 0, flag.Length) == flag.Length && new string(flag) == bom)
                    {
                        AssetBundleFileInfo info = new AssetBundleFileInfo
                        {
                            name = Path.GetFileName(file),
                            path = file,
                            rootPath = directoryPath,
                            size = streamReader.BaseStream.Length,
                            directDepends = new string[] { },
                            allDepends = new string[] { },
                        };
                        infos.Add(info);
                    }
                }
            }

            return infos;
        }

        private static void AnalyzeBundleFiles(List<AssetBundleFileInfo> infos)
        {
            int infoCount = infos.Count;
            //分析被依赖的关系
            for (int i = 0; i < infoCount; i++)
            {
                AssetBundleFileInfo info = infos[i];
                List<string> beDepends = new List<string>();
                for (int j = 0; j < infoCount; j++)
                {
                    AssetBundleFileInfo info2 = infos[j];
                    {
                        if (info2.name == info.name)
                        {
                            continue;
                        }

                        if (info2.allDepends.Contains(info.name))
                        {
                            beDepends.Add(info2.name);
                        }
                    }
                    info.beDepends = beDepends.ToArray();
                }
            }

            // 以下不能保证百分百找到所有的资源，最准确的方式是解密AssetBundle格式
            for (int x = 0; x < infoCount; x++)
            {
                AssetBundleFileInfo info = infos[x];
                AssetBundle ab = AssetBundle.LoadFromFile(info.path);
                if (ab)
                {
                    try
                    {
                        if (!ab.isStreamedSceneAssetBundle)
                        {
                            if (!analyzeOnlyScene)
                            {
                                Object[] objs = ab.LoadAllAssets<Object>();
                                foreach (var item in objs)
                                {
                                    AnalyzeObjectReference(info, item);
                                    AnalyzeObjectComponent(info, item);
                                }
                                AnalyzeObjectsCompleted(info);
                            }
                        }
                        else
                        {
                            info.isScene = true;
                            sAnalyzeScene.AddBundleSceneInfo(info, ab.GetAllScenePaths());
                        }
                    }
                    finally
                    {
                        ab.Unload(true);
                    }
                }
            }
        }

        private static PropertyInfo inspectorMode;

        public static void AnalyzeObjectReference(AssetBundleFileInfo info, Object o)
        {
            if (o == null || info.objDict.ContainsKey(o)) return;

            var serializedObject = new SerializedObject(o);
            info.objDict.Add(o, serializedObject);
            if (inspectorMode == null)
            {
                inspectorMode = typeof(SerializedObject).GetProperty("inspectorMode", BindingFlags.NonPublic | BindingFlags.Instance);
            }
            inspectorMode.SetValue(serializedObject, InspectorMode.Debug, null);

            var it = serializedObject.GetIterator();
            while (it.NextVisible(true))
            {
                if (it.propertyType == SerializedPropertyType.ObjectReference && it.objectReferenceValue != null)
                {
                    AnalyzeObjectReference(info, it.objectReferenceValue);
                }
            }

            // 只能用另一种方式获取的引用
            AnalyzeObjectReference2(info, o);
        }

        /// <summary>
        /// 动画控制器比较特殊，不能通过序列化得到
        /// </summary>
        /// <param name="info"></param>
        /// <param name="o"></param>
        private static void AnalyzeObjectReference2(AssetBundleFileInfo info, Object o)
        {
            AnimatorController ac = o as AnimatorController;
            if (ac)
            {
                foreach (var clip in ac.animationClips)
                {
                    AnalyzeObjectReference(info, clip);
                }
            }

        }

        /// <summary>
        /// 分析脚本的引用（这只在脚本在工程里时才有效）
        /// </summary>
        /// <param name="info"></param>
        /// <param name="o"></param>
        public static void AnalyzeObjectComponent(AssetBundleFileInfo info, Object o)
        {
            var go = o as GameObject;
            if (!go) return;

            var components = go.GetComponentsInChildren<Component>(true);
            foreach (var component in components)
            {
                if (!component) continue;
                AnalyzeObjectReference(info, component);
            }
        }

        public static void AnalyzeObjectsCompleted(AssetBundleFileInfo info)
        {
            foreach (var obj in info.objDict)
            {
                AssetBundleFilesAnalyzeObject.ObjectAddToFileInfo(obj.Key, obj.Value, info);
                obj.Value.Dispose();
            }
            info.objDict.Clear();
        }

        #endregion
    }
}