// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "cloud_shader_test"
{
	Properties
	{
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 6.5
		_T_clouds_test_02("T_clouds_test_02", 2D) = "white" {}
		_T_clouds_test_01("T_clouds_test_01", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _T_clouds_test_01;
		uniform float4 _T_clouds_test_01_ST;
		uniform sampler2D _T_clouds_test_02;
		uniform float _TessValue;

		float4 tessFunction( )
		{
			return _TessValue;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_T_clouds_test_01 = v.texcoord * _T_clouds_test_01_ST.xy + _T_clouds_test_01_ST.zw;
			float2 panner3 = ( 1.0 * _Time.y * float2( 0.001,-0.001 ) + v.texcoord.xy);
			float blendOpSrc8 = tex2Dlod( _T_clouds_test_01, float4( uv_T_clouds_test_01, 0, 0.0) ).r;
			float blendOpDest8 = tex2Dlod( _T_clouds_test_02, float4( panner3, 0, 0.0) ).r;
			float temp_output_8_0 = ( saturate( ( blendOpDest8 - blendOpSrc8 ) ));
			float3 temp_cast_0 = (( temp_output_8_0 * 0.1 )).xxx;
			v.vertex.xyz += temp_cast_0;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float temp_output_19_0 = 0.0;
			o.Metallic = temp_output_19_0;
			o.Smoothness = temp_output_19_0;
			float2 uv_T_clouds_test_01 = i.uv_texcoord * _T_clouds_test_01_ST.xy + _T_clouds_test_01_ST.zw;
			float2 panner3 = ( 1.0 * _Time.y * float2( 0.001,-0.001 ) + i.uv_texcoord);
			float blendOpSrc8 = tex2D( _T_clouds_test_01, uv_T_clouds_test_01 ).r;
			float blendOpDest8 = tex2D( _T_clouds_test_02, panner3 ).r;
			float temp_output_8_0 = ( saturate( ( blendOpDest8 - blendOpSrc8 ) ));
			o.Alpha = temp_output_8_0;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc tessellate:tessFunction 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
-1908;37;1906;1010;1138.585;1261.384;1.3;False;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1080.925,-566.4374;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;4;-999.1299,-380.3568;Float;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;False;0;0.001,-0.001;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;3;-748.1299,-476.3568;Float;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,0.02;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-528.9645,-523.3646;Float;True;Property;_T_clouds_test_02;T_clouds_test_02;5;0;Create;True;0;0;False;0;eeafaa6ac08cacd44b0cfe1cd17795fb;eeafaa6ac08cacd44b0cfe1cd17795fb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-507.9645,-325.3646;Float;True;Property;_T_clouds_test_01;T_clouds_test_01;6;0;Create;True;0;0;False;0;3dbf6f3fec5eff948b7218bd2333730e;3dbf6f3fec5eff948b7218bd2333730e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;8;-185.7801,-466.6564;Float;True;Subtract;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;31.72205,-88.49078;Float;False;Constant;_Float1;Float 1;3;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;199.722,-162.4908;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;197.2886,-481.7799;Float;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;469.786,-573.5468;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;cloud_shader_test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;1;6.5;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;7;0
WireConnection;3;2;4;0
WireConnection;5;1;3;0
WireConnection;8;0;6;1
WireConnection;8;1;5;1
WireConnection;13;0;8;0
WireConnection;13;1;14;0
WireConnection;0;3;19;0
WireConnection;0;4;19;0
WireConnection;0;9;8;0
WireConnection;0;11;13;0
ASEEND*/
//CHKSM=D9D631044C7D7318EE949CA4DA2BAB2B93CDCCE6