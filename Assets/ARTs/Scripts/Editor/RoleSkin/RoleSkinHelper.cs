using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Events;

public class RoleSkinHelper
{
    private string selectPath = "";


    [MenuItem("CTools/角色皮肤Skin/判断角色皮肤中是否有动画")]
    public static void CheckAllRoleSkinWithAnim()
    {
        RoleSkinHelper roleSkinHelper = new RoleSkinHelper();
        roleSkinHelper.SelectPath();
        roleSkinHelper.FindAllRoleSkin(roleSkinHelper.CheckModelHaveAnim);
    }

    [MenuItem("CTools/角色皮肤Skin/设置角色皮肤材质")]
    public static void SetAllRoleSkinWithMat()
    {
        RoleSkinHelper roleSkinHelper = new RoleSkinHelper();
        roleSkinHelper.SelectPath();
        roleSkinHelper.FindAllRoleSkin(roleSkinHelper.SetRoleSkinMat);
    }

    #region 通用方法
    private void SelectPath()
    {
        Object[] selections = Selection.GetFiltered(typeof(Object), SelectionMode.Assets);
        if (selections.Length == 0)
        {
            Debug.LogWarning("请选择一个有效文件");
            return;
        }
        selectPath = AssetDatabase.GetAssetPath(selections[0]);
    }

    private void FindAllRoleSkin(UnityAction<ModelImporter, string> completed = null)
    {
        if (string.IsNullOrEmpty(selectPath))
        {
            Debug.LogWarning("请先选择一个有效文件");
            return;
        }
        string[] guids;
        //Unity获取指定路径下的所有文件的GUID
        if (selectPath.Split('.').Length == 1)
        {
            guids = AssetDatabase.FindAssets("", new[] { selectPath });
        }
        else
        {
            guids = new[] { AssetDatabase.AssetPathToGUID(selectPath) };
        }

        AssetDatabase.StartAssetEditing();
        FindAllRoleSkinBySelected(guids, completed);
        AssetDatabase.StopAssetEditing();
        AssetDatabase.Refresh();
    }

    private void FindAllRoleSkinBySelected(string[] checkGUIDs, UnityAction<ModelImporter, string> completed)
    {
        foreach (var checkGUID in checkGUIDs)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(checkGUID);
            if (assetPath.EndsWith(".fbx") || assetPath.EndsWith(".FBX"))
            {
                ModelImporter modelImporter = AssetImporter.GetAtPath(assetPath) as ModelImporter;
                if (modelImporter == null) { Debug.LogError($"{assetPath}不是一个有效的模型文件"); continue; }
                if (!assetPath.Contains("@Skin")) { continue; }

                //检查是否包含动画
                completed(modelImporter, assetPath);
            }
        }
    }

    #endregion

    private void CheckModelHaveAnim(ModelImporter modelImporter, string assetPath)
    {
        //判断是否包含动画
        bool isAnimation = false;
        int checkOn = 0;


        // 检查是否有动画剪辑
        //if(modelImporter.clipAnimations.Length > 0)
        if (modelImporter.defaultClipAnimations.Length > 0)
        {
            isAnimation = true;
            checkOn = 2;
        }

        // 输出结果
        if (isAnimation)
        {
            Debug.Log($"✅ 动画文件: {assetPath} checkOn: {checkOn}");
        }
        else
        {
            Debug.Log($"❌ 模型文件: {assetPath} checkOn: {checkOn}");
        }
    }

    private void SetRoleSkinMat(ModelImporter modelImporter, string assetPath)
    {
        //设置材质
        modelImporter.materialSearch = ModelImporterMaterialSearch.Everywhere;
        // 设置材质导入模式为外部材质
        modelImporter.materialImportMode = ModelImporterMaterialImportMode.ImportViaMaterialDescription;
        // 设置材质位置为外部材质
        modelImporter.materialLocation = ModelImporterMaterialLocation.External;
        // 设置材质名称匹配方式（必须使用枚举值）
        modelImporter.materialName = ModelImporterMaterialName.BasedOnMaterialName;

        modelImporter.SearchAndRemapMaterials(ModelImporterMaterialName.BasedOnMaterialName, ModelImporterMaterialSearch.Everywhere);
        //保存
        AssetDatabase.ImportAsset(assetPath, ImportAssetOptions.ForceUpdate);
    }

}
