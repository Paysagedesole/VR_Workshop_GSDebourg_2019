// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Collety_Transparent"
{
	Properties
	{
		_Albedo_mask("Albedo_mask", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Gloss_Metallic_Emissive_Opacity("Gloss_Metallic_Emissive_Opacity", 2D) = "white" {}
		_GlossMultiplier("Gloss Multiplier", Float) = 0
		[Toggle(_INVERT_ON)] _Invert("Invert", Float) = 0
		_Fresnel_Color("Fresnel_Color", Color) = (1,0,0,0)
		_Emissivecolor("Emissive color", Color) = (0,0,0,0)
		_Emissiveintensity("Emissive intensity", Float) = 0
		[Toggle(_COLORMASK_ON)] _ColorMask("Color Mask", Float) = 0
		_ColorMasked("Color Masked", Color) = (0,0,0,0)
		_TransparenceStrength("Transparence Strength", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _COLORMASK_ON
		#pragma shader_feature _INVERT_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputStandardCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _Fresnel_Color;
		uniform sampler2D _Albedo_mask;
		uniform float4 _Albedo_mask_ST;
		uniform float4 _ColorMasked;
		uniform sampler2D _Gloss_Metallic_Emissive_Opacity;
		uniform float4 _Gloss_Metallic_Emissive_Opacity_ST;
		uniform float4 _Emissivecolor;
		uniform float _Emissiveintensity;
		uniform float _GlossMultiplier;
		uniform float _TransparenceStrength;

		inline half4 LightingStandardCustom(SurfaceOutputStandardCustom s, half3 viewDir, UnityGI gi )
		{
			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandard r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Metallic = s.Metallic;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandard (r, viewDir, gi) + d;
		}

		inline void LightingStandardCustom_GI(SurfaceOutputStandardCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardCustom o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV93 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode93 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV93, 5.0 ) );
			float4 temp_cast_0 = (fresnelNode93).xxxx;
			float4 blendOpSrc99 = _Fresnel_Color;
			float4 blendOpDest99 = temp_cast_0;
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
			o.Albedo = ( ( saturate( (( blendOpDest99 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest99 - 0.5 ) ) * ( 1.0 - blendOpSrc99 ) ) : ( 2.0 * blendOpDest99 * blendOpSrc99 ) ) )) + lerpResult81 ).rgb;
			float2 uv_Gloss_Metallic_Emissive_Opacity = i.uv_texcoord * _Gloss_Metallic_Emissive_Opacity_ST.xy + _Gloss_Metallic_Emissive_Opacity_ST.zw;
			float4 tex2DNode63 = tex2D( _Gloss_Metallic_Emissive_Opacity, uv_Gloss_Metallic_Emissive_Opacity );
			o.Emission = ( ( tex2DNode63.b * _Emissivecolor ) * _Emissiveintensity ).rgb;
			o.Metallic = tex2DNode63.g;
			#ifdef _INVERT_ON
				float staticSwitch73 = ( 1.0 - tex2DNode63.r );
			#else
				float staticSwitch73 = tex2DNode63.r;
			#endif
			float clampResult70 = clamp( ( staticSwitch73 * _GlossMultiplier ) , 0.0 , 1.0 );
			o.Smoothness = clampResult70;
			float3 temp_cast_5 = (( 1.0 - tex2DNode78.r )).xxx;
			o.Transmission = temp_cast_5;
			float clampResult92 = clamp( ( tex2DNode63.a + _TransparenceStrength ) , 0.0 , 1.0 );
			o.Alpha = clampResult92;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustom alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandardCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardCustom, o )
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
-1904;73;1810;964;1584.289;578.9635;1.175;True;True
Node;AmplifyShaderEditor.SamplerNode;63;-2472.705,431.7691;Float;True;Property;_Gloss_Metallic_Emissive_Opacity;Gloss_Metallic_Emissive_Opacity;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;78;-2551.791,-711.4877;Float;True;Property;_Albedo_mask;Albedo_mask;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;80;-1701.238,-268.337;Float;False;Constant;_no;no;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;83;-1681.132,-895.2562;Float;False;Property;_ColorMasked;Color Masked;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;57;-1600.361,-598.8113;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;72;-1636.137,91.63264;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1538.083,558.9037;Float;False;Property;_TransparenceStrength;Transparence Strength;10;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;85;-1285.441,-821.5224;Float;False;Overlay;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;73;-1420.336,82.53265;Float;False;Property;_Invert;Invert;4;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1528.237,208.6327;Float;False;Property;_GlossMultiplier;Gloss Multiplier;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;94;-2353.419,-1285.927;Float;False;Property;_Fresnel_Color;Fresnel_Color;5;0;Create;True;0;0;False;0;1,0,0,0;1,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;75;-1534.051,918.8839;Float;False;Property;_Emissivecolor;Emissive color;6;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;79;-1418.064,-288.5636;Float;False;Property;_ColorMask;Color Mask;8;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;93;-2364.776,-1077.099;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-1242.851,805.7833;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;99;-1788.298,-1148.814;Float;False;Overlay;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1182.436,85.13264;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1147.855,413.1673;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;81;-1145.354,-544.1035;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-1237.65,934.4838;Float;False;Property;_Emissiveintensity;Emissive intensity;7;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;92;-923.4776,397.0191;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;66;-2447.56,-0.536303;Float;True;Property;_Normal;Normal;1;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;100;-840.3663,-216.8633;Float;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;103;-871.5911,-96.05434;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;70;-1009.537,82.53268;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-1328.311,-656.0955;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-939.8162,-944.3486;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-1003.65,852.5833;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-35.19997,24.00001;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Collety_Transparent;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.34;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;57;0;78;1
WireConnection;57;1;78;2
WireConnection;57;2;78;3
WireConnection;72;0;63;1
WireConnection;85;0;83;0
WireConnection;85;1;57;0
WireConnection;73;1;63;1
WireConnection;73;0;72;0
WireConnection;79;1;80;0
WireConnection;79;0;78;4
WireConnection;74;0;63;3
WireConnection;74;1;75;0
WireConnection;99;0;94;0
WireConnection;99;1;93;0
WireConnection;67;0;73;0
WireConnection;67;1;69;0
WireConnection;90;0;63;4
WireConnection;90;1;89;0
WireConnection;81;0;57;0
WireConnection;81;1;85;0
WireConnection;81;2;79;0
WireConnection;92;0;90;0
WireConnection;103;0;78;1
WireConnection;70;0;67;0
WireConnection;84;0;83;0
WireConnection;84;1;57;0
WireConnection;97;0;99;0
WireConnection;97;1;81;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;0;0;97;0
WireConnection;0;1;66;0
WireConnection;0;2;76;0
WireConnection;0;3;63;2
WireConnection;0;4;70;0
WireConnection;0;6;103;0
WireConnection;0;9;92;0
ASEEND*/
//CHKSM=7A186D962BD9CEBD9B98FED9FB333A41D9ACA55C