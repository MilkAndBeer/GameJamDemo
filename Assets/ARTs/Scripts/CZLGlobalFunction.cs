using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using Unity.VisualScripting;
using UnityEngine;

public static class CZLGlobalFunction
{
    /// <summary>
    /// 获取全局缩放
    /// </summary>
    /// <param name="transform"></param>
    /// <returns></returns>
    public static Vector3 GetGlobalScale(this Transform transform)
    {
        //如果没有父对象，直接返回局部缩放
        if(transform.parent == null)
        {
            return transform.localScale;
        }

        //递归计算父对象的全局缩放
        Vector3 parentGlobalScale = GetGlobalScale(transform.parent);

        //计算当前对象的全局缩放
        return new Vector3(
            transform.localScale.x * parentGlobalScale.x,
            transform.localScale.y * parentGlobalScale.y,
            transform.localScale.z * parentGlobalScale.z
        );
    }

    public static Bounds GetTransformWorldBounds(this Transform transform)
    {
        Bounds renderBound = new Bounds();
        Mesh groundMesh = transform.GetComponent<MeshFilter>().sharedMesh;
        if(groundMesh == null)
        {
            Debug.LogError("没有找到Mesh,没法生成草");
            return renderBound;
        }
        //计算边界
        Vector3 centerPos = transform.position;
        Vector3 groundScale = transform.GetGlobalScale();
        float rotateYAngle = transform.eulerAngles.y;
        Vector3 localPos = groundMesh.vertices[0];
        localPos = new Vector3(localPos.x * groundScale.x, localPos.y * groundScale.y, localPos.z * groundScale.z);

        RotateYAround(Vector3.zero, ref localPos, rotateYAngle);

        renderBound = new Bounds(centerPos + localPos, Vector3.zero);
        foreach(Vector3 vert in groundMesh.vertices)
        {
            Vector3 tempVec = vert;
            tempVec = new Vector3(tempVec.x * groundScale.x, tempVec.y * groundScale.y, tempVec.z * groundScale.z);
            RotateYAround(Vector3.zero, ref tempVec, rotateYAngle);
            renderBound.Encapsulate(centerPos + tempVec);
        }

        return renderBound;
    }

    /// <summary>
    /// 绕指定轴旋转指定角度
    /// </summary>
    public static void RotateYAround(Vector3 centerPointPos, ref Vector3 rotatePointPos, float rotateYAngle)
    {
        //计算旋转物相对于中心点的位置
        Vector3 relativePos = rotatePointPos - centerPointPos;
        //绕指定轴旋转
        rotatePointPos = Quaternion.AngleAxis(rotateYAngle, Vector3.up) * relativePos;
    }

    #region 文件操作
    public static string GetRelativePath(string path)
    {
        string srcPath = path.Replace("\\", "/");
        var retPath = Regex.Replace(srcPath, @"\b.*Assets/", "Assets/");
        return retPath;
    }
    public static string GetAbsolutePath(string path)
    {
        string srcPath = path.Replace("\\", "/");
        var retPath = Regex.Replace(srcPath, @"\b.*Assets/", Application.dataPath);
        return retPath;
    }
    public static bool IsDirectory(string path)
    {
        FileAttributes attr = File.GetAttributes(path);
        return attr.HasFlag(FileAttributes.Directory);
    }
    public static string GetFileDirectoryPath(string filePath)
    {
        var fileName = Path.GetFileName(filePath);
        var directoryPath = filePath.Replace(fileName, "");
        return directoryPath;
    }
    #endregion

    #region 数据转换
    public static string GetVector3String(Vector3 vec)
    {
        return string.Format("{0}_{1}_{2}", vec.x, vec.y, vec.z);
    }
    public static Vector3 GetVector3FromString(string vecStr)
    {
        string[] vecStrs = vecStr.Split('_');
        if (vecStrs.Length != 3)
        {
            Debug.LogError("字符串格式错误");
            return Vector3.zero;
        }
        float x = float.Parse(vecStrs[0]);
        float y = float.Parse(vecStrs[1]);
        float z = float.Parse(vecStrs[2]);
        return new Vector3(x, y, z);
    }
    public static Vector3 GetVector3FromString(string xStr, string yStr, string zStr)
    {
        float x = float.Parse(xStr);
        float y = float.Parse(yStr);
        float z = float.Parse(zStr);
        return new Vector3(x, y, z);
    }
    #endregion

    #region Gamma Linear 转换
    /// <summary>
    /// Color转换为线性空间
    /// </summary>
    /// <param name="c">Gamma颜色</param>
    /// <returns></returns>
    public static Color GammaToLinear(Color c)
    {
        return new Color(
            GammaToLinearComponent(c.r),
            GammaToLinearComponent(c.g),
            GammaToLinearComponent(c.b),
            c.a
            );
    }
    private static float GammaToLinearComponent(float c)
    {
        return c <= 0.04045f ? c / 12.92f : Mathf.Pow((c + 0.055f) / 1.055f, 2.4f);
    }

    /// <summary>
    /// Color转换为Gamma空间
    /// </summary>
    /// <param name="c">Linear颜色</param>
    /// <returns></returns>
    public static Color LinearToGamma(Color c)
    {
        return new Color(
                 LinearToGammaComponent(c.r),
                 LinearToGammaComponent(c.g),
                 LinearToGammaComponent(c.b),
                 c.a
             );
    }
    private static float LinearToGammaComponent(float c)
    {
        return c <= 0.0031308f ? c * 12.92f : 1.055f * Mathf.Pow(c, 1.0f / 2.4f) - 0.055f;
    }
    #endregion
}
