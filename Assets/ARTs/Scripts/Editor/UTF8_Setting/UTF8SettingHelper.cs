using System.IO;
using System.Text;
using UnityEditor;
using UnityEngine;

public class UTF8SettingHelper 
{
    //创建UTF-8代码
    [MenuItem("Assets/Create/C# Script UTF-8", false, 20, secondaryPriority = 10)]
    static void CreateCodeText()
    {
        // 获取选中的文件夹或文件的路径
        string selectedPath = AssetDatabase.GetAssetPath(Selection.activeObject);

        string codeText = "using UnityEngine;\r\n\r\npublic class NewBehaviourScript1 : MonoBehaviour\r\n{\r\n\r\n}\r\n";

        File.WriteAllText(selectedPath + "/NewBehaviourScript1.cs", codeText, System.Text.Encoding.UTF8);

        // 刷新Unity资源窗口
        AssetDatabase.Refresh();
    }

    [MenuItem("Assets/Create/Check/编码Ansi-> UTF-8")]
    private static void ReadAnsiText()
    {
        // 获取当前在Unity编辑器中选中的对象
        UnityEngine.Object selectedObject = Selection.activeObject;

        if (selectedObject != null && selectedObject is TextAsset)
        {
            TextAsset textAsset = selectedObject as TextAsset;

            string assetPath = AssetDatabase.GetAssetPath(textAsset);

            Encoding encoding = Encoding.GetEncoding(936);

            string text = File.ReadAllText(assetPath, encoding);

            System.IO.File.WriteAllText(assetPath, text, Encoding.UTF8);

            AssetDatabase.Refresh();
        }
    }
}
