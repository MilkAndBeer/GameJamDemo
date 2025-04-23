using Language.Lua;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestExcel : MonoBehaviour
{
    private ExcelSheet _sheet = new ExcelSheet();

    private void Start()
    {
        var sheet = new ExcelSheet("test");
        sheet.Load("test");
        sheet[0, 0] = "1"; // 第一行第一列赋值为 1
        sheet[1, 2] = "2"; // 第二行第三列赋值为 2

        sheet.Save("test", "Sheet1", ExcelFormat.Csv);
    }

    void Update() { }

    private void OnGUI()
    {
        if (GUILayout.Button("Load"))
        {
            _sheet.Load("test");

            for (int i = _sheet.Start.x; i < _sheet.End.x; i++)
            {
                for (int j = _sheet.Start.y; j < _sheet.End.y; j++)
                {
                    var value = _sheet[i, j];
                    if (string.IsNullOrEmpty(value)) continue;
                    Debug.Log($"Sheet[{i}, {j}]: {value}");
                }
            }

            Debug.Log(_sheet.Start);
            Debug.Log(_sheet.End);
        }
        if (GUILayout.Button("Save"))
        {
            _sheet[0, 1] = "Hello World";
            _sheet[1, 2] = "123";

            _sheet.Save("test");
        }
        if (GUILayout.Button("Clear"))
        {
            _sheet.Clear();
        }
        if (GUILayout.Button("Get"))
        {
            Debug.Log(_sheet[0, 0]);
            Debug.Log(_sheet[1, 2]);
        }
    }
}
