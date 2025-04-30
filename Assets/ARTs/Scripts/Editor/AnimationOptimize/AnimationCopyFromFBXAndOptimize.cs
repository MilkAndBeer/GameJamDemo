using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;
using Debug = UnityEngine.Debug;

/// <summary>
/// 1.复制选择的文件夹内所有FBX内的动画
/// 2.老动画的状态机引用迁移到新动画
/// 3.删除复制出动画的fbx
/// 4.优化选择的文件夹下所有动画animationClip
/// </summary>
public class AnimationCopyFromFBXAndOptimize
{
    /// <summary>
    /// key: oldAnim value: newAnim
    /// </summary>
    private static Dictionary<AnimationClip, AnimationClip> mAnimationDic;
    private static List<string> mDelectFBXs;

    [MenuItem("CTools/动画优化/复制FBX动画并优化（选择的文件夹不能包含 Resources\\3DRole\\AnimatorController\\AnimCommon）")]
    public static void AnimationClipsCopy()
    {
        mAnimationDic = new Dictionary<AnimationClip, AnimationClip>();
        mDelectFBXs = new List<string>();

        Object[] selection = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
        if (selection.Length == 0)
        {
            Debug.LogWarning("请选择一个文件夹");
            return;
        }
        string selectedPath = AssetDatabase.GetAssetPath(selection[0]);
        //检查是否选择了文件夹
        if (string.IsNullOrEmpty(selectedPath) || !AssetDatabase.IsValidFolder(selectedPath))
        {
            Debug.LogWarning("请选择一个文件夹");
            return;
        }

        string resourcesPath = Path.Combine(Application.dataPath.Substring(0, Application.dataPath.Length - "Assets".Length), selectedPath);
        Debug.Log("开始处理目录：" + resourcesPath);

        Stopwatch stopwatch = new Stopwatch();
        stopwatch.Start();
        // 1.递归处理目录，复制动画
        ProcessDirectory(resourcesPath);
        stopwatch.Stop();
        Debug.LogError($"ProcessDirectory 执行时间: {stopwatch.ElapsedMilliseconds / 1000} 秒");
        stopwatch.Reset();
        AssetDatabase.SaveAssets();

        if(mAnimationDic != null)
        {
            stopwatch.Start();
            // 2.将复制出来的动画重引用(整个项目的(Override)controller)
            foreach (var kvp in mAnimationDic)
            {
                ReplaceInAnimationController(kvp.Key, kvp.Value);
            }
            Debug.LogError($"ReplaceInAnimationController 执行时间: {stopwatch.ElapsedMilliseconds / 1000} 秒");
            stopwatch.Reset();
            AssetDatabase.SaveAssets();
        }

        stopwatch.Start();
        // 3.优化选择文件夹的动画 path是相对路径
        OptimizeAnimationClipByText(selectedPath);
        Debug.LogError($"优化动画 执行时间：{stopwatch.ElapsedMilliseconds / 1000} 秒");
        stopwatch.Reset();

        if(mDelectFBXs != null)
        {
            stopwatch.Start();
            //4.删除FBX
            DeletFBXs();
            Debug.LogError($"删除FBX 执行时间: {stopwatch.ElapsedMilliseconds / 1000} 秒");
            stopwatch.Reset();
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
        EditorUtility.DisplayDialog("提示", "动画复制完成！", "确定");
    }

    private static void DeletFBXs()
    {
        foreach(var fbxPath in mDelectFBXs)
        {
            ////排除此文件：skin文件含无用动画,不应删除
            //if (fbxPath.EndsWith("/M_3001_byakko_1@Skin.FBX")) continue;
            
            bool success = AssetDatabase.DeleteAsset(fbxPath);
            if (success)
            {
                Debug.Log($"删除FBX成功: {fbxPath}");
            }
            else
            {
                Debug.LogError($"删除FBX失败: {fbxPath}");
            }
        }
    }

    private static void ProcessDirectory(string directoryPath)
    {
        // 获取当前目录下一层级的所有文件路径
        string[] files = Directory.GetFiles(directoryPath);
        foreach(string filePath in files)
        {
            if (filePath.EndsWith(".meta")) continue;

            // 检查文件是否为 .fbx 类型
            if(filePath.EndsWith(".fbx", System.StringComparison.OrdinalIgnoreCase))
            {
                string relativePath = filePath.Replace(Application.dataPath, "Assets").Replace("\\", "/");

                //var modelImporter = AssetImporter.GetAtPath(relativePath) as ModelImporter;
                //modelImporter.isReadable = true;
                //var tests = modelImporter.clipAnimations;
                //var fbx = AssetDatabase.LoadAssetAtPath<GameObject>(relativePath);
                //var anims = AnimationUtility.GetAnimationClips(fbx); //从animator或animation组件中检索动画信息

                var objs = AssetDatabase.LoadAllAssetRepresentationsAtPath(relativePath); //在project中显式可见的内容
                if (objs.Length <= 0) continue;
                var anims = new List<AnimationClip>();
                foreach(var obj in objs)
                {
                    if (obj is AnimationClip clip)
                    {
                        anims.Add(clip);
                    }
                }

                if(anims.Count > 0)
                {
                    string animFolderPath = Path.Combine(directoryPath, "animCopy");
                    if (!Directory.Exists(animFolderPath))
                    {
                        Directory.CreateDirectory(animFolderPath);
                        Debug.Log("创建 anim 文件夹:" + animFolderPath);
                    }

                    bool isLegal = false;
                    AnimCopy(anims, animFolderPath, ref isLegal);

                    if (!isLegal)
                    {
                        if(!mDelectFBXs.Contains(relativePath))
                        { mDelectFBXs.Add(relativePath); }
                    }
                }
            }

        }

        //递归处理子目录
        string[] subDirectories = Directory.GetDirectories(directoryPath);
        foreach (var subDirectory in subDirectories)
        {
            ProcessDirectory(subDirectory);
        }
    }

    private static void AnimCopy(List<AnimationClip> anims, string folderPath, ref bool isLegal)
    {
        //转换成相对路径
        folderPath = "Assets" + folderPath.Substring(Application.dataPath.Length);
        string animationPath = "";

        foreach(var clip in anims)
        {
            if(clip.name == "skin" || clip.name == "Skin")
            {
                isLegal = true; continue;
            }
            AnimationClip srcClip = clip;   //源AnimationClip
            AnimationClip newClip = new()   //新AnimationClip
            { name = srcClip.name };        //设置新Clip的名称
            animationPath = folderPath + "/" + newClip.name + ".anim"; //新动画的路径

            EditorUtility.CopySerialized(srcClip, newClip); //复制动画数据
            AssetDatabase.CreateAsset(newClip, animationPath); //创建新动画
            mAnimationDic.TryAdd(srcClip, newClip); //添加到字典中
        }
    }

    private static void ReplaceInAnimationController(AnimationClip oldClip, AnimationClip newClip)
    {
        if (oldClip == null)
        {
            Debug.LogError("Please assign a valid Animation Clip.");
            return;
        }
        // 遍历项目所有Animator Controllers
        string[] controllerGUIDs0 = AssetDatabase.FindAssets("t:AnimatorOverrideController");
        foreach (var guid in controllerGUIDs0)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            AnimatorOverrideController controller = AssetDatabase.LoadAssetAtPath<AnimatorOverrideController>(path);
            bool modified = false; //标记是否修改
            if (controller)
            {
                List<KeyValuePair<AnimationClip, AnimationClip>> overrides = new List<KeyValuePair<AnimationClip, AnimationClip>>(controller.overridesCount);
                controller.GetOverrides(overrides);
                for (int i = 0; i < overrides.Count; i++)
                {
                    if (overrides[i].Value == oldClip)
                    {
                        overrides[i] = new KeyValuePair<AnimationClip, AnimationClip>(overrides[i].Key, newClip);
                        modified = true;
                    }
                }

                if (modified)
                {
                    //若controller用到oldClip, 则用newClip替换
                    controller.ApplyOverrides(overrides);

                    //应用新的覆盖关系
                    EditorUtility.SetDirty(controller);
                    Debug.Log($"Replaced clip in Animator Controller: {controller.name}");
                }
            }
        }

        string[] controllerGUIDs = AssetDatabase.FindAssets("t:AnimatorController");
        foreach (var guid in controllerGUIDs)
        {
            string path = AssetDatabase.GUIDToAssetPath(guid);
            AnimatorController controller = AssetDatabase.LoadAssetAtPath<AnimatorController>(path);

            bool modified = false;//标记是否修改
            if (controller)
            {
                // 遍历AnimatorController中的每个状态机
                foreach (var layer in controller.layers)
                {
                    foreach (var state in layer.stateMachine.states)
                    {
                        // 检查每个状态的动画是否包含目标Animation Clip
                        if (state.state.motion is AnimationClip stateClip && stateClip == oldClip)
                        {
                            state.state.motion = newClip; // 替换为新剪辑
                            modified = true;
                        }
                    }
                }

                //如果修改了动画片段，保存修改
                if (modified)
                {
                    EditorUtility.SetDirty(controller);
                    Debug.Log($"Replaced clip in Animator Controller: {controller.name}");
                }
            }

        }
    }

