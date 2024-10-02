Shader "VFX/Mega Sphere" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Texture (RGB)", 2D) = "white" {}
		_SliceGuide ("Slice Guide (RGB)", 2D) = "white" {}
		_SliceAmount ("Slice Amount", Range(0, 5)) = 0.5
		_Glow ("Glow", Range(0, 10)) = 1
	}
	SubShader {
		Tags { "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
		Pass {
			Name "FORWARD"
			Tags { "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			ColorMask RGB
			ZWrite Off
			Cull Off
			GpuProgramID 56763
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
			float4 _SliceGuide_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _SliceAmount;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _SliceGuide;
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
                o.texcoord.xy = v.texcoord.xy * _SliceGuide_ST.xy + _SliceGuide_ST.zw;
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
                tmp1 = _Time * float4(0.3, 0.8, -0.2, 0.9) + inp.texcoord.xyxy;
                tmp2 = tex2D(_SliceGuide, tmp1.xy);
                tmp1 = tex2D(_SliceGuide, tmp1.zw);
                tmp0.w = tmp1.x + tmp2.x;
                tmp0.w = tmp0.w - _SliceAmount;
                tmp0.w = tmp0.w < 0.0;
                tmp1.x = 1.0 - _SliceAmount;
                tmp1.x = saturate(tmp1.x * 0.1);
                tmp0.w = tmp0.w ? tmp1.x : 1.0;
                tmp1.xyz = _Color.xyz * _Glow.xxx;
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
                tmp2.x = dot(-tmp0.xyz, inp.texcoord1.xyz);
                tmp2.x = tmp2.x + tmp2.x;
                tmp2.xyz = inp.texcoord1.xyz * -tmp2.xxx + -tmp0.xyz;
                tmp3.xyz = tmp1.www * _LightColor0.xyz;
                tmp2 = UNITY_SAMPLE_TEXCUBE_SAMPLER(unity_SpecCube0, unity_SpecCube0, float4(tmp2.xyz, 6.0));
                tmp1.w = tmp2.w - 1.0;
                tmp1.w = unity_SpecCube0_HDR.w * tmp1.w + 1.0;
                tmp1.w = log(tmp1.w);
                tmp1.w = tmp1.w * unity_SpecCube0_HDR.y;
                tmp1.w = exp(tmp1.w);
                tmp1.w = tmp1.w * unity_SpecCube0_HDR.x;
                tmp2.xyz = tmp2.xyz * tmp1.www;
                tmp1.w = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp4.xyz = tmp1.www * inp.texcoord1.xyz;
                tmp5.xyz = _Color.xyz * float3(0.96, 0.96, 0.96);
                tmp1.w = dot(tmp0.xyz, tmp4.xyz);
                tmp2.w = tmp1.w + tmp1.w;
                tmp0.xyz = tmp4.xyz * -tmp2.www + tmp0.xyz;
                tmp2.w = saturate(dot(tmp4.xyz, _WorldSpaceLightPos0.xyz));
                tmp1.w = saturate(tmp1.w);
                tmp4.x = dot(tmp0.xyz, _WorldSpaceLightPos0.xyz);
                tmp4.y = 1.0 - tmp1.w;
                tmp4.zw = tmp4.xy * tmp4.xy;
                tmp0.xy = tmp4.xy * tmp4.xw;
                tmp0.xy = tmp4.zy * tmp0.xy;
                tmp0.z = 1.0;
                tmp4 = tex2D(unity_NHxRoughness, tmp0.xz);
                tmp0.x = tmp4.x * 0.64;
                tmp4.xyz = tmp5.xyz * tmp0.www + tmp0.xxx;
                tmp3.xyz = tmp2.www * tmp3.xyz;
                tmp0.x = tmp0.y * 0.0 + 0.04;
                tmp0.xyz = tmp0.xxx * tmp2.xyz;
                tmp0.xyz = tmp4.xyz * tmp3.xyz + tmp0.xyz;
                o.sv_target.xyz = tmp1.xyz * tmp0.www + tmp0.xyz;
                o.sv_target.w = tmp0.w;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			Tags { "LIGHTMODE" = "FORWARDADD" "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
			Blend One One, One One
			ColorMask RGB
			ZWrite Off
			Cull Off
			GpuProgramID 70962
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
			float4 _SliceGuide_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _Color;
			float _SliceAmount;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _SliceGuide;
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
                o.texcoord.xy = v.texcoord.xy * _SliceGuide_ST.xy + _SliceGuide_ST.zw;
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
                tmp2 = _Time * float4(0.3, 0.8, -0.2, 0.9) + inp.texcoord.xyxy;
                tmp3 = tex2D(_SliceGuide, tmp2.xy);
                tmp2 = tex2D(_SliceGuide, tmp2.zw);
                tmp0.w = tmp2.x + tmp3.x;
                tmp0.w = tmp0.w - _SliceAmount;
                tmp0.w = tmp0.w < 0.0;
                tmp1.w = 1.0 - _SliceAmount;
                tmp1.w = saturate(tmp1.w * 0.1);
                tmp0.w = tmp0.w ? tmp1.w : 1.0;
                tmp2.xyz = inp.texcoord2.yyy * unity_WorldToLight._m01_m11_m21;
                tmp2.xyz = unity_WorldToLight._m00_m10_m20 * inp.texcoord2.xxx + tmp2.xyz;
                tmp2.xyz = unity_WorldToLight._m02_m12_m22 * inp.texcoord2.zzz + tmp2.xyz;
                tmp2.xyz = tmp2.xyz + unity_WorldToLight._m03_m13_m23;
                tmp1.w = unity_ProbeVolumeParams.x == 1.0;
                if (tmp1.w) {
                    tmp1.w = unity_ProbeVolumeParams.y == 1.0;
                    tmp3.xyz = inp.texcoord2.yyy * unity_ProbeVolumeWorldToObject._m01_m11_m21;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m00_m10_m20 * inp.texcoord2.xxx + tmp3.xyz;
                    tmp3.xyz = unity_ProbeVolumeWorldToObject._m02_m12_m22 * inp.texcoord2.zzz + tmp3.xyz;
                    tmp3.xyz = tmp3.xyz + unity_ProbeVolumeWorldToObject._m03_m13_m23;
                    tmp3.xyz = tmp1.www ? tmp3.xyz : inp.texcoord2.xyz;
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
                tmp2.x = dot(tmp2.xyz, tmp2.xyz);
                tmp2 = tex2D(_LightTexture0, tmp2.xx);
                tmp1.w = tmp1.w * tmp2.x;
                tmp2.xyz = tmp1.www * _LightColor0.xyz;
                tmp1.w = dot(inp.texcoord1.xyz, inp.texcoord1.xyz);
                tmp1.w = rsqrt(tmp1.w);
                tmp3.xyz = tmp1.www * inp.texcoord1.xyz;
                tmp4.xyz = _Color.xyz * float3(0.96, 0.96, 0.96);
                tmp1.w = dot(tmp1.xyz, tmp3.xyz);
                tmp1.w = tmp1.w + tmp1.w;
                tmp1.xyz = tmp3.xyz * -tmp1.www + tmp1.xyz;
                tmp1.w = saturate(dot(tmp3.xyz, tmp0.xyz));
                tmp0.x = dot(tmp1.xyz, tmp0.xyz);
                tmp0.x = tmp0.x * tmp0.x;
                tmp0.x = tmp0.x * tmp0.x;
                tmp0.y = 1.0;
                tmp3 = tex2D(unity_NHxRoughness, tmp0.xy);
                tmp0.x = tmp3.x * 0.64;
                tmp0.xyz = tmp4.xyz * tmp0.www + tmp0.xxx;
                tmp1.xyz = tmp1.www * tmp2.xyz;
                o.sv_target.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.w = tmp0.w;
                return o;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}