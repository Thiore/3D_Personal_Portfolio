Shader "Custom/Frost Standard World Projection" {
	Properties {
		_Color ("Tint All", Color) = (1,1,1,1)
		_Tint1 ("Texture 1 Tint", Color) = (1,1,1,1)
		_Tint2 ("Frost Tint", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MainTex2 ("Frost (RGB)", 2D) = "white" {}
		_FrostMainVariables ("Frost Vars", Vector) = (1,1,1,1)
		_FrostScale ("Frost Scale", Float) = 1
		_FrostNoiseVariables ("Frost Noise Vars", Vector) = (1,1,1,1)
		_WorldScale ("World Scale", Float) = 1
		_Blend ("Blend (RGB)", 2D) = "white" {}
		_Threshold ("blend threshold", Range(0, 1)) = 0
		_Threshold_Out ("Outer Threshold", Range(0, 1)) = 0
		_Threshold_In ("Inner Threshold", Range(0, 1)) = 0
		_Saturation ("Saturation", Range(0, 1)) = 0
		_MinY ("Low Height", Float) = 80
		_MaxY ("Top Height", Float) = 125
	}
	SubShader {
		LOD 200
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			GpuProgramID 18733
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
				float4 color : COLOR0;
				float4 texcoord5 : TEXCOORD5;
				float4 texcoord6 : TEXCOORD6;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float4 _Blend_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _FrostMainVariables;
			float4 _FrostNoiseVariables;
			float _FrostScale;
			float _WorldScale;
			float _MinY;
			float _MaxY;
			float4 _Color;
			float4 _Tint1;
			float4 _Tint2;
			float _Threshold;
			float _Threshold_Out;
			float _Threshold_In;
			float _Saturation;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _Blend;
			
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
                o.texcoord.zw = v.texcoord.xy * _Blend_ST.xy + _Blend_ST.zw;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord1.xyz = tmp0.www * tmp0.xyz;
                o.color = v.color;
                o.texcoord5 = float4(0.0, 0.0, 0.0, 0.0);
                o.texcoord6 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: DIRECTIONAL
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1 = inp.texcoord2.xzxz / float4(_FrostScale.xx, _WorldScale.xx);
                tmp1.xy = tmp1.xy + _FrostMainVariables.xy;
                tmp2 = tex2D(_MainTex2, tmp1.xy);
                tmp1.xy = tmp1.zw + _FrostNoiseVariables.xy;
                tmp0.w = _MaxY - _MinY;
                tmp1.z = inp.texcoord2.y - _MinY;
                tmp0.w = saturate(tmp1.z / tmp0.w);
                tmp1.xy = _FrostNoiseVariables.xy * tmp1.xy + _FrostNoiseVariables.zw;
                tmp1 = tex2D(_MainTex2, tmp1.xy);
                tmp3 = tex2D(_Blend, inp.texcoord.zw);
                tmp0.w = tmp1.y * tmp0.w + tmp2.x;
                tmp1.x = tmp0.w * 0.5 + -tmp3.x;
                tmp1.x = tmp1.x + 1.0;
                tmp1.y = inp.color.x * _Threshold_Out;
                tmp1.x = tmp1.x * _Threshold_In + tmp1.y;
                tmp1.x = saturate(tmp1.x - _Threshold);
                tmp1.yzw = tmp0.www * float3(0.5, 0.5, 0.5) + _Tint2.xyz;
                tmp1.yzw = tmp1.yzw * _Tint2.xyz;
                tmp1.xyz = tmp1.xxx * tmp1.yzw;
                tmp1.xyz = tmp1.xyz * _Color.xyz;
                tmp0.xyz = saturate(tmp0.xyz * _Tint1.xyz + tmp1.xyz);
                tmp0.w = dot(tmp0.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp1.x = 1.0 - _Saturation;
                tmp1.yzw = tmp0.www - tmp0.xyz;
                tmp0.xyz = tmp1.xxx * tmp1.yzw + tmp0.xyz;
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
                tmp1.xyz = tmp0.www * _LightColor0.xyz;
                tmp0.w = dot(inp.texcoord1.xyz, _WorldSpaceLightPos0.xyz);
                tmp0.w = max(tmp0.w, 0.0);
                tmp0.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.xyz = tmp0.www * tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDADD" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Blend One One, One One
			ZWrite Off
			GpuProgramID 127773
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
				float4 color : COLOR0;
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
			float4 _Blend_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _FrostMainVariables;
			float4 _FrostNoiseVariables;
			float _FrostScale;
			float _WorldScale;
			float _MinY;
			float _MaxY;
			float4 _Color;
			float4 _Tint1;
			float4 _Tint2;
			float _Threshold;
			float _Threshold_Out;
			float _Threshold_In;
			float _Saturation;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _Blend;
			sampler2D _LightTexture0;
			
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
                o.texcoord.zw = v.texcoord.xy * _Blend_ST.xy + _Blend_ST.zw;
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                o.texcoord1.xyz = tmp1.www * tmp1.xyz;
                o.texcoord2.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                o.color = v.color;
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
                float4 tmp4;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2 = inp.texcoord2.xzxz / float4(_FrostScale.xx, _WorldScale.xx);
                tmp2.xy = tmp2.xy + _FrostMainVariables.xy;
                tmp3 = tex2D(_MainTex2, tmp2.xy);
                tmp2.xy = tmp2.zw + _FrostNoiseVariables.xy;
                tmp0.w = _MaxY - _MinY;
                tmp1.w = inp.texcoord2.y - _MinY;
                tmp0.w = saturate(tmp1.w / tmp0.w);
                tmp2.xy = _FrostNoiseVariables.xy * tmp2.xy + _FrostNoiseVariables.zw;
                tmp2 = tex2D(_MainTex2, tmp2.xy);
                tmp4 = tex2D(_Blend, inp.texcoord.zw);
                tmp0.w = tmp2.y * tmp0.w + tmp3.x;
                tmp1.w = tmp0.w * 0.5 + -tmp4.x;
                tmp1.w = tmp1.w + 1.0;
                tmp2.x = inp.color.x * _Threshold_Out;
                tmp1.w = tmp1.w * _Threshold_In + tmp2.x;
                tmp1.w = saturate(tmp1.w - _Threshold);
                tmp2.xyz = tmp0.www * float3(0.5, 0.5, 0.5) + _Tint2.xyz;
                tmp2.xyz = tmp2.xyz * _Tint2.xyz;
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp2.xyz = tmp2.xyz * _Color.xyz;
                tmp1.xyz = saturate(tmp1.xyz * _Tint1.xyz + tmp2.xyz);
                tmp0.w = dot(tmp1.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp1.w = 1.0 - _Saturation;
                tmp2.xyz = tmp0.www - tmp1.xyz;
                tmp1.xyz = tmp1.www * tmp2.xyz + tmp1.xyz;
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
                tmp2.xyz = tmp0.www * _LightColor0.xyz;
                tmp0.x = dot(inp.texcoord1.xyz, tmp0.xyz);
                tmp0.x = max(tmp0.x, 0.0);
                tmp0.yzw = tmp1.xyz * tmp2.xyz;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "PREPASS"
			LOD 200
			Tags { "LIGHTMODE" = "PREPASSBASE" "RenderType" = "Opaque" }
			GpuProgramID 135372
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float3 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord1.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord.xyz = tmp0.www * tmp0.xyz;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                o.sv_target.xyz = inp.texcoord.xyz * float3(0.5, 0.5, 0.5) + float3(0.5, 0.5, 0.5);
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "PREPASS"
			LOD 200
			Tags { "LIGHTMODE" = "PREPASSFINAL" "RenderType" = "Opaque" }
			ZWrite Off
			GpuProgramID 199518
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float4 color : COLOR0;
				float4 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				float3 texcoord4 : TEXCOORD4;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float4 _Blend_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _FrostMainVariables;
			float4 _FrostNoiseVariables;
			float _FrostScale;
			float _WorldScale;
			float _MinY;
			float _MaxY;
			float4 _Color;
			float4 _Tint1;
			float4 _Tint2;
			float _Threshold;
			float _Threshold_Out;
			float _Threshold_In;
			float _Saturation;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _Blend;
			sampler2D _LightBuffer;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord1.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.position = tmp0;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _Blend_ST.xy + _Blend_ST.zw;
                o.color = v.color;
                tmp0.y = tmp0.y * _ProjectionParams.x;
                tmp1.xzw = tmp0.xwy * float3(0.5, 0.5, 0.5);
                o.texcoord2.zw = tmp0.zw;
                o.texcoord2.xy = tmp1.zz + tmp1.xw;
                o.texcoord3 = float4(0.0, 0.0, 0.0, 0.0);
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1.x = tmp0.y * tmp0.y;
                tmp1.x = tmp0.x * tmp0.x + -tmp1.x;
                tmp2 = tmp0.yzzx * tmp0.xyzz;
                tmp3.x = dot(unity_SHBr, tmp2);
                tmp3.y = dot(unity_SHBg, tmp2);
                tmp3.z = dot(unity_SHBb, tmp2);
                tmp1.xyz = unity_SHC.xyz * tmp1.xxx + tmp3.xyz;
                tmp0.w = 1.0;
                tmp2.x = dot(unity_SHAr, tmp0);
                tmp2.y = dot(unity_SHAg, tmp0);
                tmp2.z = dot(unity_SHAb, tmp0);
                o.texcoord4.xyz = tmp1.xyz + tmp2.xyz;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.x = _MaxY - _MinY;
                tmp0.y = inp.texcoord1.y - _MinY;
                tmp0.x = saturate(tmp0.y / tmp0.x);
                tmp1 = inp.texcoord1.xzxz / float4(_FrostScale.xx, _WorldScale.xx);
                tmp0.yz = tmp1.zw + _FrostNoiseVariables.xy;
                tmp1.xy = tmp1.xy + _FrostMainVariables.xy;
                tmp1 = tex2D(_MainTex2, tmp1.xy);
                tmp0.yz = _FrostNoiseVariables.xy * tmp0.yz + _FrostNoiseVariables.zw;
                tmp2 = tex2D(_MainTex2, tmp0.yz);
                tmp0.x = tmp2.y * tmp0.x + tmp1.x;
                tmp1 = tex2D(_Blend, inp.texcoord.zw);
                tmp0.y = tmp0.x * 0.5 + -tmp1.x;
                tmp0.xzw = tmp0.xxx * float3(0.5, 0.5, 0.5) + _Tint2.xyz;
                tmp0.xzw = tmp0.xzw * _Tint2.xyz;
                tmp0.y = tmp0.y + 1.0;
                tmp1.x = inp.color.x * _Threshold_Out;
                tmp0.y = tmp0.y * _Threshold_In + tmp1.x;
                tmp0.y = saturate(tmp0.y - _Threshold);
                tmp0.xyz = tmp0.yyy * tmp0.xzw;
                tmp0.xyz = tmp0.xyz * _Color.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.xyz = saturate(tmp1.xyz * _Tint1.xyz + tmp0.xyz);
                tmp0.w = dot(tmp0.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp1.xyz = tmp0.www - tmp0.xyz;
                tmp0.w = 1.0 - _Saturation;
                tmp0.xyz = tmp0.www * tmp1.xyz + tmp0.xyz;
                tmp1.xy = inp.texcoord2.xy / inp.texcoord2.ww;
                tmp1 = tex2D(_LightBuffer, tmp1.xy);
                tmp1.xyz = log(tmp1.xyz);
                tmp1.xyz = inp.texcoord4.xyz - tmp1.xyz;
                o.sv_target.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "DEFERRED"
			LOD 200
			Tags { "LIGHTMODE" = "DEFERRED" "RenderType" = "Opaque" }
			GpuProgramID 308497
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
				float4 color : COLOR0;
				float4 texcoord3 : TEXCOORD3;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
				float4 sv_target1 : SV_Target1;
				float4 sv_target2 : SV_Target2;
				float4 sv_target3 : SV_Target3;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float4 _Blend_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _FrostMainVariables;
			float4 _FrostNoiseVariables;
			float _FrostScale;
			float _WorldScale;
			float _MinY;
			float _MaxY;
			float4 _Color;
			float4 _Tint1;
			float4 _Tint2;
			float _Threshold;
			float _Threshold_Out;
			float _Threshold_In;
			float _Saturation;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _Blend;
			
			// Keywords: 
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
                o.texcoord.zw = v.texcoord.xy * _Blend_ST.xy + _Blend_ST.zw;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord1.xyz = tmp0.www * tmp0.xyz;
                o.color = v.color;
                o.texcoord3 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.x = _MaxY - _MinY;
                tmp0.y = inp.texcoord2.y - _MinY;
                tmp0.x = saturate(tmp0.y / tmp0.x);
                tmp1 = inp.texcoord2.xzxz / float4(_FrostScale.xx, _WorldScale.xx);
                tmp0.yz = tmp1.zw + _FrostNoiseVariables.xy;
                tmp1.xy = tmp1.xy + _FrostMainVariables.xy;
                tmp1 = tex2D(_MainTex2, tmp1.xy);
                tmp0.yz = _FrostNoiseVariables.xy * tmp0.yz + _FrostNoiseVariables.zw;
                tmp2 = tex2D(_MainTex2, tmp0.yz);
                tmp0.x = tmp2.y * tmp0.x + tmp1.x;
                tmp1 = tex2D(_Blend, inp.texcoord.zw);
                tmp0.y = tmp0.x * 0.5 + -tmp1.x;
                tmp0.xzw = tmp0.xxx * float3(0.5, 0.5, 0.5) + _Tint2.xyz;
                tmp0.xzw = tmp0.xzw * _Tint2.xyz;
                tmp0.y = tmp0.y + 1.0;
                tmp1.x = inp.color.x * _Threshold_Out;
                tmp0.y = tmp0.y * _Threshold_In + tmp1.x;
                tmp0.y = saturate(tmp0.y - _Threshold);
                tmp0.xyz = tmp0.yyy * tmp0.xzw;
                tmp0.xyz = tmp0.xyz * _Color.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.xyz = saturate(tmp1.xyz * _Tint1.xyz + tmp0.xyz);
                tmp0.w = dot(tmp0.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp1.xyz = tmp0.www - tmp0.xyz;
                tmp0.w = 1.0 - _Saturation;
                o.sv_target.xyz = tmp0.www * tmp1.xyz + tmp0.xyz;
                o.sv_target.w = 1.0;
                o.sv_target1 = float4(0.0, 0.0, 0.0, 0.0);
                o.sv_target2.xyz = inp.texcoord1.xyz * float3(0.5, 0.5, 0.5) + float3(0.5, 0.5, 0.5);
                o.sv_target2.w = 1.0;
                o.sv_target3 = float4(1.0, 1.0, 1.0, 1.0);
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}