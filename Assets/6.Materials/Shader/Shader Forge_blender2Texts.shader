Shader "Shader Forge/blender2Texts" {
	Properties {
		_Metallic ("Metallic", Range(0, 1)) = 0
		_Gloss ("Gloss", Range(0, 1)) = 0.8
		_blendStrength ("blendStrength", Range(-0.5, 1)) = 0.03
		_AlphaChannel ("AlphaChannel", 2D) = "white" {}
		_RedChannel ("RedChannel", 2D) = "white" {}
		_mask1 ("mask1", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType" = "Opaque" }
		Pass {
			Name "FORWARD"
			Tags { "LIGHTMODE" = "FORWARDBASE" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			GpuProgramID 25346
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				float3 texcoord4 : TEXCOORD4;
				float3 texcoord5 : TEXCOORD5;
				float3 texcoord6 : TEXCOORD6;
				float4 color : COLOR0;
				float4 texcoord10 : TEXCOORD10;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Metallic;
			float _Gloss;
			float4 _RedChannel_ST;
			float4 _AlphaChannel_ST;
			float _blendStrength;
			float4 _mask1_ST;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _AlphaChannel;
			sampler2D _RedChannel;
			sampler2D _mask1;
			
			// Keywords: DIRECTIONAL DIRLIGHTMAP_OFF DYNAMICLIGHTMAP_OFF LIGHTMAP_OFF
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
                o.texcoord3 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.texcoord.xy = v.texcoord.xy;
                o.texcoord1.xy = v.texcoord1.xy;
                o.texcoord2.xy = v.texcoord2.xy;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                o.texcoord4.xyz = tmp0.xyz;
                tmp1.xyz = v.tangent.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp1.xyz = unity_ObjectToWorld._m00_m10_m20 * v.tangent.xxx + tmp1.xyz;
                tmp1.xyz = unity_ObjectToWorld._m02_m12_m22 * v.tangent.zzz + tmp1.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp1.xyz = tmp0.www * tmp1.xyz;
                o.texcoord5.xyz = tmp1.xyz;
                tmp2.xyz = tmp0.zxy * tmp1.yzx;
                tmp0.xyz = tmp0.yzx * tmp1.zxy + -tmp2.xyz;
                tmp0.xyz = tmp0.xyz * v.tangent.www;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord6.xyz = tmp0.www * tmp0.xyz;
                o.color = v.color;
                o.texcoord10 = float4(0.0, 0.0, 0.0, 0.0);
                return o;
			}
			// Keywords: DIRECTIONAL DIRLIGHTMAP_OFF DYNAMICLIGHTMAP_OFF LIGHTMAP_OFF
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
                tmp0.x = dot(inp.texcoord4.xyz, inp.texcoord4.xyz);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.xyz = tmp0.xxx * inp.texcoord4.xyz;
                tmp1.xyz = _WorldSpaceCameraPos - inp.texcoord3.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp2.xyz = tmp0.www * tmp1.xyz;
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
                    tmp6.xyz = unity_SpecCube0_BoxMax.xyz - inp.texcoord3.xyz;
                    tmp6.xyz = tmp6.xyz / tmp5.xyz;
                    tmp7.xyz = unity_SpecCube0_BoxMin.xyz - inp.texcoord3.xyz;
                    tmp7.xyz = tmp7.xyz / tmp5.xyz;
                    tmp8.xyz = tmp5.xyz > float3(0.0, 0.0, 0.0);
                    tmp6.xyz = tmp8.xyz ? tmp6.xyz : tmp7.xyz;
                    tmp2.w = min(tmp6.y, tmp6.x);
                    tmp2.w = min(tmp6.z, tmp2.w);
                    tmp6.xyz = inp.texcoord3.xyz - unity_SpecCube0_ProbePosition.xyz;
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
                        tmp8.xyz = unity_SpecCube1_BoxMax.xyz - inp.texcoord3.xyz;
                        tmp8.xyz = tmp8.xyz / tmp7.xyz;
                        tmp9.xyz = unity_SpecCube1_BoxMin.xyz - inp.texcoord3.xyz;
                        tmp9.xyz = tmp9.xyz / tmp7.xyz;
                        tmp10.xyz = tmp7.xyz > float3(0.0, 0.0, 0.0);
                        tmp8.xyz = tmp10.xyz ? tmp8.xyz : tmp9.xyz;
                        tmp4.w = min(tmp8.y, tmp8.x);
                        tmp4.w = min(tmp8.z, tmp4.w);
                        tmp8.xyz = inp.texcoord3.xyz - unity_SpecCube1_ProbePosition.xyz;
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
                tmp3.zw = inp.texcoord.xy * _AlphaChannel_ST.xy + _AlphaChannel_ST.zw;
                tmp4 = tex2D(_AlphaChannel, tmp3.zw);
                tmp3.zw = inp.texcoord.xy * _RedChannel_ST.xy + _RedChannel_ST.zw;
                tmp5 = tex2D(_RedChannel, tmp3.zw);
                tmp3.zw = inp.texcoord.xy * _mask1_ST.xy + _mask1_ST.zw;
                tmp7 = tex2D(_mask1, tmp3.zw);
                tmp3.z = saturate(inp.color.x + _blendStrength);
                tmp3.z = 1.0 - tmp3.z;
                tmp3.w = saturate(tmp7.x * 3.8 + -0.8);
                tmp3.w = saturate(tmp3.w + _blendStrength);
                tmp3.z = tmp3.z / tmp3.w;
                tmp3.z = 1.0 - tmp3.z;
                tmp3.z = max(tmp3.z, 0.0);
                tmp5.xyz = tmp5.xyz - tmp4.xyz;
                tmp4.xyz = tmp3.zzz * tmp5.xyz + tmp4.xyz;
                tmp5.xyz = tmp4.xyz - float3(0.04, 0.04, 0.04);
                tmp5.xyz = _Metallic.xxx * tmp5.xyz + float3(0.04, 0.04, 0.04);
                tmp3.z = -_Metallic * 0.96 + 0.96;
                tmp4.xyz = tmp3.zzz * tmp4.xyz;
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
                tmp0.z = dot(tmp5.xyz, tmp5.xyz);
                tmp0.z = tmp0.z != 0.0;
                tmp0.z = tmp0.z ? 1.0 : 0.0;
                tmp0.x = tmp0.z * tmp0.x;
                tmp1.xyz = tmp0.xxx * _LightColor0.xyz;
                tmp0.x = 1.0 - tmp3.y;
                tmp0.z = tmp0.x * tmp0.x;
                tmp0.z = tmp0.z * tmp0.z;
                tmp0.x = tmp0.x * tmp0.z;
                tmp7.xyz = float3(1.0, 1.0, 1.0) - tmp5.xyz;
                tmp7.xyz = tmp7.xyz * tmp0.xxx + tmp5.xyz;
                tmp0.x = saturate(tmp3.z + _Gloss);
                tmp0.z = 1.0 - abs(tmp2.x);
                tmp1.w = tmp0.z * tmp0.z;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.z = tmp0.z * tmp1.w;
                tmp2.xyz = tmp0.xxx - tmp5.xyz;
                tmp2.xyz = tmp0.zzz * tmp2.xyz + tmp5.xyz;
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
                tmp0.xyz = tmp0.xxx * _LightColor0.xyz;
                o.sv_target.xyz = tmp0.xyz * tmp4.xyz + tmp1.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD_DELTA"
			Tags { "LIGHTMODE" = "FORWARDADD" "RenderType" = "Opaque" "SHADOWSUPPORT" = "true" }
			Blend One One, One One
			GpuProgramID 72822
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				float3 texcoord4 : TEXCOORD4;
				float3 texcoord5 : TEXCOORD5;
				float3 texcoord6 : TEXCOORD6;
				float4 color : COLOR0;
				float3 texcoord7 : TEXCOORD7;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float _Metallic;
			float _Gloss;
			float4 _RedChannel_ST;
			float4 _AlphaChannel_ST;
			float _blendStrength;
			float4 _mask1_ST;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _LightTexture0;
			sampler2D _AlphaChannel;
			sampler2D _RedChannel;
			sampler2D _mask1;
			
			// Keywords: DIRLIGHTMAP_OFF DYNAMICLIGHTMAP_OFF LIGHTMAP_OFF POINT
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
                tmp0 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp2 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp2 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp2;
                tmp2 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp2;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp2;
                o.texcoord.xy = v.texcoord.xy;
                o.texcoord1.xy = v.texcoord1.xy;
                o.texcoord2.xy = v.texcoord2.xy;
                o.texcoord3 = tmp0;
                tmp1.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp1.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp1.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.xyz = tmp1.www * tmp1.xyz;
                o.texcoord4.xyz = tmp1.xyz;
                tmp2.xyz = v.tangent.yyy * unity_ObjectToWorld._m01_m11_m21;
                tmp2.xyz = unity_ObjectToWorld._m00_m10_m20 * v.tangent.xxx + tmp2.xyz;
                tmp2.xyz = unity_ObjectToWorld._m02_m12_m22 * v.tangent.zzz + tmp2.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                o.texcoord5.xyz = tmp2.xyz;
                tmp3.xyz = tmp1.zxy * tmp2.yzx;
                tmp1.xyz = tmp1.yzx * tmp2.zxy + -tmp3.xyz;
                tmp1.xyz = tmp1.xyz * v.tangent.www;
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                o.texcoord6.xyz = tmp1.www * tmp1.xyz;
                o.color = v.color;
                tmp1.xyz = tmp0.yyy * unity_WorldToLight._m01_m11_m21;
                tmp1.xyz = unity_WorldToLight._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToLight._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                o.texcoord7.xyz = unity_WorldToLight._m03_m13_m23 * tmp0.www + tmp0.xyz;
                return o;
			}
			// Keywords: DIRLIGHTMAP_OFF DYNAMICLIGHTMAP_OFF LIGHTMAP_OFF POINT
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                tmp0.xy = inp.texcoord.xy * _mask1_ST.xy + _mask1_ST.zw;
                tmp0 = tex2D(_mask1, tmp0.xy);
                tmp0.x = saturate(tmp0.x * 3.8 + -0.8);
                tmp0.x = saturate(tmp0.x + _blendStrength);
                tmp0.y = saturate(inp.color.x + _blendStrength);
                tmp0.y = 1.0 - tmp0.y;
                tmp0.x = tmp0.y / tmp0.x;
                tmp0.x = 1.0 - tmp0.x;
                tmp0.x = max(tmp0.x, 0.0);
                tmp0.yz = inp.texcoord.xy * _RedChannel_ST.xy + _RedChannel_ST.zw;
                tmp1 = tex2D(_RedChannel, tmp0.yz);
                tmp0.yz = inp.texcoord.xy * _AlphaChannel_ST.xy + _AlphaChannel_ST.zw;
                tmp2 = tex2D(_AlphaChannel, tmp0.yz);
                tmp0.yzw = tmp1.xyz - tmp2.xyz;
                tmp0.xyz = tmp0.xxx * tmp0.yzw + tmp2.xyz;
                tmp0.w = -_Metallic * 0.96 + 0.96;
                tmp1.xyz = tmp0.www * tmp0.xyz;
                tmp0.xyz = tmp0.xyz - float3(0.04, 0.04, 0.04);
                tmp0.xyz = _Metallic.xxx * tmp0.xyz + float3(0.04, 0.04, 0.04);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = tmp0.w != 0.0;
                tmp0.w = tmp0.w ? 1.0 : 0.0;
                tmp2.xyz = _WorldSpaceCameraPos - inp.texcoord3.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp3.xyz = tmp1.www * tmp2.xyz;
                tmp2.w = dot(inp.texcoord4.xyz, inp.texcoord4.xyz);
                tmp2.w = rsqrt(tmp2.w);
                tmp4.xyz = tmp2.www * inp.texcoord4.xyz;
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.xyz = _WorldSpaceLightPos0.www * -inp.texcoord3.xyz + _WorldSpaceLightPos0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.w = rsqrt(tmp3.w);
                tmp3.xyz = tmp3.www * tmp3.xyz;
                tmp3.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.w = max(tmp3.w, 0.0);
                tmp4.w = min(tmp3.w, 1.0);
                tmp5.x = 1.0 - _Gloss;
                tmp5.y = -tmp5.x * tmp5.x + 1.0;
                tmp5.z = tmp5.x * tmp5.x;
                tmp5.w = tmp4.w * tmp5.y + tmp5.z;
                tmp5.y = abs(tmp2.w) * tmp5.y + tmp5.z;
                tmp5.z = tmp5.z * tmp5.z;
                tmp5.w = abs(tmp2.w) * tmp5.w;
                tmp2.w = 1.0 - abs(tmp2.w);
                tmp5.y = tmp4.w * tmp5.y + tmp5.w;
                tmp5.y = tmp5.y + 0.00001;
                tmp5.y = 0.5 / tmp5.y;
                tmp2.xyz = tmp2.xyz * tmp1.www + tmp3.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp2.xyz = tmp1.www * tmp2.xyz;
                tmp1.w = saturate(dot(tmp4.xyz, tmp2.xyz));
                tmp2.x = saturate(dot(tmp3.xyz, tmp2.xyz));
                tmp2.y = tmp1.w * tmp5.z + -tmp1.w;
                tmp1.w = tmp2.y * tmp1.w + 1.0;
                tmp1.w = tmp1.w * tmp1.w + 0.0000001;
                tmp2.y = tmp5.z * 0.3183099;
                tmp1.w = tmp2.y / tmp1.w;
                tmp1.w = tmp1.w * tmp5.y;
                tmp1.w = tmp4.w * tmp1.w;
                tmp1.w = tmp1.w * 3.141593;
                tmp1.w = max(tmp1.w, 0.0);
                tmp0.w = tmp0.w * tmp1.w;
                tmp1.w = dot(inp.texcoord7.xyz, inp.texcoord7.xyz);
                tmp4 = tex2D(_LightTexture0, tmp1.ww);
                tmp3.xyz = tmp4.xxx * _LightColor0.xyz;
                tmp4.xyz = tmp0.www * tmp3.xyz;
                tmp5.yzw = float3(1.0, 1.0, 1.0) - tmp0.xyz;
                tmp0.w = 1.0 - tmp2.x;
                tmp1.w = tmp0.w * tmp0.w;
                tmp1.w = tmp1.w * tmp1.w;
                tmp0.w = tmp0.w * tmp1.w;
                tmp0.xyz = tmp5.yzw * tmp0.www + tmp0.xyz;
                tmp0.xyz = tmp0.xyz * tmp4.xyz;
                tmp0.w = tmp2.w * tmp2.w;
                tmp0.w = tmp0.w * tmp0.w;
                tmp0.w = tmp2.w * tmp0.w;
                tmp1.w = tmp2.x + tmp2.x;
                tmp1.w = tmp2.x * tmp1.w;
                tmp1.w = tmp1.w * tmp5.x + -0.5;
                tmp0.w = tmp1.w * tmp0.w + 1.0;
                tmp2.x = 1.0 - tmp3.w;
                tmp2.y = tmp2.x * tmp2.x;
                tmp2.y = tmp2.y * tmp2.y;
                tmp2.x = tmp2.x * tmp2.y;
                tmp1.w = tmp1.w * tmp2.x + 1.0;
                tmp0.w = tmp0.w * tmp1.w;
                tmp0.w = tmp3.w * tmp0.w;
                tmp2.xyz = tmp3.xyz * tmp0.www;
                o.sv_target.xyz = tmp2.xyz * tmp1.xyz + tmp0.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ShaderForgeMaterialInspector"
}