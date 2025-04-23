using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using OfficeOpenXml;
using System.Text;
using System.Linq;

public enum ExcelFormat
{
    Xlsx,
    Csv
}

/// <summary>
/// Excel 文件存储和读取器 <br/>
/// </summary>
public partial class ExcelSheet
{
    public static string ExcelSavePath { get; set; } = Application.streamingAssetsPath + "/Excel";

#if UNITY_EDITOR
    [UnityEditor.MenuItem("CTools/ExcelSheet/Open Excel Folder")]
    public static void OpenExcelSavePath()
    {
        if(!Directory.Exists(ExcelSavePath))
        {
            Directory.CreateDirectory(ExcelSavePath);
        }

        // 将路径转换为当前环境下的路径（替换分隔符）
        var currentEnvironmentPath = ExcelSavePath.Replace("/", Path.DirectorySeparatorChar.ToString())
            .Replace("\\", Path.DirectorySeparatorChar.ToString());

        System.Diagnostics.Process.Start("explorer.exe", currentEnvironmentPath);
    }
#endif

    public Vector2Int Start { get; private set; } = Vector2Int.zero;
    public Vector2Int End { get; private set; } = Vector2Int.one;
    private Dictionary<Vector2Int, string> _sheetDic = new Dictionary<Vector2Int, string>(); //缓存当前数据的字典
    public ExcelSheet() { }
    public ExcelSheet(string filePath, string sheetName = null, ExcelFormat format = ExcelFormat.Xlsx)
    {
        Load(filePath, sheetName, format);
    }

    public string this[int row, int col]
    {
        get
        {
            //越界检查
            if (row >= End.x || row < Start.x)
            {
                Debug.LogWarning($"ExcelSheet: Row {row} out of range!");
            }
            if(col >= End.y || col < Start.y)
            {
                Debug.LogWarning($"ExcelSheet: Column {col} out of range!");
            }
            //不存在结果，则返回空字符串
            return _sheetDic.GetValueOrDefault(new Vector2Int(row, col), string.Empty);
        }
        set 
        {
            _sheetDic[new Vector2Int(row, col)] = value;
            //记录最大行数和列数
            End = new Vector2Int(Math.Max(End.x, row + 1), Math.Max(End.y, col + 1));
            Start = new Vector2Int(Math.Min(Start.x, row), Math.Min(Start.y, col));
        }
    }

    public List<List<string>> Rows
    {
        get
        {
            var rows = new List<List<string>>();
            for(int i = 0; i < End.x; i++)
            {
                var row = new List<string>();
                for (int j = 0; j < End.y; j++)
                {
                    row.Add(this[i, j]);
                }
                rows.Add(row);
            }
            return rows;
        }
    }

    public List<List<string>> Columns
    {
        get
        {
            var columns = new List<List<string>>();
            for (int j = 0; j < End.y; j++)
            {
                var column = new List<string>();
                for (int i = 0; i < End.x; i++)
                {
                    column.Add(this[i, j]);
                }
                columns.Add(column);
            }
            return columns;
        }
    }

    /// <summary>
    /// 处理输入路径，使得路径符合 ExcelSheet 下的路径
    /// </summary>
    private static string ProcessPath(string path)
    {
        return Path.Combine(ExcelSavePath, path);
    }

    /// <summary>
    /// 存储 Excel 文件
    /// </summary>
    /// <param name="filePath">文件路径，可以不写文件扩展名</param>
    /// <param name="sheetName">表名，如果没有指定表名，则使用文件名。若使用 csv 格式，则忽略此参数</param>
    /// <param name="format">保存的文件格式</param>
    public void Save(string filePath, string sheetName = null, ExcelFormat format = ExcelFormat.Xlsx)
    {
        string fullPath = ProcessPath(filePath);
        fullPath = Path.ChangeExtension(fullPath, FileFormatToExtension(format));       // 确保文件路径扩展名为指定格式

        var directory = Path.GetDirectoryName(fullPath);
        if (!Directory.Exists(directory)) //确保文件所在目录存在
        {
            Directory.CreateDirectory(directory);
        }

        switch (format)
        {
            case ExcelFormat.Xlsx:
                SaveXlsx(fullPath, sheetName);
                break;
            case ExcelFormat.Csv:
                SaveCsv(fullPath);
                break;
            default: throw new ArgumentOutOfRangeException(nameof(format), format, null);
        }

#if UNITY_EDITOR
        UnityEditor.AssetDatabase.Refresh();
#endif
    }

    /// <summary>
    /// 读取 Excel 文件
    /// </summary>
    /// <param name="filePath">文件相对路径，可以不写文件扩展名</param>
    /// <param name="sheetName">表名，如果没有指定表名，则使用文件名</param>
    /// <param name="format">保存的文件格式</param>
    public void Load(string filePath, string sheetName = null, ExcelFormat format = ExcelFormat.Xlsx) 
    {
        //清空当前数据
        Clear();

        string fullPath = ProcessPath(filePath);
        fullPath = Path.ChangeExtension(fullPath, FileFormatToExtension(format)); // 确保文件路径扩展名为指定格式

        if (!File.Exists(fullPath))
        {
            //不存在文件，则报错
            Debug.LogError($"ExcelSheet: File {fullPath} not found!");
            return;
        }

        switch (format)
        {
            case ExcelFormat.Xlsx:
                LoadFromXlsx(fullPath, sheetName);
                break;
            case ExcelFormat.Csv:
                LoadFromCsv(fullPath);
                break;
            default: throw new ArgumentOutOfRangeException(nameof(format), format, null);
        }
    }

