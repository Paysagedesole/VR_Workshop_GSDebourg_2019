#if UNITY_EDITOR
namespace Gameleon.Editor
{
	using System.Collections;
	using UnityEngine;
	using UnityEditor;

	public static class EditorHelper
	{
		public enum EIndentLevel
		{
			Root,
			Level1
		}

		public const int DefaultSpacingSize = 4;

		#region LayoutUtility
		public static void DrawSeparator()
		{
			EditorGUI.indentLevel = (int)EIndentLevel.Root;
			EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
			EditorGUI.indentLevel = (int)EIndentLevel.Level1;
		}

		public static bool DrawDefaultBoxButton(string name, Color color, params GUILayoutOption[] layoutOptions)
		{
			return DrawColoredButton(name, color, (layoutOptions.Length == 0 ? new GUILayoutOption[] { GUILayout.MaxHeight(15), GUILayout.MaxWidth(20) } : layoutOptions));
		}

		public static bool DrawColoredButton(string name, Color color, params GUILayoutOption[] layoutOptions)
		{
			bool result = false;
			GUI.backgroundColor = color;

			result = GUILayout.Button(name, layoutOptions);

			GUI.backgroundColor = Color.white;

			return result;
		}

		public static bool DrawIndentedButton(string name, Color color, params GUILayoutOption[] layoutOptions)
		{
			bool result = false;
			Rect runtimeRectBuffer = EditorGUI.IndentedRect(EditorGUILayout.GetControlRect(layoutOptions));
			GUI.backgroundColor = color;

			result = GUI.Button(runtimeRectBuffer, name);

			GUI.backgroundColor = Color.white;

			return result;
		}

		public static void DrawIndentedBox(string name, Color color, params GUILayoutOption[] layoutOptions)
		{
			Rect runtimeRectBuffer = EditorGUI.IndentedRect(EditorGUILayout.GetControlRect(layoutOptions));
			GUI.backgroundColor = color;
			GUI.Box(runtimeRectBuffer, name);
			GUI.backgroundColor = Color.white;
		}

		public static int AddConditionnalLayoutSize(int addedSize)
		{
			return addedSize + DefaultSpacingSize;
		}

		#endregion LayoutUtility
	}
}
#endif //UNITY_EDITOR