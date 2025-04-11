using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace EBGame
{
    [CustomPropertyDrawer(typeof(TooltipAttribute))]
    public class ToolTipDrawer : MaterialPropertyDrawer
    {
        private GUIContent _guiContent;
        private MethodInfo _internalMethod;
        private Type[] _methodArgumentTypes;
        private object[] _methodArguments;
        private MethodInfo _getPropertyRectMethodInfo;
        private object[] _getPropertyRectMethodInfoArguments;

        public ToolTipDrawer(string tooltip)
        {
            _guiContent = new GUIContent(string.Empty, tooltip);
            _methodArgumentTypes = new[] { typeof(Rect), typeof(MaterialProperty), typeof(GUIContent) };
            _methodArguments = new object[3];
            _internalMethod = typeof(MaterialEditor).GetMethod("DefaultShaderPropertyInternal", BindingFlags.Instance | BindingFlags.NonPublic,
                null, _methodArgumentTypes, null);

            _getPropertyRectMethodInfo = typeof(MaterialEditor).GetMethod("GetPropertyRect", BindingFlags.Instance | BindingFlags.NonPublic, null,
                new[] { typeof(MaterialProperty), typeof(string), typeof(bool) }, null);
            _getPropertyRectMethodInfoArguments = new object[3];
        }

        #region 添加Vector的Content支持
        //拷贝至https://github.com/Unity-Technologies/UnityCsReference/blob/master/Editor/Mono/Inspector/MaterialEditor.cs
        private Vector4 VectorProperty(Rect position, MaterialProperty prop, GUIContent content)
        {
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;
            var oldLabelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 0f;

            Vector4 newValue = EditorGUI.Vector4Field(position, content, prop.vectorValue);
            EditorGUIUtility.labelWidth = oldLabelWidth;
            EditorGUI.showMixedValue = false;
            if (EditorGUI.EndChangeCheck())
                prop.vectorValue = newValue;
            return prop.vectorValue;
        }
        #endregion
        public override void OnGUI(Rect position, MaterialProperty prop, string label, MaterialEditor editor)
        {
            _guiContent.text = label;
            if(prop.type == MaterialProperty.PropType.Vector)
            {
                VectorProperty(position, prop, _guiContent);
            }
            else if(prop.type == MaterialProperty.PropType.Texture)
            {
                bool scaleOffset = (prop.flags & MaterialProperty.PropFlags.NoScaleOffset) == 0;
                _getPropertyRectMethodInfoArguments[0] = prop;
                _getPropertyRectMethodInfoArguments[1] = label;
                _getPropertyRectMethodInfoArguments[2] = true;
                Rect r = (Rect)_getPropertyRectMethodInfo.Invoke(editor, _getPropertyRectMethodInfoArguments);
                editor.TextureProperty(r, prop, _guiContent.text, _guiContent.tooltip, scaleOffset);
            }
            else
            {
                //其他几个类型默认
                if(_internalMethod != null)
                {
                    _methodArguments[0] = position;
                    _methodArguments[1] = prop;
                    _methodArguments[2] = _guiContent;

                    _internalMethod.Invoke(editor, _methodArguments);
                }
            }
        }

    }

}