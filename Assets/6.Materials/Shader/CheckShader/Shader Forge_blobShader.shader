Shader "Shader Forge/blobShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_speedScroll ("speedScroll", Range(0, 10)) = 0.3162393
		_intensity ("intensity", Range(0, 10)) = 0
		_noise ("noise", 2D) = "white" {}
		_distanceChecker ("distanceChecker", Range(0, 0.1)) = 0.02338241
		_normalStrength ("normalStrength", Float) = 1
		_Metallic ("Metallic", Range(0, 1)) = 0
		_Gloss ("Gloss", Range(0, 1)) = 0.1651257
		_MainTex ("MainTex", 2D) = "white" {}
		_Glow ("Glow", Float) = 1
	}
	SubShader {
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			GpuProgramID 51996
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float3 texcoord4 : TEXCOORD4;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float _speedScroll;
			float _intensity;
			float4 _noise_ST;
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _distanceChecker;
			float _normalStrength;
			float _Metallic;
			float _Gloss;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _noise;
			sampler2D _MainTex;
			// Texture params for Fragment Shader
			
			// Keywords: DIRECTIONAL
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.xyz = v.vertex.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp0.xyz = unity_ObjectToWorld._m00_m10_m20 * v.vertex.xxx + tmp0.xyz;
                tmp0.xyz = unity_ObjectToWorld._m02_m12_m22 * v.vertex.zzz + tmp0.xyz;
                tmp0.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0.yw = tmp0.yy * unity_WorldToObject._m01_m11;
                tmp0.xy = unity_WorldToObject._m00_m10 * tmp0.xx + tmp0.yw;
                tmp0.xy = unity_WorldToObject._m02_m12 * tmp0.zz + tmp0.xy;
                tmp0.zw = unity_ObjectToWorld._m13_m13 * unity_WorldToObject._m01_m11;
                tmp0.zw = unity_WorldToObject._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp0.zw;
                tmp0.zw = unity_WorldToObject._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp0.zw;
                tmp0.xy = tmp0.zw - tmp0.xy;
                tmp0.z = _speedScroll * abs(_Time.y);
                tmp0.xy = tmp0.zz * float2(0.0, -1.0) + tmp0.xy;
                tmp0.xy = tmp0.xy * _noise_ST.xy + _noise_ST.zw;
                tmp0 = tex2Dlod(_noise, float4(tmp0.xy, 0, 0.0));
                tmp0.xyz = tmp0.xxx * v.normal.xyz;
                tmp0.xyz = tmp0.xyz * _intensity.xxx;
                tmp1.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.xyz = tmp1.www * tmp0.xyz + v.vertex.xyz;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord1 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.texcoord.xy = v.texcoord.xy;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                o.texcoord2.xyz = tmp0.xyz;
                tmp1.xyz = v.tangent.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp1.xyz = unity_ObjectToWorld._m00_m10_m20 * v.tangent.xxx + tmp1.xyz;
                tmp1.xyz = unity_ObjectToWorld._m02_m12_m22 * v.tangent.zzz + tmp1.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                o.texcoord3.xyz = tmp1.xyz;
                tmp2.xyz = tmp0.zxy * tmp1.yzx;
                tmp0.xyz = tmp0.yzx * tmp1.zxy + -tmp2.xyz;
                tmp0.xyz = tmp0.xyz * v.tangent.www;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord4.xyz = tmp0.www * tmp0.xyz;
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
                tmp0.x = dot(inp.texcoord2.xyz, inp.texcoord2.xyz);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.xyz = tmp0.xxx * inp.texcoord2.xyz;
                tmp1.xyz = _WorldSpaceCameraPos - inp.texcoord1.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp2.xyz = tmp0.www * tmp1.xyz;
                tmp1.w = _speedScroll * abs(_Time.y);
                tmp3.xy = unity_ObjectToWorld._m13_m13 * unity_WorldToObject._m01_m11;
                tmp3.xy = unity_WorldToObject._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp3.xy;
                tmp3.xy = unity_WorldToObject._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp3.xy;
                tmp3.zw = inp.texcoord1.yy * unity_WorldToObject._m01_m11;
                tmp3.zw = unity_WorldToObject._m00_m10 * inp.texcoord1.xx + tmp3.zw;
                tmp3.zw = unity_WorldToObject._m02_m12 * inp.texcoord1.zz + tmp3.zw;
                tmp3.xy = tmp3.xy - tmp3.zw;
                tmp3.xy = tmp1.ww * float2(0.0, -1.0) + tmp3.xy;
                tmp4.xw = -_distanceChecker.xx;
                tmp4.yz = float2(-0.0, -0.0);
                tmp4 = tmp4 + inp.texcoord.xyxy;
                tmp4 = tmp4 - tmp3.xyxy;
                tmp4 = tmp4 * _noise_ST + _noise_ST;
                tmp5 = tex2D(_noise, tmp4.xy);
                tmp4 = tex2D(_noise, tmp4.zw);
                tmp3.xy = tmp3.xy * _noise_ST.xy + _noise_ST.zw;
                tmp3 = tex2D(_noise, tmp3.xy);
                tmp4.x = tmp5.x;
                tmp3.xy = tmp4.xy - tmp3.xx;
                tmp3.xy = tmp3.xy * _normalStrength.xx;
                tmp3.xy = max(tmp3.xy, float2(-1.0, -1.0));
                tmp3.xy = min(tmp3.xy, float2(1.0, 1.0));
                tmp1.w = dot(tmp3.xy, tmp3.xy);
                tmp1.w = 1.0 - tmp1.w;
                tmp1.w = sqrt(tmp1.w);
                tmp3.yzw = tmp3.yyy * inp.texcoord4.xyz;
                tmp3.xyz = tmp3.xxx * inp.texcoord3.xyz + tmp3.yzw;
                tmp0.xyz = tmp1.www * tmp0.xyz + tmp3.xyz;
                tmp1.w = dot(tmp0.xyz, tmp0.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp0.xyz = tmp0.xyz * tmp1.www;
                tmp1.w = dot(-tmp2.xyz, tmp0.xyz);
                tmp1.w = tmp1.w + tmp1.w;
                tmp3.xyz = tmp0.xyz * -tmp1.www + -tmp2.xyz;
                tmp1.w = dot(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp4.xyz = tmp1.www * _WorldSpaceLightPos0.xyz;
                tmp1.xyz = tmp1.xyz * tmp0.www + tmp4.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                tmp0.w = 1.0 - _Gloss;
                tmp1.w = tmp0.w * tmp0.w;
                tmp2.w = unity_SpecCube0_ProbePosition.w > 0.0;
                if (tmp2.w) {
                    tmp2.w = dot(tmp3.xyz, tmp3.xyz);
                    tmp2.w = rsqrt(tmp2.w);
                    tmp5.xyz = tmp2.www * tmp3.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMax.xyz - inp.texcoord1.xyz;
                    tmp6.xyz = tmp6.xyz / tmp5.xyz;
                    tmp7.xyz = unity_SpecCube0_BoxMin.xyz - inp.texcoord1.xyz;
                    tmp7.xyz = tmp7.xyz / tmp5.xyz;
                    tmp8.xyz = tmp5.xyz > float3(0.0, 0.0, 0.0);
                    tmp6.xyz = tmp8.xyz ? tmp6.xyz : tmp7.xyz;
                    tmp2.w = min(tmp6.y, tmp6.x);
                    tmp2.w = min(tmp6.z, tmp2.w);
                    tmp6.xyz = inp.texcoord1.xyz - unity_SpecCube0_ProbePosition.xyz;
                    tmp5.xyz = tmp5.xyz * tmp2.www + tmp6.xyz;
                } else {
                    tmp5.xyz = tmp3.xyz;
                }
                tmp2.w = -tmp0.w * 0.7 + 1.7;
                tmp2.w = tmp0.w * tmp2.w;
                tmp2.w = tmp2.w * 6.0;
                tmp5 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp5.xyz, tmp2.w));
                tmp3.w = tmp5.w - 1.0;
                tmp3.w = unity_SpecCube0_HDR.w * tmp3.w + 1.0;
                tmp3.w = log(tmp3.w);
                tmp3.w = tmp3.w * unity_SpecCube0_HDR.y;
                tmp3.w = exp(tmp3.w);
                tmp3.w = tmp3.w * unity_SpecCube0_HDR.x;
                tmp6.xyz = tmp5.xyz * tmp3.www;
                tmp4.w = unity_SpecCube0_BoxMin.w < 0.99999;
                if (tmp4.w) {
                    tmp4.w = unity_SpecCube1_ProbePosition.w > 0.0;
                    if (tmp4.w) {
                        tmp4.w = dot(tmp3.xyz, tmp3.xyz);
                        tmp4.w = rsqrt(tmp4.w);
                        tmp7.xyz = tmp3.xyz * tmp4.www;
                        tmp8.xyz = unity_SpecCube1_BoxMax.xyz - inp.texcoord1.xyz;
                        tmp8.xyz = tmp8.xyz / tmp7.xyz;
                        tmp9.xyz = unity_SpecCube1_BoxMin.xyz - inp.texcoord1.xyz;
                        tmp9.xyz = tmp9.xyz / tmp7.xyz;
                        tmp10.xyz = tmp7.xyz > float3(0.0, 0.0, 0.0);
                        tmp8.xyz = tmp10.xyz ? tmp8.xyz : tmp9.xyz;
                        tmp4.w = min(tmp8.y, tmp8.x);
                        tmp4.w = min(tmp8.z, tmp4.w);
                        tmp8.xyz = inp.texcoord1.xyz - unity_SpecCube1_ProbePosition.xyz;
                        tmp3.xyz = tmp7.xyz * tmp4.www + tmp8.xyz;
                    }
                    tmp7 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp3.xyz, tmp2.w));
                    tmp2.w = tmp7.w - 1.0;
                    tmp2.w = unity_SpecCube1_HDR.w * tmp2.w + 1.0;
                    tmp2.w = log(tmp2.w);
                    tmp2.w = tmp2.w * unity_SpecCube1_HDR.y;
                    tmp2.w = exp(tmp2.w);
                    tmp2.w = tmp2.w * unity_SpecCube1_HDR.x;
                    tmp3.xyz = tmp7.xyz * tmp2.www;
                    tmp5.xyz = tmp3.www * tmp5.xyz + -tmp3.xyz;
                    tmp6.xyz = unity_SpecCube0_BoxMin.www * tmp5.xyz + tmp3.xyz;
                }
                tmp2.w = dot(tmp0.xyz, tmp4.xyz);
                tmp2.w = max(tmp2.w, 0.0);
                tmp3.x = min(tmp2.w, 1.0);
                tmp3.y = saturate(dot(tmp4.xyz, tmp1.xyz));
                tmp3.zw = inp.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp4 = tex2D(_MainTex, tmp3.zw);
                tmp5.xyz = tmp4.xyz * _Color.xyz;
                tmp4.xyz = _Color.xyz * tmp4.xyz + float3(-0.04, -0.04, -0.04);
                tmp4.xyz = _Metallic.xxx * tmp4.xyz + float3(0.04, 0.04, 0.04);
                tmp3.z = -_Metallic * 0.96 + 0.96;
                tmp5.xyz = tmp3.zzz * tmp5.xyz;
                tmp3.z = 1.0 - tmp3.z;
                tmp2.x = dot(tmp0.xyz, tmp2.xyz);
                tmp0.x = saturate(dot(tmp0.xyz, tmp1.xyz));
                tmp0.y = -tmp0.w * tmp0.w + 1.0;
                tmp0.z = abs(tmp2.x) * tmp0.y + tmp1.w;
                tmp0.y = tmp3.x * tmp0.y + tmp1.w;
                tmp0.y = tmp0.y * abs(tmp2.x);
                tmp0.y = tmp3.x * tmp0.z + tmp0.y;
                tmp0.y = tmp0.y + 0.00001;
                tmp0.y = 0.5 / tmp0.y;
                tmp0.z = tmp1.w * tmp1.w;
                tmp1.x = tmp0.x * tmp0.z + -tmp0.x;
                tmp0.x = tmp1.x * tmp0.x + 1.0;
                tmp0.z = tmp0.z * 0.3183099;
                tmp0.x = tmp0.x * tmp0.x + 0.0000001;
                tmp0.x = tmp0.z / tmp0.x;
                tmp0.x = tmp0.x * tmp0.y;
                tmp0.x = tmp3.x * tmp0.x;
                tmp0.x = tmp0.x * 3.141593;
                tmp0.x = max(tmp0.x, 0.0);
                tmp0.y = tmp1.w * tmp1.w + 1.0;
                tmp0.y = 1.0 / tmp0.y;
                tmp0.z = dot(tmp4.xyz, tmp4.xyz);
                tmp0.z = tmp0.z != 0.0;
                tmp0.z = tmp0.z ? 1.0 : 0.0;
                tmp0.x = tmp0.z * tmp0.x;
                tmp1.xyz = tmp0.xxx * _LightColor0.xyz;
                tmp0.x = 1.0 - tmp3.y;
                tmp0.z = tmp0.x * tmp0.x;
                tmp0.z = tmp0.z * tmp0.z;
                tmp0.x = tmp0.x * tmp0.z;
                tmp7.xyz = float3(1.0, 1.0, 1.0) - tmp4.xyz;
                tmp7.xyz = tmp7.xyz * tmp0.xxx + tmp4.xyz;
                tmp0.x = saturate(tmp3.z + _Gloss);
                tmp0.z = 1.0 - abs(tmp2.x);
                tmp1.w = tmp0.z * tmp0.z;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.z = tmp0.z * tmp1.w;
                tmp2.xyz = tmp0.xxx - tmp4.xyz;
                tmp2.xyz = tmp0.zzz * tmp2.xyz + tmp4.xyz;
                tmp2.xyz = tmp2.xyz * tmp6.xyz;
                tmp2.xyz = tmp0.yyy * tmp2.xyz;
                tmp1.xyz = tmp1.xyz * tmp7.xyz + tmp2.xyz;
                tmp0.x = tmp3.y + tmp3.y;
                tmp0.x = tmp3.y * tmp0.x;
                tmp0.y = 1.0 - tmp2.w;
                tmp1.w = tmp0.y * tmp0.y;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.y = tmp0.y * tmp1.w;
                tmp0.x = tmp0.x * tmp0.w + -0.5;
                tmp0.y = tmp0.x * tmp0.y + 1.0;
                tmp0.x = tmp0.x * tmp0.z + 1.0;
                tmp0.x = tmp0.x * tmp0.y;
                tmp0.x = tmp2.w * tmp0.x;
                tmp0.yzw = glstate_lightmodel_ambient.xyz + glstate_lightmodel_ambient.xyz;
                tmp0.xyz = tmp0.xxx * _LightColor0.xyz + tmp0.yzw;
                tmp0.xyz = tmp5.xyz * tmp0.xyz;
                o.sv_target.xyz = tmp0.xyz * _Glow.xxx + tmp1.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD_DELTA"
			Tags { "LIGHTMODE" = "FORWARDADD" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Blend One One, One One
			GpuProgramID 84414
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
				float3 texcoord4 : TEXCOORD4;
				float3 texcoord5 : TEXCOORD5;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float _speedScroll;
			float _intensity;
			float4 _noise_ST;
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _distanceChecker;
			float _normalStrength;
			float _Metallic;
			float _Gloss;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _noise;
			sampler2D _MainTex;
			// Texture params for Fragment Shader
			sampler2D _LightTexture0;
			
			// Keywords: POINT
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                tmp0.xyz = v.vertex.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp0.xyz = unity_ObjectToWorld._m00_m10_m20 * v.vertex.xxx + tmp0.xyz;
                tmp0.xyz = unity_ObjectToWorld._m02_m12_m22 * v.vertex.zzz + tmp0.xyz;
                tmp0.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0.yw = tmp0.yy * unity_WorldToObject._m01_m11;
                tmp0.xy = unity_WorldToObject._m00_m10 * tmp0.xx + tmp0.yw;
                tmp0.xy = unity_WorldToObject._m02_m12 * tmp0.zz + tmp0.xy;
                tmp0.zw = unity_ObjectToWorld._m13_m13 * unity_WorldToObject._m01_m11;
                tmp0.zw = unity_WorldToObject._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp0.zw;
                tmp0.zw = unity_WorldToObject._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp0.zw;
                tmp0.xy = tmp0.zw - tmp0.xy;
                tmp0.z = _speedScroll * abs(_Time.y);
                tmp0.xy = tmp0.zz * float2(0.0, -1.0) + tmp0.xy;
                tmp0.xy = tmp0.xy * _noise_ST.xy + _noise_ST.zw;
                tmp0 = tex2Dlod(_noise, float4(tmp0.xy, 0, 0.0));
                tmp0.xyz = tmp0.xxx * v.normal.xyz;
                tmp0.xyz = tmp0.xyz * _intensity.xxx;
                tmp1.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.xyz = tmp1.www * tmp0.xyz + v.vertex.xyz;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp2 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp2;
                tmp2 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp2;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp2;
                o.texcoord.xy = v.texcoord.xy;
                o.texcoord1 = tmp0;
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.xyz = tmp1.www * tmp1.xyz;
                o.texcoord2.xyz = tmp1.xyz;
                tmp2.xyz = v.tangent.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp2.xyz = unity_ObjectToWorld._m00_m10_m20 * v.tangent.xxx + tmp2.xyz;
                tmp2.xyz = unity_ObjectToWorld._m02_m12_m22 * v.tangent.zzz + tmp2.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                o.texcoord3.xyz = tmp2.xyz;
                tmp3.xyz = tmp1.zxy * tmp2.yzx;
                tmp1.xyz = tmp1.yzx * tmp2.zxy + -tmp3.xyz;
                tmp1.xyz = tmp1.xyz * v.tangent.www;
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                o.texcoord4.xyz = tmp1.www * tmp1.xyz;
                tmp1.xyz = tmp0.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToLight._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                o.texcoord5.xyz = unity_WorldToLight._m03_m13_m23 * tmp0.www + tmp0.xyz;
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
                tmp0.xy = unity_ObjectToWorld._m13_m13 * unity_WorldToObject._m01_m11;
                tmp0.xy = unity_WorldToObject._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp0.xy;
                tmp0.xy = unity_WorldToObject._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp0.xy;
                tmp0.zw = inp.texcoord1.yy * unity_WorldToObject._m01_m11;
                tmp0.zw = unity_WorldToObject._m00_m10 * inp.texcoord1.xx + tmp0.zw;
                tmp0.zw = unity_WorldToObject._m02_m12 * inp.texcoord1.zz + tmp0.zw;
                tmp0.xy = tmp0.xy - tmp0.zw;
                tmp0.z = _speedScroll * abs(_Time.y);
                tmp0.xy = tmp0.zz * float2(0.0, -1.0) + tmp0.xy;
                tmp0.zw = tmp0.xy * _noise_ST.xy + _noise_ST.zw;
                tmp1 = tex2D(_noise, tmp0.zw);
                tmp2.xw = -_distanceChecker.xx;
                tmp2.yz = float2(-0.0, -0.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp0 = tmp2 - tmp0.xyxy;
                tmp0 = tmp0 * _noise_ST + _noise_ST;
                tmp2 = tex2D(_noise, tmp0.xy);
                tmp0 = tex2D(_noise, tmp0.zw);
                tmp2.y = tmp0.x;
                tmp0.xy = tmp2.xy - tmp1.xx;
                tmp0.xy = tmp0.xy * _normalStrength.xx;
                tmp0.xy = max(tmp0.xy, float2(-1.0, -1.0));
                tmp0.xy = min(tmp0.xy, float2(1.0, 1.0));
                tmp1.xyz = tmp0.yyy * inp.texcoord4.xyz;
                tmp1.xyz = tmp0.xxx * inp.texcoord3.xyz + tmp1.xyz;
                tmp0.x = dot(tmp0.xy, tmp0.xy);
                tmp0.x = 1.0 - tmp0.x;
                tmp0.x = sqrt(tmp0.x);
                tmp0.y = dot(inp.texcoord2.xyz, inp.texcoord2.xyz);
                tmp0.y = rsqrt(tmp0.y);
                tmp0.yzw = tmp0.yyy * inp.texcoord2.xyz;
                tmp0.xyz = tmp0.xxx * tmp0.yzw + tmp1.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp1.xyz = _WorldSpaceLightPos0.www * -inp.texcoord1.xyz + _WorldSpaceLightPos0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                tmp0.w = dot(tmp0.xyz, tmp1.xyz);
                tmp0.w = max(tmp0.w, 0.0);
                tmp1.w = min(tmp0.w, 1.0);
                tmp2.xyz = _WorldSpaceCameraPos - inp.texcoord1.xyz;
                tmp2.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.w = rsqrt(tmp2.w);
                tmp3.xyz = tmp2.www * tmp2.xyz;
                tmp2.xyz = tmp2.xyz * tmp2.www + tmp1.xyz;
                tmp2.w = dot(tmp0.xyz, tmp3.xyz);
                tmp3.x = 1.0 - _Gloss;
                tmp3.y = -tmp3.x * tmp3.x + 1.0;
                tmp3.z = tmp3.x * tmp3.x;
                tmp3.w = abs(tmp2.w) * tmp3.y + tmp3.z;
                tmp3.y = tmp1.w * tmp3.y + tmp3.z;
                tmp3.z = tmp3.z * tmp3.z;
                tmp3.y = abs(tmp2.w) * tmp3.y;
                tmp2.w = 1.0 - abs(tmp2.w);
                tmp3.y = tmp1.w * tmp3.w + tmp3.y;
                tmp3.y = tmp3.y + 0.00001;
                tmp3.y = 0.5 / tmp3.y;
                tmp3.w = dot(tmp2.xyz, tmp2.xyz);
                tmp3.w = rsqrt(tmp3.w);
                tmp2.xyz = tmp2.xyz * tmp3.www;
                tmp0.x = saturate(dot(tmp0.xyz, tmp2.xyz));
                tmp0.y = saturate(dot(tmp1.xyz, tmp2.xyz));
                tmp0.z = tmp0.x * tmp3.z + -tmp0.x;
                tmp0.x = tmp0.z * tmp0.x + 1.0;
                tmp0.x = tmp0.x * tmp0.x + 0.0000001;
                tmp0.z = tmp3.z * 0.3183099;
                tmp0.x = tmp0.z / tmp0.x;
                tmp0.x = tmp0.x * tmp3.y;
                tmp0.x = tmp1.w * tmp0.x;
                tmp0.x = tmp0.x * 3.141593;
                tmp0.x = max(tmp0.x, 0.0);
                tmp1.xy = inp.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp1 = tex2D(_MainTex, tmp1.xy);
                tmp2.xyz = _Color.xyz * tmp1.xyz + float3(-0.04, -0.04, -0.04);
                tmp1.xyz = tmp1.xyz * _Color.xyz;
                tmp2.xyz = _Metallic.xxx * tmp2.xyz + float3(0.04, 0.04, 0.04);
                tmp0.z = dot(tmp2.xyz, tmp2.xyz);
                tmp0.z = tmp0.z != 0.0;
                tmp0.z = tmp0.z ? 1.0 : 0.0;
                tmp0.x = tmp0.z * tmp0.x;
                tmp0.z = dot(inp.texcoord5.xyz, inp.texcoord5.xyz);
                tmp4 = tex2D(_LightTexture0, tmp0.zz);
                tmp3.yzw = tmp4.xxx * _LightColor0.xyz;
                tmp4.xyz = tmp0.xxx * tmp3.yzw;
                tmp0.x = 1.0 - tmp0.y;
                tmp0.z = tmp0.x * tmp0.x;
                tmp0.z = tmp0.z * tmp0.z;
                tmp0.x = tmp0.x * tmp0.z;
                tmp5.xyz = float3(1.0, 1.0, 1.0) - tmp2.xyz;
                tmp2.xyz = tmp5.xyz * tmp0.xxx + tmp2.xyz;
                tmp2.xyz = tmp2.xyz * tmp4.xyz;
                tmp0.x = tmp0.y + tmp0.y;
                tmp0.x = tmp0.y * tmp0.x;
                tmp0.x = tmp0.x * tmp3.x + -0.5;
                tmp0.y = tmp2.w * tmp2.w;
                tmp0.y = tmp0.y * tmp0.y;
                tmp0.y = tmp2.w * tmp0.y;
                tmp0.y = tmp0.x * tmp0.y + 1.0;
                tmp0.z = 1.0 - tmp0.w;
                tmp1.w = tmp0.z * tmp0.z;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.z = tmp0.z * tmp1.w;
                tmp0.x = tmp0.x * tmp0.z + 1.0;
                tmp0.x = tmp0.y * tmp0.x;
                tmp0.x = tmp0.w * tmp0.x;
                tmp0.xyz = tmp3.yzw * tmp0.xxx;
                tmp0.w = -_Metallic * 0.96 + 0.96;
                tmp1.xyz = tmp0.www * tmp1.xyz;
                tmp0.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.xyz = tmp0.xyz * _Glow.xxx + tmp2.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "ShadowCaster"
			Tags { "LIGHTMODE" = "SHADOWCASTER" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Offset 1, 1
			GpuProgramID 188203
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float3 texcoord3 : TEXCOORD3;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float _speedScroll;
			float _intensity;
			float4 _noise_ST;
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _noise;
			sampler2D _MainTex;
			// Texture params for Fragment Shader
			
			// Keywords: SHADOWS_DEPTH
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.xyz = v.vertex.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp0.xyz = unity_ObjectToWorld._m00_m10_m20 * v.vertex.xxx + tmp0.xyz;
                tmp0.xyz = unity_ObjectToWorld._m02_m12_m22 * v.vertex.zzz + tmp0.xyz;
                tmp0.xyz = unity_ObjectToWorld._m03_m13_m23 * v.vertex.www + tmp0.xyz;
                tmp0.yw = tmp0.yy * unity_WorldToObject._m01_m11;
                tmp0.xy = unity_WorldToObject._m00_m10 * tmp0.xx + tmp0.yw;
                tmp0.xy = unity_WorldToObject._m02_m12 * tmp0.zz + tmp0.xy;
                tmp0.zw = unity_ObjectToWorld._m13_m13 * unity_WorldToObject._m01_m11;
                tmp0.zw = unity_WorldToObject._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp0.zw;
                tmp0.zw = unity_WorldToObject._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp0.zw;
                tmp0.xy = tmp0.zw - tmp0.xy;
                tmp0.z = _speedScroll * abs(_Time.y);
                tmp0.xy = tmp0.zz * float2(0.0, -1.0) + tmp0.xy;
                tmp0.xy = tmp0.xy * _noise_ST.xy + _noise_ST.zw;
                tmp0 = tex2Dlod(_noise, float4(tmp0.xy, 0, 0.0));
                tmp0.xyz = tmp0.xxx * v.normal.xyz;
                tmp0.xyz = tmp0.xyz * _intensity.xxx;
                tmp1.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.xyz = tmp1.www * tmp0.xyz + v.vertex.xyz;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord2 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                tmp1.x = unity_LightShadowBias.x / tmp0.w;
                tmp1.x = min(tmp1.x, 0.0);
                tmp1.x = max(tmp1.x, -1.0);
                tmp0.z = tmp0.z + tmp1.x;
                tmp1.x = min(tmp0.w, tmp0.z);
                o.position.xyw = tmp0.xyw;
                tmp0.x = tmp1.x - tmp0.z;
                o.position.z = unity_LightShadowBias.y * tmp0.x + tmp0.z;
                o.texcoord1.xy = v.texcoord.xy;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord3.xyz = tmp0.www * tmp0.xyz;
                return o;
			}
			// Keywords: SHADOWS_DEPTH
			fout frag(v2f inp)
			{
                fout o;
                o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ShaderForgeMaterialInspector"
}