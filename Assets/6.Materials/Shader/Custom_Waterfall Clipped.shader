Shader "Custom/Waterfall Clipped" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_FoamColor ("Foam Color", Color) = (1,1,1,1)
		_NoiseTex ("Noise (RGB)", 2D) = "white" {}
		_NoiseTex2 ("Noise2 (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0
		_NoiseCutoff ("Noise Cutoff", Range(0, 1)) = 0.5
		_FallSpeed ("Fall Speed", Float) = 10
		_WobbleStrength ("Wobble Strength", Float) = 1
		_ReflectionTex ("ReflectionTex", 2D) = "white" {}
		_ReflectionAlpha ("Reflection Alpha", Range(0, 1)) = 1
		[PropertyBlock] _ClipValue ("Clip", Range(0, 1)) = 0
	}
	SubShader {
		LOD 200
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			GpuProgramID 3780
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
			float4 _NoiseTex_ST;
			float4 _NoiseTex2_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Glossiness;
			float _Metallic;
			float _FallSpeed;
			float _ClipValue;
			float4 _FoamColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _NoiseTex2;
			sampler2D _NoiseTex;
			
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
                o.texcoord.xy = v.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _NoiseTex2_ST.xy + _NoiseTex2_ST.zw;
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
                tmp0.xyz = _WorldSpaceCameraPos - inp.texcoord2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2.x = _Time.x * 0.1 + inp.texcoord.z;
                tmp2.yz = _Time.xx * _FallSpeed.xx + inp.texcoord.wy;
                tmp3 = tex2D(_NoiseTex2, tmp2.xy);
                tmp1.w = tmp3.x * tmp3.x;
                tmp1.w = tmp1.w * tmp1.w;
                tmp2.x = tmp3.x * tmp1.w;
                tmp2.w = inp.texcoord.x;
                tmp4 = tex2D(_NoiseTex, tmp2.wz);
                tmp5.xy = inp.texcoord.yx * float2(0.5, 0.5);
                tmp5.z = _Time.x * _FallSpeed + tmp5.x;
                tmp5 = tex2D(_NoiseTex, tmp5.yz);
                tmp2.y = inp.color.x + inp.color.x;
                tmp2.y = tmp4.x * tmp2.y;
                tmp2.y = tmp5.x * tmp2.y;
                tmp1.w = -tmp1.w * tmp3.x + 1.0;
                tmp1.w = inp.color.y * tmp1.w + tmp2.x;
                tmp1.w = tmp2.y * tmp1.w + -_ClipValue;
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
                tmp2.x = 1.0 - _Glossiness;
                tmp2.y = dot(-tmp1.xyz, inp.texcoord1.xyz);
                tmp2.y = tmp2.y + tmp2.y;
                tmp2.yzw = inp.texcoord1.xyz * -tmp2.yyy + -tmp1.xyz;
                tmp3.xyz = tmp1.www * _LightColor0.xyz;
                tmp1.w = unity_SpecCube0_ProbePosition.w > 0.0;
                if (tmp1.w) {
                    tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                    tmp1.w = rsqrt(tmp1.w);
                    tmp4.xyz = tmp1.www * tmp2.yzw;
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
                    tmp4.xyz = tmp2.yzw;
                }
                tmp1.w = -tmp2.x * 0.7 + 1.7;
                tmp1.w = tmp1.w * tmp2.x;
                tmp1.w = tmp1.w * 6.0;
                tmp4 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp4.xyz, tmp1.w));
                tmp3.w = tmp4.w - 1.0;
                tmp3.w = unity_SpecCube0_HDR.w * tmp3.w + 1.0;
                tmp3.w = log(tmp3.w);
                tmp3.w = tmp3.w * unity_SpecCube0_HDR.y;
                tmp3.w = exp(tmp3.w);
                tmp3.w = tmp3.w * unity_SpecCube0_HDR.x;
                tmp5.xyz = tmp4.xyz * tmp3.www;
                tmp4.w = unity_SpecCube0_BoxMin.w < 0.99999;
                if (tmp4.w) {
                    tmp4.w = unity_SpecCube1_ProbePosition.w > 0.0;
                    if (tmp4.w) {
                        tmp4.w = dot(tmp2.xyz, tmp2.xyz);
                        tmp4.w = rsqrt(tmp4.w);
                        tmp6.xyz = tmp2.yzw * tmp4.www;
                        tmp7.xyz = unity_SpecCube1_BoxMax.xyz - inp.texcoord2.xyz;
                        tmp7.xyz = tmp7.xyz / tmp6.xyz;
                        tmp8.xyz = unity_SpecCube1_BoxMin.xyz - inp.texcoord2.xyz;
                        tmp8.xyz = tmp8.xyz / tmp6.xyz;
                        tmp9.xyz = tmp6.xyz > float3(0.0, 0.0, 0.0);
                        tmp7.xyz = tmp9.xyz ? tmp7.xyz : tmp8.xyz;
                        tmp4.w = min(tmp7.y, tmp7.x);
                        tmp4.w = min(tmp7.z, tmp4.w);
                        tmp7.xyz = inp.texcoord2.xyz - unity_SpecCube1_ProbePosition.xyz;
                        tmp2.yzw = tmp6.xyz * tmp4.www + tmp7.xyz;
                    }
                    tmp6 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp2.yzw, tmp1.w));
                    tmp1.w = tmp6.w - 1.0;
                    tmp1.w = unity_SpecCube1_HDR.w * tmp1.w + 1.0;
                    tmp1.w = log(tmp1.w);
                    tmp1.w = tmp1.w * unity_SpecCube1_HDR.y;
                    tmp1.w = exp(tmp1.w);
                    tmp1.w = tmp1.w * unity_SpecCube1_HDR.x;
                    tmp2.yzw = tmp6.xyz * tmp1.www;
                    tmp4.xyz = tmp3.www * tmp4.xyz + -tmp2.yzw;
                    tmp5.xyz = unity_SpecCube0_BoxMin.www * tmp4.xyz + tmp2.yzw;
                }
                tmp1.w = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.yzw = tmp1.www * inp.texcoord1.xyz;
                tmp4.xyz = _FoamColor.xyz - float3(0.04, 0.04, 0.04);
                tmp4.xyz = _Metallic.xxx * tmp4.xyz + float3(0.04, 0.04, 0.04);
                tmp1.w = -_Metallic * 0.96 + 0.96;
                tmp6.xyz = tmp1.www * _FoamColor.xyz;
                tmp0.xyz = tmp0.xyz * tmp0.www + _WorldSpaceLightPos0.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp2.xyz, tmp1.xyz);
                tmp1.x = saturate(dot(tmp2.xyz, _WorldSpaceLightPos0.xyz));
                tmp1.y = saturate(dot(tmp2.xyz, tmp0.xyz));
                tmp0.x = saturate(dot(_WorldSpaceLightPos0.xyz, tmp0.xyz));
                tmp0.y = tmp0.x * tmp0.x;
                tmp0.y = dot(tmp0.xy, tmp2.xy);
                tmp0.y = tmp0.y - 0.5;
                tmp0.z = 1.0 - tmp1.x;
                tmp1.z = tmp0.z * tmp0.z;
                tmp1.z = tmp1.z * tmp1.z;
                tmp0.z = tmp0.z * tmp1.z;
                tmp0.z = tmp0.y * tmp0.z + 1.0;
                tmp1.z = 1.0 - abs(tmp0.w);
                tmp2.y = tmp1.z * tmp1.z;
                tmp2.y = tmp2.y * tmp2.y;
                tmp1.z = tmp1.z * tmp2.y;
                tmp0.y = tmp0.y * tmp1.z + 1.0;
                tmp0.y = tmp0.y * tmp0.z;
                tmp0.z = tmp2.x * tmp2.x;
                tmp0.z = max(tmp0.z, 0.002);
                tmp2.x = 1.0 - tmp0.z;
                tmp2.y = abs(tmp0.w) * tmp2.x + tmp0.z;
                tmp2.x = tmp1.x * tmp2.x + tmp0.z;
                tmp0.w = abs(tmp0.w) * tmp2.x;
                tmp0.w = tmp1.x * tmp2.y + tmp0.w;
                tmp0.w = tmp0.w + 0.00001;
                tmp0.w = 0.5 / tmp0.w;
                tmp2.x = tmp0.z * tmp0.z;
                tmp2.y = tmp1.y * tmp2.x + -tmp1.y;
                tmp1.y = tmp2.y * tmp1.y + 1.0;
                tmp2.x = tmp2.x * 0.3183099;
                tmp1.y = tmp1.y * tmp1.y + 0.0000001;
                tmp1.y = tmp2.x / tmp1.y;
                tmp0.w = tmp0.w * tmp1.y;
                tmp0.w = tmp0.w * 3.141593;
                tmp0.yw = tmp1.xx * tmp0.yw;
                tmp0.w = max(tmp0.w, 0.0);
                tmp0.z = tmp0.z * tmp0.z + 1.0;
                tmp0.z = 1.0 / tmp0.z;
                tmp1.x = dot(tmp4.xyz, tmp4.xyz);
                tmp1.x = tmp1.x != 0.0;
                tmp1.x = tmp1.x ? 1.0 : 0.0;
                tmp0.w = tmp0.w * tmp1.x;
                tmp1.x = _Glossiness - tmp1.w;
                tmp1.x = saturate(tmp1.x + 1.0);
                tmp2.xyz = tmp0.yyy * tmp3.xyz;
                tmp3.xyz = tmp3.xyz * tmp0.www;
                tmp0.x = 1.0 - tmp0.x;
                tmp0.y = tmp0.x * tmp0.x;
                tmp0.y = tmp0.y * tmp0.y;
                tmp0.x = tmp0.x * tmp0.y;
                tmp7.xyz = float3(1.0, 1.0, 1.0) - tmp4.xyz;
                tmp0.xyw = tmp7.xyz * tmp0.xxx + tmp4.xyz;
                tmp0.xyw = tmp0.xyw * tmp3.xyz;
                tmp0.xyw = tmp6.xyz * tmp2.xyz + tmp0.xyw;
                tmp2.xyz = tmp5.xyz * tmp0.zzz;
                tmp1.xyw = tmp1.xxx - tmp4.xyz;
                tmp1.xyz = tmp1.zzz * tmp1.xyw + tmp4.xyz;
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
			GpuProgramID 122683
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
			float4 _NoiseTex_ST;
			float4 _NoiseTex2_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Glossiness;
			float _Metallic;
			float _FallSpeed;
			float _ClipValue;
			float4 _FoamColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _NoiseTex2;
			sampler2D _NoiseTex;
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
                o.texcoord.xy = v.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _NoiseTex2_ST.xy + _NoiseTex2_ST.zw;
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
                tmp3.x = _Time.x * 0.1 + inp.texcoord.z;
                tmp3.yz = _Time.xx * _FallSpeed.xx + inp.texcoord.wy;
                tmp4 = tex2D(_NoiseTex2, tmp3.xy);
                tmp1.w = tmp4.x * tmp4.x;
                tmp1.w = tmp1.w * tmp1.w;
                tmp2.w = tmp4.x * tmp1.w;
                tmp3.w = inp.texcoord.x;
                tmp3 = tex2D(_NoiseTex, tmp3.wz);
                tmp5.xy = inp.texcoord.yx * float2(0.5, 0.5);
                tmp5.z = _Time.x * _FallSpeed + tmp5.x;
                tmp5 = tex2D(_NoiseTex, tmp5.yz);
                tmp3.y = inp.color.x + inp.color.x;
                tmp3.x = tmp3.x * tmp3.y;
                tmp3.x = tmp5.x * tmp3.x;
                tmp1.w = -tmp1.w * tmp4.x + 1.0;
                tmp1.w = inp.color.y * tmp1.w + tmp2.w;
                tmp1.w = tmp3.x * tmp1.w + -_ClipValue;
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
                tmp5.xyz = _FoamColor.xyz - float3(0.04, 0.04, 0.04);
                tmp5.xyz = _Metallic.xxx * tmp5.xyz + float3(0.04, 0.04, 0.04);
                tmp1.w = -_Metallic * 0.96 + 0.96;
                tmp6.xyz = tmp1.www * _FoamColor.xyz;
                tmp1.w = 1.0 - _Glossiness;
                tmp0.xyz = tmp0.xyz * tmp0.www + tmp2.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = saturate(dot(tmp4.xyz, tmp1.xyz));
                tmp2.y = saturate(dot(tmp4.xyz, tmp0.xyz));
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
                tmp0.w = dot(tmp5.xyz, tmp5.xyz);
                tmp0.w = tmp0.w != 0.0;
                tmp0.w = tmp0.w ? 1.0 : 0.0;
                tmp0.z = tmp0.w * tmp0.z;
                tmp1.xyz = tmp0.yyy * tmp3.xyz;
                tmp0.yzw = tmp3.xyz * tmp0.zzz;
                tmp0.x = 1.0 - tmp0.x;
                tmp1.w = tmp0.x * tmp0.x;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.x = tmp0.x * tmp1.w;
                tmp2.xyz = float3(1.0, 1.0, 1.0) - tmp5.xyz;
                tmp2.xyz = tmp2.xyz * tmp0.xxx + tmp5.xyz;
                tmp0.xyz = tmp0.yzw * tmp2.xyz;
                o.sv_target.xyz = tmp6.xyz * tmp1.xyz + tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "DEFERRED"
			LOD 200
			Tags { "LIGHTMODE" = "DEFERRED" "RenderType" = "Opaque" }
			GpuProgramID 188232
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
			float4 _NoiseTex_ST;
			float4 _NoiseTex2_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float _Glossiness;
			float _Metallic;
			float _FallSpeed;
			float _ClipValue;
			float4 _FoamColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _NoiseTex2;
			sampler2D _NoiseTex;
			
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
                o.texcoord.xy = v.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _NoiseTex2_ST.xy + _NoiseTex2_ST.zw;
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
                float4 tmp2;
                tmp0.xy = inp.texcoord.yx * float2(0.5, 0.5);
                tmp0.z = _Time.x * _FallSpeed + tmp0.x;
                tmp0 = tex2D(_NoiseTex, tmp0.yz);
                tmp1.w = inp.texcoord.x;
                tmp1.yz = _Time.xx * _FallSpeed.xx + inp.texcoord.wy;
                tmp2 = tex2D(_NoiseTex, tmp1.wz);
                tmp0.y = inp.color.x + inp.color.x;
                tmp0.y = tmp2.x * tmp0.y;
                tmp0.x = tmp0.x * tmp0.y;
                tmp1.x = _Time.x * 0.1 + inp.texcoord.z;
                tmp1 = tex2D(_NoiseTex2, tmp1.xy);
                tmp0.y = tmp1.x * tmp1.x;
                tmp0.y = tmp0.y * tmp0.y;
                tmp0.z = tmp1.x * tmp0.y;
                tmp0.y = -tmp0.y * tmp1.x + 1.0;
                tmp0.y = inp.color.y * tmp0.y + tmp0.z;
                tmp0.x = tmp0.x * tmp0.y + -_ClipValue;
                tmp0.x = tmp0.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                tmp0.x = -_Metallic * 0.96 + 0.96;
                o.sv_target.xyz = tmp0.xxx * _FoamColor.xyz;
                o.sv_target.w = 1.0;
                tmp0.xyz = _FoamColor.xyz - float3(0.04, 0.04, 0.04);
                o.sv_target1.xyz = _Metallic.xxx * tmp0.xyz + float3(0.04, 0.04, 0.04);
                o.sv_target1.w = _Glossiness;
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