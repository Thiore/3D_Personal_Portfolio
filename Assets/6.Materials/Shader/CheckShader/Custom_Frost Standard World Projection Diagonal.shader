Shader "Custom/Frost Standard World Projection Diagonal" {
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
		_Glossiness ("Smoothness", Range(0, 1)) = 0
		_Metallic ("Metallic", Range(0, 1)) = 0
	}
	SubShader {
		LOD 200
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			GpuProgramID 4683
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
			float _Glossiness;
			float _Metallic;
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
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                float4 tmp7;
                float4 tmp8;
                float4 tmp9;
                float4 tmp10;
                tmp0.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2 = tex2D(_MainTex, inp.texcoord.xy);
                tmp3.xy = inp.texcoord2.yz + inp.texcoord2.xx;
                tmp3.xy = tmp3.xy / _FrostScale.xx;
                tmp4.x = tmp3.x + _FrostMainVariables.x;
                tmp4.y = _FrostMainVariables.y - tmp3.y;
                tmp3 = tex2D(_MainTex2, tmp4.xy);
                tmp1.w = -inp.texcoord2.y - inp.texcoord2.x;
                tmp1.w = tmp1.w / _WorldScale;
                tmp4.x = tmp1.w + _FrostNoiseVariables.x;
                tmp1.w = inp.texcoord2.z / _WorldScale;
                tmp4.y = tmp1.w + _FrostNoiseVariables.y;
                tmp1.w = _MaxY - _MinY;
                tmp2.w = inp.texcoord2.y - _MinY;
                tmp1.w = saturate(tmp2.w / tmp1.w);
                tmp3.yz = _FrostNoiseVariables.xy * tmp4.xy + _FrostNoiseVariables.zw;
                tmp4 = tex2D(_MainTex2, tmp3.yz);
                tmp5 = tex2D(_Blend, inp.texcoord.zw);
                tmp2.w = tmp4.y * tmp1.w + tmp3.x;
                tmp3.x = tmp2.w * 0.5 + -tmp5.x;
                tmp3.x = tmp3.x + 1.0;
                tmp3.y = inp.color.x * _Threshold_Out;
                tmp3.x = tmp3.x * _Threshold_In + tmp3.y;
                tmp3.x = saturate(tmp3.x - _Threshold);
                tmp2.w = tmp2.w * 0.5 + _Tint2.x;
                tmp2.w = tmp2.w * _Tint2.x;
                tmp2.w = tmp3.x * tmp2.w;
                tmp3.x = tmp1.w * tmp2.w;
                tmp3.xyz = tmp3.xxx * _Color.xyz;
                tmp2.xyz = saturate(tmp2.xyz * _Tint1.xyz + tmp3.xyz);
                tmp3.x = dot(tmp2.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp3.y = 1.0 - _Saturation;
                tmp3.xzw = tmp3.xxx - tmp2.xyz;
                tmp2.xyz = tmp3.yyy * tmp3.xzw + tmp2.xyz;
                tmp1.w = -tmp2.w * tmp1.w + 1.0;
                tmp2.w = tmp1.w * _Metallic;
                tmp3.x = unity_ProbeVolumeParams.x == 1.0;
                if (tmp3.x) {
                    tmp3.x = unity_ProbeVolumeParams.y == 1.0;
                    tmp3.yzw = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp3.yzw = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp3.yzw;
                    tmp3.yzw = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp3.yzw;
                    tmp3.yzw = tmp3.yzw + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp3.xyz = tmp3.xxx ? tmp3.yzw : inp.texcoord2.xyz;
                    tmp3.xyz = tmp3.xyz - unity_ProbeVolumeMin;
                    tmp3.yzw = tmp3.xyz * unity_ProbeVolumeSizeInv;
                    tmp3.y = tmp3.y * 0.25 + 0.75;
                    tmp4.x = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp3.x = max(tmp3.y, tmp4.x);
                    tmp3 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp3.xzw);
                } else {
                    tmp3 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp3.x = saturate(dot(tmp3, unity_OcclusionMaskSelector));
                tmp3.y = -_Glossiness * tmp1.w + 1.0;
                tmp3.z = dot(-tmp1.xyz, inp.texcoord1.xyz);
                tmp3.z = tmp3.z + tmp3.z;
                tmp4.xyz = inp.texcoord1.xyz * -tmp3.zzz + -tmp1.xyz;
                tmp3.xzw = tmp3.xxx * _LightColor0.xyz;
                tmp4.w = unity_SpecCube0_ProbePosition.w > 0.0;
                if (tmp4.w) {
                    tmp4.w = dot(tmp4.xyz, tmp4.xyz);
                    tmp4.w = rsqrt(tmp4.w);
                    tmp5.xyz = tmp4.www * tmp4.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMax.xyz - inp.texcoord2.xyz;
                    tmp6.xyz = tmp6.xyz / tmp5.xyz;
                    tmp7.xyz = unity_SpecCube0_BoxMin.xyz - inp.texcoord2.xyz;
                    tmp7.xyz = tmp7.xyz / tmp5.xyz;
                    tmp8.xyz = tmp5.xyz > float3(0.0, 0.0, 0.0);
                    tmp6.xyz = tmp8.xyz ? tmp6.xyz : tmp7.xyz;
                    tmp4.w = min(tmp6.y, tmp6.x);
                    tmp4.w = min(tmp6.z, tmp4.w);
                    tmp6.xyz = inp.texcoord2.xyz - unity_SpecCube0_ProbePosition.xyz;
                    tmp5.xyz = tmp5.xyz * tmp4.www + tmp6.xyz;
                } else {
                    tmp5.xyz = tmp4.xyz;
                }
                tmp4.w = -tmp3.y * 0.7 + 1.7;
                tmp4.w = tmp3.y * tmp4.w;
                tmp4.w = tmp4.w * 6.0;
                tmp5 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp5.xyz, tmp4.w));
                tmp5.w = tmp5.w - 1.0;
                tmp5.w = unity_SpecCube0_HDR.w * tmp5.w + 1.0;
                tmp5.w = log(tmp5.w);
                tmp5.w = tmp5.w * unity_SpecCube0_HDR.y;
                tmp5.w = exp(tmp5.w);
                tmp5.w = tmp5.w * unity_SpecCube0_HDR.x;
                tmp6.xyz = tmp5.xyz * tmp5.www;
                tmp6.w = unity_SpecCube0_BoxMin.w < 0.99999;
                if (tmp6.w) {
                    tmp6.w = unity_SpecCube1_ProbePosition.w > 0.0;
                    if (tmp6.w) {
                        tmp6.w = dot(tmp4.xyz, tmp4.xyz);
                        tmp6.w = rsqrt(tmp6.w);
                        tmp7.xyz = tmp4.xyz * tmp6.www;
                        tmp8.xyz = unity_SpecCube1_BoxMax.xyz - inp.texcoord2.xyz;
                        tmp8.xyz = tmp8.xyz / tmp7.xyz;
                        tmp9.xyz = unity_SpecCube1_BoxMin.xyz - inp.texcoord2.xyz;
                        tmp9.xyz = tmp9.xyz / tmp7.xyz;
                        tmp10.xyz = tmp7.xyz > float3(0.0, 0.0, 0.0);
                        tmp8.xyz = tmp10.xyz ? tmp8.xyz : tmp9.xyz;
                        tmp6.w = min(tmp8.y, tmp8.x);
                        tmp6.w = min(tmp8.z, tmp6.w);
                        tmp8.xyz = inp.texcoord2.xyz - unity_SpecCube1_ProbePosition.xyz;
                        tmp4.xyz = tmp7.xyz * tmp6.www + tmp8.xyz;
                    }
                    tmp4 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp4.xyz, tmp4.w));
                    tmp4.w = tmp4.w - 1.0;
                    tmp4.w = unity_SpecCube1_HDR.w * tmp4.w + 1.0;
                    tmp4.w = log(tmp4.w);
                    tmp4.w = tmp4.w * unity_SpecCube1_HDR.y;
                    tmp4.w = exp(tmp4.w);
                    tmp4.w = tmp4.w * unity_SpecCube1_HDR.x;
                    tmp4.xyz = tmp4.xyz * tmp4.www;
                    tmp5.xyz = tmp5.www * tmp5.xyz + -tmp4.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMin.www * tmp5.xyz + tmp4.xyz;
                }
                tmp4.x = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp4.x = rsqrt(tmp4.x);
                tmp4.xyz = tmp4.xxx * inp.texcoord1.xyz;
                tmp5.xyz = tmp2.xyz - float3(0.04, 0.04, 0.04);
                tmp5.xyz = tmp2.www * tmp5.xyz + float3(0.04, 0.04, 0.04);
                tmp2.w = -tmp2.w * 0.96 + 0.96;
                tmp2.xyz = tmp2.www * tmp2.xyz;
                tmp0.xyz = tmp0.xyz * tmp0.www + _WorldSpaceLightPos0.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = saturate(dot(tmp4.xyz, _WorldSpaceLightPos0.xyz));
                tmp1.y = saturate(dot(tmp4.xyz, tmp0.xyz));
                tmp0.x = saturate(dot(_WorldSpaceLightPos0.xyz, tmp0.xyz));
                tmp0.y = tmp0.x * tmp0.x;
                tmp0.y = dot(tmp0.xy, tmp3.xy);
                tmp0.y = tmp0.y - 0.5;
                tmp0.z = 1.0 - tmp1.x;
                tmp1.z = tmp0.z * tmp0.z;
                tmp1.z = tmp1.z * tmp1.z;
                tmp0.z = tmp0.z * tmp1.z;
                tmp0.z = tmp0.y * tmp0.z + 1.0;
                tmp1.z = 1.0 - abs(tmp0.w);
                tmp4.x = tmp1.z * tmp1.z;
                tmp4.x = tmp4.x * tmp4.x;
                tmp1.z = tmp1.z * tmp4.x;
                tmp0.y = tmp0.y * tmp1.z + 1.0;
                tmp0.y = tmp0.y * tmp0.z;
                tmp0.z = tmp3.y * tmp3.y;
                tmp0.z = max(tmp0.z, 0.002);
                tmp3.y = 1.0 - tmp0.z;
                tmp4.x = abs(tmp0.w) * tmp3.y + tmp0.z;
                tmp3.y = tmp1.x * tmp3.y + tmp0.z;
                tmp0.w = abs(tmp0.w) * tmp3.y;
                tmp0.w = tmp1.x * tmp4.x + tmp0.w;
                tmp0.w = tmp0.w + 0.00001;
                tmp0.w = 0.5 / tmp0.w;
                tmp3.y = tmp0.z * tmp0.z;
                tmp4.x = tmp1.y * tmp3.y + -tmp1.y;
                tmp1.y = tmp4.x * tmp1.y + 1.0;
                tmp3.y = tmp3.y * 0.3183099;
                tmp1.y = tmp1.y * tmp1.y + 0.0000001;
                tmp1.y = tmp3.y / tmp1.y;
                tmp0.w = tmp0.w * tmp1.y;
                tmp0.w = tmp0.w * 3.141593;
                tmp0.yw = tmp1.xx * tmp0.yw;
                tmp0.w = max(tmp0.w, 0.0);
                tmp0.z = tmp0.z * tmp0.z + 1.0;
                tmp0.z = 1.0 / tmp0.z;
                tmp1.x = dot(tmp5.xyz, tmp5.xyz);
                tmp1.x = tmp1.x != 0.0;
                tmp1.x = tmp1.x ? 1.0 : 0.0;
                tmp0.w = tmp0.w * tmp1.x;
                tmp1.x = _Glossiness * tmp1.w + -tmp2.w;
                tmp1.x = saturate(tmp1.x + 1.0);
                tmp4.xyz = tmp0.yyy * tmp3.xzw;
                tmp3.xyz = tmp3.xzw * tmp0.www;
                tmp0.x = 1.0 - tmp0.x;
                tmp0.y = tmp0.x * tmp0.x;
                tmp0.y = tmp0.y * tmp0.y;
                tmp0.x = tmp0.x * tmp0.y;
                tmp7.xyz = float3(1.0, 1.0, 1.0) - tmp5.xyz;
                tmp0.xyw = tmp7.xyz * tmp0.xxx + tmp5.xyz;
                tmp0.xyw = tmp0.xyw * tmp3.xyz;
                tmp0.xyw = tmp2.xyz * tmp4.xyz + tmp0.xyw;
                tmp2.xyz = tmp6.xyz * tmp0.zzz;
                tmp1.xyw = tmp1.xxx - tmp5.xyz;
                tmp1.xyz = tmp1.zzz * tmp1.xyw + tmp5.xyz;
                o.sv_target.xyz = tmp2.xyz * tmp1.xyz + tmp0.xyw;
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
			GpuProgramID 94796
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
			float _Glossiness;
			float _Metallic;
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
                float4 tmp5;
                float4 tmp6;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp3 = tex2D(_MainTex, inp.texcoord.xy);
                tmp4.xy = inp.texcoord2.yz + inp.texcoord2.xx;
                tmp4.xy = tmp4.xy / _FrostScale.xx;
                tmp5.x = tmp4.x + _FrostMainVariables.x;
                tmp5.y = _FrostMainVariables.y - tmp4.y;
                tmp4 = tex2D(_MainTex2, tmp5.xy);
                tmp1.w = -inp.texcoord2.y - inp.texcoord2.x;
                tmp1.w = tmp1.w / _WorldScale;
                tmp5.x = tmp1.w + _FrostNoiseVariables.x;
                tmp1.w = inp.texcoord2.z / _WorldScale;
                tmp5.y = tmp1.w + _FrostNoiseVariables.y;
                tmp1.w = _MaxY - _MinY;
                tmp2.w = inp.texcoord2.y - _MinY;
                tmp1.w = saturate(tmp2.w / tmp1.w);
                tmp4.yz = _FrostNoiseVariables.xy * tmp5.xy + _FrostNoiseVariables.zw;
                tmp5 = tex2D(_MainTex2, tmp4.yz);
                tmp6 = tex2D(_Blend, inp.texcoord.zw);
                tmp2.w = tmp5.y * tmp1.w + tmp4.x;
                tmp3.w = tmp2.w * 0.5 + -tmp6.x;
                tmp3.w = tmp3.w + 1.0;
                tmp4.x = inp.color.x * _Threshold_Out;
                tmp3.w = tmp3.w * _Threshold_In + tmp4.x;
                tmp3.w = saturate(tmp3.w - _Threshold);
                tmp2.w = tmp2.w * 0.5 + _Tint2.x;
                tmp2.w = tmp2.w * _Tint2.x;
                tmp2.w = tmp3.w * tmp2.w;
                tmp3.w = tmp1.w * tmp2.w;
                tmp4.xyz = tmp3.www * _Color.xyz;
                tmp3.xyz = saturate(tmp3.xyz * _Tint1.xyz + tmp4.xyz);
                tmp3.w = dot(tmp3.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp4.x = 1.0 - _Saturation;
                tmp4.yzw = tmp3.www - tmp3.xyz;
                tmp3.xyz = tmp4.xxx * tmp4.yzw + tmp3.xyz;
                tmp1.w = -tmp2.w * tmp1.w + 1.0;
                tmp2.w = tmp1.w * _Metallic;
                tmp4.xyz = inp.texcoord2.yyy * unity_WorldToLight._m01_m11_m21;
                tmp4.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord2.xxx + tmp4.xyz;
                tmp4.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord2.zzz + tmp4.xyz;
                tmp4.xyz = tmp4.xyz + unity_WorldToLight._m03_m13_m23;
                tmp3.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp3.w) {
                    tmp3.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp5.xyz = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp5.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp5.xyz;
                    tmp5.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp5.xyz;
                    tmp5.xyz = tmp5.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp5.xyz = tmp3.www ? tmp5.xyz : inp.texcoord2.xyz;
                    tmp5.xyz = tmp5.xyz - unity_ProbeVolumeMin;
                    tmp5.yzw = tmp5.xyz * unity_ProbeVolumeSizeInv;
                    tmp3.w = tmp5.y * 0.25 + 0.75;
                    tmp4.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp5.x = max(tmp3.w, tmp4.w);
                    tmp5 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp5.xzw);
                } else {
                    tmp5 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp3.w = saturate(dot(tmp5, unity_OcclusionMaskSelector));
                tmp4.x = dot(tmp4.xyz, tmp4.xyz);
                tmp4 = tex2D(_LightTexture0, tmp4.xx);
                tmp3.w = tmp3.w * tmp4.x;
                tmp4.xyz = tmp3.www * _LightColor0.xyz;
                tmp3.w = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp3.w = rsqrt(tmp3.w);
                tmp5.xyz = tmp3.www * inp.texcoord1.xyz;
                tmp6.xyz = tmp3.xyz - float3(0.04, 0.04, 0.04);
                tmp6.xyz = tmp2.www * tmp6.xyz + float3(0.04, 0.04, 0.04);
                tmp2.w = -tmp2.w * 0.96 + 0.96;
                tmp3.xyz = tmp2.www * tmp3.xyz;
                tmp1.w = -_Glossiness * tmp1.w + 1.0;
                tmp0.xyz = tmp0.xyz * tmp0.www + tmp2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp5.xyz, tmp2.xyz);
                tmp2.x = saturate(dot(tmp5.xyz, tmp1.xyz));
                tmp2.y = saturate(dot(tmp5.xyz, tmp0.xyz));
                tmp0.x = saturate(dot(tmp1.xyz, tmp0.xyz));
                tmp0.y = tmp0.x * tmp0.x;
                tmp0.y = dot(tmp0.xy, tmp1.xy);
                tmp0.y = tmp0.y - 0.5;
                tmp0.z = 1.0 - tmp2.x;
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
                tmp0.z = tmp1.w * tmp1.w;
                tmp0.z = max(tmp0.z, 0.002);
                tmp1.x = 1.0 - tmp0.z;
                tmp1.y = abs(tmp0.w) * tmp1.x + tmp0.z;
                tmp1.x = tmp2.x * tmp1.x + tmp0.z;
                tmp0.w = abs(tmp0.w) * tmp1.x;
                tmp0.w = tmp2.x * tmp1.y + tmp0.w;
                tmp0.w = tmp0.w + 0.00001;
                tmp0.w = 0.5 / tmp0.w;
                tmp0.z = tmp0.z * tmp0.z;
                tmp1.x = tmp2.y * tmp0.z + -tmp2.y;
                tmp1.x = tmp1.x * tmp2.y + 1.0;
                tmp0.z = tmp0.z * 0.3183099;
                tmp1.x = tmp1.x * tmp1.x + 0.0000001;
                tmp0.z = tmp0.z / tmp1.x;
                tmp0.z = tmp0.z * tmp0.w;
                tmp0.z = tmp0.z * 3.141593;
                tmp0.yz = tmp2.xx * tmp0.yz;
                tmp0.z = max(tmp0.z, 0.0);
                tmp0.w = dot(tmp6.xyz, tmp6.xyz);
                tmp0.w = tmp0.w != 0.0;
                tmp0.w = tmp0.w ? 1.0 : 0.0;
                tmp0.z = tmp0.w * tmp0.z;
                tmp1.xyz = tmp0.yyy * tmp4.xyz;
                tmp0.yzw = tmp4.xyz * tmp0.zzz;
                tmp0.x = 1.0 - tmp0.x;
                tmp1.w = tmp0.x * tmp0.x;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.x = tmp0.x * tmp1.w;
                tmp2.xyz = float3(1.0, 1.0, 1.0) - tmp6.xyz;
                tmp2.xyz = tmp2.xyz * tmp0.xxx + tmp6.xyz;
                tmp0.xyz = tmp0.yzw * tmp2.xyz;
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
			GpuProgramID 195223
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
				float4 texcoord4 : TEXCOORD4;
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
			float _Glossiness;
			float _Metallic;
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
                o.texcoord4 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = -inp.texcoord2.y - inp.texcoord2.x;
                tmp0.x = tmp0.x / _WorldScale;
                tmp0.z = inp.texcoord2.z / _WorldScale;
                tmp0.xy = tmp0.xz + _FrostNoiseVariables.xy;
                tmp0.xy = _FrostNoiseVariables.xy * tmp0.xy + _FrostNoiseVariables.zw;
                tmp0 = tex2D(_MainTex2, tmp0.xy);
                tmp0.xz = inp.texcoord2.yz + inp.texcoord2.xx;
                tmp0.xz = tmp0.xz / _FrostScale.xx;
                tmp1.x = tmp0.x + _FrostMainVariables.x;
                tmp1.y = _FrostMainVariables.y - tmp0.z;
                tmp1 = tex2D(_MainTex2, tmp1.xy);
                tmp0.x = _MaxY - _MinY;
                tmp0.z = inp.texcoord2.y - _MinY;
                tmp0.x = saturate(tmp0.z / tmp0.x);
                tmp0.y = tmp0.y * tmp0.x + tmp1.x;
                tmp1 = tex2D(_Blend, inp.texcoord.zw);
                tmp0.z = tmp0.y * 0.5 + -tmp1.x;
                tmp0.y = tmp0.y * 0.5 + _Tint2.x;
                tmp0.y = tmp0.y * _Tint2.x;
                tmp0.z = tmp0.z + 1.0;
                tmp0.w = inp.color.x * _Threshold_Out;
                tmp0.z = tmp0.z * _Threshold_In + tmp0.w;
                tmp0.z = saturate(tmp0.z - _Threshold);
                tmp0.y = tmp0.z * tmp0.y;
                tmp0.z = tmp0.x * tmp0.y;
                tmp0.x = -tmp0.y * tmp0.x + 1.0;
                tmp0.yzw = tmp0.zzz * _Color.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.yzw = saturate(tmp1.xyz * _Tint1.xyz + tmp0.yzw);
                tmp1.x = dot(tmp0.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp1.xyz = tmp1.xxx - tmp0.yzw;
                tmp1.w = 1.0 - _Saturation;
                tmp0.yzw = tmp1.www * tmp1.xyz + tmp0.yzw;
                tmp1.x = tmp0.x * _Metallic;
                o.sv_target1.w = tmp0.x * _Glossiness;
                tmp0.x = -tmp1.x * 0.96 + 0.96;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw;
                tmp0.xyz = tmp0.yzw - float3(0.04, 0.04, 0.04);
                o.sv_target1.xyz = tmp1.xxx * tmp0.xyz + float3(0.04, 0.04, 0.04);
                o.sv_target.w = 1.0;
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