    public static void OptimizeAnimationClipByText(string folderPath)
    {
        if(string.IsNullOrEmpty(folderPath) || !Directory.Exists(folderPath))
        {
            EditorUtility.DisplayDialog("优化动画错误", "请先在 Project 视图中选择一个文件夹。", "确定");
            return;
        }

        //查找选定文件夹下的所有.anim文件
        string[] animFilePaths = Directory.GetFiles(Path.Combine(Application.dataPath, folderPath.Substring(7)), "*.anim", SearchOption.AllDirectories);
        if(animFilePaths.Length > 0)
        {
            foreach(string animFilePath in animFilePaths)
            {
                // 将文件路径转换为 Unity 相对路径
                string assetPath = "Assets" +animFilePath.Replace(Application.dataPath, "").Replace("\\", "/");

                //检查文件是否为文本格式
                if (!IsTextFile(animFilePath))
                {
                    Debug.LogWarning($"文件不是文本格式: {assetPath}");
                    continue;
                }

                //读取文件内容
                string[] lines = File.ReadAllLines(animFilePath);
                bool modified = false;
                for (int i = 0; i < lines.Length; i++)
                {
                    string line = lines[i];
                    //处理 m_UesHighQualityCurve
                    if(line.Contains("m_UseHighQualityCurve:"))
                    {
                        string pattern = @"(m_UseHighQualityCurve:\s*)(\d+)";
                        string replacement = "${1}0";

                        string newLine = Regex.Replace(line, pattern, replacement);
                        if(newLine != line)
                        {
                            line = newLine;
                            modified = true;
                        }
                    }

                    //处理浮点数四舍五入
                    string floatPattern = @"-?\d+\.\d+([eE][-+]?\d+)?";
                    string newLineAfterFloat = Regex.Replace(line, floatPattern, match =>
                    {
                        string numberStr = match.Value;
                        if(float.TryParse(numberStr, out float number))
                        {
                            //四舍五入到三位小数
                            float roundedNumber = Mathf.Round(number * 1000f) / 1000f;
                            if(!Mathf.Approximately(number, roundedNumber))
                            {
                                modified = true;
                                numberStr = roundedNumber.ToString("F3");
                            }
                        }

                        return numberStr;
                    });

                    if(newLineAfterFloat != line)
                    {
                        line = newLineAfterFloat;
                    }

                    lines[i] = line;
                }

                if (modified)
                {
                    // 写回文件，保持原有的行格式
                    File.WriteAllLines(animFilePath, lines);
                    Debug.Log($"优化了动画剪辑：{assetPath}");
                }
            }
            AssetDatabase.SaveAssets();
        }
    }

    private static bool IsTextFile(string filePath)
    {
        // 读取文件的前几个字节，检查是否包含可读字符
        using (FileStream fs = File.OpenRead(filePath))
        {
            byte[] buffer = new byte[512];
            int byteRead = fs.Read(buffer, 0, buffer.Length);

            //简单检查：如果包含二进制零字节，则认为是二进制文件
            for(int i = 0; i < byteRead; i++)
            {
                if (buffer[i] == 0)
                {
                    return false;
                }
            }
        }
        return true;
    }
}
