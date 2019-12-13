// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Kowloon_Opaque"
{
	Properties
	{
		_Albedo_mask("Albedo_mask", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Gloss_Metallic_Emissive_Opacity("Gloss_Metallic_Emissive_Opacity", 2D) = "white" {}
		_GlossMultiplier("Gloss Multiplier", Range( 0 , 1)) = 1
		[Toggle(_INVERT_ON)] _Invert("Invert", Float) = 0
		_EnableEmissive("EnableEmissive", Range( 0 , 1)) = 0
		_Emissivecolor("Emissive color", Color) = (0,0,0,0)
		_Emissiveintensity("Emissive intensity", Float) = 2
		[Toggle(_COLORMASK_ON)] _ColorMask("Color Mask", Float) = 0
		_ColorMasked("Color Masked", Color) = (0,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Transparentcutout("Transparent ? (cutout)", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma shader_feature _COLORMASK_ON
		#pragma shader_feature _INVERT_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo_mask;
		uniform float4 _Albedo_mask_ST;
		uniform float4 _ColorMasked;
		uniform sampler2D _Gloss_Metallic_Emissive_Opacity;
		uniform float4 _Gloss_Metallic_Emissive_Opacity_ST;
		uniform float4 _Emissivecolor;
		uniform float _Emissiveintensity;
		uniform float _EnableEmissive;
		uniform float _GlossMultiplier;
		uniform float _Transparentcutout;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_Albedo_mask = i.uv_texcoord * _Albedo_mask_ST.xy + _Albedo_mask_ST.zw;
			float4 tex2DNode78 = tex2D( _Albedo_mask, uv_Albedo_mask );
			float4 appendResult57 = (float4(tex2DNode78.r , tex2DNode78.g , tex2DNode78.b , 0.0));
			float4 blendOpSrc85 = _ColorMasked;
			float4 blendOpDest85 = appendResult57;
			#ifdef _COLORMASK_ON
				float staticSwitch79 = tex2DNode78.a;
			#else
				float staticSwitch79 = 0.0;
			#endif
			float4 lerpResult81 = lerp( appendResult57 , (( blendOpDest85 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest85 - 0.5 ) ) * ( 1.0 - blendOpSrc85 ) ) : ( 2.0 * blendOpDest85 * blendOpSrc85 ) ) , staticSwitch79);
			o.Albedo = lerpResult81.xyz;
			float2 uv_Gloss_Metallic_Emissive_Opacity = i.uv_texcoord * _Gloss_Metallic_Emissive_Opacity_ST.xy + _Gloss_Metallic_Emissive_Opacity_ST.zw;
			float4 tex2DNode63 = tex2D( _Gloss_Metallic_Emissive_Opacity, uv_Gloss_Metallic_Emissive_Opacity );
			o.Emission = ( ( tex2DNode63.b * _Emissivecolor ) * _Emissiveintensity * _EnableEmissive ).rgb;
			o.Metallic = tex2DNode63.g;
			#ifdef _INVERT_ON
				float staticSwitch73 = ( 1.0 - tex2DNode63.r );
			#else
				float staticSwitch73 = tex2DNode63.r;
			#endif
			float clampResult70 = clamp( ( staticSwitch73 * _GlossMultiplier ) , 0.0 , 1.0 );
			o.Smoothness = clampResult70;
			o.Alpha = 1;
			clip( ( tex2DNode63.a * _Transparentcutout ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
7;355;1906;678;1961.273;-322.7611;1;True;False
Node;AmplifyShaderEditor.SamplerNode;63;-2472.705,431.7691;Float;True;Property;_Gloss_Metallic_Emissive_Opacity;Gloss_Metallic_Emissive_Opacity;2;0;Create;True;0;0;False;0;None;04c8a3edf61ba8c42a075b62ae387773;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;78;-2551.791,-711.4877;Float;True;Property;_Albedo_mask;Albedo_mask;0;0;Create;True;0;0;False;0;None;aed72b8f69408b04b9c58cd2b34c156d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;72;-1636.137,91.63264;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1510.312,203.8284;Float;False;Property;_GlossMultiplier;Gloss Multiplier;3;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1701.238,-268.337;Float;False;Constant;_no;no;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;73;-1420.336,82.53265;Float;False;Property;_Invert;Invert;4;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;75;-1432.813,732.4859;Float;False;Property;_Emissivecolor;Emissive color;7;0;Create;True;0;0;False;0;0,0,0,0;0.2039215,0.7687522,0.8784314,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;83;-1646.311,-934.0955;Float;False;Property;_ColorMasked;Color Masked;10;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;57;-1600.361,-598.8113;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;79;-1418.064,-288.5636;Float;False;Property;_ColorMask;Color Mask;9;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1114.011,578.886;Float;False;Property;_Emissiveintensity;Emissive intensity;8;0;Create;True;0;0;False;0;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-2127.784,675.8522;Float;False;Property;_Transparentcutout;Transparent ? (cutout);12;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;85;-1285.441,-821.5224;Float;False;Overlay;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1182.436,85.13264;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1060.212,404.1858;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-1072.882,741.7897;Float;False;Property;_EnableEmissive;EnableEmissive;5;0;Create;True;0;0;False;0;0;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;81;-1145.354,-544.1035;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;70;-1009.537,82.53268;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1328.311,-656.0955;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;90;-517.1807,475.3859;Float;False;Property;_EnableEmissive2;EnableEmissive2;6;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-835.0117,526.9857;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;66;-2447.56,-0.536303;Float;True;Property;_Normal;Normal;1;0;Create;True;0;0;False;0;None;be158d0e756654a4b9538033f235eaca;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1719.757,576.6833;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-35.19997,24.00001;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Kowloon_Opaque;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;11;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;72;0;63;1
WireConnection;73;1;63;1
WireConnection;73;0;72;0
WireConnection;57;0;78;1
WireConnection;57;1;78;2
WireConnection;57;2;78;3
WireConnection;79;1;80;0
WireConnection;79;0;78;4
WireConnection;85;0;83;0
WireConnection;85;1;57;0
WireConnection;67;0;73;0
WireConnection;67;1;69;0
WireConnection;74;0;63;3
WireConnection;74;1;75;0
WireConnection;81;0;57;0
WireConnection;81;1;85;0
WireConnection;81;2;79;0
WireConnection;70;0;67;0
WireConnection;84;0;83;0
WireConnection;84;1;57;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;76;2;91;0
WireConnection;87;0;63;4
WireConnection;87;1;89;0
WireConnection;0;0;81;0
WireConnection;0;1;66;0
WireConnection;0;2;76;0
WireConnection;0;3;63;2
WireConnection;0;4;70;0
WireConnection;0;10;87;0
ASEEND*/
//CHKSM=27684A1F1D7921E6381C6C87F27D3A7F2510C845