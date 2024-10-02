Shader "Custom/SoulOrb" {
	Properties {
		_Alpha ("Alpha", Range(0, 1)) = 1
		_Color ("Color", Color) = (1,1,1,1)
		_BaseGlow ("Base Glow", Float) = 1
		_NoiseColor ("Noise Color", Color) = (1,1,1,1)
		_EmissiveGlow ("Emissive Glow", Float) = 1
		_LogoGlow ("Logo Glow", Float) = 1
		_MainTex ("Texture", 2D) = "black" {}
		_Noise ("Noise", 2D) = "white" {}
		_Shine ("Shine", 2D) = "white" {}
		_NoisePower ("Noise Power", Float) = 1
		_NoiseAlpha ("Noise Alpha", Range(0, 1)) = 0.4
		_NoiseSpeed ("Noise Speed", Float) = 1
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0
		_RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0)
		_RimPower ("Rim Power Fresnal", Range(0.5, 8)) = 3
		_R0 ("R0 Fresnel", Float) = 0.05
	}
	SubShader {
		Tags { "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Name "FORWARD"
			Tags { "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			ColorMask RGB
			ZWrite Off
			GpuProgramID 3863
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
			float _Alpha;
			float _NoisePower;
			float _NoiseAlpha;
			float _NoiseSpeed;
			float4 _Color;
			float4 _NoiseColor;
			float4 _RimColor;
			float _RimPower;
			float _R0;
			float _BaseGlow;
			float _EmissiveGlow;
			float _LogoGlow;
			float _Glossiness;
			float _Metallic;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _Noise;
			sampler2D _Shine;
			sampler2D unity_NHxRoughness;
			
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
                tmp0.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2.x = _Time.x;
                tmp2.y = 0.0;
                tmp1.yz = tmp2.xy * _NoiseSpeed.xx + inp.texcoord.zw;
                tmp2 = tex2D(_Noise, tmp1.yz);
                tmp3.xy = _Time.yx * float2(0.3, 3.0);
                tmp3.z = 0.0;
                tmp1.yz = tmp3.yz * _NoiseSpeed.xx + inp.texcoord.zw;
                tmp4 = tex2D(_Noise, tmp1.yz);
                tmp0.w = saturate(tmp2.x + tmp4.x);
                tmp1.y = saturate(dot(tmp0.xyz, inp.texcoord1.xyz));
                tmp1.y = 1.0 - tmp1.y;
                tmp1.z = log(tmp1.y);
                tmp1.z = tmp1.z * _RimPower;
                tmp1.z = exp(tmp1.z);
                tmp1.y = _R0 * tmp1.y + tmp1.z;
                tmp1.y = log(tmp1.y);
                tmp1.y = tmp1.y * _RimPower;
                tmp1.y = exp(tmp1.y);
                tmp0.w = log(tmp0.w);
                tmp0.w = tmp0.w * _NoisePower;
                tmp0.w = exp(tmp0.w);
                tmp0.w = saturate(tmp0.w * _NoiseAlpha + tmp1.x);
                tmp2.xyz = tmp0.www * _NoiseColor.xyz;
                tmp0.w = min(tmp1.y, 1.0);
                tmp1.yzw = tmp0.www * _RimColor.xyz;
                tmp0.w = tmp1.x * _NoiseColor.x;
                tmp3.z = inp.texcoord.w * 0.5;
                tmp3.y = inp.texcoord.z * 0.5 + tmp3.x;
                tmp3 = tex2D(_Shine, tmp3.yz);
                tmp1.xyz = tmp2.xyz * _EmissiveGlow.xxx + tmp1.yzw;
                tmp1.xyz = _Color.xyz * _BaseGlow.xxx + tmp1.xyz;
                tmp1.xyz = tmp0.www * _LogoGlow.xxx + tmp1.xyz;
                tmp2.xyz = tmp3.xxx * _NoiseColor.xyz;
                tmp2.xyz = tmp2.xyz * float3(5.0, 5.0, 5.0);
                tmp1.xyz = tmp1.xyz * _Alpha.xxx + tmp2.xyz;
                tmp0.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp0.w) {
                    tmp0.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp2.xyz = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp2.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp2.xyz;
                    tmp2.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp2.xyz;
                    tmp2.xyz = tmp2.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp2.xyz = tmp0.www ? tmp2.xyz : inp.texcoord2.xyz;
                    tmp2.xyz = tmp2.xyz - unity_ProbeVolumeMin;
                    tmp2.yzw = tmp2.xyz * unity_ProbeVolumeSizeInv;
                    tmp0.w = tmp2.y * 0.25 + 0.75;
                    tmp1.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp2.x = max(tmp0.w, tmp1.w);
                    tmp2 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp2.xzw);
                } else {
                    tmp2 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp0.w = saturate(dot(tmp2, unity_OcclusionMaskSelector));
                tmp2.xw = float2(1.0, 1.0) - _Glossiness.xx;
                tmp1.w = dot(-tmp0.xyz, inp.texcoord1.xyz);
                tmp1.w = tmp1.w + tmp1.w;
                tmp3.xyz = inp.texcoord1.xyz * -tmp1.www + -tmp0.xyz;
                tmp4.xyz = tmp0.www * _LightColor0.xyz;
                tmp0.w = -tmp2.x * 0.7 + 1.7;
                tmp0.w = tmp0.w * tmp2.x;
                tmp0.w = tmp0.w * 6.0;
                tmp3 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp3.xyz, tmp0.w));
                tmp0.w = tmp3.w - 1.0;
                tmp0.w = unity_SpecCube0_HDR.w * tmp0.w + 1.0;
                tmp0.w = log(tmp0.w);
                tmp0.w = tmp0.w * unity_SpecCube0_HDR.y;
                tmp0.w = exp(tmp0.w);
                tmp0.w = tmp0.w * unity_SpecCube0_HDR.x;
                tmp3.xyz = tmp3.xyz * tmp0.www;
                tmp0.w = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp5.xyz = tmp0.www * inp.texcoord1.xyz;
                tmp0.w = _Metallic * -0.04 + 0.04;
                tmp1.w = -_Metallic * 0.96 + 0.96;
                tmp2.x = dot(tmp0.xyz, tmp5.xyz);
                tmp3.w = tmp2.x + tmp2.x;
                tmp0.xyz = tmp5.xyz * -tmp3.www + tmp0.xyz;
                tmp3.w = saturate(dot(tmp5.xyz, _WorldSpaceLightPos0.xyz));
                tmp2.x = saturate(tmp2.x);
                tmp5.x = dot(tmp0.xyz, _WorldSpaceLightPos0.xyz);
                tmp5.y = 1.0 - tmp2.x;
                tmp5.zw = tmp5.xy * tmp5.xy;
                tmp0.xy = tmp5.xy * tmp5.xw;
                tmp2.yz = tmp5.zy * tmp0.xy;
                tmp0.x = 1.0 - tmp1.w;
                tmp0.x = saturate(tmp0.x + _Glossiness);
                tmp5 = tex2D(unity_NHxRoughness, tmp2.yw);
                tmp0.y = tmp5.x * 16.0;
                tmp0.y = tmp0.w * tmp0.y;
                tmp2.xyw = tmp3.www * tmp4.xyz;
                tmp0.x = tmp0.x - tmp0.w;
                tmp0.x = tmp2.z * tmp0.x + tmp0.w;
                tmp0.xzw = tmp0.xxx * tmp3.xyz;
                tmp0.xyz = tmp0.yyy * tmp2.xyw + tmp0.xzw;
                o.sv_target.xyz = tmp1.xyz + tmp0.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			Tags { "LIGHTMODE" = "FORWARDADD" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One One, One One
			ColorMask RGB
			ZWrite Off
			GpuProgramID 127809
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float3 texcoord : TEXCOORD0;
				float3 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Glossiness;
			float _Metallic;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _LightTexture0;
			sampler2D unity_NHxRoughness;
			
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
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                o.texcoord.xyz = tmp1.www * tmp1.xyz;
                o.texcoord1.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
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
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord1.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1.xyz = _WorldSpaceCameraPos - inp.texcoord1.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                tmp2.xyz = inp.texcoord1.yyy * unity_WorldToLight._m01_m11_m21;
                tmp2.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord1.xxx + tmp2.xyz;
                tmp2.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord1.zzz + tmp2.xyz;
                tmp2.xyz = tmp2.xyz + unity_WorldToLight._m03_m13_m23;
                tmp0.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp0.w) {
                    tmp0.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp3.xyz = inp.texcoord1.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord1.xxx + tmp3.xyz;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord1.zzz + tmp3.xyz;
                    tmp3.xyz = tmp3.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp3.xyz = tmp0.www ? tmp3.xyz : inp.texcoord1.xyz;
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
                tmp0.w = dot(inp.texcoord.xyz, inp.texcoord.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp3.xyz = tmp0.www * inp.texcoord.xyz;
                tmp0.w = _Metallic * -0.04 + 0.04;
                tmp1.w = dot(tmp1.xyz, tmp3.xyz);
                tmp1.w = tmp1.w + tmp1.w;
                tmp1.xyz = tmp3.xyz * -tmp1.www + tmp1.xyz;
                tmp1.w = saturate(dot(tmp3.xyz, tmp0.xyz));
                tmp0.x = dot(tmp1.xyz, tmp0.xyz);
                tmp0.x = tmp0.x * tmp0.x;
                tmp0.x = tmp0.x * tmp0.x;
                tmp0.y = 1.0 - _Glossiness;
                tmp3 = tex2D(unity_NHxRoughness, tmp0.xy);
                tmp0.x = tmp3.x * 16.0;
                tmp0.x = tmp0.w * tmp0.x;
                tmp0.yzw = tmp1.www * tmp2.xyz;
                o.sv_target.xyz = tmp0.yzw * tmp0.xxx;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}