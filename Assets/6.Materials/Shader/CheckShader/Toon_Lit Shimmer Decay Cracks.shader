Shader "Toon/Lit Shimmer Decay Cracks" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_Noise ("Noise", 2D) = "white" {}
		_ShimmerColor ("Shift Color", Color) = (1,1,1,1)
		_ShimmerSpeed ("Shimmer Speed", Float) = 1
		_ShimmerPower ("Shimmer Power", Float) = 1
		_ShimmerScale ("Shimmer Scale", Float) = 0.8
		_Mask ("Mask", 2D) = "white" {}
		_HueNoise ("Hue Noise", 2D) = "white" {}
		_HueSpeed ("Hue Speed", Float) = 1
		_HueScale ("Hue Scale", Float) = 0.8
		_HueColor ("Hue Color", Color) = (1,1,1,1)
		_DecayTex ("Decay (RGB)", 2D) = "white" {}
		_DecayColor ("Decay Color", Color) = (0.5,0.5,0.5,1)
		_Decay ("Alpha Cutoff", Float) = 1
		_DecayGlow ("Decay Glow", Float) = 5
		_CrackColor ("Crack Color", Color) = (1,1,1,1)
		_CrackTex ("Cracks (RGB)", 2D) = "white" {}
		[PropertyBlock] _Cracked ("Cracked", Range(0, 1)) = 0
		_Glow ("Glow", Float) = 1
	}
	SubShader {
		LOD 200
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Cull Off
			GpuProgramID 23748
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
			float4 _CrackTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _ShimmerSpeed;
			float _ShimmerPower;
			float _ShimmerScale;
			float4 _CrackColor;
			float _Glow;
			float _Cracked;
			float4 _Color;
			float4 _ShimmerColor;
			float4 _HueColor;
			float _HueScale;
			float _HueSpeed;
			float4 _DecayColor;
			float _Decay;
			float _DecayGlow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DecayTex;
			sampler2D _MainTex;
			sampler2D _Noise;
			sampler2D _HueNoise;
			sampler2D _Mask;
			sampler2D _CrackTex;
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
                o.texcoord.zw = v.texcoord.xy * _CrackTex_ST.xy + _CrackTex_ST.zw;
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
                float4 tmp3;
                float4 tmp4;
                tmp0 = tex2D(_DecayTex, inp.texcoord.xy);
                tmp0.x = tmp0.x + 1.0;
                tmp0.y = tmp0.x * _Decay;
                tmp0.x = _Decay * tmp0.x + -1.0;
                tmp0.x = -tmp0.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.xzw = tmp1.xyz * _Color.xyz;
                tmp2.x = _Time.x * _ShimmerSpeed + inp.texcoord.x;
                tmp1.w = _Time.x + _Time.x;
                tmp2.w = tmp1.w * _ShimmerSpeed + inp.texcoord.y;
                tmp2.yz = inp.texcoord.yx;
                tmp2 = tmp2 * _ShimmerScale.xxxx;
                tmp3 = tex2D(_Noise, tmp2.xy);
                tmp2 = tex2D(_Noise, tmp2.zw);
                tmp2.x = tmp2.x * tmp3.x;
                tmp3.x = _Time.x * _HueSpeed + inp.texcoord.x;
                tmp3.w = tmp1.w * _HueSpeed + inp.texcoord.y;
                tmp3.yz = inp.texcoord.yx;
                tmp3 = tmp3 * _HueScale.xxxx;
                tmp4 = tex2D(_HueNoise, tmp3.xy);
                tmp3 = tex2D(_HueNoise, tmp3.zw);
                tmp1.w = tmp3.x * tmp4.x;
                tmp3 = tex2D(_Mask, inp.texcoord.xy);
                tmp1.w = tmp1.w * tmp3.x;
                tmp1.xyz = -tmp1.xyz * _Color.xyz + _HueColor.xyz;
                tmp0.xzw = tmp1.www * tmp1.xyz + tmp0.xzw;
                tmp1.x = tmp2.x * tmp3.x;
                tmp1.x = tmp1.x * _ShimmerPower;
                tmp1.yzw = _ShimmerColor.xyz - tmp0.xzw;
                tmp0.xzw = tmp1.xxx * tmp1.yzw + tmp0.xzw;
                tmp1.x = _DecayGlow * tmp0.y + 1.0;
                tmp1.yzw = _DecayColor.xyz * _DecayGlow.xxx;
                tmp0.y = saturate(tmp0.y);
                tmp1.xyz = tmp1.yzw * tmp1.xxx + -tmp0.xzw;
                tmp0.xyz = tmp0.yyy * tmp1.xyz + tmp0.xzw;
                tmp1 = tex2D(_CrackTex, inp.texcoord.zw);
                tmp0.w = 1.0 - _Cracked;
                tmp0.w = saturate(tmp1.w - tmp0.w);
                tmp1.x = 1.0 - tmp0.w;
                tmp1.yzw = tmp0.www * _CrackColor.xyz;
                tmp1.yzw = tmp1.yzw * _Glow.xxx;
                tmp0.xyz = tmp0.xyz * tmp1.xxx + tmp1.yzw;
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
			Tags { "LIGHTMODE" = "FORWARDADD" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Blend One One, One One
			ZWrite Off
			Cull Off
			GpuProgramID 99360
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
			float4 _CrackTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _ShimmerSpeed;
			float _ShimmerPower;
			float _ShimmerScale;
			float4 _CrackColor;
			float _Glow;
			float _Cracked;
			float4 _Color;
			float4 _ShimmerColor;
			float4 _HueColor;
			float _HueScale;
			float _HueSpeed;
			float4 _DecayColor;
			float _Decay;
			float _DecayGlow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DecayTex;
			sampler2D _MainTex;
			sampler2D _Noise;
			sampler2D _HueNoise;
			sampler2D _Mask;
			sampler2D _CrackTex;
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
                o.texcoord.zw = v.texcoord.xy * _CrackTex_ST.xy + _CrackTex_ST.zw;
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
                float4 tmp4;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1 = tex2D(_DecayTex, inp.texcoord.xy);
                tmp0.w = tmp1.x + 1.0;
                tmp1.x = tmp0.w * _Decay;
                tmp0.w = _Decay * tmp0.w + -1.0;
                tmp0.w = -tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp2 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.yzw = tmp2.xyz * _Color.xyz;
                tmp3.x = _Time.x * _ShimmerSpeed + inp.texcoord.x;
                tmp0.w = _Time.x + _Time.x;
                tmp3.w = tmp0.w * _ShimmerSpeed + inp.texcoord.y;
                tmp3.yz = inp.texcoord.yx;
                tmp3 = tmp3 * _ShimmerScale.xxxx;
                tmp4 = tex2D(_Noise, tmp3.xy);
                tmp3 = tex2D(_Noise, tmp3.zw);
                tmp2.w = tmp3.x * tmp4.x;
                tmp3.x = _Time.x * _HueSpeed + inp.texcoord.x;
                tmp3.w = tmp0.w * _HueSpeed + inp.texcoord.y;
                tmp3.yz = inp.texcoord.yx;
                tmp3 = tmp3 * _HueScale.xxxx;
                tmp4 = tex2D(_HueNoise, tmp3.xy);
                tmp3 = tex2D(_HueNoise, tmp3.zw);
                tmp0.w = tmp3.x * tmp4.x;
                tmp3 = tex2D(_Mask, inp.texcoord.xy);
                tmp0.w = tmp0.w * tmp3.x;
                tmp2.xyz = -tmp2.xyz * _Color.xyz + _HueColor.xyz;
                tmp1.yzw = tmp0.www * tmp2.xyz + tmp1.yzw;
                tmp0.w = tmp2.w * tmp3.x;
                tmp0.w = tmp0.w * _ShimmerPower;
                tmp2.xyz = _ShimmerColor.xyz - tmp1.yzw;
                tmp1.yzw = tmp0.www * tmp2.xyz + tmp1.yzw;
                tmp0.w = _DecayGlow * tmp1.x + 1.0;
                tmp2.xyz = _DecayColor.xyz * _DecayGlow.xxx;
                tmp1.x = saturate(tmp1.x);
                tmp2.xyz = tmp2.xyz * tmp0.www + -tmp1.yzw;
                tmp1.xyz = tmp1.xxx * tmp2.xyz + tmp1.yzw;
                tmp2 = tex2D(_CrackTex, inp.texcoord.zw);
                tmp0.w = 1.0 - _Cracked;
                tmp0.w = saturate(tmp2.w - tmp0.w);
                tmp1.w = 1.0 - tmp0.w;
                tmp2.xyz = tmp0.www * _CrackColor.xyz;
                tmp2.xyz = tmp2.xyz * _Glow.xxx;
                tmp1.xyz = tmp1.xyz * tmp1.www + tmp2.xyz;
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
		Pass {
			Name "ShadowCaster"
			LOD 200
			Tags { "LIGHTMODE" = "SHADOWCASTER" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Cull Off
			GpuProgramID 143545
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord1 : TEXCOORD1;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float _Decay;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DecayTex;
			
			// Keywords: SHADOWS_DEPTH
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp1;
                tmp1 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp1;
                tmp1 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp1;
                tmp2.xyz = -tmp1.xyz * _WorldSpaceLightPos0.www + _WorldSpaceLightPos0.xyz;
                tmp0.w = dot(tmp2.xyz, tmp2.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp2.xyz = tmp0.www * tmp2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp2.xyz);
                tmp0.w = -tmp0.w * tmp0.w + 1.0;
                tmp0.w = sqrt(tmp0.w);
                tmp0.w = tmp0.w * unity_LightShadowBias.z;
                tmp0.xyz = -tmp0.xyz * tmp0.www + tmp1.xyz;
                tmp0.w = unity_LightShadowBias.z != 0.0;
                tmp0.xyz = tmp0.www ? tmp0.xyz : tmp1.xyz;
                tmp2 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp2;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp2;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                tmp1.x = unity_LightShadowBias.x / tmp0.w;
                tmp1.x = min(tmp1.x, 0.0);
                tmp1.x = max(tmp1.x, -1.0);
                tmp0.z = tmp0.z + tmp1.x;
                tmp1.x = min(tmp0.w, tmp0.z);
                o.position.xyw = tmp0.xyw;
                tmp0.x = tmp1.x - tmp0.z;
                o.position.z = unity_LightShadowBias.y * tmp0.x + tmp0.z;
                o.texcoord1.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
			}
			// Keywords: SHADOWS_DEPTH
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                tmp0 = tex2D(_DecayTex, inp.texcoord1.xy);
                tmp0.x = tmp0.x + 1.0;
                tmp0.x = _Decay * tmp0.x + -1.0;
                tmp0.x = -tmp0.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}