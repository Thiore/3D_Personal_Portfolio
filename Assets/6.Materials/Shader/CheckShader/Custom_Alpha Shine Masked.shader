Shader "Custom/Alpha Shine Masked" {
	Properties {
		_Shine ("Shine (RGB)", 2D) = "white" {}
		_Shine2 ("Shine (RGB)", 2D) = "white" {}
		[PropertyBlock] _ShineOffset ("Shine Offset", Range(-1, 2)) = 0
		_ShineColor ("Shine Color", Color) = (0.5,0.5,0.5,1)
		[PropertyBlock] _ShineGlow ("Shine Glow", Range(0, 50)) = 1
		_MegaGlow ("Overriding glow", Range(0, 1)) = 0
	}
	SubShader {
		LOD 200
		Tags { "QUEUE" = "Transparent+100" "RenderType" = "Transparent" }
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDBASE" "QUEUE" = "Transparent+100" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			Blend One One, One One
			Stencil {
				Ref 2
				Comp Equal
				Pass Keep
				Fail Keep
				ZFail DecrementWrap
			}
			GpuProgramID 40686
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
				float4 texcoord5 : TEXCOORD5;
				float4 texcoord6 : TEXCOORD6;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _Shine_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _ShineColor;
			float _ShineOffset;
			float _ShineGlow;
			float _MegaGlow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _Shine;
			sampler2D _Shine2;
			
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
                o.texcoord.xy = v.texcoord.xy * _Shine_ST.xy + _Shine_ST.zw;
                tmp0.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp0.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp0.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.texcoord1.xyz = tmp0.www * tmp0.xyz;
                o.texcoord3.xyz = float3(0.0, 0.0, 0.0);
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
                tmp0.xy = -_ShineOffset.xx * float2(2.0, 2.0) + inp.texcoord.xy;
                tmp0 = tex2D(_Shine, tmp0.xy);
                tmp1.x = _ShineOffset * 0.1 + inp.texcoord.x;
                tmp1.yz = inp.texcoord.yx - _ShineOffset.xx;
                tmp2 = tex2D(_Shine, tmp1.xy);
                tmp1.w = -_ShineOffset * 6.0 + inp.texcoord.y;
                tmp1 = tex2D(_Shine2, tmp1.zw);
                tmp0.x = tmp2.x * tmp0.x + tmp1.x;
                tmp0.y = 1.0 - tmp0.x;
                tmp0.x = _MegaGlow * tmp0.y + tmp0.x;
                tmp0.xyz = tmp0.xxx * _ShineColor.xyz;
                tmp0.xyz = tmp0.xyz * _ShineGlow.xxx;
                o.sv_target.xyz = tmp0.xyz * inp.texcoord3.xyz + tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Name "FORWARD"
			LOD 200
			Tags { "LIGHTMODE" = "FORWARDADD" "QUEUE" = "Transparent+100" "RenderType" = "Transparent" }
			Blend One One, One One
			ZWrite Off
			Stencil {
				Ref 2
				Comp Equal
				Pass Keep
				Fail Keep
				ZFail DecrementWrap
			}
			GpuProgramID 70120
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
				float4 texcoord4 : TEXCOORD4;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_WorldToLight;
			float4 _Shine_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _ShineColor;
			float _ShineOffset;
			float _ShineGlow;
			float _MegaGlow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _Shine;
			sampler2D _Shine2;
			
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
                o.texcoord.xy = v.texcoord.xy * _Shine_ST.xy + _Shine_ST.zw;
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
                tmp0.xy = -_ShineOffset.xx * float2(2.0, 2.0) + inp.texcoord.xy;
                tmp0 = tex2D(_Shine, tmp0.xy);
                tmp1.x = _ShineOffset * 0.1 + inp.texcoord.x;
                tmp1.yz = inp.texcoord.yx - _ShineOffset.xx;
                tmp2 = tex2D(_Shine, tmp1.xy);
                tmp1.w = -_ShineOffset * 6.0 + inp.texcoord.y;
                tmp1 = tex2D(_Shine2, tmp1.zw);
                tmp0.x = tmp2.x * tmp0.x + tmp1.x;
                tmp0.y = 1.0 - tmp0.x;
                tmp0.x = _MegaGlow * tmp0.y + tmp0.x;
                tmp0.xyz = tmp0.xxx * _ShineColor.xyz;
                o.sv_target.xyz = tmp0.xyz * _ShineGlow.xxx;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
	}
}