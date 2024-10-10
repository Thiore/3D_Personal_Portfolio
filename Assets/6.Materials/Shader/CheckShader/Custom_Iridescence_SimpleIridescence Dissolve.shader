Shader "Custom/Iridescence/SimpleIridescence Dissolve" {
	Properties {
		[Space(20)] [Header(MainTex and ColorRamp)] [Space(20)] _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_ColorRamp ("ColorRamp", 2D) = "white" {}
		_Blend ("Blend", Range(0, 1)) = 0.5
		[Space(20)] [Header(Dissolve)] [Space(20)] _DissolveTex ("Dissolve Guide (RGB)", 2D) = "white" {}
		[PropertyBlock] _DissolveAmount ("Dissolve Amount", Range(0, 1.01)) = 0.5
		[Space(20)] [Header(Mask)] [Space(20)] _Mask ("Mask", 2D) = "white" {}
		[Space(20)] [Header(BumpMap and BumpPower)] [Space(20)] _BumpMap ("Bumpmap", 2D) = "bump" {}
		_BumpPower ("BumpPower", Range(0.1, 1)) = 0.1
		[Space(20)] [Header(Change ColorRamp)] [Space(20)] _Hue ("Hue", Range(0, 1)) = 0
		_Saturation ("Saturation", Range(0, 1)) = 0.5
		_FinalSaturation ("Final Saturation", Range(0, 1)) = 1
		_Brightness ("Brightness", Range(0, 1)) = 0.5
		_Contrast ("Contrast", Range(0, 1)) = 0.5
		[Space(20)] [Header(Smoothness and Metallic)] [Space(20)] _Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0
		[PropertyBlock] _Glow ("Glow", Range(0, 1)) = 0
		_GlowColor ("Glow Color", Color) = (1,1,1,1)
		_CrackTex ("Cracks (RGB)", 2D) = "black" {}
		_CrackTexFat ("Cracks Fat (RGB)", 2D) = "black" {}
		_CrackColor ("Crack Color", Color) = (1,1,1,1)
		[PropertyBlock] _CrackAmount ("Crack Amount", Float) = 0
		_CrackGlow ("Crack Glow", Float) = 0
		[PropertyBlock] _PulseOrigin ("Pulse Coords", Vector) = (0,0,0,0)
		[PropertyBlock] _PulseRadius ("Pulse Radius", Float) = 0
	}
	SubShader {
		LOD 200
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Cull Off
			GpuProgramID 31060
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				float4 texcoord4 : TEXCOORD4;
				float4 texcoord6 : TEXCOORD6;
				float4 texcoord7 : TEXCOORD7;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float4 _CrackTex_ST;
			float4 _Mask_ST;
			float4 _BumpMap_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _CrackAmount;
			float3 _PulseOrigin;
			float _PulseRadius;
			float4 _ColorRamp_ST;
			float _Glossiness;
			float _Metallic;
			float _Blend;
			float _BumpPower;
			float _Hue;
			float _Saturation;
			float _Brightness;
			float _Contrast;
			float _FinalSaturation;
			float _DissolveAmount;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DissolveTex;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _Mask;
			sampler2D _ColorRamp;
			sampler2D _CrackTexFat;
			
			// Keywords: DIRECTIONAL
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
                tmp0.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp2 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp2;
                tmp2 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp2;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp2;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _CrackTex_ST.xy + _CrackTex_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
                o.texcoord1.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                o.texcoord2.w = tmp0.x;
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.x = dot(tmp1.xyz, tmp1.xyz);
                tmp0.x = rsqrt(tmp0.x);
                tmp1.xyz = tmp0.xxx * tmp1.xyz;
                tmp2.xyz = v.tangent.yyy * unity_ObjectToWorld._m11_m21_m01;
                tmp2.xyz = unity_ObjectToWorld._m10_m20_m00 * v.tangent.xxx + tmp2.xyz;
                tmp2.xyz = unity_ObjectToWorld._m12_m22_m02 * v.tangent.zzz + tmp2.xyz;
                tmp0.x = dot(tmp2.xyz, tmp2.xyz);
                tmp0.x = rsqrt(tmp0.x);
                tmp2.xyz = tmp0.xxx * tmp2.xyz;
                tmp3.xyz = tmp1.xyz * tmp2.xyz;
                tmp3.xyz = tmp1.zxy * tmp2.yzx + -tmp3.xyz;
                tmp0.x = v.tangent.w * unity_WorldTransformParams.w;
                tmp3.xyz = tmp0.xxx * tmp3.xyz;
                o.texcoord2.y = tmp3.x;
                o.texcoord2.x = tmp2.z;
                o.texcoord2.z = tmp1.y;
                o.texcoord3.x = tmp2.x;
                o.texcoord4.x = tmp2.y;
                o.texcoord3.z = tmp1.z;
                o.texcoord4.z = tmp1.x;
                o.texcoord3.w = tmp0.y;
                o.texcoord4.w = tmp0.z;
                o.texcoord3.y = tmp3.y;
                o.texcoord4.y = tmp3.z;
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
                float4 tmp11;
                float4 tmp12;
                tmp0.x = inp.texcoord2.w;
                tmp0.y = inp.texcoord3.w;
                tmp0.z = inp.texcoord4.w;
                tmp1.xyz = _WorldSpaceCameraPos - tmp0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp2.xyz = tmp0.www * tmp1.xyz;
                tmp3.xyz = tmp2.yyy * inp.texcoord3.xyz;
                tmp3.xyz = inp.texcoord2.xyz * tmp2.xxx + tmp3.xyz;
                tmp3.xyz = inp.texcoord4.xyz * tmp2.zzz + tmp3.xyz;
                tmp4 = tex2D(_DissolveTex, inp.texcoord.xy);
                tmp1.w = tmp4.x - _DissolveAmount;
                tmp1.w = tmp1.w < 0.0;
                if (tmp1.w) {
                    discard;
                }
                tmp4 = tex2D(_MainTex, inp.texcoord.xy);
                tmp5 = tex2D(_BumpMap, inp.texcoord1.zw);
                tmp5.x = tmp5.w * tmp5.x;
                tmp5.xy = tmp5.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                tmp1.w = dot(tmp5.xy, tmp5.xy);
                tmp1.w = min(tmp1.w, 1.0);
                tmp1.w = 1.0 - tmp1.w;
                tmp1.w = sqrt(tmp1.w);
                tmp5.z = tmp1.w / _BumpPower;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp5.xyz = tmp1.www * tmp5.xyz;
                tmp3.y = tmp3.y + _SinTime.z;
                tmp3.x = tmp3.x + _CosTime.z;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp3.xyz = tmp1.www * tmp3.xyz;
                tmp1.w = dot(tmp3.xyz, tmp5.xyz);
                tmp3 = tex2D(_Mask, inp.texcoord1.xy);
                tmp6.xy = tmp1.ww * _ColorRamp_ST.xy + _ColorRamp_ST.zw;
                tmp6 = tex2D(_ColorRamp, tmp6.xy);
                tmp6.xyz = tmp3.xyz * tmp6.xyz;
                tmp3.yzw = float3(1.0, 1.0, 1.0) - tmp3.xyz;
                tmp3.yzw = tmp4.xyz * tmp3.yzw;
                tmp3.yzw = max(tmp3.yzw, tmp6.xyz);
                tmp1.w = _Saturation + _Saturation;
                tmp2.w = _Brightness * 2.0 + -1.0;
                tmp4.w = _Contrast + _Contrast;
                tmp5.w = _Hue * 6.283185;
                tmp6.x = sin(tmp5.w);
                tmp7.x = cos(tmp5.w);
                tmp6.yzw = tmp3.wyz * float3(0.57735, 0.57735, 0.57735);
                tmp6.yzw = tmp3.wyz * float3(0.57735, 0.57735, 0.57735) + -tmp6.wyz;
                tmp6.xyz = tmp6.xxx * tmp6.yzw;
                tmp6.xyz = tmp3.yzw * tmp7.xxx + tmp6.xyz;
                tmp3.y = dot(float3(0.57735, 0.57735, 0.57735), tmp3.xyz);
                tmp3.y = tmp3.y * 0.57735;
                tmp3.z = 1.0 - tmp7.x;
                tmp3.yzw = tmp3.yyy * tmp3.zzz + tmp6.xyz;
                tmp3.yzw = tmp3.yzw - float3(0.5, 0.5, 0.5);
                tmp3.yzw = tmp3.yzw * tmp4.www + float3(0.5, 0.5, 0.5);
                tmp3.yzw = tmp2.www + tmp3.yzw;
                tmp2.w = dot(tmp3.xyz, float3(0.39, 0.59, 0.11));
                tmp3.yzw = tmp3.yzw - tmp2.www;
                tmp3.yzw = tmp1.www * tmp3.yzw + tmp2.www;
                tmp3.yzw = tmp3.yzw - tmp4.xyz;
                tmp3.yzw = _Blend.xxx * tmp3.yzw + tmp4.xyz;
                tmp4.xyz = _PulseOrigin - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp4.xyz);
                tmp1.w = sqrt(tmp1.w);
                tmp1.w = tmp1.w - _PulseRadius;
                tmp1.w = tmp1.w * tmp1.w;
                tmp1.w = 1.0 / tmp1.w;
                tmp1.w = min(tmp1.w, 5.0);
                tmp1.w = tmp1.w + 1.0;
                tmp4 = tex2D(_CrackTexFat, inp.texcoord.xy);
                tmp2.w = tmp4.x * _CrackAmount;
                tmp1.w = -tmp2.w * tmp1.w + 1.0;
                tmp1.w = tmp1.w * 0.7;
                tmp4.xyz = tmp1.www * tmp3.yzw;
                tmp2.w = dot(tmp4.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp4.w = 1.0 - _FinalSaturation;
                tmp3.yzw = -tmp3.yzw * tmp1.www + tmp2.www;
                tmp3.yzw = tmp4.www * tmp3.yzw + tmp4.xyz;
                tmp1.w = tmp3.x * _Metallic;
                tmp2.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp2.w) {
                    tmp2.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp4.xyz = inp.texcoord3.www * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp4.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.www + tmp4.xyz;
                    tmp4.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord4.www + tmp4.xyz;
                    tmp4.xyz = tmp4.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp4.xyz = tmp2.www ? tmp4.xyz : tmp0.xyz;
                    tmp4.xyz = tmp4.xyz - unity_ProbeVolumeMin;
                    tmp4.yzw = tmp4.xyz * unity_ProbeVolumeSizeInv;
                    tmp2.w = tmp4.y * 0.25 + 0.75;
                    tmp4.y = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp4.x = max(tmp2.w, tmp4.y);
                    tmp4 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp4.xzw);
                } else {
                    tmp4 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp2.w = saturate(dot(tmp4, unity_OcclusionMaskSelector));
                tmp4.x = dot(inp.texcoord2.xyz, tmp5.xyz);
                tmp4.y = dot(inp.texcoord3.xyz, tmp5.xyz);
                tmp4.z = dot(inp.texcoord4.xyz, tmp5.xyz);
                tmp4.w = dot(tmp4.xyz, tmp4.xyz);
                tmp4.w = rsqrt(tmp4.w);
                tmp4.xyz = tmp4.www * tmp4.xyz;
                tmp4.w = -_Glossiness * tmp3.x + 1.0;
                tmp5.x = dot(-tmp2.xyz, tmp4.xyz);
                tmp5.x = tmp5.x + tmp5.x;
                tmp5.xyz = tmp4.xyz * -tmp5.xxx + -tmp2.xyz;
                tmp6.xyz = tmp2.www * _LightColor0.xyz;
                tmp2.w = unity_SpecCube0_ProbePosition.w > 0.0;
                if (tmp2.w) {
                    tmp2.w = dot(tmp5.xyz, tmp5.xyz);
                    tmp2.w = rsqrt(tmp2.w);
                    tmp7.xyz = tmp2.www * tmp5.xyz;
                    tmp8.xyz = unity_SpecCube0_BoxMax.xyz - tmp0.xyz;
                    tmp8.xyz = tmp8.xyz / tmp7.xyz;
                    tmp9.xyz = unity_SpecCube0_BoxMin.xyz - tmp0.xyz;
                    tmp9.xyz = tmp9.xyz / tmp7.xyz;
                    tmp10.xyz = tmp7.xyz > float3(0.0, 0.0, 0.0);
                    tmp8.xyz = tmp10.xyz ? tmp8.xyz : tmp9.xyz;
                    tmp2.w = min(tmp8.y, tmp8.x);
                    tmp2.w = min(tmp8.z, tmp2.w);
                    tmp8.xyz = tmp0.xyz - unity_SpecCube0_ProbePosition.xyz;
                    tmp7.xyz = tmp7.xyz * tmp2.www + tmp8.xyz;
                } else {
                    tmp7.xyz = tmp5.xyz;
                }
                tmp2.w = -tmp4.w * 0.7 + 1.7;
                tmp2.w = tmp2.w * tmp4.w;
                tmp2.w = tmp2.w * 6.0;
                tmp7 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp7.xyz, tmp2.w));
                tmp5.w = tmp7.w - 1.0;
                tmp5.w = unity_SpecCube0_HDR.w * tmp5.w + 1.0;
                tmp5.w = log(tmp5.w);
                tmp5.w = tmp5.w * unity_SpecCube0_HDR.y;
                tmp5.w = exp(tmp5.w);
                tmp5.w = tmp5.w * unity_SpecCube0_HDR.x;
                tmp8.xyz = tmp7.xyz * tmp5.www;
                tmp6.w = unity_SpecCube0_BoxMin.w < 0.99999;
                if (tmp6.w) {
                    tmp6.w = unity_SpecCube1_ProbePosition.w > 0.0;
                    if (tmp6.w) {
                        tmp6.w = dot(tmp5.xyz, tmp5.xyz);
                        tmp6.w = rsqrt(tmp6.w);
                        tmp9.xyz = tmp5.xyz * tmp6.www;
                        tmp10.xyz = unity_SpecCube1_BoxMax.xyz - tmp0.xyz;
                        tmp10.xyz = tmp10.xyz / tmp9.xyz;
                        tmp11.xyz = unity_SpecCube1_BoxMin.xyz - tmp0.xyz;
                        tmp11.xyz = tmp11.xyz / tmp9.xyz;
                        tmp12.xyz = tmp9.xyz > float3(0.0, 0.0, 0.0);
                        tmp10.xyz = tmp12.xyz ? tmp10.xyz : tmp11.xyz;
                        tmp6.w = min(tmp10.y, tmp10.x);
                        tmp6.w = min(tmp10.z, tmp6.w);
                        tmp0.xyz = tmp0.xyz - unity_SpecCube1_ProbePosition.xyz;
                        tmp5.xyz = tmp9.xyz * tmp6.www + tmp0.xyz;
                    }
                    tmp9 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp5.xyz, tmp2.w));
                    tmp0.x = tmp9.w - 1.0;
                    tmp0.x = unity_SpecCube1_HDR.w * tmp0.x + 1.0;
                    tmp0.x = log(tmp0.x);
                    tmp0.x = tmp0.x * unity_SpecCube1_HDR.y;
                    tmp0.x = exp(tmp0.x);
                    tmp0.x = tmp0.x * unity_SpecCube1_HDR.x;
                    tmp0.xyz = tmp9.xyz * tmp0.xxx;
                    tmp5.xyz = tmp5.www * tmp7.xyz + -tmp0.xyz;
                    tmp8.xyz = unity_SpecCube0_BoxMin.www * tmp5.xyz + tmp0.xyz;
                }
                tmp0.xyz = tmp3.yzw - float3(0.04, 0.04, 0.04);
                tmp0.xyz = tmp1.www * tmp0.xyz + float3(0.04, 0.04, 0.04);
                tmp1.w = -tmp1.w * 0.96 + 0.96;
                tmp3.yzw = tmp1.www * tmp3.yzw;
                tmp1.xyz = tmp1.xyz * tmp0.www + _WorldSpaceLightPos0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = max(tmp0.w, 0.001);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                tmp0.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = saturate(dot(tmp4.xyz, _WorldSpaceLightPos0.xyz));
                tmp2.y = saturate(dot(tmp4.xyz, tmp1.xyz));
                tmp1.x = saturate(dot(_WorldSpaceLightPos0.xyz, tmp1.xyz));
                tmp1.y = tmp1.x * tmp1.x;
                tmp1.y = dot(tmp1.xy, tmp4.xy);
                tmp1.y = tmp1.y - 0.5;
                tmp1.z = 1.0 - tmp2.x;
                tmp2.z = tmp1.z * tmp1.z;
                tmp2.z = tmp2.z * tmp2.z;
                tmp1.z = tmp1.z * tmp2.z;
                tmp1.z = tmp1.y * tmp1.z + 1.0;
                tmp2.z = 1.0 - abs(tmp0.w);
                tmp2.w = tmp2.z * tmp2.z;
                tmp2.w = tmp2.w * tmp2.w;
                tmp2.z = tmp2.z * tmp2.w;
                tmp1.y = tmp1.y * tmp2.z + 1.0;
                tmp1.y = tmp1.y * tmp1.z;
                tmp1.y = tmp2.x * tmp1.y;
                tmp1.z = tmp4.w * tmp4.w;
                tmp1.z = max(tmp1.z, 0.002);
                tmp2.w = 1.0 - tmp1.z;
                tmp4.x = abs(tmp0.w) * tmp2.w + tmp1.z;
                tmp2.w = tmp2.x * tmp2.w + tmp1.z;
                tmp0.w = abs(tmp0.w) * tmp2.w;
                tmp0.w = tmp2.x * tmp4.x + tmp0.w;
                tmp0.w = tmp0.w + 0.00001;
                tmp0.w = 0.5 / tmp0.w;
                tmp2.w = tmp1.z * tmp1.z;
                tmp4.x = tmp2.y * tmp2.w + -tmp2.y;
                tmp2.y = tmp4.x * tmp2.y + 1.0;
                tmp2.w = tmp2.w * 0.3183099;
                tmp2.y = tmp2.y * tmp2.y + 0.0000001;
                tmp2.y = tmp2.w / tmp2.y;
                tmp0.w = tmp0.w * tmp2.y;
                tmp0.w = tmp0.w * 3.141593;
                tmp0.w = tmp2.x * tmp0.w;
                tmp0.w = max(tmp0.w, 0.0);
                tmp1.z = tmp1.z * tmp1.z + 1.0;
                tmp1.z = 1.0 / tmp1.z;
                tmp2.x = dot(tmp0.xyz, tmp0.xyz);
                tmp2.x = tmp2.x != 0.0;
                tmp2.x = tmp2.x ? 1.0 : 0.0;
                tmp0.w = tmp0.w * tmp2.x;
                tmp1.w = _Glossiness * tmp3.x + -tmp1.w;
                tmp1.w = saturate(tmp1.w + 1.0);
                tmp2.xyw = tmp1.yyy * tmp6.xyz;
                tmp4.xyz = tmp6.xyz * tmp0.www;
                tmp0.w = 1.0 - tmp1.x;
                tmp1.x = tmp0.w * tmp0.w;
                tmp1.x = tmp1.x * tmp1.x;
                tmp0.w = tmp0.w * tmp1.x;
                tmp5.xyz = float3(1.0, 1.0, 1.0) - tmp0.xyz;
                tmp5.xyz = tmp5.xyz * tmp0.www + tmp0.xyz;
                tmp4.xyz = tmp4.xyz * tmp5.xyz;
                tmp2.xyw = tmp3.yzw * tmp2.xyw + tmp4.xyz;
                tmp1.xyz = tmp8.xyz * tmp1.zzz;
                tmp3.xyz = tmp1.www - tmp0.xyz;
                tmp0.xyz = tmp2.zzz * tmp3.xyz + tmp0.xyz;
                o.sv_target.xyz = tmp1.xyz * tmp0.xyz + tmp2.xyw;
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
			GpuProgramID 118987
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float3 texcoord4 : TEXCOORD4;
				float3 texcoord5 : TEXCOORD5;
				float3 texcoord6 : TEXCOORD6;
				float4 texcoord7 : TEXCOORD7;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float4 _MainTex_ST;
			float4 _Mask_ST;
			float4 _BumpMap_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _CrackAmount;
			float3 _PulseOrigin;
			float _PulseRadius;
			float4 _ColorRamp_ST;
			float _Glossiness;
			float _Metallic;
			float _Blend;
			float _BumpPower;
			float _Hue;
			float _Saturation;
			float _Brightness;
			float _Contrast;
			float _FinalSaturation;
			float _DissolveAmount;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DissolveTex;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _Mask;
			sampler2D _ColorRamp;
			sampler2D _CrackTexFat;
			sampler2D _LightTexture0;
			
			// Keywords: POINT
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
                tmp2 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp2;
                tmp2 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp2;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp2;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.xyz = tmp1.www * tmp1.xyz;
                tmp2.xyz = v.tangent.yyy * unity_ObjectToWorld._m11_m21_m01;
                tmp2.xyz = unity_ObjectToWorld._m10_m20_m00 * v.tangent.xxx + tmp2.xyz;
                tmp2.xyz = unity_ObjectToWorld._m12_m22_m02 * v.tangent.zzz + tmp2.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp3.xyz = tmp1.xyz * tmp2.xyz;
                tmp3.xyz = tmp1.zxy * tmp2.yzx + -tmp3.xyz;
                tmp1.w = v.tangent.w * unity_WorldTransformParams.w;
                tmp3.xyz = tmp1.www * tmp3.xyz;
                o.texcoord2.y = tmp3.x;
                o.texcoord2.x = tmp2.z;
                o.texcoord2.z = tmp1.y;
                o.texcoord3.x = tmp2.x;
                o.texcoord4.x = tmp2.y;
                o.texcoord3.z = tmp1.z;
                o.texcoord4.z = tmp1.x;
                o.texcoord3.y = tmp3.y;
                o.texcoord4.y = tmp3.z;
                o.texcoord5.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp1.xyz = tmp0.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToLight._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                o.texcoord6.xyz = unity_WorldToLight._m03_m13_m23 * tmp0.www + tmp0.xyz;
                o.texcoord7 = float4(0.0, 0.0, 0.0, 0.0);
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
                float4 tmp7;
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord5.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2.xyz = _WorldSpaceCameraPos - inp.texcoord5.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp3.xyz = tmp2.yyy * inp.texcoord3.xyz;
                tmp3.xyz = inp.texcoord2.xyz * tmp2.xxx + tmp3.xyz;
                tmp3.xyz = inp.texcoord4.xyz * tmp2.zzz + tmp3.xyz;
                tmp4 = tex2D(_DissolveTex, inp.texcoord.xy);
                tmp1.w = tmp4.x - _DissolveAmount;
                tmp1.w = tmp1.w < 0.0;
                if (tmp1.w) {
                    discard;
                }
                tmp4 = tex2D(_MainTex, inp.texcoord.xy);
                tmp5 = tex2D(_BumpMap, inp.texcoord1.xy);
                tmp5.x = tmp5.w * tmp5.x;
                tmp5.xy = tmp5.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                tmp1.w = dot(tmp5.xy, tmp5.xy);
                tmp1.w = min(tmp1.w, 1.0);
                tmp1.w = 1.0 - tmp1.w;
                tmp1.w = sqrt(tmp1.w);
                tmp5.z = tmp1.w / _BumpPower;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp5.xyz = tmp1.www * tmp5.xyz;
                tmp3.y = tmp3.y + _SinTime.z;
                tmp3.x = tmp3.x + _CosTime.z;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp3.xyz = tmp1.www * tmp3.xyz;
                tmp1.w = dot(tmp3.xyz, tmp5.xyz);
                tmp3 = tex2D(_Mask, inp.texcoord.zw);
                tmp6.xy = tmp1.ww * _ColorRamp_ST.xy + _ColorRamp_ST.zw;
                tmp6 = tex2D(_ColorRamp, tmp6.xy);
                tmp6.xyz = tmp3.xyz * tmp6.xyz;
                tmp3.yzw = float3(1.0, 1.0, 1.0) - tmp3.xyz;
                tmp3.yzw = tmp4.xyz * tmp3.yzw;
                tmp3.yzw = max(tmp3.yzw, tmp6.xyz);
                tmp1.w = _Saturation + _Saturation;
                tmp2.w = _Brightness * 2.0 + -1.0;
                tmp4.w = _Contrast + _Contrast;
                tmp5.w = _Hue * 6.283185;
                tmp6.x = sin(tmp5.w);
                tmp7.x = cos(tmp5.w);
                tmp6.yzw = tmp3.wyz * float3(0.57735, 0.57735, 0.57735);
                tmp6.yzw = tmp3.wyz * float3(0.57735, 0.57735, 0.57735) + -tmp6.wyz;
                tmp6.xyz = tmp6.xxx * tmp6.yzw;
                tmp6.xyz = tmp3.yzw * tmp7.xxx + tmp6.xyz;
                tmp3.y = dot(float3(0.57735, 0.57735, 0.57735), tmp3.xyz);
                tmp3.y = tmp3.y * 0.57735;
                tmp3.z = 1.0 - tmp7.x;
                tmp3.yzw = tmp3.yyy * tmp3.zzz + tmp6.xyz;
                tmp3.yzw = tmp3.yzw - float3(0.5, 0.5, 0.5);
                tmp3.yzw = tmp3.yzw * tmp4.www + float3(0.5, 0.5, 0.5);
                tmp3.yzw = tmp2.www + tmp3.yzw;
                tmp2.w = dot(tmp3.xyz, float3(0.39, 0.59, 0.11));
                tmp3.yzw = tmp3.yzw - tmp2.www;
                tmp3.yzw = tmp1.www * tmp3.yzw + tmp2.www;
                tmp3.yzw = tmp3.yzw - tmp4.xyz;
                tmp3.yzw = _Blend.xxx * tmp3.yzw + tmp4.xyz;
                tmp4.xyz = _PulseOrigin - inp.texcoord5.xyz;
                tmp1.w = dot(tmp4.xyz, tmp4.xyz);
                tmp1.w = sqrt(tmp1.w);
                tmp1.w = tmp1.w - _PulseRadius;
                tmp1.w = tmp1.w * tmp1.w;
                tmp1.w = 1.0 / tmp1.w;
                tmp1.w = min(tmp1.w, 5.0);
                tmp1.w = tmp1.w + 1.0;
                tmp4 = tex2D(_CrackTexFat, inp.texcoord.xy);
                tmp2.w = tmp4.x * _CrackAmount;
                tmp1.w = -tmp2.w * tmp1.w + 1.0;
                tmp1.w = tmp1.w * 0.7;
                tmp4.xyz = tmp1.www * tmp3.yzw;
                tmp2.w = dot(tmp4.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp4.w = 1.0 - _FinalSaturation;
                tmp3.yzw = -tmp3.yzw * tmp1.www + tmp2.www;
                tmp3.yzw = tmp4.www * tmp3.yzw + tmp4.xyz;
                tmp1.w = tmp3.x * _Metallic;
                tmp4.xyz = inp.texcoord5.yyy * unity_WorldToLight._m01_m11_m21;
                tmp4.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord5.xxx + tmp4.xyz;
                tmp4.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord5.zzz + tmp4.xyz;
                tmp4.xyz = tmp4.xyz + unity_WorldToLight._m03_m13_m23;
                tmp2.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp2.w) {
                    tmp2.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp6.xyz = inp.texcoord5.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp6.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord5.xxx + tmp6.xyz;
                    tmp6.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord5.zzz + tmp6.xyz;
                    tmp6.xyz = tmp6.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp6.xyz = tmp2.www ? tmp6.xyz : inp.texcoord5.xyz;
                    tmp6.xyz = tmp6.xyz - unity_ProbeVolumeMin;
                    tmp6.yzw = tmp6.xyz * unity_ProbeVolumeSizeInv;
                    tmp2.w = tmp6.y * 0.25 + 0.75;
                    tmp4.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp6.x = max(tmp2.w, tmp4.w);
                    tmp6 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp6.xzw);
                } else {
                    tmp6 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp2.w = saturate(dot(tmp6, unity_OcclusionMaskSelector));
                tmp4.x = dot(tmp4.xyz, tmp4.xyz);
                tmp4 = tex2D(_LightTexture0, tmp4.xx);
                tmp2.w = tmp2.w * tmp4.x;
                tmp4.x = dot(inp.texcoord2.xyz, tmp5.xyz);
                tmp4.y = dot(inp.texcoord3.xyz, tmp5.xyz);
                tmp4.z = dot(inp.texcoord4.xyz, tmp5.xyz);
                tmp4.w = dot(tmp4.xyz, tmp4.xyz);
                tmp4.w = rsqrt(tmp4.w);
                tmp4.xyz = tmp4.www * tmp4.xyz;
                tmp5.xyz = tmp2.www * _LightColor0.xyz;
                tmp6.xyz = tmp3.yzw - float3(0.04, 0.04, 0.04);
                tmp6.xyz = tmp1.www * tmp6.xyz + float3(0.04, 0.04, 0.04);
                tmp1.w = -tmp1.w * 0.96 + 0.96;
                tmp3.yzw = tmp1.www * tmp3.yzw;
                tmp1.w = -_Glossiness * tmp3.x + 1.0;
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
                tmp0.w = dot(tmp6.xyz, tmp6.xyz);
                tmp0.w = tmp0.w != 0.0;
                tmp0.w = tmp0.w ? 1.0 : 0.0;
                tmp0.z = tmp0.w * tmp0.z;
                tmp1.xyz = tmp0.yyy * tmp5.xyz;
                tmp0.yzw = tmp5.xyz * tmp0.zzz;
                tmp0.x = 1.0 - tmp0.x;
                tmp1.w = tmp0.x * tmp0.x;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.x = tmp0.x * tmp1.w;
                tmp2.xyz = float3(1.0, 1.0, 1.0) - tmp6.xyz;
                tmp2.xyz = tmp2.xyz * tmp0.xxx + tmp6.xyz;
                tmp0.xyz = tmp0.yzw * tmp2.xyz;
                o.sv_target.xyz = tmp3.yzw * tmp1.xyz + tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "DEFERRED"
			LOD 200
			Tags { "LIGHTMODE" = "DEFERRED" "RenderType" = "Opaque" }
			Cull Off
			GpuProgramID 195402
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				float4 texcoord4 : TEXCOORD4;
				float3 texcoord5 : TEXCOORD5;
				float4 texcoord6 : TEXCOORD6;
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
			float4 _CrackTex_ST;
			float4 _Mask_ST;
			float4 _BumpMap_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float _CrackAmount;
			float _CrackGlow;
			float4 _CrackColor;
			float3 _PulseOrigin;
			float _PulseRadius;
			float4 _ColorRamp_ST;
			float _Glossiness;
			float _Metallic;
			float _Blend;
			float _BumpPower;
			float4 _GlowColor;
			float _Glow;
			float _Hue;
			float _Saturation;
			float _Brightness;
			float _Contrast;
			float _FinalSaturation;
			float _DissolveAmount;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DissolveTex;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D _Mask;
			sampler2D _ColorRamp;
			sampler2D _CrackTex;
			sampler2D _CrackTexFat;
			
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
                tmp0.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp2 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp2;
                tmp2 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp2;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp2;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.texcoord.zw = v.texcoord.xy * _CrackTex_ST.xy + _CrackTex_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _Mask_ST.xy + _Mask_ST.zw;
                o.texcoord1.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                o.texcoord2.w = tmp0.x;
                tmp0.w = v.tangent.w * unity_WorldTransformParams.w;
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.xyz = tmp1.www * tmp1.xyz;
                tmp2.xyz = v.tangent.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp2.xyz = unity_ObjectToWorld._m00_m10_m20 * v.tangent.xxx + tmp2.xyz;
                tmp2.xyz = unity_ObjectToWorld._m02_m12_m22 * v.tangent.zzz + tmp2.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp3.xyz = tmp1.zxy * tmp2.yzx;
                tmp3.xyz = tmp1.yzx * tmp2.zxy + -tmp3.xyz;
                tmp3.xyz = tmp0.www * tmp3.xyz;
                o.texcoord2.y = tmp3.x;
                o.texcoord2.x = tmp2.x;
                o.texcoord2.z = tmp1.x;
                o.texcoord3.x = tmp2.y;
                o.texcoord3.z = tmp1.y;
                o.texcoord3.w = tmp0.y;
                o.texcoord3.y = tmp3.y;
                o.texcoord4.x = tmp2.z;
                o.texcoord4.z = tmp1.z;
                o.texcoord4.w = tmp0.z;
                tmp0.xyz = _WorldSpaceCameraPos - tmp0.xyz;
                o.texcoord4.y = tmp3.z;
                o.texcoord5.y = dot(tmp0.xyz, tmp3.xyz);
                o.texcoord5.x = dot(tmp0.xyz, tmp2.xyz);
                o.texcoord5.z = dot(tmp0.xyz, tmp1.xyz);
                o.texcoord6 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                tmp0 = tex2D(_DissolveTex, inp.texcoord.xy);
                tmp0.x = tmp0.x - _DissolveAmount;
                tmp0.x = tmp0.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                tmp0.x = dot(inp.texcoord5.xyz, inp.texcoord5.xyz);
                tmp0.x = rsqrt(tmp0.x);
                tmp1.z = tmp0.x * inp.texcoord5.z;
                tmp1.y = inp.texcoord5.y * tmp0.x + _SinTime.z;
                tmp1.x = inp.texcoord5.x * tmp0.x + _CosTime.z;
                tmp0.x = dot(tmp1.xyz, tmp1.xyz);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.xyz = tmp0.xxx * tmp1.xyz;
                tmp1 = tex2D(_BumpMap, inp.texcoord1.zw);
                tmp1.x = tmp1.w * tmp1.x;
                tmp1.xy = tmp1.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                tmp0.w = dot(tmp1.xy, tmp1.xy);
                tmp0.w = min(tmp0.w, 1.0);
                tmp0.w = 1.0 - tmp0.w;
                tmp0.w = sqrt(tmp0.w);
                tmp1.z = tmp0.w / _BumpPower;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                tmp0.x = dot(tmp0.xyz, tmp1.xyz);
                tmp0.xy = tmp0.xx * _ColorRamp_ST.xy + _ColorRamp_ST.zw;
                tmp0 = tex2D(_ColorRamp, tmp0.xy);
                tmp2 = tex2D(_Mask, inp.texcoord1.xy);
                tmp0.xyz = tmp0.xyz * tmp2.xyz;
                tmp2.yzw = float3(1.0, 1.0, 1.0) - tmp2.xyz;
                tmp3 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2.yzw = tmp2.yzw * tmp3.xyz;
                tmp0.xyz = max(tmp0.xyz, tmp2.yzw);
                tmp2.yzw = tmp0.zxy * float3(0.57735, 0.57735, 0.57735);
                tmp2.yzw = tmp0.zxy * float3(0.57735, 0.57735, 0.57735) + -tmp2.wyz;
                tmp0.w = _Hue * 6.283185;
                tmp4.x = sin(tmp0.w);
                tmp5.x = cos(tmp0.w);
                tmp2.yzw = tmp2.yzw * tmp4.xxx;
                tmp2.yzw = tmp0.xyz * tmp5.xxx + tmp2.yzw;
                tmp0.x = dot(float3(0.57735, 0.57735, 0.57735), tmp0.xyz);
                tmp0.x = tmp0.x * 0.57735;
                tmp0.y = 1.0 - tmp5.x;
                tmp0.xyz = tmp0.xxx * tmp0.yyy + tmp2.yzw;
                tmp0.xyz = tmp0.xyz - float3(0.5, 0.5, 0.5);
                tmp0.w = _Contrast + _Contrast;
                tmp0.xyz = tmp0.xyz * tmp0.www + float3(0.5, 0.5, 0.5);
                tmp0.w = _Brightness * 2.0 + -1.0;
                tmp0.xyz = tmp0.www + tmp0.xyz;
                tmp0.w = dot(tmp0.xyz, float3(0.39, 0.59, 0.11));
                tmp0.xyz = tmp0.xyz - tmp0.www;
                tmp1.w = _Saturation + _Saturation;
                tmp0.xyz = tmp1.www * tmp0.xyz + tmp0.www;
                tmp0.xyz = tmp0.xyz - tmp3.xyz;
                tmp0.xyz = _Blend.xxx * tmp0.xyz + tmp3.xyz;
                tmp3.x = inp.texcoord2.w;
                tmp3.y = inp.texcoord3.w;
                tmp3.z = inp.texcoord4.w;
                tmp2.yzw = _PulseOrigin - tmp3.xyz;
                tmp0.w = dot(tmp2.xyz, tmp2.xyz);
                tmp0.w = sqrt(tmp0.w);
                tmp0.w = tmp0.w - _PulseRadius;
                tmp0.w = tmp0.w * tmp0.w;
                tmp0.w = 1.0 / tmp0.w;
                tmp0.w = min(tmp0.w, 5.0);
                tmp0.w = tmp0.w + 1.0;
                tmp3 = tex2D(_CrackTexFat, inp.texcoord.xy);
                tmp1.w = tmp3.x * _CrackAmount;
                tmp1.w = -tmp1.w * tmp0.w + 1.0;
                tmp1.w = tmp1.w * 0.7;
                tmp2.yzw = tmp0.xyz * tmp1.www;
                tmp3.x = dot(tmp2.xyz, float3(0.0396819, 0.4580218, 0.0060965));
                tmp0.xyz = -tmp0.xyz * tmp1.www + tmp3.xxx;
                tmp1.w = 1.0 - _FinalSaturation;
                tmp0.xyz = tmp1.www * tmp0.xyz + tmp2.yzw;
                tmp1.w = tmp2.x * _Metallic;
                o.sv_target1.w = tmp2.x * _Glossiness;
                tmp2.x = -tmp1.w * 0.96 + 0.96;
                tmp2.xyz = tmp0.xyz * tmp2.xxx;
                tmp0.xyz = tmp0.xyz - float3(0.04, 0.04, 0.04);
                o.sv_target1.xyz = tmp1.www * tmp0.xyz + float3(0.04, 0.04, 0.04);
                tmp3 = tex2D(_CrackTex, inp.texcoord.zw);
                tmp0.x = tmp3.x - _CrackAmount;
                tmp0.y = -tmp0.x * tmp0.w + 1.0;
                tmp0.x = tmp0.w * tmp0.x;
                tmp0.x = saturate(tmp0.x);
                o.sv_target.xyz = tmp0.yyy * tmp2.xyz;
                o.sv_target.w = 1.0;
                tmp2.x = dot(inp.texcoord2.xyz, tmp1.xyz);
                tmp2.y = dot(inp.texcoord3.xyz, tmp1.xyz);
                tmp2.z = dot(inp.texcoord4.xyz, tmp1.xyz);
                tmp0.y = dot(tmp2.xyz, tmp2.xyz);
                tmp0.y = rsqrt(tmp0.y);
                tmp0.yzw = tmp0.yyy * tmp2.xyz;
                o.sv_target2.xyz = tmp0.yzw * float3(0.5, 0.5, 0.5) + float3(0.5, 0.5, 0.5);
                o.sv_target2.w = 1.0;
                tmp0.yzw = _CrackColor.xyz * _CrackGlow.xxx + float3(-1.0, -1.0, -1.0);
                tmp0.xyz = tmp0.xxx * tmp0.yzw + float3(1.0, 1.0, 1.0);
                tmp1.xyz = _GlowColor.xyz - tmp0.xyz;
                o.sv_target3.xyz = _Glow.xxx * tmp1.xyz + tmp0.xyz;
                o.sv_target3.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "ShadowCaster"
			LOD 200
			Tags { "LIGHTMODE" = "SHADOWCASTER" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Cull Off
			GpuProgramID 214992
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float _DissolveAmount;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DissolveTex;
			
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
                tmp0.xyz = v.vertex.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp0.xyz = unity_ObjectToWorld._m00_m10_m20 * v.vertex.xxx + tmp0.xyz;
                tmp0.xyz = unity_ObjectToWorld._m02_m12_m22 * v.vertex.zzz + tmp0.xyz;
                o.texcoord2.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                return o;
			}
			// Keywords: SHADOWS_DEPTH
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                tmp0 = tex2D(_DissolveTex, inp.texcoord1.xy);
                tmp0.x = tmp0.x - _DissolveAmount;
                tmp0.x = tmp0.x < 0.0;
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