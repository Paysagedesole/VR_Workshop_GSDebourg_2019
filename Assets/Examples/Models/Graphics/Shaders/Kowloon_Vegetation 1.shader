// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Kowloon_Vegetation"
{
	Properties
	{
		[Header(Translucency)]
		_Translucency("Strength", Range( 0 , 50)) = 1
		_TransNormalDistortion("Normal Distortion", Range( 0 , 1)) = 0.1
		_TransScattering("Scaterring Falloff", Range( 1 , 50)) = 2
		_TransDirect("Direct", Range( 0 , 1)) = 1
		_TransAmbient("Ambient", Range( 0 , 1)) = 0.2
		_TransShadow("Shadow", Range( 0 , 1)) = 0.9
		_spec("spec", Float) = 0
		_Color0("Color 0", Color) = (0.7647059,0.6289047,0.1855536,0)
		_Gloss("Gloss", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.71
		_T_LowTest3_Albedo_Mask("T_LowTest3_Albedo_Mask", 2D) = "white" {}
		_T_LowTest3_GMEO("T_LowTest3_GMEO", 2D) = "white" {}
		_T_LowTest3_Normal1("T_LowTest3_Normal 1", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecularCustom keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		struct SurfaceOutputStandardSpecularCustom
		{
			fixed3 Albedo;
			fixed3 Normal;
			half3 Emission;
			fixed3 Specular;
			half Smoothness;
			half Occlusion;
			fixed Alpha;
			fixed3 Translucency;
		};

		uniform sampler2D _T_LowTest3_Normal1;
		uniform float4 _T_LowTest3_Normal1_ST;
		uniform float4 _Color0;
		uniform sampler2D _T_LowTest3_Albedo_Mask;
		uniform float4 _T_LowTest3_Albedo_Mask_ST;
		uniform sampler2D _T_LowTest3_GMEO;
		uniform float4 _T_LowTest3_GMEO_ST;
		uniform float _spec;
		uniform float _Gloss;
		uniform half _Translucency;
		uniform half _TransNormalDistortion;
		uniform half _TransScattering;
		uniform half _TransDirect;
		uniform half _TransAmbient;
		uniform half _TransShadow;
		uniform float _Cutoff = 0.71;

		inline half4 LightingStandardSpecularCustom(SurfaceOutputStandardSpecularCustom s, half3 viewDir, UnityGI gi )
		{
			#if !DIRECTIONAL
			float3 lightAtten = gi.light.color;
			#else
			float3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, _TransShadow );
			#endif
			half3 lightDir = gi.light.dir + s.Normal * _TransNormalDistortion;
			half transVdotL = pow( saturate( dot( viewDir, -lightDir ) ), _TransScattering );
			half3 translucency = lightAtten * (transVdotL * _TransDirect + gi.indirect.diffuse * _TransAmbient) * s.Translucency;
			half4 c = half4( s.Albedo * translucency * _Translucency, 0 );

			SurfaceOutputStandardSpecular r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Specular = s.Specular;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandardSpecular (r, viewDir, gi) + c;
		}

		inline void LightingStandardSpecularCustom_GI(SurfaceOutputStandardSpecularCustom s, UnityGIInput data, inout UnityGI gi )
		{
			UNITY_GI(gi, s, data);
		}

		void surf( Input i , inout SurfaceOutputStandardSpecularCustom o )
		{
			float2 uv_T_LowTest3_Normal1 = i.uv_texcoord * _T_LowTest3_Normal1_ST.xy + _T_LowTest3_Normal1_ST.zw;
			o.Normal = UnpackNormal( tex2D( _T_LowTest3_Normal1, uv_T_LowTest3_Normal1 ) );
			float2 uv_T_LowTest3_Albedo_Mask = i.uv_texcoord * _T_LowTest3_Albedo_Mask_ST.xy + _T_LowTest3_Albedo_Mask_ST.zw;
			o.Albedo = ( _Color0 * tex2D( _T_LowTest3_Albedo_Mask, uv_T_LowTest3_Albedo_Mask ) ).rgb;
			float2 uv_T_LowTest3_GMEO = i.uv_texcoord * _T_LowTest3_GMEO_ST.xy + _T_LowTest3_GMEO_ST.zw;
			float4 tex2DNode2 = tex2D( _T_LowTest3_GMEO, uv_T_LowTest3_GMEO );
			float3 temp_cast_1 = (tex2DNode2.b).xxx;
			o.Emission = temp_cast_1;
			float3 temp_cast_2 = (_spec).xxx;
			o.Specular = temp_cast_2;
			o.Smoothness = ( tex2DNode2.r * _Gloss );
			o.Occlusion = tex2DNode2.a;
			float4 temp_output_4_0 = _Color0;
			o.Translucency = temp_output_4_0.rgb;
			o.Alpha = 1;
			clip( tex2DNode2.a - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=13901
7;29;1906;1004;1276;347;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;8;-611,290;Float;False;Property;_Gloss;Gloss;8;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;2;-924,236;Float;True;Property;_T_LowTest3_GMEO;T_LowTest3_GMEO;11;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.ColorNode;4;-585,414;Float;False;Property;_Color0;Color 0;7;0;0.7647059,0.6289047,0.1855536,0;0;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SamplerNode;1;-718,-274;Float;True;Property;_T_LowTest3_Albedo_Mask;T_LowTest3_Albedo_Mask;10;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-506,189;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-231,-80;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR
Node;AmplifyShaderEditor.RangedFloatNode;6;-248,113;Float;False;Property;_spec;spec;6;0;0;0;0;0;1;FLOAT
Node;AmplifyShaderEditor.SamplerNode;3;-698,4;Float;True;Property;_T_LowTest3_Normal1;T_LowTest3_Normal 1;12;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;FLOAT;FLOAT;FLOAT;FLOAT
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;StandardSpecular;Kowloon_Vegetation;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Masked;0.71;True;True;0;False;TransparentCutout;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;2;15;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;False;Cylindrical;False;Relative;0;;9;0;-1;-1;0;0;0;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;2;1
WireConnection;7;1;8;0
WireConnection;5;0;4;0
WireConnection;5;1;1;0
WireConnection;0;0;5;0
WireConnection;0;1;3;0
WireConnection;0;2;2;3
WireConnection;0;3;6;0
WireConnection;0;4;7;0
WireConnection;0;5;2;4
WireConnection;0;7;4;0
WireConnection;0;10;2;4
ASEEND*/
//CHKSM=D931ADC974E73244C316D1B43871BA6B4C4A2DAE