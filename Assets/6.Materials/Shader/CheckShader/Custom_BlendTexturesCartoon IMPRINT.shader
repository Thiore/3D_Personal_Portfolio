Shader "Custom/BlendTexturesCartoon IMPRINT" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MainTex2 ("Albedo2 (RGB)", 2D) = "white" {}
		_Blend ("Blend (RGB)", 2D) = "white" {}
		_Threshold ("blend threshold", Range(0, 1)) = 0
		_Threshold_Out ("Outer Threshold", Range(0, 1)) = 0
		_Threshold_In ("Inner Threshold", Range(0, 1)) = 0
		_EdgeThreshold ("Edge Threshold", Range(0, 1)) = 0
		_EdgeColor ("Edge Color", Color) = (0,0,0,1)
		_ImprintTex ("Imprint", 2D) = "black" {}
	}
	SubShader {
		LOD 200
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			GpuProgramID 36118
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float4 color : COLOR0;
				float4 texcoord6 : TEXCOORD6;
				float4 texcoord7 : TEXCOORD7;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float4 _MainTex2_ST;
			float4 _Blend_ST;
			float4 _ImprintTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _Threshold;
			float _Threshold_Out;
			float _Threshold_In;
			float _EdgeThreshold;
			float4 _EdgeColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _Blend;
			sampler2D _ImprintTex;
			
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
                o.texcoord3.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _MainTex2_ST.xy + _MainTex2_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _Blend_ST.xy + _Blend_ST.zw;
                o.texcoord1.zw = v.texcoord.xy * _ImprintTex_ST.xy + _ImprintTex_ST.zw;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord2.xyz = tmp0.www * tmp0.xyz;
                o.color = v.color;
                o.texcoord6 = float4(0.0, 0.0, 0.0, 0.0);
                o.texcoord7 = float4(0.0, 0.0, 0.0, 0.0);
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
                float4 tmp10;
                tmp0.xyz = _WorldSpaceCameraPos - inp.texcoord3.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2 = tex2D(_MainTex, inp.texcoord.xy);
                tmp3 = tex2D(_MainTex2, inp.texcoord.zw);
                tmp4 = tex2D(_Blend, inp.texcoord1.xy);
                tmp5 = tex2D(_ImprintTex, inp.texcoord1.zw);
                tmp1.w = inp.color.x - tmp5.x;
                tmp1.w = max(tmp1.w, 0.0);
                tmp2.w = 1.0 - tmp4.x;
                tmp1.w = tmp1.w * _Threshold_Out;
                tmp1.w = tmp2.w * _Threshold_In + tmp1.w;
                tmp2.w = _Threshold < tmp1.w;
                tmp3.w = tmp2.w ? 1.0 : 0.0;
                tmp4.x = _EdgeThreshold + _Threshold;
                tmp1.w = tmp1.w < tmp4.x;
                tmp1.w = tmp2.w ? tmp1.w : 0.0;
                tmp4.xyz = _Color.xyz * _EdgeColor.xyz;
                tmp4.xyz = tmp1.www ? tmp4.xyz : _Color.xyz;
                tmp3.xyz = tmp3.xyz - tmp2.xyz;
                tmp2.xyz = tmp3.www * tmp3.xyz + tmp2.xyz;
                tmp2.xyz = tmp4.xyz * tmp2.xyz;
                tmp1.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp1.w) {
                    tmp1.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp3.xyz = inp.texcoord3.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord3.xxx + tmp3.xyz;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord3.zzz + tmp3.xyz;
                    tmp3.xyz = tmp3.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp3.xyz = tmp1.www ? tmp3.xyz : inp.texcoord3.xyz;
                    tmp3.xyz = tmp3.xyz - unity_ProbeVolumeMin;
                    tmp3.yzw = tmp3.xyz * unity_ProbeVolumeSizeInv;
                    tmp1.w = tmp3.y * 0.25 + 0.75;
                    tmp2.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp3.x = max(tmp1.w, tmp2.w);
                    tmp3 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp3.xzw);
                } else {
                    tmp3 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp1.w = saturate(dot(tmp3, unity_OcclusionMaskSelector));
                tmp2.w = dot(-tmp1.xyz, inp.texcoord2.xyz);
                tmp2.w = tmp2.w + tmp2.w;
                tmp3.xyz = inp.texcoord2.xyz * -tmp2.www + -tmp1.xyz;
                tmp4.xyz = tmp1.www * _LightColor0.xyz;
                tmp1.w = unity_SpecCube0_ProbePosition.w > 0.0;
                if (tmp1.w) {
                    tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                    tmp1.w = rsqrt(tmp1.w);
                    tmp5.xyz = tmp1.www * tmp3.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMax.xyz - inp.texcoord3.xyz;
                    tmp6.xyz = tmp6.xyz / tmp5.xyz;
                    tmp7.xyz = unity_SpecCube0_BoxMin.xyz - inp.texcoord3.xyz;
                    tmp7.xyz = tmp7.xyz / tmp5.xyz;
                    tmp8.xyz = tmp5.xyz > float3(0.0, 0.0, 0.0);
                    tmp6.xyz = tmp8.xyz ? tmp6.xyz : tmp7.xyz;
                    tmp1.w = min(tmp6.y, tmp6.x);
                    tmp1.w = min(tmp6.z, tmp1.w);
                    tmp6.xyz = inp.texcoord3.xyz - unity_SpecCube0_ProbePosition.xyz;
                    tmp5.xyz = tmp5.xyz * tmp1.www + tmp6.xyz;
                } else {
                    tmp5.xyz = tmp3.xyz;
                }
                tmp5 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp5.xyz, 6.0));
                tmp1.w = tmp5.w - 1.0;
                tmp1.w = unity_SpecCube0_HDR.w * tmp1.w + 1.0;
                tmp1.w = log(tmp1.w);
                tmp1.w = tmp1.w * unity_SpecCube0_HDR.y;
                tmp1.w = exp(tmp1.w);
                tmp1.w = tmp1.w * unity_SpecCube0_HDR.x;
                tmp6.xyz = tmp5.xyz * tmp1.www;
                tmp2.w = unity_SpecCube0_BoxMin.w < 0.99999;
                if (tmp2.w) {
                    tmp2.w = unity_SpecCube1_ProbePosition.w > 0.0;
                    if (tmp2.w) {
                        tmp2.w = dot(tmp3.xyz, tmp3.xyz);
                        tmp2.w = rsqrt(tmp2.w);
                        tmp7.xyz = tmp2.www * tmp3.xyz;
                        tmp8.xyz = unity_SpecCube1_BoxMax.xyz - inp.texcoord3.xyz;
                        tmp8.xyz = tmp8.xyz / tmp7.xyz;
                        tmp9.xyz = unity_SpecCube1_BoxMin.xyz - inp.texcoord3.xyz;
                        tmp9.xyz = tmp9.xyz / tmp7.xyz;
                        tmp10.xyz = tmp7.xyz > float3(0.0, 0.0, 0.0);
                        tmp8.xyz = tmp10.xyz ? tmp8.xyz : tmp9.xyz;
                        tmp2.w = min(tmp8.y, tmp8.x);
                        tmp2.w = min(tmp8.z, tmp2.w);
                        tmp8.xyz = inp.texcoord3.xyz - unity_SpecCube1_ProbePosition.xyz;
                        tmp3.xyz = tmp7.xyz * tmp2.www + tmp8.xyz;
                    }
                    tmp3 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp3.xyz, 6.0));
                    tmp2.w = tmp3.w - 1.0;
                    tmp2.w = unity_SpecCube1_HDR.w * tmp2.w + 1.0;
                    tmp2.w = log(tmp2.w);
                    tmp2.w = tmp2.w * unity_SpecCube1_HDR.y;
                    tmp2.w = exp(tmp2.w);
                    tmp2.w = tmp2.w * unity_SpecCube1_HDR.x;
                    tmp3.xyz = tmp3.xyz * tmp2.www;
                    tmp5.xyz = tmp1.www * tmp5.xyz + -tmp3.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMin.www * tmp5.xyz + tmp3.xyz;
                }
                tmp1.w = dot(inp.texcoord2.xyz, inp.texcoord2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp3.xyz = tmp1.www * inp.texcoord2.xyz;
                tmp2.xyz = tmp2.xyz * float3(0.96, 0.96, 0.96);
                tmp0.xyz = tmp0.xyz * tmp0.www + _WorldSpaceLightPos0.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp3.xyz, tmp1.xyz);
                tmp1.x = saturate(dot(tmp3.xyz, _WorldSpaceLightPos0.xyz));
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
                tmp1.xzw = tmp0.yyy * tmp4.xyz;
                tmp0.yzw = tmp4.xyz * tmp0.zzz;
                tmp0.x = 1.0 - tmp0.x;
                tmp2.w = tmp0.x * tmp0.x;
                tmp2.w = tmp2.w * tmp2.w;
                tmp0.x = tmp0.x * tmp2.w;
                tmp0.x = tmp0.x * 0.96 + 0.04;
                tmp0.xyz = tmp0.xxx * tmp0.yzw;
                tmp0.xyz = tmp2.xyz * tmp1.xzw + tmp0.xyz;
                tmp1.xzw = tmp6.xyz * float3(0.5, 0.5, 0.5);
                tmp0.w = tmp1.y * 0.0 + 0.04;
                o.sv_target.xyz = tmp1.xzw * tmp0.www + tmp0.xyz;
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
			GpuProgramID 109022
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float4 color : COLOR0;
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
			float4 _MainTex2_ST;
			float4 _Blend_ST;
			float4 _ImprintTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _Threshold;
			float _Threshold_Out;
			float _Threshold_In;
			float _EdgeThreshold;
			float4 _EdgeColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _Blend;
			sampler2D _ImprintTex;
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
                o.texcoord.zw = v.texcoord.xy * _MainTex2_ST.xy + _MainTex2_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _Blend_ST.xy + _Blend_ST.zw;
                o.texcoord1.zw = v.texcoord.xy * _ImprintTex_ST.xy + _ImprintTex_ST.zw;
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                o.texcoord2.xyz = tmp1.www * tmp1.xyz;
                o.texcoord3.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                o.color = v.color;
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
                float4 tmp6;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord3.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2.xyz = _WorldSpaceCameraPos - inp.texcoord3.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp3 = tex2D(_MainTex, inp.texcoord.xy);
                tmp4 = tex2D(_MainTex2, inp.texcoord.zw);
                tmp5 = tex2D(_Blend, inp.texcoord1.xy);
                tmp6 = tex2D(_ImprintTex, inp.texcoord1.zw);
                tmp1.w = inp.color.x - tmp6.x;
                tmp1.w = max(tmp1.w, 0.0);
                tmp2.w = 1.0 - tmp5.x;
                tmp1.w = tmp1.w * _Threshold_Out;
                tmp1.w = tmp2.w * _Threshold_In + tmp1.w;
                tmp2.w = _Threshold < tmp1.w;
                tmp3.w = tmp2.w ? 1.0 : 0.0;
                tmp4.w = _EdgeThreshold + _Threshold;
                tmp1.w = tmp1.w < tmp4.w;
                tmp1.w = tmp2.w ? tmp1.w : 0.0;
                tmp5.xyz = _Color.xyz * _EdgeColor.xyz;
                tmp5.xyz = tmp1.www ? tmp5.xyz : _Color.xyz;
                tmp4.xyz = tmp4.xyz - tmp3.xyz;
                tmp3.xyz = tmp3.www * tmp4.xyz + tmp3.xyz;
                tmp3.xyz = tmp5.xyz * tmp3.xyz;
                tmp4.xyz = inp.texcoord3.yyy * unity_WorldToLight._m01_m11_m21;
                tmp4.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord3.xxx + tmp4.xyz;
                tmp4.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord3.zzz + tmp4.xyz;
                tmp4.xyz = tmp4.xyz + unity_WorldToLight._m03_m13_m23;
                tmp1.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp1.w) {
                    tmp1.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp5.xyz = inp.texcoord3.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp5.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord3.xxx + tmp5.xyz;
                    tmp5.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord3.zzz + tmp5.xyz;
                    tmp5.xyz = tmp5.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp5.xyz = tmp1.www ? tmp5.xyz : inp.texcoord3.xyz;
                    tmp5.xyz = tmp5.xyz - unity_ProbeVolumeMin;
                    tmp5.yzw = tmp5.xyz * unity_ProbeVolumeSizeInv;
                    tmp1.w = tmp5.y * 0.25 + 0.75;
                    tmp2.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp5.x = max(tmp1.w, tmp2.w);
                    tmp5 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp5.xzw);
                } else {
                    tmp5 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp1.w = saturate(dot(tmp5, unity_OcclusionMaskSelector));
                tmp2.w = dot(tmp4.xyz, tmp4.xyz);
                tmp4 = tex2D(_LightTexture0, tmp2.ww);
                tmp1.w = tmp1.w * tmp4.x;
                tmp4.xyz = tmp1.www * _LightColor0.xyz;
                tmp1.w = dot(inp.texcoord2.xyz, inp.texcoord2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp5.xyz = tmp1.www * inp.texcoord2.xyz;
                tmp3.xyz = tmp3.xyz * float3(0.96, 0.96, 0.96);
                tmp0.xyz = tmp0.xyz * tmp0.www + tmp2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp5.xyz, tmp2.xyz);
                tmp1.w = saturate(dot(tmp5.xyz, tmp1.xyz));
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
                tmp1.xyz = tmp0.yyy * tmp4.xyz;
                tmp0.yzw = tmp4.xyz * tmp0.zzz;
                tmp0.x = 1.0 - tmp0.x;
                tmp1.w = tmp0.x * tmp0.x;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.x = tmp0.x * tmp1.w;
                tmp0.x = tmp0.x * 0.96 + 0.04;
                tmp0.xyz = tmp0.xxx * tmp0.yzw;
                o.sv_target.xyz = tmp3.xyz * tmp1.xyz + tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "DEFERRED"
			LOD 200
			Tags { "LIGHTMODE" = "DEFERRED" "RenderType" = "Opaque" }
			GpuProgramID 135109
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float4 color : COLOR0;
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
			float4 _MainTex2_ST;
			float4 _Blend_ST;
			float4 _ImprintTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Color;
			float _Threshold;
			float _Threshold_Out;
			float _Threshold_In;
			float _EdgeThreshold;
			float4 _EdgeColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _Blend;
			sampler2D _ImprintTex;
			
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
                o.texcoord3.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _MainTex2_ST.xy + _MainTex2_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _Blend_ST.xy + _Blend_ST.zw;
                o.texcoord1.zw = v.texcoord.xy * _ImprintTex_ST.xy + _ImprintTex_ST.zw;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord2.xyz = tmp0.www * tmp0.xyz;
                o.color = v.color;
                o.texcoord5 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0 = tex2D(_ImprintTex, inp.texcoord1.zw);
                tmp0.x = inp.color.x - tmp0.x;
                tmp0.x = max(tmp0.x, 0.0);
                tmp0.x = tmp0.x * _Threshold_Out;
                tmp1 = tex2D(_Blend, inp.texcoord1.xy);
                tmp0.y = 1.0 - tmp1.x;
                tmp0.x = tmp0.y * _Threshold_In + tmp0.x;
                tmp0.y = _EdgeThreshold + _Threshold;
                tmp0.y = tmp0.x < tmp0.y;
                tmp0.x = _Threshold < tmp0.x;
                tmp0.y = tmp0.x ? tmp0.y : 0.0;
                tmp0.x = tmp0.x ? 1.0 : 0.0;
                tmp1.xyz = _Color.xyz * _EdgeColor.xyz;
                tmp0.yzw = tmp0.yyy ? tmp1.xyz : _Color.xyz;
                tmp1 = tex2D(_MainTex2, inp.texcoord.zw);
                tmp2 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.xyz = tmp1.xyz - tmp2.xyz;
                tmp1.xyz = tmp0.xxx * tmp1.xyz + tmp2.xyz;
                tmp0.xyz = tmp0.yzw * tmp1.xyz;
                o.sv_target.xyz = tmp0.xyz * float3(0.96, 0.96, 0.96);
                o.sv_target.w = 1.0;
                o.sv_target1 = float4(0.04, 0.04, 0.04, 0.0);
                o.sv_target2.xyz = inp.texcoord2.xyz * float3(0.5, 0.5, 0.5) + float3(0.5, 0.5, 0.5);
                o.sv_target2.w = 1.0;
                o.sv_target3 = float4(1.0, 1.0, 1.0, 1.0);
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}