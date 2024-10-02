Shader "Transparent/Ghost Spirit Crow" {
	Properties {
		[PropertyBlock] _Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_NoiseTex ("Noise (RGB) Trans (A)", 2D) = "white" {}
		_NoiseScale ("Noise Scale", Float) = 0.3
		[PropertyBlock] _NoiseDirection ("Noise Direction Scale", Float) = 0
		_Glow ("Glow", Float) = 1
		[PropertyBlock] _Dissolve ("Dissolve", Float) = 0
		_DissolveNoise ("Dissolve Noise", Float) = 1
		[PropertyBlock] _SourcePoint ("Source Pos", Vector) = (0,0,0,0)
		_RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0)
		_RimPower ("Rim Power", Range(0.01, 8)) = 3
	}
	SubShader {
		LOD 200
		Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			LOD 200
			Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			ColorMask 0
			Cull Off
			GpuProgramID 33627
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
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
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			ZWrite Off
			Cull Off
			GpuProgramID 86985
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
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float _NoiseScale;
			float _NoiseDirection;
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _Glow;
			float4 _RimColor;
			float _RimPower;
			float _Dissolve;
			float _DissolveNoise;
			float3 _SourcePoint;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _NoiseTex;
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: DIRECTIONAL
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.y = v.texcoord.y + _Time.x;
                tmp0.x = v.texcoord.x;
                tmp0 = tex2Dlod(_NoiseTex, float4(tmp0.xy, 0, v.texcoord.w));
                tmp0.x = tmp0.y * tmp0.x;
                tmp0.x = tmp0.x * v.color.w;
                tmp0.y = tmp0.x * _NoiseDirection;
                tmp0.xzw = tmp0.xxx * v.normal.xyz;
                tmp1.xyz = tmp0.xzw * _NoiseScale.xxx;
                tmp1.w = 0.0;
                tmp1 = tmp1 + v.vertex;
                tmp0.x = saturate(v.normal.y);
                tmp0.x = tmp0.y * tmp0.x + tmp1.y;
                tmp0 = tmp0.xxxx * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.texcoord2.xyz = unity_ObjectToWorld._m03_m13_m23 * tmp1.www + tmp0.xyz;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
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
                tmp0.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1 = tmp1 * _Color;
                tmp2.x = inp.texcoord.x + _Time.x;
                tmp2.y = _Time.x * 1.5 + inp.texcoord.y;
                tmp2 = tex2D(_MainTex, tmp2.xy);
                tmp3.x = inp.texcoord.x - _Time.x;
                tmp3.y = _Time.x * 2.0 + inp.texcoord.y;
                tmp3 = tex2D(_NoiseTex, tmp3.xy);
                tmp2.yzw = inp.texcoord2.xyz - _SourcePoint;
                tmp0.w = dot(tmp2.xyz, tmp2.xyz);
                tmp0.w = sqrt(tmp0.w);
                tmp2.x = tmp2.x * tmp3.x;
                tmp0.w = tmp2.x * _DissolveNoise + tmp0.w;
                tmp0.w = saturate(tmp0.w - _Dissolve);
                tmp0.x = saturate(dot(tmp0.xyz, inp.texcoord1.xyz));
                tmp0.xw = float2(1.0, 1.0) - tmp0.xw;
                tmp0.x = log(tmp0.x);
                tmp0.x = tmp0.x * _RimPower;
                tmp0.x = exp(tmp0.x);
                tmp2.xyz = tmp0.xxx * _RimColor.xyz;
                tmp2.xyz = tmp2.xyz * _Glow.xxx;
                tmp0.x = tmp0.x * tmp1.w;
                o.sv_target.w = tmp0.w * tmp0.x;
                tmp0.x = unity_ProbeVolumeParams.x == 1.0;
                if (tmp0.x) {
                    tmp0.x = unity_ProbeVolumeParams.y == 1.0;
                    tmp0.yzw = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp0.yzw = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp0.yzw;
                    tmp0.yzw = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp0.yzw;
                    tmp0.yzw = tmp0.yzw + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp0.xyz = tmp0.xxx ? tmp0.yzw : inp.texcoord2.xyz;
                    tmp0.xyz = tmp0.xyz - unity_ProbeVolumeMin;
                    tmp0.yzw = tmp0.xyz * unity_ProbeVolumeSizeInv;
                    tmp0.y = tmp0.y * 0.25 + 0.75;
                    tmp1.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp0.x = max(tmp0.y, tmp1.w);
                    tmp0 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp0.xzw);
                } else {
                    tmp0 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp0.x = saturate(dot(tmp0, unity_OcclusionMaskSelector));
                tmp0.xyz = tmp0.xxx * _LightColor0.xyz;
                tmp0.w = dot(inp.texcoord1.xyz, _WorldSpaceLightPos0.xyz);
                tmp0.w = max(tmp0.w, 0.0);
                tmp0.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.xyz = tmp0.xyz * tmp0.www + tmp2.xyz;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDADD" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend SrcAlpha One, SrcAlpha One
			ColorMask RGB
			ZWrite Off
			Cull Off
			GpuProgramID 191884
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
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float _NoiseScale;
			float _NoiseDirection;
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _RimPower;
			float _Dissolve;
			float _DissolveNoise;
			float3 _SourcePoint;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _NoiseTex;
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
                float4 tmp3;
                tmp0.y = v.texcoord.y + _Time.x;
                tmp0.x = v.texcoord.x;
                tmp0 = tex2Dlod(_NoiseTex, float4(tmp0.xy, 0, v.texcoord.w));
                tmp0.x = tmp0.y * tmp0.x;
                tmp0.x = tmp0.x * v.color.w;
                tmp0.y = tmp0.x * _NoiseDirection;
                tmp0.xzw = tmp0.xxx * v.normal.xyz;
                tmp1.xyz = tmp0.xzw * _NoiseScale.xxx;
                tmp0.x = saturate(v.normal.y);
                tmp1.w = 0.0;
                tmp1 = tmp1 + v.vertex;
                tmp0.x = tmp0.y * tmp0.x + tmp1.y;
                tmp0 = tmp0.xxxx * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                tmp2 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp3 = tmp2.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp3 = unity_MatrixVP._m00_m10_m20_m30 * tmp2.xxxx + tmp3;
                tmp3 = unity_MatrixVP._m02_m12_m22_m32 * tmp2.zzzz + tmp3;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp2.wwww + tmp3;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp2.x = dot(tmp1.xyz, tmp1.xyz);
                tmp2.x = rsqrt(tmp2.x);
                o.texcoord1.xyz = tmp1.xyz * tmp2.xxx;
                o.texcoord2.xyz = unity_ObjectToWorld._m03_m13_m23 * tmp1.www + tmp0.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                tmp1.xyz = tmp0.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToLight._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                o.texcoord3.xyz = unity_WorldToLight._m03_m13_m23 * tmp0.www + tmp0.xyz;
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
                tmp1.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                tmp2 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2 = tmp2 * _Color;
                tmp3.x = inp.texcoord.x + _Time.x;
                tmp3.y = _Time.x * 1.5 + inp.texcoord.y;
                tmp3 = tex2D(_MainTex, tmp3.xy);
                tmp4.x = inp.texcoord.x - _Time.x;
                tmp4.y = _Time.x * 2.0 + inp.texcoord.y;
                tmp4 = tex2D(_NoiseTex, tmp4.xy);
                tmp3.yzw = inp.texcoord2.xyz - _SourcePoint;
                tmp0.w = dot(tmp3.xyz, tmp3.xyz);
                tmp0.w = sqrt(tmp0.w);
                tmp1.w = tmp3.x * tmp4.x;
                tmp0.w = tmp1.w * _DissolveNoise + tmp0.w;
                tmp0.w = saturate(tmp0.w - _Dissolve);
                tmp0.w = 1.0 - tmp0.w;
                tmp1.x = saturate(dot(tmp1.xyz, inp.texcoord1.xyz));
                tmp1.x = 1.0 - tmp1.x;
                tmp1.x = log(tmp1.x);
                tmp1.x = tmp1.x * _RimPower;
                tmp1.x = exp(tmp1.x);
                tmp1.x = tmp1.x * tmp2.w;
                o.sv_target.w = tmp0.w * tmp1.x;
                tmp1.xyz = inp.texcoord2.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord2.xxx + tmp1.xyz;
                tmp1.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord2.zzz + tmp1.xyz;
                tmp1.xyz = tmp1.xyz + unity_WorldToLight._m03_m13_m23;
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
                tmp1.x = dot(tmp1.xyz, tmp1.xyz);
                tmp1 = tex2D(_LightTexture0, tmp1.xx);
                tmp0.w = tmp0.w * tmp1.x;
                tmp1.xyz = tmp0.www * _LightColor0.xyz;
                tmp0.x = dot(inp.texcoord1.xyz, tmp0.xyz);
                tmp0.x = max(tmp0.x, 0.0);
                tmp0.yzw = tmp1.xyz * tmp2.xyz;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw;
                return o;
			}
			ENDCG
		}
	}
	Fallback "Transparent/Diffuse"
}