using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace CToolsForEditor
{
    public class CToolsBaseEditorWindow : EditorWindow
    {
        protected string pathLabelText = "Operation Affects Path: ";
        protected string path = "Assets";
        private bool isAutoPath = true;

        private static bool isWindowShow = false;
        protected static CToolsBaseEditorWindow window;
        protected static void OpenWindow()
        {
            window.Show();
            isWindowShow = true;
            window.Focus();
        }

        private void Update()
        {
            if(isWindowShow && isAutoPath)
            {
                SelectionCheckPath();
            }
        }

        private void SelectionCheckPath()
        {
            if(Selection.assetGUIDs == null || Selection.assetGUIDs.Length == 0)
            {
                return;
            }
            string[] guids = Selection.assetGUIDs;
            string tempGuid = guids[guids.Length - 1];
            string tempPath = AssetDatabase.GUIDToAssetPath(tempGuid);
            if (tempPath != path)
            {
                path = tempPath;
                window.Focus();
            }
        }

        protected virtual void OnGUI()
        {
            path = EditorGUILayout.TextField(pathLabelText, GetDatafilePath(path));
            isAutoPath = EditorGUILayout.Toggle("AutoPath By Selection: ", isAutoPath);
        }

        public string GetDatafilePath(string path)
        {
            string tempPath = path;
            string assetsFileName = "Assets";
            if (tempPath.Contains(assetsFileName))
            {
                int index = tempPath.IndexOf(assetsFileName, StringComparison.CurrentCultureIgnoreCase);
                tempPath = tempPath.Substring(index);
            }
            return tempPath;
        }

        public string GetFullDataPath(string path)
        {
            string tempPath = path;
            string assetsFileName = "Assets";
            if (tempPath.Contains(assetsFileName))
            {
                int index = tempPath.IndexOf(assetsFileName, StringComparison.CurrentCultureIgnoreCase);
                tempPath = tempPath.Substring(index + 7);
            }

            string tempFolderPath = Application.dataPath + "/" + tempPath;
            return tempFolderPath;
        }

        public string[] GetDirPathsInSelectPath(string path)
        {
            List<string> dirPaths = new List<string>();
            dirPaths.Add(path);

            DirectoryInfo direction = new DirectoryInfo(path);
            DirectoryInfo[] folders = direction.GetDirectories("*", SearchOption.AllDirectories);
            dirPaths.AddRange(Array.ConvertAll(folders, folder => folder.FullName));

            return dirPaths.ToArray();
        }
    }

}
