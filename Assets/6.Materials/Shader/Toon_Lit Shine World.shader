Shader "Toon/Lit Shine World" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_Noise ("Shine (RGB)", 2D) = "white" {}
		[PropertyBlock] _ShineOffset ("Shine Offset", Float) = 0
		[PropertyBlock] _SourcePoint ("Source Pos", Vector) = (0,0,0,0)
		_ShineColor ("Shine Color", Color) = (0.5,0.5,0.5,1)
		_ShineGlow ("Shine Glow", Range(1, 10)) = 1
		_MaxDist ("Max Dist", Float) = 0
		_MinDist ("Min Dist", Float) = 0
	}
	SubShader {
		LOD 200
		Tags { "QUEUE" = "Geometry" "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Geometry" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Cull Off
			GpuProgramID 31435
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float4 texcoord5 : TEXCOORD5;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float4 _Noise_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float4 _ShineColor;
			float _ShineOffset;
			float _ShineGlow;
			float3 _SourcePoint;
			float _MaxDist;
			float _MinDist;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _Noise;
			sampler2D _Ramp;
			
			// Keywords: DIRECTIONAL
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord2.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord1.xyz = tmp0.www * tmp0.xyz;
                o.texcoord3.xyz = float3(0.0, 0.0, 0.0);
                o.texcoord5 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: DIRECTIONAL
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1 = tex2D(_Noise, inp.texcoord.zw);
                tmp0.w = inp.texcoord2.y - _SourcePoint.y;
                tmp0.w = tmp1.x + tmp0.w;
                tmp0.w = tmp0.w - _ShineOffset;
                tmp1.x = _MinDist < tmp0.w;
                tmp0.w = tmp0.w < _MaxDist;
                tmp0.w = tmp0.w ? tmp1.x : 0.0;
                tmp1.xyz = _ShineColor.xyz * _ShineGlow.xxx;
                tmp1.xyz = tmp0.www ? tmp1.xyz : 0.0;
                tmp0.xyz = tmp0.xyz * _Color.xyz + tmp1.xyz;
                tmp0.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp0.w) {
                    tmp0.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp1.xyz = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp1.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp1.xyz;
                    tmp1.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp1.xyz;
                    tmp1.xyz = tmp1.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp1.xyz = tmp0.www ? tmp1.xyz : inp.texcoord2.xyz;
                    tmp1.xyz = tmp1.xyz - unity_ProbeVolumeMin;
                    tmp1.yzw = tmp1.xyz * unity_ProbeVolumeSizeInv;
                    tmp0.w = tmp1.y * 0.25 + 0.75;
                    tmp1.y = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp1.x = max(tmp0.w, tmp1.y);
                    tmp1 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp1.xzw);
                } else {
                    tmp1 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp0.w = saturate(dot(tmp1, unity_OcclusionMaskSelector));
                tmp1.x = dot(inp.texcoord1.xyz, _WorldSpaceLightPos0.xyz);
                tmp1.x = tmp1.x * 0.5 + 0.5;
                tmp1 = tex2D(_Ramp, tmp1.xx);
                tmp2.xyz = tmp0.xyz * _LightColor0.xyz;
                tmp1.xyz = tmp1.xyz * tmp2.xyz;
                tmp1.xyz = tmp0.www * tmp1.xyz;
                o.sv_target.xyz = tmp0.xyz * inp.texcoord3.xyz + tmp1.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDADD" "QUEUE" = "Geometry" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Blend One One, One One
			ZWrite Off
			Cull Off
			GpuProgramID 65716
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float4 texcoord4 : TEXCOORD4;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float4 _MainTex_ST;
			float4 _Noise_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float4 _ShineColor;
			float _ShineOffset;
			float _ShineGlow;
			float3 _SourcePoint;
			float _MaxDist;
			float _MinDist;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _Noise;
			sampler2D _LightTexture0;
			sampler2D _Ramp;
			
			// Keywords: POINT
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp2 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp2;
                tmp2 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp2;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp2;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                o.texcoord1.xyz = tmp1.www * tmp1.xyz;
                o.texcoord2.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp1.xyz = tmp0.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToLight._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                o.texcoord3.xyz = unity_WorldToLight._m03_m13_m23 * tmp0.www + tmp0.xyz;
                o.texcoord4 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: POINT
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2 = tex2D(_Noise, inp.texcoord.zw);
                tmp0.w = inp.texcoord2.y - _SourcePoint.y;
                tmp0.w = tmp2.x + tmp0.w;
                tmp0.w = tmp0.w - _ShineOffset;
                tmp1.w = _MinDist < tmp0.w;
                tmp0.w = tmp0.w < _MaxDist;
                tmp0.w = tmp0.w ? tmp1.w : 0.0;
                tmp2.xyz = _ShineColor.xyz * _ShineGlow.xxx;
                tmp2.xyz = tmp0.www ? tmp2.xyz : 0.0;
                tmp1.xyz = tmp1.xyz * _Color.xyz + tmp2.xyz;
                tmp2.xyz = inp.texcoord2.yyy * unity_WorldToLight._m01_m11_m21;
                tmp2.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord2.xxx + tmp2.xyz;
                tmp2.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord2.zzz + tmp2.xyz;
                tmp2.xyz = tmp2.xyz + unity_WorldToLight._m03_m13_m23;
                tmp0.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp0.w) {
                    tmp0.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp3.xyz = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp3.xyz;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp3.xyz;
                    tmp3.xyz = tmp3.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp3.xyz = tmp0.www ? tmp3.xyz : inp.texcoord2.xyz;
                    tmp3.xyz = tmp3.xyz - unity_ProbeVolumeMin;
                    tmp3.yzw = tmp3.xyz * unity_ProbeVolumeSizeInv;
                    tmp0.w = tmp3.y * 0.25 + 0.75;
                    tmp1.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp3.x = max(tmp0.w, tmp1.w);
                    tmp3 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp3.xzw);
                } else {
                    tmp3 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp0.w = saturate(dot(tmp3, unity_OcclusionMaskSelector));
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2 = tex2D(_LightTexture0, tmp1.ww);
                tmp0.w = tmp0.w * tmp2.x;
                tmp0.x = dot(inp.texcoord1.xyz, tmp0.xyz);
                tmp0.x = tmp0.x * 0.5 + 0.5;
                tmp2 = tex2D(_Ramp, tmp0.xx);
                tmp0.xyz = tmp1.xyz * _LightColor0.xyz;
                tmp0.xyz = tmp2.xyz * tmp0.xyz;
                o.sv_target.xyz = tmp0.www * tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}