    public void Clear()
    {
        _sheetDic.Clear();
        Start = Vector2Int.zero;
        End = Vector2Int.one;
    }

    /// <summary>
    /// 获取 Excel 文件中的所有表名
    /// </summary>
    public static List<string> GetSheetNamesInExcel(string filePath)
    {
        string fullPath = ProcessPath(filePath);    //处理输入路径
        fullPath = Path.ChangeExtension(fullPath, FileFormatToExtension(ExcelFormat.Xlsx)); // 确保文件路径扩展名为指定格式
        if(!File.Exists(fullPath)) return new List<string>(); //不存在文件，则返回空列表

        var fileInfo = new FileInfo(fullPath);
        using var package = new ExcelPackage(fileInfo);

        return package.Workbook.Worksheets.Select(sheet => sheet.Name).ToList(); //获取所有表名
    }

    public static bool ExistSheetInExcel(string filePath, string sheetName)
    {
        string fullPath = ProcessPath(filePath);
        fullPath = Path.ChangeExtension(fullPath, FileFormatToExtension(ExcelFormat.Xlsx)); // 确保文件路径扩展名为指定格式

        if(!File.Exists(fullPath)) return false;

        var fileInfo = new FileInfo(fullPath);
        using var package = new ExcelPackage(fileInfo);

        return package.Workbook.Worksheets[sheetName] != null; //判断表是否存在
    }

    public static bool DeleteSheetInExcel(string filePath, string sheetName)
    {
        string fullPath = ProcessPath(filePath);
        fullPath = Path.ChangeExtension(fullPath, FileFormatToExtension(ExcelFormat.Xlsx)); // 确保文件路径扩展名为指定格式

        if(!File.Exists(fullPath)) return false;

        var fileInfo = new FileInfo(fullPath);
        using var package = new ExcelPackage(fileInfo);

        if (package.Workbook.Worksheets[sheetName] == null) return false; //不存在表，则返回 false

        package.Workbook.Worksheets.Delete(sheetName); //删除表
        package.Save();
        return true;
    }
}

public partial class ExcelSheet
{
    private static string FileFormatToExtension(ExcelFormat format)
    {
        return $".{format.ToString().ToLower()}";
    }

    private void SaveXlsx(string filePath, string sheetName)
    {
        sheetName ??= Path.GetFileNameWithoutExtension(filePath); //如果没有指定表名，则使用文件名

        var fileInfo = new FileInfo(filePath);
        using var package = new ExcelPackage(fileInfo);

        if (!File.Exists(filePath)|| //不存在 Excel
            package.Workbook.Worksheets[sheetName] == null) 
        {
            package.Workbook.Worksheets.Add(sheetName); // 创建表时，Excel 文件也会被创建
        }

        var sheet = package.Workbook.Worksheets[sheetName];
        var cells = sheet.Cells;
        cells.Clear(); //清空表格

        foreach (var pair in _sheetDic)
        {
            var i = pair.Key.x;
            var j = pair.Key.y;
            var cell = cells[i + 1, j + 1]; //Excel 的行列从 1 开始
            cell.Value = pair.Value;
            cell.Style.Numberformat.Format = "@"; //设置单元格格式为文本
        }

        package.Save(); //保存文件
    }

    private void SaveCsv(string filePath)
    {
        using FileStream fs = new FileStream(filePath, FileMode.Create, FileAccess.Write);

        var idx = new Vector2Int(0, 0);
        for (int i = 0; i < End.x; i++)
        {
            idx.x = i;
            idx.y = 0;

            // 写入第一个 value
            var value = _sheetDic.GetValueOrDefault(idx, "");
            if (!string.IsNullOrEmpty(value))
            {
                fs.Write(Encoding.UTF8.GetBytes(value));
            }

            // 写入后续 value，需要添加 ","
            for(int j = 1; j < End.y; j++)
            {
                idx.y = j;
                value = "," + _sheetDic.GetValueOrDefault(idx, "");
                fs.Write(Encoding.UTF8.GetBytes(value));
            }

            //写入 "\n"
            fs.Write(Encoding.UTF8.GetBytes("\n"));
        }
    }

    private void LoadFromXlsx(string fullPath, string sheetName)
    {
        sheetName ??= Path.GetFileNameWithoutExtension(fullPath); //如果没有指定表名，则使用文件名
        var fileInfo = new FileInfo(fullPath);
        using var package = new ExcelPackage(fileInfo);
        var sheet = package.Workbook.Worksheets[sheetName];
        if(sheet == null)
        {
            Debug.LogError($"ExcelSheet: Sheet {sheetName} not found in {fullPath}");
            return;
        }

        var start = sheet.Dimension.Start;
        var end = sheet.Dimension.End;

        Start = new Vector2Int(start.Row - 1, start.Column - 1);
        End = new Vector2Int(end.Row, end.Column);

        var cells = sheet.Cells;
        for(int i = Start.x; i <= End.x; i++)
        {
            for(int j = Start.y; j <= End.y; j++)
            {
                var value = cells[i + 1, j + 1].Text; //Excel 的行列从 1 开始
                if (string.IsNullOrEmpty(value)) continue;  //有数据才记录
                this[i, j] = value; //使用 this 索引器来记录数据
            }
        }
    }

    private void LoadFromCsv(string fullPath)
    {
        //读取文件
        string[] lines = File.ReadAllLines(fullPath);
        for(int i = 0; i < lines.Length; i++)
        {
            string[] line = lines[i].Split(','); //读取一行，逗号分割
            for(int j = 0; j < line.Length; j++)
            {
                if (line[j] != "")//有数据才记录
                {
                    this[i, j] = line[j]; //使用 this 索引器来记录数据
                }
            }
        }
    }

}