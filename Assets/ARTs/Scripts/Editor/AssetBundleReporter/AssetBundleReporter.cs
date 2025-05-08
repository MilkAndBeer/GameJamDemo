using OfficeOpenXml;
using OfficeOpenXml.Style;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Events;


namespace AnalyzeAssetBundleTool
{
    public class AssetBundleReporter
    {
        /// <summary>
        /// AssetBundle报告
        /// 生成各个资源的报告Excel
        /// </summary>
        [MenuItem("CTools/AssetBundle相关/AB分析报告")]
        public static void AnalyzePrintCmd()
        {
            string path = EditorUtility.OpenFolderPanel("选择AssetBundle目录", "", "");
            if (string.IsNullOrEmpty(path)) return;

            string bundlePath = path;
            string outputPath = Path.Combine(path, "AssetBundle报告" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xlsx");
            AnalyzePrint(bundlePath, outputPath, () => System.Diagnostics.Process.Start(outputPath));
        }

        /// <summary>
        /// 分析打印 AssetBundle
        /// </summary>
        /// <param name="bundlePath">AssetBundle 文件所在文件夹路径</param>
        /// <param name="outputPath">Excel 报告文件保存路径</param>
        /// <param name="completed">分析打印完毕后的回调</param>
        public static void AnalyzePrint(string bundlePath, string outputPath, UnityAction completed = null)
        {
            AssetBundleFilesAnalyze.analyzeCompleted = () =>
            {
                PrintToExcel(outputPath);
                if (completed != null) completed();
            };

            EditorUtility.DisplayProgressBar("分析AssetBundle", "正在分析AssetBundle文件", 0.45f);
            if (!AssetBundleFilesAnalyze.Analyze(bundlePath))
            {
                EditorUtility.ClearProgressBar();
                Debug.LogError("分析AssetBundle文件失败");
                return;
            }

        }

        public static void PrintToExcel(string outputPath)
        {
            EditorUtility.DisplayProgressBar("打印Excel", "正在打印Excel文件", 0.9f);
            var newFile = new FileInfo(outputPath);
            if (newFile.Exists) { newFile.Delete(); }

            using (var package = new ExcelPackage(newFile))
            {
                AssetBundleFilesReporter.CreateWorksheet(package.Workbook.Worksheets);
                AssetBundleDetailsReporter.CreateWorksheet(package.Workbook.Worksheets);
                AssetBundleResReporter.CreateWorksheet(package.Workbook.Worksheets);

                AssetBundleFilesReporter.FillWorksheet(package.Workbook.Worksheets[0]);
                AssetBundleDetailsReporter.FillWorksheet(package.Workbook.Worksheets[1]);
                AssetBundleResReporter.FillWorksheet(package.Workbook.Worksheets[2]);

                AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.mesh);
                AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.material);
                AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.texture2D);
                //AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.shader);
                //AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.sprite);
                //AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.monoScript);
                //AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.animatorController);
                //AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.animatorOverrideController);
                AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.animationClip);
                AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.audioClip);
                //AssetBundlePropertyReporter.CreateAndFillWorksheet(package.Workbook.Worksheets, AssetFileInfoType.font);

                WriteUIAllays(package.Workbook.Worksheets);
                DeoendRedundancyDataAllays(package.Workbook.Worksheets);

                package.Save();
            }

            AssetBundleFilesAnalyze.Clear();
            EditorUtility.ClearProgressBar();
        }

        public static void WriteUIAllays(ExcelWorksheets wss)
        {
            ExcelWorksheet ws = wss.Add("UI图集优化");
            int colIndex = 1;
            ws.Cells[2, colIndex++].Value = "AssetBundle 名称";
            ws.Cells[2, colIndex++].Value = "文件大小";
            ws.Cells[2, colIndex++].Value = "依赖AB数";
            ws.Cells[2, colIndex++].Value = "依赖图集数";

            int startRow = 3;

            List<AssetBundleFileInfo> infos = AssetBundleFilesAnalyze.GetAllAssetBundleFileInfos();
            foreach (var info in infos)
            {
                if (info.name.IndexOf("ui") != 0)
                {
                    continue;
                }

                int atlasNum = 0;
                for (int i = 0; i < info.allDepends.Length; i++)
                {
                    if (info.allDepends[i].IndexOf("atlas") >= 0)
                    {
                        atlasNum++;
                    }
                }

                if (atlasNum >= 4)
                {
                    colIndex = 1;
                    ws.Cells[startRow, colIndex].Value = info.name;
                    //info.detailHyperLink = new ExcelHyperLink(String.Empty, info.name);
                    ws.Cells[startRow, colIndex++].Hyperlink = info.detailHyperLink;
                    ws.Cells[startRow, colIndex++].Value = info.size;
                    ws.Cells[startRow, colIndex++].Value = info.allDepends.Length;
                    ws.Cells[startRow, colIndex++].Value = atlasNum;

                    startRow++;
                }
            }
        }

        public static void DeoendRedundancyDataAllays(ExcelWorksheets wss)
        {
            ExcelWorksheet ws = wss.Add("依赖数据分析");
            ws.TabColor = ColorTranslator.FromHtml("#32b1fa");

            int colIndex = 1;
            ws.Cells[1, colIndex++].Value = "时间";
            ws.Column(colIndex - 1).Width = 20;
            ws.Cells[1, colIndex++].Value = "AB包总大小(MB)";
            ws.Column(colIndex - 1).Width = 15;
            ws.Cells[1, colIndex++].Value = "纯在依赖的AB总数量";
            ws.Column(colIndex - 1).Width = 15;
            ws.Cells[1, colIndex++].Value = "依赖最大值";
            ws.Column(colIndex - 1).Width = 10;
            ws.Cells[1, colIndex++].Value = "依赖最小值";
            ws.Column(colIndex - 1).Width = 10;
            ws.Cells[1, colIndex++].Value = "依赖平均数";
            ws.Column(colIndex - 1).Width = 10;
            ws.Cells[1, colIndex++].Value = "依赖方差";
            ws.Column(colIndex - 1).Width = 10;

            int startRow = 2;
            List<AssetBundleFileInfo> infos = AssetBundleFilesAnalyze.GetAllAssetBundleFileInfos();
            long Size = 0;
            int Depedns = 0;
            int MaxDepend = 0;
            int MinDepend = 10000;
            double MeanValue;
            double Varianface;
            List<AssetBundleFileInfo> DependDatas = new List<AssetBundleFileInfo>();
            List<int> Depends = new List<int>();

            foreach (var info in infos)
            {
                Size += info.size;
                if (info.allDepends.Length > 0)
                {
                    DependDatas.Add(info);
                }
            }

            Depedns = DependDatas.Count;
            foreach (var dependData in DependDatas)
            {
                if (dependData.allDepends.Length > MaxDepend)
                {
                    MaxDepend = dependData.allDepends.Length;
                }

                if (dependData.allDepends.Length < MinDepend)
                {
                    MinDepend = dependData.allDepends.Length;
                }
                Depends.Add(dependData.allDepends.Length);
            }

            //平均数
            MeanValue = Depends.Average();
            // 方差
            Varianface = Depends.Average(x => Math.Pow(x - MeanValue, 2));
            int colIndex2 = 1;
            ws.Cells[startRow, colIndex2++].Value = DateTime.Now.ToString("yyyyMMdd_HHmmss");
            ws.Cells[startRow, colIndex2++].Value = Size / 1024 / 1024;
            ws.Cells[startRow, colIndex2++].Value = Depedns;
            ws.Cells[startRow, colIndex2++].Value = MaxDepend;
            ws.Cells[startRow, colIndex2++].Value = MinDepend;
            ws.Cells[startRow, colIndex2++].Value = MeanValue;
            ws.Cells[startRow, colIndex2++].Value = Varianface;

        }

        public static void CreateWorksheetBase(ExcelWorksheet ws, string title, int colCount)
        {
            // 全体颜色
            ws.Cells.Style.Font.Color.SetColor(ColorTranslator.FromHtml("#3d4d65"));
            {
                // 边框样式
                var border = ws.Cells.Style.Border;
                border.Bottom.Style = border.Top.Style = border.Left.Style = border.Right.Style
                    = ExcelBorderStyle.Thin;

                // 边框颜色
                var clr = ColorTranslator.FromHtml("#B2C6C9");
                border.Bottom.Color.SetColor(clr);
                border.Top.Color.SetColor(clr);
                border.Left.Color.SetColor(clr);
                border.Right.Color.SetColor(clr);
            }

            // 标题
            ws.Cells[1, 1].Value = title;
            using (var range = ws.Cells[1, 1, 1, colCount])
            {
                range.Merge = true;
                range.Style.Font.Bold = true;
                range.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                range.Style.VerticalAlignment = ExcelVerticalAlignment.Center;
            }
            ws.Row(1).Height = 30;
        }

    }
}