// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Kowloon_VertexPainting"
{
	Properties
	{
		_Base_Albedo("Base_Albedo", 2D) = "white" {}
		_Base_Normal("Base_Normal", 2D) = "white" {}
		_Base_Gloss("Base_Gloss", 2D) = "white" {}
		[Toggle]_ColorMask("ColorMask", Int) = 0
		_ColorMask_intensity("ColorMask_intensity", Float) = 0
		_Color0("Color 0", Color) = (0,0,0,0)
		_Red_Albedo("Red_Albedo", 2D) = "white" {}
		_Red_Normal("Red_Normal", 2D) = "white" {}
		_Red_Gloss("Red_Gloss", 2D) = "white" {}
		_Red_BlendStrengh("Red_BlendStrengh", Float) = 0
		_Red_heightpower("Red_heightpower", Float) = 0
		_Green_Albedo("Green_Albedo", 2D) = "white" {}
		_Green_Normal("Green_Normal", 2D) = "white" {}
		_Green_Gloss("Green_Gloss", 2D) = "white" {}
		_Green_BlendStrengh("Green_BlendStrengh", Float) = 0
		_Green_heightpower("Green_heightpower", Float) = 0
		_Gloss("Gloss", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma shader_feature _COLORMASK_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _Base_Normal;
		uniform float4 _Base_Normal_ST;
		uniform sampler2D _Red_Normal;
		uniform float4 _Red_Normal_ST;
		uniform sampler2D _Red_Gloss;
		uniform float4 _Red_Gloss_ST;
		uniform float _Red_heightpower;
		uniform float _Red_BlendStrengh;
		uniform sampler2D _Green_Normal;
		uniform float4 _Green_Normal_ST;
		uniform sampler2D _Green_Gloss;
		uniform float4 _Green_Gloss_ST;
		uniform float _Green_heightpower;
		uniform float _Green_BlendStrengh;
		uniform sampler2D _Base_Albedo;
		uniform float4 _Base_Albedo_ST;
		uniform float4 _Color0;
		uniform float _ColorMask_intensity;
		uniform sampler2D _Red_Albedo;
		uniform float4 _Red_Albedo_ST;
		uniform sampler2D _Green_Albedo;
		uniform float4 _Green_Albedo_ST;
		uniform sampler2D _Base_Gloss;
		uniform float4 _Base_Gloss_ST;
		uniform float _Gloss;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Base_Normal = i.uv_texcoord * _Base_Normal_ST.xy + _Base_Normal_ST.zw;
			float2 uv_Red_Normal = i.uv_texcoord * _Red_Normal_ST.xy + _Red_Normal_ST.zw;
			float2 uv_Red_Gloss = i.uv_texcoord * _Red_Gloss_ST.xy + _Red_Gloss_ST.zw;
			float4 tex2DNode39 = tex2D( _Red_Gloss, uv_Red_Gloss );
			float HeightMask1 = saturate(pow(((pow( tex2DNode39.b , _Red_heightpower )*i.vertexColor.r)*4)+(i.vertexColor.r*2),_Red_BlendStrengh));
			float3 lerpResult23 = lerp( UnpackNormal( tex2D( _Base_Normal, uv_Base_Normal ) ) , UnpackNormal( tex2D( _Red_Normal, uv_Red_Normal ) ) , HeightMask1);
			float2 uv_Green_Normal = i.uv_texcoord * _Green_Normal_ST.xy + _Green_Normal_ST.zw;
			float2 uv_Green_Gloss = i.uv_texcoord * _Green_Gloss_ST.xy + _Green_Gloss_ST.zw;
			float4 tex2DNode42 = tex2D( _Green_Gloss, uv_Green_Gloss );
			float HeightMask14 = saturate(pow(((pow( tex2DNode42.b , _Green_heightpower )*i.vertexColor.g)*4)+(i.vertexColor.g*2),_Green_BlendStrengh));
			float3 lerpResult24 = lerp( lerpResult23 , UnpackNormal( tex2D( _Green_Normal, uv_Green_Normal ) ) , HeightMask14);
			o.Normal = lerpResult24;
			float2 uv_Base_Albedo = i.uv_texcoord * _Base_Albedo_ST.xy + _Base_Albedo_ST.zw;
			float4 tex2DNode36 = tex2D( _Base_Albedo, uv_Base_Albedo );
			float4 appendResult59 = (float4(tex2DNode36.r , tex2DNode36.g , tex2DNode36.b , 0.0));
			float4 blendOpSrc60 = _Color0;
			float4 blendOpDest60 = appendResult59;
			#ifdef _COLORMASK_ON
				float staticSwitch61 = tex2DNode36.a;
			#else
				float staticSwitch61 = _ColorMask_intensity;
			#endif
			float4 lerpResult62 = lerp( appendResult59 , (( blendOpDest60 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest60 - 0.5 ) ) * ( 1.0 - blendOpSrc60 ) ) : ( 2.0 * blendOpDest60 * blendOpSrc60 ) ) , staticSwitch61);
			float2 uv_Red_Albedo = i.uv_texcoord * _Red_Albedo_ST.xy + _Red_Albedo_ST.zw;
			float4 lerpResult6 = lerp( lerpResult62 , tex2D( _Red_Albedo, uv_Red_Albedo ) , HeightMask1);
			float2 uv_Green_Albedo = i.uv_texcoord * _Green_Albedo_ST.xy + _Green_Albedo_ST.zw;
			float4 lerpResult11 = lerp( lerpResult6 , tex2D( _Green_Albedo, uv_Green_Albedo ) , HeightMask14);
			o.Albedo = lerpResult11.rgb;
			float2 uv_Base_Gloss = i.uv_texcoord * _Base_Gloss_ST.xy + _Base_Gloss_ST.zw;
			float4 tex2DNode35 = tex2D( _Base_Gloss, uv_Base_Gloss );
			float lerpResult52 = lerp( tex2DNode35.g , tex2DNode39.g , HeightMask1);
			float lerpResult53 = lerp( lerpResult52 , tex2DNode42.g , HeightMask14);
			o.Metallic = lerpResult53;
			float lerpResult26 = lerp( tex2DNode35.r , ( 1.0 - tex2DNode39.r ) , HeightMask1);
			float lerpResult27 = lerp( lerpResult26 , ( 1.0 - tex2DNode42.r ) , HeightMask14);
			o.Smoothness = ( lerpResult27 * _Gloss );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13901
1927;29;1906;1004;4903.041;1291.901;3.459039;True;True
Node;AmplifyShaderEditor.SamplerNode;36;-3328.473,-1782.516;Float;True;Property;_Base_Albedo;Base_Albedo;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;10;-4821.018,508.9763;Float;False;Property;_Red_heightpower;Red_heightpower;10;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;39;-3327.731,-661.8502;Float;True;Property;_Red_Gloss;Red_Gloss;8;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;57;-2537.023,-1893.554;Float;False;Property;_Color0;Color 0;5;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;42;-3330.998,31.71956;Float;True;Property;_Green_Gloss;Green_Gloss;13;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.DynamicAppendNode;59;-2491.073,-1558.27;Float;False;FLOAT4;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT4
Node;AmplifyShaderEditor.RangedFloatNode;58;-2591.95,-1227.795;Float;False;Property;_ColorMask_intensity;ColorMask_intensity;4;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;15;-4680.305,1053.729;Float;False;Property;_Green_heightpower;Green_heightpower;15;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;9;-4500.597,431.1744;Float;False;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;5;-4482.343,712.3773;Float;False;Property;_Red_BlendStrengh;Red_BlendStrengh;9;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.VertexColorNode;4;-5247.325,731.6923;Float;False;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;35;-3328.425,-1374.029;Float;True;Property;_Base_Gloss;Base_Gloss;2;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StaticSwitch;61;-2308.776,-1248.022;Float;False;Property;_ColorMask;ColorMask;3;0;0;False;True;;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;60;-2176.153,-1780.981;Float;False;Overlay;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.HeightMapBlendNode;1;-4198.145,428.1044;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.PowerNode;12;-4319.271,908.2419;Float;False;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;16;-4341.629,1257.13;Float;False;Property;_Green_BlendStrengh;Green_BlendStrengh;14;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;46;-2844.31,-464.2924;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;62;-2036.066,-1503.562;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;FLOAT4
Node;AmplifyShaderEditor.SamplerNode;38;-3327.779,-1070.338;Float;True;Property;_Red_Albedo;Red_Albedo;6;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;37;-3327.036,-859.5143;Float;True;Property;_Red_Normal;Red_Normal;7;0;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.OneMinusNode;47;-2775.495,64.48611;Float;False;1;0;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.HeightMapBlendNode;14;-4160.541,978.7267;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;26;-1354.59,761.0193;Float;False;3;0;FLOAT;0,0,0,0;False;1;FLOAT;0,0,0,0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;34;-3327.73,-1571.693;Float;True;Property;_Base_Normal;Base_Normal;1;0;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;52;-1623.947,-1039.094;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;40;-3331.046,-376.7674;Float;True;Property;_Green_Albedo;Green_Albedo;11;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;23;-1446.539,340.6813;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0.0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.LerpOp;6;-1590.95,31.26534;Float;False;3;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;65;-879.8528,925.097;Float;False;Property;_Gloss;Gloss;16;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;27;-1100.585,759.3439;Float;False;3;0;FLOAT;0,0,0,0;False;1;FLOAT;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;41;-3330.303,-165.9446;Float;True;Property;_Green_Normal;Green_Normal;12;0;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.LerpOp;53;-1273.787,-1010.933;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;11;-1194.273,-13.06429;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2219.023,-1615.554;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-750.8054,734.2969;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.LerpOp;24;-1192.533,339.0059;Float;False;3;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0,0,0;False;1;FLOAT3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;65,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Kowloon_VertexPainting;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Opaque;0.5;True;True;0;False;Opaque;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;59;0;36;1
WireConnection;59;1;36;2
WireConnection;59;2;36;3
WireConnection;9;0;39;3
WireConnection;9;1;10;0
WireConnection;61;0;36;4
WireConnection;61;1;58;0
WireConnection;60;0;57;0
WireConnection;60;1;59;0
WireConnection;1;0;9;0
WireConnection;1;1;4;1
WireConnection;1;2;5;0
WireConnection;12;0;42;3
WireConnection;12;1;15;0
WireConnection;46;0;39;1
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;62;2;61;0
WireConnection;47;0;42;1
WireConnection;14;0;12;0
WireConnection;14;1;4;2
WireConnection;14;2;16;0
WireConnection;26;0;35;1
WireConnection;26;1;46;0
WireConnection;26;2;1;0
WireConnection;52;0;35;2
WireConnection;52;1;39;2
WireConnection;52;2;1;0
WireConnection;23;0;34;0
WireConnection;23;1;37;0
WireConnection;23;2;1;0
WireConnection;6;0;62;0
WireConnection;6;1;38;0
WireConnection;6;2;1;0
WireConnection;27;0;26;0
WireConnection;27;1;47;0
WireConnection;27;2;14;0
WireConnection;53;0;52;0
WireConnection;53;1;42;2
WireConnection;53;2;14;0
WireConnection;11;0;6;0
WireConnection;11;1;40;0
WireConnection;11;2;14;0
WireConnection;63;0;57;0
WireConnection;63;1;59;0
WireConnection;64;0;27;0
WireConnection;64;1;65;0
WireConnection;24;0;23;0
WireConnection;24;1;41;0
WireConnection;24;2;14;0
WireConnection;0;0;11;0
WireConnection;0;1;24;0
WireConnection;0;3;53;0
WireConnection;0;4;64;0
ASEEND*/
//CHKSM=7C94D72C8D116AB555A8035F0FCC8B63D693DD00