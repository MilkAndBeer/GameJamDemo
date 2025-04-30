using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using Debug = UnityEngine.Debug;

public class AnimationOptimize
{
    [MenuItem("CTools/动画优化/仅优化动画clip")]
    public static void AnimationOptimizeFunc()
    {
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

        //path是相对路径
        OptimizeAnimationClipsByText(selectedPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }

    public static void OptimizeAnimationClipsByText(string folderPath)
    {
        if(string.IsNullOrEmpty(folderPath) || !Directory.Exists(folderPath))
        {
            EditorUtility.DisplayDialog("优化动画错误", "请先在 Project 试图中选择一个文件夹", "确定");
            return;
        }

        // 查找选定文件夹下的所有 .anim 文件
        string[] animFilePaths = Directory.GetFiles(Path.Combine(Application.dataPath, folderPath.Substring(7)), "*.anim", SearchOption.AllDirectories);

        foreach (string animFilePath in animFilePaths)
        {
            // 将文件路径转换为 Unity 相对路径
            string assetPath = "Assets" + animFilePath.Replace(Application.dataPath, "").Replace("\\", "/");

            // 检查文件是否为文本格式
            if (!IsTextFile(animFilePath))
            {
                Debug.LogWarning($"文件 {assetPath} 不是文本格式，已跳过。");
                continue;
            }

            // 读取文件内容
            string[] lines = File.ReadAllLines(animFilePath);
            bool modified = false;

            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i];

                // 处理 m_UseHighQualityCurve
                if (line.Contains("m_UseHighQualityCurve:"))
                {
                    string pattern = @"(m_UseHighQualityCurve:\s*)(\d+)";
                    string replacement = "${1}0"; // 修改这里

                    string newLine = Regex.Replace(line, pattern, replacement);

                    if (newLine != line)
                    {
                        line = newLine;
                        modified = true;
                    }
                }

                // 处理浮点数四舍五入
                string floatPattern = @"-?\d+\.\d+([eE][-+]?\d+)?";
                string newLineAfterFloat = Regex.Replace(line, floatPattern, match =>
                {
                    string numberStr = match.Value;
                    if (float.TryParse(numberStr, out float number))
                    {
                        // 四舍五入到三位小数
                        float roundedNumber = Mathf.Round(number * 1000f) / 1000f;

                        if (!Mathf.Approximately(number, roundedNumber))
                        {
                            modified = true;
                            return roundedNumber.ToString("F3");
                        }
                    }
                    return numberStr;
                });

                if (newLineAfterFloat != line)
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

        EditorUtility.DisplayDialog("完成", "已优化所有动画剪辑。", "确定");

    }

    private static bool IsTextFile(string filePath)
    {
        // 读取文件的前几个字节，检查是否包含可读字符
        using (FileStream fs = File.OpenRead(filePath))
        {
            byte[] buffer = new byte[512];
            int bytesRead = fs.Read(buffer, 0, buffer.Length);

            // 简单检查：如果包含二进制零字节，认为是二进制文件
            for (int i = 0; i < bytesRead; i++)
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
