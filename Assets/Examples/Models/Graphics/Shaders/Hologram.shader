// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hologram"
{
	Properties
	{
		[Header(Refraction)]
		_linear_gradient("linear_gradient", 2D) = "white" {}
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_linear_gradient_solo("linear_gradient_solo", 2D) = "white" {}
		_EmissiveFactor("EmissiveFactor", Range( 0.2 , 1)) = 0.2
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_EmissiveColor("EmissiveColor", Color) = (0.8773585,0.1448469,0.8257731,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#pragma surface surf Standard alpha:fade keepalpha finalcolor:RefractionF noshadow exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform float _EmissiveFactor;
		uniform sampler2D _linear_gradient_solo;
		uniform sampler2D _linear_gradient;
		uniform float4 _EmissiveColor;
		uniform float _Opacity;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( ( ( ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) ) * ( 1.0 / ( screenPos.z + 1.0 ) ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) ) );
			float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			float3 ase_worldPos = i.worldPos;
			float2 panner5 = ( 1.0 * _Time.y * float2( 0,0.05 ) + ( ase_worldPos * 3 ).xy);
			float4 tex2DNode10 = tex2D( _linear_gradient, panner5 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV81 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode81 = ( 0.0 + 1.09 * pow( 1.0 - fresnelNdotV81, 5.6 ) );
			float mulTime121 = _Time.y * 5.0;
			color.rgb = color.rgb + Refraction( i, o, ( 1.0 - ( ( tex2DNode10 * 0.5 ) + pow( ( fresnelNode81 * ( ( sin( mulTime121 ) + 1.83 ) * 0.25 ) ) , 0.5 ) ) ).r, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float2 panner19 = ( 1.0 * _Time.y * float2( 0,-0.15 ) + ase_worldPos.xy);
			float2 panner5 = ( 1.0 * _Time.y * float2( 0,0.05 ) + ( ase_worldPos * 3 ).xy);
			float4 tex2DNode10 = tex2D( _linear_gradient, panner5 );
			float4 temp_cast_2 = (0.4).xxxx;
			float4 temp_cast_3 = (0.6).xxxx;
			float4 clampResult15 = clamp( tex2DNode10 , temp_cast_2 , temp_cast_3 );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV81 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode81 = ( 0.0 + 1.09 * pow( 1.0 - fresnelNdotV81, 5.6 ) );
			float temp_output_61_0 = ( 1.0 * fresnelNode81 );
			o.Emission = ( ( ( _EmissiveFactor * 6.0 ) * ( ( tex2D( _linear_gradient_solo, panner19 ) + ( float4(0.251157,0.5294013,0.6415094,0) * clampResult15 ) ) + ( temp_output_61_0 * float4(0.504717,1,0.9572697,0) ) ) ) * _EmissiveColor ).rgb;
			float4 clampResult25 = clamp( ( clampResult15 * _Opacity ) , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
			o.Alpha = saturate( (( clampResult25 + temp_output_61_0 )).r );
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
-1908;37;1906;1010;3245.831;2193.933;1.31737;True;True
Node;AmplifyShaderEditor.WorldPosInputsNode;33;-4194.396,-1183.413;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;12;-3140.294,-653.1055;Float;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0,0.05;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScaleNode;59;-3088.793,-796.4705;Float;False;3;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;5;-2881.417,-753.9567;Float;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,-0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2484.46,-582.0952;Float;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;False;0;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-2481.46,-504.0952;Float;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;False;0;0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;18;-2724.562,-1874.537;Float;False;Constant;_Vector1;Vector 1;2;0;Create;True;0;0;False;0;0,-0.15;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;10;-2667.464,-775.3301;Float;True;Property;_linear_gradient;linear_gradient;1;0;Create;True;0;0;False;0;7e53bf1fcf258044dbd6fd1e1478a9cf;7e53bf1fcf258044dbd6fd1e1478a9cf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;121;-1957.482,252.7886;Float;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;19;-2386.282,-1777.5;Float;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,-0.3;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;15;-2203.637,-785.1812;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.4433962,0.4433962,0.4433962,0;False;2;COLOR;0.7169812,0.7169812,0.7169812,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1395.386,-362.1372;Float;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-990.0123,-1739.256;Float;False;Property;_Opacity;Opacity;4;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;81;-2194.311,-283.3674;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1.09;False;3;FLOAT;5.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;-2178.227,-1016.233;Float;False;Constant;_Color3;Color 3;2;0;Create;True;0;0;False;0;0.251157,0.5294013,0.6415094,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;122;-1754.66,244.5881;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;82;-1138.801,-34.44099;Float;False;Constant;_Color1;Color 1;3;0;Create;True;0;0;False;0;0.504717,1,0.9572697,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-1077.649,-299.1745;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-1999.824,-1818.179;Float;True;Property;_linear_gradient_solo;linear_gradient_solo;2;0;Create;True;0;0;False;0;da5e2946c8563dc4f83113d6eff1dd31;da5e2946c8563dc4f83113d6eff1dd31;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;124;-1568.417,264.8796;Float;False;ConstantBiasScale;-1;;1;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT;0;False;1;FLOAT;1.83;False;2;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1660.801,-797.6442;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-469.5959,-1818.051;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-1645.997,437.5412;Float;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-297.866,-829.76;Float;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;False;0;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-436.072,-922.5203;Float;False;Property;_EmissiveFactor;EmissiveFactor;3;0;Create;True;0;0;False;0;0.2;0.2;0.2;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-759.6877,-125.4716;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;25;-195.029,-1823.519;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-1269.269,-804.7805;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-1175.511,236.015;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-349.1529,-251.1987;Float;False;Constant;_Float5;Float 5;6;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;66;-400.8664,-670.8404;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-132.866,-857.76;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-187.5536,-370.4959;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;148.0896,-1816.155;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;128;-819.0454,427.6591;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;119;401.7968,-1599.364;Float;False;True;False;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;83.4966,-785.7101;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;78.96128,-323.7614;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;114;-42.35677,-1152.425;Float;False;Property;_EmissiveColor;EmissiveColor;5;0;Create;True;0;0;False;0;0.8773585,0.1448469,0.8257731,0;0,0.7358486,0.735849,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;118;623.489,-1595.588;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;120;247.1875,-328.4044;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;314.1902,-1015.552;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;837.4868,-1201.449;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Hologram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;3.45;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;0;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;59;0;33;0
WireConnection;5;0;59;0
WireConnection;5;2;12;0
WireConnection;10;1;5;0
WireConnection;19;0;33;0
WireConnection;19;2;18;0
WireConnection;15;0;10;0
WireConnection;15;1;76;0
WireConnection;15;2;77;0
WireConnection;122;0;121;0
WireConnection;61;0;63;0
WireConnection;61;1;81;0
WireConnection;16;1;19;0
WireConnection;124;3;122;0
WireConnection;13;0;83;0
WireConnection;13;1;15;0
WireConnection;21;0;15;0
WireConnection;21;1;20;0
WireConnection;68;0;61;0
WireConnection;68;1;82;0
WireConnection;25;0;21;0
WireConnection;78;0;16;0
WireConnection;78;1;13;0
WireConnection;125;0;81;0
WireConnection;125;1;124;0
WireConnection;66;0;78;0
WireConnection;66;1;68;0
WireConnection;117;0;35;0
WireConnection;117;1;116;0
WireConnection;136;0;10;0
WireConnection;136;1;166;0
WireConnection;75;0;25;0
WireConnection;75;1;61;0
WireConnection;128;0;125;0
WireConnection;128;1;126;0
WireConnection;119;0;75;0
WireConnection;34;0;117;0
WireConnection;34;1;66;0
WireConnection;134;0;136;0
WireConnection;134;1;128;0
WireConnection;118;0;119;0
WireConnection;120;0;134;0
WireConnection;115;0;34;0
WireConnection;115;1;114;0
WireConnection;0;2;115;0
WireConnection;0;8;120;0
WireConnection;0;9;118;0
ASEEND*/
//CHKSM=C09F2FEE1499C54D0E7B159090E45A0A0F8D861B