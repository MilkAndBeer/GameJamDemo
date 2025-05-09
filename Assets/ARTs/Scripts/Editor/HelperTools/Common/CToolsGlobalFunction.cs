using System.IO;
using System.Text.RegularExpressions;
using UnityEngine;

namespace CToolsForEditor
{
    public static class CToolsGlobalFunction
    {
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
    }
}