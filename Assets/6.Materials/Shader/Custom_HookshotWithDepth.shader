Shader "Custom/HookshotWithDepth" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_GlowColor ("Glow Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glow ("Glow", Float) = 1
	}
	SubShader {
		LOD 200
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			GpuProgramID 19601
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float4 texcoord5 : TEXCOORD5;
				float4 texcoord6 : TEXCOORD6;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Glow;
			float4 _Color;
			float4 _GlowColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
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
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord1.xyz = tmp0.www * tmp0.xyz;
                o.texcoord3.xyz = v.color.xyz;
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
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                float4 tmp7;
                float4 tmp8;
                float4 tmp9;
                tmp0.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.w = tmp2.w * _Color.w + -0.5;
                tmp1.w = tmp1.w < 0.0;
                if (tmp1.w) {
                    discard;
                }
                tmp1.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp1.w) {
                    tmp1.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp2.xyz = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp2.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp2.xyz;
                    tmp2.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp2.xyz;
                    tmp2.xyz = tmp2.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp2.xyz = tmp1.www ? tmp2.xyz : inp.texcoord2.xyz;
                    tmp2.xyz = tmp2.xyz - unity_ProbeVolumeMin;
                    tmp2.yzw = tmp2.xyz * unity_ProbeVolumeSizeInv;
                    tmp1.w = tmp2.y * 0.25 + 0.75;
                    tmp2.y = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp2.x = max(tmp1.w, tmp2.y);
                    tmp2 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp2.xzw);
                } else {
                    tmp2 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp1.w = saturate(dot(tmp2, unity_OcclusionMaskSelector));
                tmp2.x = dot(-tmp1.xyz, inp.texcoord1.xyz);
                tmp2.x = tmp2.x + tmp2.x;
                tmp2.xyz = inp.texcoord1.xyz * -tmp2.xxx + -tmp1.xyz;
                tmp3.xyz = tmp1.www * _LightColor0.xyz;
                tmp1.w = unity_SpecCube0_ProbePosition.w > 0.0;
                if (tmp1.w) {
                    tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                    tmp1.w = rsqrt(tmp1.w);
                    tmp4.xyz = tmp1.www * tmp2.xyz;
                    tmp5.xyz = unity_SpecCube0_BoxMax.xyz - inp.texcoord2.xyz;
                    tmp5.xyz = tmp5.xyz / tmp4.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMin.xyz - inp.texcoord2.xyz;
                    tmp6.xyz = tmp6.xyz / tmp4.xyz;
                    tmp7.xyz = tmp4.xyz > float3(0.0, 0.0, 0.0);
                    tmp5.xyz = tmp7.xyz ? tmp5.xyz : tmp6.xyz;
                    tmp1.w = min(tmp5.y, tmp5.x);
                    tmp1.w = min(tmp5.z, tmp1.w);
                    tmp5.xyz = inp.texcoord2.xyz - unity_SpecCube0_ProbePosition.xyz;
                    tmp4.xyz = tmp4.xyz * tmp1.www + tmp5.xyz;
                } else {
                    tmp4.xyz = tmp2.xyz;
                }
                tmp4 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp4.xyz, 6.0));
                tmp1.w = tmp4.w - 1.0;
                tmp1.w = unity_SpecCube0_HDR.w * tmp1.w + 1.0;
                tmp1.w = log(tmp1.w);
                tmp1.w = tmp1.w * unity_SpecCube0_HDR.y;
                tmp1.w = exp(tmp1.w);
                tmp1.w = tmp1.w * unity_SpecCube0_HDR.x;
                tmp5.xyz = tmp4.xyz * tmp1.www;
                tmp2.w = unity_SpecCube0_BoxMin.w < 0.99999;
                if (tmp2.w) {
                    tmp2.w = unity_SpecCube1_ProbePosition.w > 0.0;
                    if (tmp2.w) {
                        tmp2.w = dot(tmp2.xyz, tmp2.xyz);
                        tmp2.w = rsqrt(tmp2.w);
                        tmp6.xyz = tmp2.www * tmp2.xyz;
                        tmp7.xyz = unity_SpecCube1_BoxMax.xyz - inp.texcoord2.xyz;
                        tmp7.xyz = tmp7.xyz / tmp6.xyz;
                        tmp8.xyz = unity_SpecCube1_BoxMin.xyz - inp.texcoord2.xyz;
                        tmp8.xyz = tmp8.xyz / tmp6.xyz;
                        tmp9.xyz = tmp6.xyz > float3(0.0, 0.0, 0.0);
                        tmp7.xyz = tmp9.xyz ? tmp7.xyz : tmp8.xyz;
                        tmp2.w = min(tmp7.y, tmp7.x);
                        tmp2.w = min(tmp7.z, tmp2.w);
                        tmp7.xyz = inp.texcoord2.xyz - unity_SpecCube1_ProbePosition.xyz;
                        tmp2.xyz = tmp6.xyz * tmp2.www + tmp7.xyz;
                    }
                    tmp2 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp2.xyz, 6.0));
                    tmp2.w = tmp2.w - 1.0;
                    tmp2.w = unity_SpecCube1_HDR.w * tmp2.w + 1.0;
                    tmp2.w = log(tmp2.w);
                    tmp2.w = tmp2.w * unity_SpecCube1_HDR.y;
                    tmp2.w = exp(tmp2.w);
                    tmp2.w = tmp2.w * unity_SpecCube1_HDR.x;
                    tmp2.xyz = tmp2.xyz * tmp2.www;
                    tmp4.xyz = tmp1.www * tmp4.xyz + -tmp2.xyz;
                    tmp5.xyz = unity_SpecCube0_BoxMin.www * tmp4.xyz + tmp2.xyz;
                }
                tmp1.w = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * inp.texcoord1.xyz;
                tmp4.xyz = inp.texcoord3.xyz * float3(0.96, 0.96, 0.96);
                tmp0.xyz = tmp0.xyz * tmp0.www + _WorldSpaceLightPos0.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp2.xyz, tmp1.xyz);
                tmp1.x = saturate(dot(tmp2.xyz, _WorldSpaceLightPos0.xyz));
                tmp0.x = saturate(dot(_WorldSpaceLightPos0.xyz, tmp0.xyz));
                tmp0.y = dot(tmp0.xy, tmp0.xy);
                tmp0.y = tmp0.y - 0.5;
                tmp0.z = 1.0 - tmp1.x;
                tmp1.y = tmp0.z * tmp0.z;
                tmp1.y = tmp1.y * tmp1.y;
                tmp0.z = tmp0.z * tmp1.y;
                tmp0.z = tmp0.y * tmp0.z + 1.0;
                tmp1.y = 1.0 - abs(tmp0.w);
                tmp1.z = tmp1.y * tmp1.y;
                tmp1.z = tmp1.z * tmp1.z;
                tmp1.y = tmp1.y * tmp1.z;
                tmp0.y = tmp0.y * tmp1.y + 1.0;
                tmp0.y = tmp0.y * tmp0.z;
                tmp0.z = abs(tmp0.w) + tmp1.x;
                tmp0.z = tmp0.z + 0.00001;
                tmp0.z = 0.5 / tmp0.z;
                tmp0.z = tmp0.z * 0.9999999;
                tmp0.yz = tmp1.xx * tmp0.yz;
                tmp1.xzw = tmp0.yyy * tmp3.xyz;
                tmp0.yzw = tmp3.xyz * tmp0.zzz;
                tmp0.x = 1.0 - tmp0.x;
                tmp2.x = tmp0.x * tmp0.x;
                tmp2.x = tmp2.x * tmp2.x;
                tmp0.x = tmp0.x * tmp2.x;
                tmp0.x = tmp0.x * 0.96 + 0.04;
                tmp0.xyz = tmp0.xxx * tmp0.yzw;
                tmp0.xyz = tmp4.xyz * tmp1.xzw + tmp0.xyz;
                tmp1.xzw = tmp5.xyz * float3(0.5, 0.5, 0.5);
                tmp0.w = tmp1.y * 0.0 + 0.04;
                tmp0.xyz = tmp1.xzw * tmp0.www + tmp0.xyz;
                o.sv_target.xyz = _GlowColor.xyz * _Glow.xxx + tmp0.xyz;
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
			GpuProgramID 66438
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float3 texcoord4 : TEXCOORD4;
				float4 texcoord5 : TEXCOORD5;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Glow;
			float4 _Color;
			float4 _GlowColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
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
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                o.texcoord1.xyz = tmp1.www * tmp1.xyz;
                o.texcoord2.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                o.texcoord3.xyz = v.color.xyz;
                tmp1.xyz = tmp0.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToLight._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                o.texcoord4.xyz = unity_WorldToLight._m03_m13_m23 * tmp0.www + tmp0.xyz;
                o.texcoord5 = float4(0.0, 0.0, 0.0, 0.0);
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
                float4 tmp5;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp3 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.w = tmp3.w * _Color.w + -0.5;
                tmp1.w = tmp1.w < 0.0;
                if (tmp1.w) {
                    discard;
                }
                tmp3.xyz = inp.texcoord2.yyy * unity_WorldToLight._m01_m11_m21;
                tmp3.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord2.xxx + tmp3.xyz;
                tmp3.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord2.zzz + tmp3.xyz;
                tmp3.xyz = tmp3.xyz + unity_WorldToLight._m03_m13_m23;
                tmp1.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp1.w) {
                    tmp1.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp4.xyz = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp4.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp4.xyz;
                    tmp4.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp4.xyz;
                    tmp4.xyz = tmp4.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp4.xyz = tmp1.www ? tmp4.xyz : inp.texcoord2.xyz;
                    tmp4.xyz = tmp4.xyz - unity_ProbeVolumeMin;
                    tmp4.yzw = tmp4.xyz * unity_ProbeVolumeSizeInv;
                    tmp1.w = tmp4.y * 0.25 + 0.75;
                    tmp2.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp4.x = max(tmp1.w, tmp2.w);
                    tmp4 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp4.xzw);
                } else {
                    tmp4 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp1.w = saturate(dot(tmp4, unity_OcclusionMaskSelector));
                tmp2.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3 = tex2D(_LightTexture0, tmp2.ww);
                tmp1.w = tmp1.w * tmp3.x;
                tmp3.xyz = tmp1.www * _LightColor0.xyz;
                tmp1.w = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp4.xyz = tmp1.www * inp.texcoord1.xyz;
                tmp5.xyz = inp.texcoord3.xyz * float3(0.96, 0.96, 0.96);
                tmp0.xyz = tmp0.xyz * tmp0.www + tmp2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp4.xyz, tmp2.xyz);
                tmp1.w = saturate(dot(tmp4.xyz, tmp1.xyz));
                tmp0.x = saturate(dot(tmp1.xyz, tmp0.xyz));
                tmp0.y = dot(tmp0.xy, tmp0.xy);
                tmp0.y = tmp0.y - 0.5;
                tmp0.z = 1.0 - tmp1.w;
                tmp1.x = tmp0.z * tmp0.z;
                tmp1.x = tmp1.x * tmp1.x;
                tmp0.z = tmp0.z * tmp1.x;
                tmp0.z = tmp0.y * tmp0.z + 1.0;
                tmp1.x = 1.0 - abs(tmp0.w);
                tmp1.y = tmp1.x * tmp1.x;
                tmp1.y = tmp1.y * tmp1.y;
                tmp1.x = tmp1.x * tmp1.y;
                tmp0.y = tmp0.y * tmp1.x + 1.0;
                tmp0.y = tmp0.y * tmp0.z;
                tmp0.z = abs(tmp0.w) + tmp1.w;
                tmp0.z = tmp0.z + 0.00001;
                tmp0.z = 0.5 / tmp0.z;
                tmp0.z = tmp0.z * 0.9999999;
                tmp0.yz = tmp1.ww * tmp0.yz;
                tmp1.xyz = tmp0.yyy * tmp3.xyz;
                tmp0.yzw = tmp3.xyz * tmp0.zzz;
                tmp0.x = 1.0 - tmp0.x;
                tmp1.w = tmp0.x * tmp0.x;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.x = tmp0.x * tmp1.w;
                tmp0.x = tmp0.x * 0.96 + 0.04;
                tmp0.xyz = tmp0.xxx * tmp0.yzw;
                tmp0.xyz = tmp5.xyz * tmp1.xyz + tmp0.xyz;
                o.sv_target.xyz = _GlowColor.xyz * _Glow.xxx + tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "DEFERRED"
			LOD 200
			Tags { "LIGHTMODE" = "DEFERRED" "RenderType" = "Opaque" }
			GpuProgramID 193381
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float4 texcoord5 : TEXCOORD5;
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
			// $Globals ConstantBuffers for Fragment Shader
			float _Glow;
			float4 _Color;
			float4 _GlowColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
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
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord1.xyz = tmp0.www * tmp0.xyz;
                o.texcoord3.xyz = v.color.xyz;
                o.texcoord5 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.x = tmp0.w * _Color.w + -0.5;
                tmp0.x = tmp0.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                tmp0.xyz = inp.texcoord3.xyz * float3(0.96, 0.96, 0.96);
                tmp0.w = 1.0;
                o.sv_target = tmp0;
                tmp0 = tmp0 * _GlowColor;
                o.sv_target3 = tmp0 * _Glow.xxxx;
                o.sv_target1 = float4(0.04, 0.04, 0.04, 0.0);
                o.sv_target2.xyz = inp.texcoord1.xyz * float3(0.5, 0.5, 0.5) + float3(0.5, 0.5, 0.5);
                o.sv_target2.w = 1.0;
                return o;
			}
			ENDCG
		}
	}
}