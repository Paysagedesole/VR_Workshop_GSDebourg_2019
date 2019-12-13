namespace Gameleon.Editor.Tools
{
	using System.Collections.Generic;
	using System.IO;

	using UnityEngine;
	using UnityEngine.SceneManagement;
	using UnityEditor;
	using UnityEditor.SceneManagement;
	using System;

	//TODO: SceneBrowserEditorWindow Path selectable label
	//TODO: SceneBrowserEditorWindow Select scene asset
	//TODO: SceneBrowserEditorWindow keep the saved scenes between compilation
	public class SceneBrowserEditorWindow : EditorWindow
	{

		#region Internals Classes
		[Serializable]
		private class SceneData : System.IEquatable<SceneData>, System.IComparable<SceneData>
		{
			#region Fields
			[SerializeField] private Scene _scene;
			#endregion Fields

			#region Properties
			public SceneSetup SceneSetup { get; set; }
			public string Name { get; set; }
			public string Path { get; set; }
			public int BuildIndex { get; private set; }
			public bool IsReferenced { get; private set; }
			public bool IsInHierarchy
			{
				get
				{
					return SceneSetup != null;
				}
			}

			public bool IsLoaded
			{
				get
				{
					return SceneSetup != null && Scene.isLoaded;
				}
			}

			public bool IsEnabledInBuildSettings
			{
				get
				{
					if (BuildIndex != -1 && EditorBuildSettings.scenes.Length > BuildIndex)
					{
						return EditorBuildSettings.scenes[BuildIndex].enabled;
					}
					return false;
				}
			}

			public Scene Scene
			{
				get
				{
					if (_scene.IsValid() == false)
					{
						_scene = EditorSceneManager.GetSceneByName(Name);
					}
					return _scene;
				}
			}
			#endregion Properties

			#region ctor
			public SceneData(string name, string path, SceneSetup sceneSetup)
			{
				Name = name;
				Path = path;
				SceneSetup = sceneSetup;
				BuildIndex = SceneUtility.GetBuildIndexByScenePath("Assets" + Path);
			}
			#endregion ctor

			#region Methods
			public string FormatString()
			{
				return string.Format("[{0} at path: {1}] [build index: {2}] [In Hierarchy : {3}] [Loaded : {4}]",
					Name,
					Path,
					BuildIndex,
					IsInHierarchy,
					IsLoaded
				);
			}

			public void SetIsSceneReferenced(List<string> references)
			{
				foreach (string item in references)
				{
					if (item == Name)
					{
						IsReferenced = true;
						break;
					}
				}
			}

			int IComparable<SceneData>.CompareTo(SceneData other)
			{
				if (other == null)
				{
					return -2;
				}

				return BuildIndex - other.BuildIndex;
			}

			bool IEquatable<SceneData>.Equals(SceneData other)
			{
				if (other == null)
				{
					return false;
				}

				return BuildIndex == other.BuildIndex;
			}
			#endregion Methods
		}

		private class SceneInfo
		{
			#region Properties
			public int SceneCountInBuildSettings { get; private set; }
			public int LoadedSceneCount { get; private set; }
			public string ActiveScene { get; private set; }
			#endregion Properties

			#region ctor
			public SceneInfo()
			{
				Update();
			}
			#endregion ctor

			#region Methods

			public void Update()
			{
				SceneCountInBuildSettings = EditorSceneManager.sceneCountInBuildSettings;
				LoadedSceneCount = EditorSceneManager.sceneCount;
				ActiveScene = EditorSceneManager.GetActiveScene().name;
			}

			public string FormatString()
			{
				return string.Format("Scene Count in Build Settings : {0}\nLoaded Scene Count : {1}\nActive Scene : {2}",
						_sceneInfo.SceneCountInBuildSettings,
						_sceneInfo.LoadedSceneCount,
						_sceneInfo.ActiveScene
				);
			}
			#endregion Methods

		}
		#endregion Internals Classes

		#region enums

		#endregion enums

		#region Fields
		#region Statics
		static SceneBrowserEditorWindow _window;

		private static readonly Vector2 _minWindowSize = new Vector2(400, float.MaxValue);
		private static readonly Vector2 _maxWindowSize = new Vector2(600, float.MaxValue);

		#endregion Statics

		#region Public
		//[SerializeField] private GameDependencies _gameDependencies;
		#endregion Public

		#region Internals
		private List<SceneData> _allScenes = null;
		private static SceneInfo _sceneInfo = null;
		//private GameDependencies.ScenesDatabase _scenesDB;
		private bool _isDrawingOutOfBuildSettings = false;

		private Vector2 _scrollPosition;
		private bool _displaySettings = false;
		private bool _displayDebugSettings = false;
		private bool _displaySceneOutOfBuildSettings = false;
		private SceneSetup[] _sceneInHierarchy = null;

		#endregion Internals
		#endregion Fields 

		#region Properties
		private bool IsInit
		{
			get
			{
				return /*_gameDependencies != null
					&&*/ _allScenes != null
					&& _sceneInfo != null
					/*&& _scenesDB != null*/;
			}
		}
		#endregion Properties

		#region Methods

		[MenuItem("Gameleon/Tools/Scene Browser")]
		static void Initialize()
		{
			_window = null;
			_window = EditorWindow.GetWindow(typeof(SceneBrowserEditorWindow), false, "Scene Browser") as SceneBrowserEditorWindow;
			_window.minSize = new Vector2(_minWindowSize.x, _window.minSize.y);
			_window.maxSize = new Vector2(_maxWindowSize.x, _window.maxSize.y);
		}

		private void OnEnable()
		{
			//_gameDependencies = AssetDatabase.LoadAssetAtPath<GameDependencies>(_gameDependenciesPath);

			_sceneInfo = new SceneInfo();
			_sceneInfo.Update();
		}

		private void OnGUI()
		{
			DrawHeader();
			EditorHelper.DrawSeparator();
			DrawScenesList();
		}

		#region Display

		private void DrawHeader()
		{
			EditorGUILayout.BeginVertical();
			{
				GUILayout.Space(5);
				EditorGUILayout.LabelField("Scenes Browser", EditorStyles.boldLabel);
				EditorGUI.indentLevel = (int)EditorHelper.EIndentLevel.Level1;

				// Draw GameDependencies assignment
				//EditorGUILayout.BeginHorizontal();
				//{
				//	_gameDependencies = EditorGUILayout.ObjectField(_gameDependencies, typeof(GameDependencies), false) as GameDependencies;
				//	if (DrawDefaultBoxButton("X", Color.red) == true)
				//	{
				//		_gameDependencies = null;
				//	}
				//}
				//EditorGUILayout.EndHorizontal();
				//

				// Draw Draw Options settings
				_displaySettings = EditorGUILayout.Foldout(_displaySettings, "Settings");

				if (_displaySettings == true)
				{
					_displaySceneOutOfBuildSettings = EditorGUILayout.Toggle("Display Scenes out of build settings", _displaySceneOutOfBuildSettings);

					// Draw Draw Infos
					if (_sceneInfo != null)
					{
						// Height of 60, 3 line * 20 pixel
						EditorHelper.DrawIndentedBox(_sceneInfo.FormatString(), Color.white, GUILayout.ExpandWidth(true), GUILayout.MinHeight(45));
					}
					//

					// Draw Debug
					_displayDebugSettings = EditorGUILayout.Foldout(_displayDebugSettings, "Debug");
					if (_displayDebugSettings == true)
					{
						if (EditorHelper.DrawIndentedButton("Update", Color.white))
						{
							UpdateFields();
						}
					}
					//
				}
				//

				// Draw Controls buttons
				EditorGUILayout.BeginHorizontal();
				{
					if (EditorHelper.DrawIndentedButton("Browse all scenes", (IsInit == false ? Color.yellow : Color.white)/*, GUILayout.ExpandWidth(false)*/) == true)
					{
						ResetDisplay();

						//if (_gameDependencies != null)
						//{
						//}
						SetAllScenesFromProject();
					}
				}
				EditorGUILayout.EndHorizontal();

				//if (_gameDependencies == null)
				//{
				//	EditorGUILayout.HelpBox(GetMessage(EMessage.MissingGameDependencies), MessageType.Error, true);
				//}
				EditorGUI.indentLevel = (int)EditorHelper.EIndentLevel.Root;

			}
			EditorGUILayout.EndVertical();
		}

		private void ResetDisplay()
		{
			_allScenes = null;
			_scrollPosition = Vector2.zero;
			_sceneInHierarchy = null;
			_isDrawingOutOfBuildSettings = false;

			//if (_gameDependencies != null)
			//{
			//	_scenesDB = _gameDependencies.Scenes;
			//}

			_sceneInHierarchy = EditorSceneManager.GetSceneManagerSetup();
		}

		private void DrawScenesList()
		{
			if (IsInit == false)
			{
				return;
			}

			// Draw header
			EditorGUILayout.LabelField("Scenes in build settings", EditorStyles.boldLabel);
			EditorGUI.indentLevel = (int)EditorHelper.EIndentLevel.Level1;

			_isDrawingOutOfBuildSettings = false;
			_scrollPosition = EditorGUILayout.BeginScrollView(_scrollPosition, false, false);

			int length = _allScenes.Count;
			SceneData sceneData;
			Color objectColor;

			for (int i = 0; i < length; i++)
			{
				sceneData = _allScenes[i];

				// Scenes in build settings, the list was sorted before
				if (sceneData.BuildIndex == -1)
				{
					if (_displaySceneOutOfBuildSettings == false)
					{
						break;
					}

					if (_isDrawingOutOfBuildSettings == false)
					{
						_isDrawingOutOfBuildSettings = true;
						EditorHelper.DrawSeparator();
						EditorGUILayout.LabelField("Scenes out of build settings", EditorStyles.boldLabel);
					}
				}

				objectColor = Color.white;
				if (sceneData.IsLoaded == true)
				{
					objectColor = Color.green;
				}

				DrawSceneDataObject(sceneData, objectColor);
			}

			EditorGUI.indentLevel = (int)EditorHelper.EIndentLevel.Root;
			EditorGUILayout.EndScrollView();
		}

		private void DrawSceneDataObject(SceneData sceneData, Color backgroundColor)
		{
			int conditionnalLayoutSize = 0;

			EditorGUILayout.BeginHorizontal();

			// Draw buildIndex
			if (sceneData.BuildIndex != -1)
			{
				GUILayout.Toggle(sceneData.IsEnabledInBuildSettings, sceneData.BuildIndex.ToString(), GUILayout.ExpandWidth(false), GUILayout.Width(40));
			}
			else
			{
				conditionnalLayoutSize += EditorHelper.AddConditionnalLayoutSize(40);
			}

			// Draw active references
			if (sceneData.IsReferenced == true)
			{
				GUI.backgroundColor = Color.green;
				GUILayout.Box("", GUILayout.Width(20));
				GUI.backgroundColor = Color.white;
			}
			else
			{
				conditionnalLayoutSize += EditorHelper.AddConditionnalLayoutSize(20);
			}

			// Draw Name
			GUI.backgroundColor = backgroundColor;
			GUILayout.Box(sceneData.Name, GUILayout.ExpandWidth(false), GUILayout.MinWidth(250), GUILayout.MaxWidth(600));
			GUI.backgroundColor = Color.white;

			//  Draw loading scene button
			GUI.backgroundColor = backgroundColor;

			string loadUnloadButtonName = (sceneData.Scene.isLoaded ? "Unload" : "Load");
			if (EditorHelper.DrawColoredButton(loadUnloadButtonName, backgroundColor, GUILayout.Width(50), GUILayout.ExpandWidth(false)) == true)
			{
				if (sceneData.Scene.isLoaded == true)
				{
					EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo();
					EditorSceneManager.CloseScene(sceneData.Scene, false);
				}
				else
				{
					EditorSceneManager.OpenScene(Application.dataPath + sceneData.Path, OpenSceneMode.Additive);
				}
				UpdateFields();
			}

			// Draw Remove scene button
			if (sceneData.IsInHierarchy == true)
			{
				if (EditorHelper.DrawDefaultBoxButton("X", Color.red) == true)
				{
					if (sceneData.Scene.IsValid())
					{
						EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo();
						EditorSceneManager.CloseScene(sceneData.Scene, true);
						UpdateFields();
					}
				}
			}
			else
			{
				// 20 is the width size of DrawDefaultBoxButton
				conditionnalLayoutSize += EditorHelper.AddConditionnalLayoutSize(20);
			}

			//// Draw Select scene asset
			//if (DrawColoredButton("Select Scene Asset", Color.white, GUILayout.Width(120)))
			//{

			//}
			//else
			//{
			//	conditionnalLayoutSize += AddConditionnalLayoutSize(100);
			//}

			GUI.backgroundColor = Color.white;

			EditorGUILayout.EndHorizontal();
		}

		#endregion Display

		#region Logics
		private void SetAllScenesFromProject()
		{
			string[] allScenesPath = Directory.GetFiles(Application.dataPath, "*.unity", SearchOption.AllDirectories);

			_allScenes = new List<SceneData>();

			string sceneName = string.Empty;
			SceneData sceneData;
			List<SceneData> _sceneAddedToBuildSettings = new List<SceneData>();

			int length = allScenesPath.Length;
			for (int i = 0; i < length; i++)
			{
				int slashTokenIndex = allScenesPath[i].LastIndexOf('\\');
				int dotTokenIndex = allScenesPath[i].LastIndexOf('.');

				if (dotTokenIndex - slashTokenIndex <= 0)
				{
					Debug.LogErrorFormat("Parsing error : [. : {0}] [\\ : {1}] [{2}]", dotTokenIndex, slashTokenIndex, dotTokenIndex - slashTokenIndex);
					return;
				}

				// Getting scene name
				sceneName = allScenesPath[i].Substring(slashTokenIndex + 1);

				// Removing extension
				sceneName = sceneName.Substring(0, dotTokenIndex - slashTokenIndex - 1);

				// Removing persistant path
				slashTokenIndex = allScenesPath[i].IndexOf('\\');
				allScenesPath[i] = allScenesPath[i].Substring(slashTokenIndex);
				allScenesPath[i] = allScenesPath[i].Replace('\\', '/');

				// Getting buildIndex if exists
				sceneData = new SceneData(sceneName, allScenesPath[i], GetSceneSetupAtPath(allScenesPath[i]));
				//sceneData.SetIsSceneReferenced(_scenesDB.AllScenesName);

				//Debug.LogFormat(allScenesPath[i]);

				if (sceneData.BuildIndex != -1)
				{
					_sceneAddedToBuildSettings.Add(sceneData);
				}
				else
				{
					_allScenes.Add(sceneData);
				}
			}

			_sceneAddedToBuildSettings.Sort();

			_allScenes.InsertRange(0, _sceneAddedToBuildSettings);
		}

		private SceneSetup GetSceneSetupAtPath(string path)
		{
			path = "Assets" + path;
			//path = path.Replace('\\', '/');

			int length = _sceneInHierarchy.Length;
			for (int i = 0; i < length; i++)
			{
				if (_sceneInHierarchy[i].path == path)
				{
					return _sceneInHierarchy[i];
				}
			}
			return null;
		}

		private void UpdateFields()
		{
			_sceneInHierarchy = EditorSceneManager.GetSceneManagerSetup();
			_sceneInfo = new SceneInfo();
			_sceneInfo.Update();

			if (_allScenes != null)
			{
				_allScenes.ForEach(item =>
				{
					item.SceneSetup = GetSceneSetupAtPath(item.Path);
				});
			}
		}

		#endregion Logics

		#endregion Methods
	}
}