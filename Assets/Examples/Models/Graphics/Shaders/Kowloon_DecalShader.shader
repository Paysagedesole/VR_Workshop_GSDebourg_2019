// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Kowloon_DecalShader"
{
	Properties
	{
		_GMEO("GMEO", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Albedo("Albedo", 2D) = "white" {}
		_Color0("Color 0", Color) = (0,0,0,0)
		_OpacityContrast("Opacity Contrast", Float) = 1
		_HeyThere("HeyThere", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 5.0
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _Color0;
		uniform float _HeyThere;
		uniform sampler2D _GMEO;
		uniform float4 _GMEO_ST;
		uniform float _OpacityContrast;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 blendOpSrc5 = tex2D( _Albedo, uv_Albedo );
			float4 blendOpDest5 = _Color0;
			o.Albedo = ( saturate( (( blendOpDest5 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest5 - 0.5 ) ) * ( 1.0 - blendOpSrc5 ) ) : ( 2.0 * blendOpDest5 * blendOpSrc5 ) ) )).rgb;
			float3 temp_cast_1 = (_HeyThere).xxx;
			o.Specular = temp_cast_1;
			float2 uv_GMEO = i.uv_texcoord * _GMEO_ST.xy + _GMEO_ST.zw;
			float4 tex2DNode3 = tex2D( _GMEO, uv_GMEO );
			o.Smoothness = tex2DNode3.r;
			o.Alpha = 1;
			clip( pow( tex2DNode3.a , _OpacityContrast ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13901
1927;29;1906;1004;1348.519;343.9894;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;8;-716.8719,610.678;Float;False;Property;_OpacityContrast;Opacity Contrast;5;0;1;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;3;-781.7998,388.7001;Float;True;Property;_GMEO;GMEO;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;-951.2766,-235.697;Float;True;Property;_Albedo;Albedo;3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;6;-929.2991,78.02557;Float;False;Property;_Color0;Color 0;4;0;0,0,0,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.PowerNode;7;-395.7726,540.4774;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-579,147;Float;True;Property;_Normal;Normal;1;0;None;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.RangedFloatNode;9;-265.5193,-15.98944;Float;False;Property;_HeyThere;HeyThere;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.BlendOpsNode;5;-497.0344,40.20237;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;7;Float;ASEMaterialInspector;0;0;StandardSpecular;Kowloon_DecalShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;Back;0;0;False;0;0;Masked;0.5;True;True;0;False;TransparentCutout;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;3;4
WireConnection;7;1;8;0
WireConnection;5;0;1;0
WireConnection;5;1;6;0
WireConnection;0;0;5;0
WireConnection;0;1;2;0
WireConnection;0;3;9;0
WireConnection;0;4;3;1
WireConnection;0;10;7;0
ASEEND*/
//CHKSM=80C83EF56DCADED6ED31EC3B64923F064BA21E14