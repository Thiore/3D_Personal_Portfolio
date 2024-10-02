Shader "Custom/Cobwebs" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NoiseTex ("Noise (RGB)", 2D) = "white" {}
		_Multiplier ("Multi", Float) = 1
		_Add ("Add", Float) = 1
		[PropertyBlock] _BurnPoint ("Burn Point", Vector) = (0,0,0,0)
		[PropertyBlock] _BurnValue ("Burn Value", Float) = 0
		[PropertyBlock] _BurnSize ("Burn Size", Float) = 0
		_BurnColor ("Burn Color", Color) = (1,1,1,1)
		_Glow ("Glow", Float) = 10
		_Shine ("Shine (RGB)", 2D) = "white" {}
		[PropertyBlock] _ShineOffset ("Shine Offset", Range(-1, 2)) = 0
		_ShineColor ("Shine Color", Color) = (0.5,0.5,0.5,1)
		_ShineGlow ("Shine Glow", Float) = 1
	}
	SubShader {
		LOD 200
		Tags { "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			ColorMask RGB
			ZWrite Off
			GpuProgramID 31958
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
				float4 color : COLOR0;
				float4 texcoord7 : TEXCOORD7;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float4 _Shine_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Multiplier;
			float _Add;
			float3 _BurnPoint;
			float _BurnValue;
			float _BurnSize;
			float4 _Color;
			float4 _BurnColor;
			float _Glow;
			float4 _ShineColor;
			float _ShineOffset;
			float _ShineGlow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _Shine;
			
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
                o.texcoord.zw = v.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _Shine_ST.xy + _Shine_ST.zw;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord2.xyz = tmp0.www * tmp0.xyz;
                o.color = v.color;
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
                tmp2.xyz = _BurnPoint - inp.texcoord3.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = sqrt(tmp1.w);
                tmp1.w = _BurnSize / tmp1.w;
                tmp1.w = tmp1.w * _BurnValue;
                tmp2 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2.y = tmp2.x * _Color.x;
                tmp3 = tex2D(_NoiseTex, inp.texcoord.zw);
                tmp2.y = tmp2.y * inp.color.x;
                tmp2.y = tmp2.y * _Multiplier + _Add;
                tmp2.z = tmp2.y < 0.0;
                if (tmp2.z) {
                    discard;
                }
                tmp2.x = tmp2.x * _Color.x + tmp3.x;
                tmp2.x = tmp2.x * 0.1 + 0.8;
                tmp1.w = -tmp1.w * tmp2.x + 1.0;
                tmp2.xz = tmp1.ww < float2(0.0, 0.2);
                if (tmp2.x) {
                    discard;
                }
                if (tmp2.z) {
                    tmp2.xzw = _BurnColor.xyz * _Glow.xxx;
                } else {
                    tmp3.xy = inp.texcoord1.xy + _ShineOffset.xx;
                    tmp3 = tex2D(_Shine, tmp3.xy);
                    tmp3.xyz = tmp3.xyz * _ShineColor.xyz;
                    tmp2.xzw = tmp3.xyz * _ShineGlow.xxx + _Color.xyz;
                }
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
                    tmp3.y = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp3.x = max(tmp1.w, tmp3.y);
                    tmp3 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp3.xzw);
                } else {
                    tmp3 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp1.w = saturate(dot(tmp3, unity_OcclusionMaskSelector));
                tmp3.x = dot(-tmp1.xyz, inp.texcoord2.xyz);
                tmp3.x = tmp3.x + tmp3.x;
                tmp3.xyz = inp.texcoord2.xyz * -tmp3.xxx + -tmp1.xyz;
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
                tmp3.w = unity_SpecCube0_BoxMin.w < 0.99999;
                if (tmp3.w) {
                    tmp3.w = unity_SpecCube1_ProbePosition.w > 0.0;
                    if (tmp3.w) {
                        tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                        tmp3.w = rsqrt(tmp3.w);
                        tmp7.xyz = tmp3.www * tmp3.xyz;
                        tmp8.xyz = unity_SpecCube1_BoxMax.xyz - inp.texcoord3.xyz;
                        tmp8.xyz = tmp8.xyz / tmp7.xyz;
                        tmp9.xyz = unity_SpecCube1_BoxMin.xyz - inp.texcoord3.xyz;
                        tmp9.xyz = tmp9.xyz / tmp7.xyz;
                        tmp10.xyz = tmp7.xyz > float3(0.0, 0.0, 0.0);
                        tmp8.xyz = tmp10.xyz ? tmp8.xyz : tmp9.xyz;
                        tmp3.w = min(tmp8.y, tmp8.x);
                        tmp3.w = min(tmp8.z, tmp3.w);
                        tmp8.xyz = inp.texcoord3.xyz - unity_SpecCube1_ProbePosition.xyz;
                        tmp3.xyz = tmp7.xyz * tmp3.www + tmp8.xyz;
                    }
                    tmp3 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp3.xyz, 6.0));
                    tmp3.w = tmp3.w - 1.0;
                    tmp3.w = unity_SpecCube1_HDR.w * tmp3.w + 1.0;
                    tmp3.w = log(tmp3.w);
                    tmp3.w = tmp3.w * unity_SpecCube1_HDR.y;
                    tmp3.w = exp(tmp3.w);
                    tmp3.w = tmp3.w * unity_SpecCube1_HDR.x;
                    tmp3.xyz = tmp3.xyz * tmp3.www;
                    tmp5.xyz = tmp1.www * tmp5.xyz + -tmp3.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMin.www * tmp5.xyz + tmp3.xyz;
                }
                tmp1.w = dot(inp.texcoord2.xyz, inp.texcoord2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp3.xyz = tmp1.www * inp.texcoord2.xyz;
                tmp2.xzw = tmp2.yyy * tmp2.xzw;
                tmp2.xzw = tmp2.xzw * float3(0.96, 0.96, 0.96);
                o.sv_target.w = tmp2.y * 0.96 + 0.04;
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
                tmp2.y = tmp0.x * tmp0.x;
                tmp2.y = tmp2.y * tmp2.y;
                tmp0.x = tmp0.x * tmp2.y;
                tmp0.x = tmp0.x * 0.96 + 0.04;
                tmp0.xyz = tmp0.xxx * tmp0.yzw;
                tmp0.xyz = tmp2.xzw * tmp1.xzw + tmp0.xyz;
                tmp1.xzw = tmp6.xyz * float3(0.5, 0.5, 0.5);
                tmp0.w = tmp1.y * 0.0 + 0.04;
                o.sv_target.xyz = tmp1.xzw * tmp0.www + tmp0.xyz;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDADD" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One One, One One
			ColorMask RGB
			ZWrite Off
			GpuProgramID 118653
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
				float4 color : COLOR0;
				float3 texcoord4 : TEXCOORD4;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float4 _MainTex_ST;
			float4 _NoiseTex_ST;
			float4 _Shine_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Multiplier;
			float _Add;
			float3 _BurnPoint;
			float _BurnValue;
			float _BurnSize;
			float4 _Color;
			float4 _BurnColor;
			float _Glow;
			float4 _ShineColor;
			float _ShineOffset;
			float _ShineGlow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			sampler2D _Shine;
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
                o.texcoord.zw = v.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                o.texcoord1.xy = v.texcoord.xy * _Shine_ST.xy + _Shine_ST.zw;
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
                tmp0.xyz = _WorldSpaceLightPos0.xyz - inp.texcoord3.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp2.xyz = _WorldSpaceCameraPos - inp.texcoord3.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp3.xyz = _BurnPoint - inp.texcoord3.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = sqrt(tmp1.w);
                tmp1.w = _BurnSize / tmp1.w;
                tmp1.w = tmp1.w * _BurnValue;
                tmp3 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2.w = tmp3.x * _Color.x;
                tmp4 = tex2D(_NoiseTex, inp.texcoord.zw);
                tmp2.w = tmp2.w * inp.color.x;
                tmp2.w = tmp2.w * _Multiplier + _Add;
                tmp3.y = tmp2.w < 0.0;
                if (tmp3.y) {
                    discard;
                }
                tmp3.x = tmp3.x * _Color.x + tmp4.x;
                tmp3.x = tmp3.x * 0.1 + 0.8;
                tmp1.w = -tmp1.w * tmp3.x + 1.0;
                tmp3.xy = tmp1.ww < float2(0.0, 0.2);
                if (tmp3.x) {
                    discard;
                }
                if (tmp3.y) {
                    tmp3.xyz = _BurnColor.xyz * _Glow.xxx;
                } else {
                    tmp4.xy = inp.texcoord1.xy + _ShineOffset.xx;
                    tmp4 = tex2D(_Shine, tmp4.xy);
                    tmp4.xyz = tmp4.xyz * _ShineColor.xyz;
                    tmp3.xyz = tmp4.xyz * _ShineGlow.xxx + _Color.xyz;
                }
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
                    tmp3.w = unity_ProbeVolumeParams.z * 0.5 + 0.75;
                    tmp5.x = max(tmp1.w, tmp3.w);
                    tmp5 = UNITY_SAMPLE_TEX3D_SAMPLER(unity_ProbeVolumeSH, unity_ProbeVolumeSH, tmp5.xzw);
                } else {
                    tmp5 = float4(1.0, 1.0, 1.0, 1.0);
                }
                tmp1.w = saturate(dot(tmp5, unity_OcclusionMaskSelector));
                tmp3.w = dot(tmp4.xyz, tmp4.xyz);
                tmp4 = tex2D(_LightTexture0, tmp3.ww);
                tmp1.w = tmp1.w * tmp4.x;
                tmp4.xyz = tmp1.www * _LightColor0.xyz;
                tmp1.w = dot(inp.texcoord2.xyz, inp.texcoord2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp5.xyz = tmp1.www * inp.texcoord2.xyz;
                tmp3.xyz = tmp2.www * tmp3.xyz;
                tmp3.xyz = tmp3.xyz * float3(0.96, 0.96, 0.96);
                o.sv_target.w = tmp2.w * 0.96 + 0.04;
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
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}