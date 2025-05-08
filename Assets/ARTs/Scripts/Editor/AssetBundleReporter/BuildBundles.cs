using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;


namespace AnalyzeAssetBundleTool
{
    public class BuildBundles
    {
        [MenuItem("CTools/AssetBundle相关/BuildAssetBundle")]
        public static void Build()
        {
            string path = EditorUtility.SaveFolderPanel("AssetBundle 打包目录", "", "");
            if (string.IsNullOrEmpty(path)) return;
            path = Path.Combine(path, GetBuildTarget().ToString());
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            BuildPipeline.BuildAssetBundles(path, BuildAssetBundleOptions.UncompressedAssetBundle, GetBuildTarget());
        }

        public static BuildTarget GetBuildTarget()
        {
            // 这里可以根据需要选择不同的 BuildTarget
            // 例如：BuildTarget.Android, BuildTarget.iOS, BuildTarget.StandaloneWindows 等
            return EditorUserBuildSettings.activeBuildTarget;
        }

        //[MenuItem("CTools/AssetBundle相关/AB分析报告")]
        public static void Reporter()
        {
            string directoryPath = Path.GetDirectoryName(Application.dataPath);
            string bundlePath = Application.streamingAssetsPath + "\\StreamingResources";
            string outputPath = Application.streamingAssetsPath + "\\" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xlsx";
            //AssetBundleReporter.AnalyzePrint(bundlePath, outputPath, () => System.Diagnostics.Process.Start(outputPath));
        }

        public static void MyAnalyzeCustomDepend()
        {
            //AssetBundleFilesAnalyze.
        }

    }
}