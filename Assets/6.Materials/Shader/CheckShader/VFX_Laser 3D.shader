Shader "VFX/Laser 3D" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_ColorBase ("Base/Under Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NoiseTex ("Noise Decay", 2D) = "white" {}
		_NewLightDir ("Light Dir", Vector) = (0,0,0,0)
		_Alpha ("Alpha Amount", Range(0, 1)) = 0
		_Glow ("Glow Amount", Range(1, 4)) = 1
		_VertexOffset ("Vertex Offset", Float) = 1
		_Speed ("Speed", Float) = 1
		_NoiseOffset ("Noise Offset", Vector) = (0,0,0,0)
		_NoiseScale ("Noise Scale", Float) = 1
	}
	SubShader {
		LOD 200
		Tags { "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			ZWrite Off
			GpuProgramID 45830
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float3 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float4 color : COLOR0;
				float3 texcoord2 : TEXCOORD2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float _VertexOffset;
			float _Speed;
			float _NoiseScale;
			float2 _NoiseOffset;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Color;
			float4 _ColorBase;
			float _Alpha;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _NoiseTex;
			sampler2D _MainTex;
			// Texture params for Fragment Shader
			
			// Keywords: DIRECTIONAL
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.xy = _Speed.xx * _Time.yx;
                tmp1.xy = v.texcoord.xy * _NoiseOffset;
                tmp0.y = tmp0.y * 0.1 + tmp1.y;
                tmp1.w = v.texcoord.y * _NoiseOffset.y + tmp0.x;
                tmp1.y = tmp0.y + 0.02;
                tmp1.z = v.texcoord.w;
                tmp0.xyz = tmp1.xwz * _NoiseScale.xxx;
                tmp0 = tex2Dlod(_NoiseTex, float4(tmp0.xy, 0, tmp0.z));
                tmp0.yzw = tmp1.xyz * _NoiseScale.xxx;
                tmp1 = tex2Dlod(_MainTex, float4(tmp0.yz, 0, tmp0.w));
                tmp0.x = tmp0.x + tmp1.x;
                tmp0.yz = tmp0.xx * v.normal.xy;
                o.color.w = tmp0.x * tmp0.x;
                tmp0.xy = tmp0.yz * _VertexOffset.xx;
                tmp0.zw = float2(0.0, 0.0);
                tmp0 = tmp0 + v.vertex;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.texcoord1.xyz = unity_ObjectToWorld._m03_m13_m23 * tmp0.www + tmp1.xyz;
                tmp0 = tmp1 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord.xyz = tmp0.www * tmp0.xyz;
                o.color.xyz = v.color.xyz;
                o.texcoord2.xyz = float3(0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: DIRECTIONAL
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                tmp0.xyz = _Color.xyz * _Glow.xxx + -_ColorBase.xyz;
                tmp0.xyz = inp.color.www * tmp0.xyz + _ColorBase.xyz;
                o.sv_target.xyz = tmp0.xyz * inp.texcoord2.xyz + tmp0.xyz;
                o.sv_target.w = _Alpha;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDADD" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend SrcAlpha One, SrcAlpha One
			ColorMask RGB
			ZWrite Off
			GpuProgramID 74878
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float3 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float4 color : COLOR0;
				float3 texcoord2 : TEXCOORD2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float _VertexOffset;
			float _Speed;
			float _NoiseScale;
			float2 _NoiseOffset;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Color;
			float4 _ColorBase;
			float _Alpha;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _NoiseTex;
			sampler2D _MainTex;
			// Texture params for Fragment Shader
			
			// Keywords: POINT
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0.xy = _Speed.xx * _Time.yx;
                tmp1.xy = v.texcoord.xy * _NoiseOffset;
                tmp0.y = tmp0.y * 0.1 + tmp1.y;
                tmp1.w = v.texcoord.y * _NoiseOffset.y + tmp0.x;
                tmp1.y = tmp0.y + 0.02;
                tmp1.z = v.texcoord.w;
                tmp0.xyz = tmp1.xwz * _NoiseScale.xxx;
                tmp0 = tex2Dlod(_NoiseTex, float4(tmp0.xy, 0, tmp0.z));
                tmp0.yzw = tmp1.xyz * _NoiseScale.xxx;
                tmp1 = tex2Dlod(_MainTex, float4(tmp0.yz, 0, tmp0.w));
                tmp0.x = tmp0.x + tmp1.x;
                tmp0.yz = tmp0.xx * v.normal.xy;
                o.color.w = tmp0.x * tmp0.x;
                tmp0.xy = tmp0.yz * _VertexOffset.xx;
                tmp0.zw = float2(0.0, 0.0);
                tmp0 = tmp0 + v.vertex;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp2 = tmp1 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp3 = tmp2.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp3 = unity_MatrixVP._m00_m10_m20_m30 * tmp2.xxxx + tmp3;
                tmp3 = unity_MatrixVP._m02_m12_m22_m32 * tmp2.zzzz + tmp3;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp2.wwww + tmp3;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp2.x = dot(tmp0.xyz, tmp0.xyz);
                tmp2.x = rsqrt(tmp2.x);
                o.texcoord.xyz = tmp0.xyz * tmp2.xxx;
                o.texcoord1.xyz = unity_ObjectToWorld._m03_m13_m23 * tmp0.www + tmp1.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.color.xyz = v.color.xyz;
                tmp1.xyz = tmp0.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToLight._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                o.texcoord2.xyz = unity_WorldToLight._m03_m13_m23 * tmp0.www + tmp0.xyz;
                return o;
			}
			// Keywords: POINT
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                tmp0.xyz = _Color.xyz * _Glow.xxx + -_ColorBase.xyz;
                o.sv_target.xyz = inp.color.www * tmp0.xyz + _ColorBase.xyz;
                o.sv_target.w = _Alpha;
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}