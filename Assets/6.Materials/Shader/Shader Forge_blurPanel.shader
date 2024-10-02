Shader "Shader Forge/blurPanel" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_BumpAmt ("Distortion", Range(0, 128)) = 10
		_MainTex ("Tint Color (RGB)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_Size ("Size", Range(0, 20)) = 1
	}
	SubShader {
		Tags { "IGNOREPROJECTOR" = "true" "QUEUE" = "Transparent" "RenderType" = "Opaque" }
		GrabPass {
		}
		Pass {
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "ALWAYS" "QUEUE" = "Transparent" "RenderType" = "Opaque" }
			GpuProgramID 34047
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 sv_position : SV_Position0;
				float4 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			float4 _GrabTexture_TexelSize;
			float _Size;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _GrabTexture;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.sv_position = tmp0;
                tmp0.xy = tmp0.xy * float2(1.0, -1.0) + tmp0.ww;
                o.texcoord.zw = tmp0.zw;
                o.texcoord.xy = tmp0.xy * float2(0.5, 0.5);
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
                tmp0.yw = inp.texcoord.yy;
                tmp1.x = _GrabTexture_TexelSize.x * _Size;
                tmp2 = tmp1.xxxx * float4(3.0, -4.0, -3.0, -2.0) + inp.texcoord.xxxx;
                tmp0.xz = tmp2.yz;
                tmp0 = tmp0 / inp.texcoord.wwww;
                tmp3 = tex2D(_GrabTexture, tmp0.zw);
                tmp0 = tex2D(_GrabTexture, tmp0.xy);
                tmp3 = tmp3 * float4(0.09, 0.09, 0.09, 0.09);
                tmp0 = tmp0 * float4(0.05, 0.05, 0.05, 0.05) + tmp3;
                tmp3.x = tmp2.w;
                tmp3.yw = inp.texcoord.yy;
                tmp1.yz = tmp3.xy / inp.texcoord.ww;
                tmp4 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp4 * float4(0.12, 0.12, 0.12, 0.12) + tmp0;
                tmp3.z = -_GrabTexture_TexelSize.x * _Size + inp.texcoord.x;
                tmp1.yz = tmp3.zw / inp.texcoord.ww;
                tmp3 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp3 * float4(0.15, 0.15, 0.15, 0.15) + tmp0;
                tmp1.yz = inp.texcoord.xy / inp.texcoord.ww;
                tmp3 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp3 * float4(0.18, 0.18, 0.18, 0.18) + tmp0;
                tmp3.x = _GrabTexture_TexelSize.x * _Size + inp.texcoord.x;
                tmp3.yw = inp.texcoord.yy;
                tmp1.yz = tmp3.xy / inp.texcoord.ww;
                tmp4 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp4 * float4(0.15, 0.15, 0.15, 0.15) + tmp0;
                tmp3.z = tmp1.x * 2.0 + inp.texcoord.x;
                tmp2.z = tmp1.x * 4.0 + inp.texcoord.x;
                tmp1.xy = tmp3.zw / inp.texcoord.ww;
                tmp1 = tex2D(_GrabTexture, tmp1.xy);
                tmp0 = tmp1 * float4(0.12, 0.12, 0.12, 0.12) + tmp0;
                tmp2.yw = inp.texcoord.yy;
                tmp1 = tmp2 / inp.texcoord.wwww;
                tmp2 = tex2D(_GrabTexture, tmp1.zw);
                tmp1 = tex2D(_GrabTexture, tmp1.xy);
                tmp0 = tmp1 * float4(0.09, 0.09, 0.09, 0.09) + tmp0;
                o.sv_target = tmp2 * float4(0.05, 0.05, 0.05, 0.05) + tmp0;
                return o;
			}
			ENDCG
		}
		GrabPass {
		}
		Pass {
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "ALWAYS" "QUEUE" = "Transparent" "RenderType" = "Opaque" }
			GpuProgramID 90330
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 sv_position : SV_Position0;
				float4 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			float4 _GrabTexture_TexelSize;
			float _Size;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _GrabTexture;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.sv_position = tmp0;
                tmp0.xy = tmp0.xy * float2(1.0, -1.0) + tmp0.ww;
                o.texcoord.zw = tmp0.zw;
                o.texcoord.xy = tmp0.xy * float2(0.5, 0.5);
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
                tmp0.xz = inp.texcoord.xx;
                tmp1.x = _GrabTexture_TexelSize.y * _Size;
                tmp2 = tmp1.xxxx * float4(-4.0, 3.0, -3.0, -2.0) + inp.texcoord.yyyy;
                tmp0.yw = tmp2.xz;
                tmp0 = tmp0 / inp.texcoord.wwww;
                tmp3 = tex2D(_GrabTexture, tmp0.zw);
                tmp0 = tex2D(_GrabTexture, tmp0.xy);
                tmp3 = tmp3 * float4(0.09, 0.09, 0.09, 0.09);
                tmp0 = tmp0 * float4(0.05, 0.05, 0.05, 0.05) + tmp3;
                tmp3.y = tmp2.w;
                tmp3.xz = inp.texcoord.xx;
                tmp1.yz = tmp3.xy / inp.texcoord.ww;
                tmp4 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp4 * float4(0.12, 0.12, 0.12, 0.12) + tmp0;
                tmp3.w = -_GrabTexture_TexelSize.y * _Size + inp.texcoord.y;
                tmp1.yz = tmp3.zw / inp.texcoord.ww;
                tmp3 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp3 * float4(0.15, 0.15, 0.15, 0.15) + tmp0;
                tmp1.yz = inp.texcoord.xy / inp.texcoord.ww;
                tmp3 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp3 * float4(0.18, 0.18, 0.18, 0.18) + tmp0;
                tmp3.y = _GrabTexture_TexelSize.y * _Size + inp.texcoord.y;
                tmp3.xz = inp.texcoord.xx;
                tmp1.yz = tmp3.xy / inp.texcoord.ww;
                tmp4 = tex2D(_GrabTexture, tmp1.yz);
                tmp0 = tmp4 * float4(0.15, 0.15, 0.15, 0.15) + tmp0;
                tmp3.w = tmp1.x * 2.0 + inp.texcoord.y;
                tmp2.w = tmp1.x * 4.0 + inp.texcoord.y;
                tmp1.xy = tmp3.zw / inp.texcoord.ww;
                tmp1 = tex2D(_GrabTexture, tmp1.xy);
                tmp0 = tmp1 * float4(0.12, 0.12, 0.12, 0.12) + tmp0;
                tmp2.xz = inp.texcoord.xx;
                tmp1 = tmp2 / inp.texcoord.wwww;
                tmp2 = tex2D(_GrabTexture, tmp1.zw);
                tmp1 = tex2D(_GrabTexture, tmp1.xy);
                tmp0 = tmp1 * float4(0.09, 0.09, 0.09, 0.09) + tmp0;
                o.sv_target = tmp2 * float4(0.05, 0.05, 0.05, 0.05) + tmp0;
                return o;
			}
			ENDCG
		}
		GrabPass {
		}
		Pass {
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "ALWAYS" "QUEUE" = "Transparent" "RenderType" = "Opaque" }
			GpuProgramID 134677
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 sv_position : SV_Position0;
				float4 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _BumpMap_ST;
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float _BumpAmt;
			float4 _Color;
			float4 _GrabTexture_TexelSize;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _BumpMap;
			sampler2D _GrabTexture;
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.sv_position = tmp0;
                tmp0.xy = tmp0.xy * float2(1.0, -1.0) + tmp0.ww;
                o.texcoord.zw = tmp0.zw;
                o.texcoord.xy = tmp0.xy * float2(0.5, 0.5);
                o.texcoord1.xy = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                o.texcoord2.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = tex2D(_BumpMap, inp.texcoord1.xy);
                tmp0.x = tmp0.w * tmp0.x;
                tmp0.xy = tmp0.xy * float2(2.0, 2.0) + float2(-1.0, -1.0);
                tmp0.xy = tmp0.xy * _BumpAmt.xx;
                tmp0.xy = tmp0.xy * _GrabTexture_TexelSize.xy;
                tmp0.xy = tmp0.xy * inp.texcoord.zz + inp.texcoord.xy;
                tmp0.xy = tmp0.xy / inp.texcoord.ww;
                tmp0 = tex2D(_GrabTexture, tmp0.xy);
                tmp1 = tex2D(_MainTex, inp.texcoord2.xy);
                tmp1 = tmp1 * _Color;
                o.sv_target = tmp0 * tmp1;
                return o;
			}
			ENDCG
		}
	}
}