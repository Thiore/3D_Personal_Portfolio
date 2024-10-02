// Upgrade NOTE: replaced 'glstate_matrix_projection' with 'UNITY_MATRIX_P'

Shader "Hidden/ProBuilder/VertexPicker" {
	Properties {
	}
	SubShader {
		Tags { "DisableBatching" = "true" "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "ALWAYS" "ProBuilderPicker" = "VertexPass" "RenderType" = "Transparent" }
		Pass {
			Name "Vertices"
			Tags { "DisableBatching" = "true" "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "ALWAYS" "ProBuilderPicker" = "VertexPass" "RenderType" = "Transparent" }
			Cull Off
			Offset -1, -1
			GpuProgramID 18139
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float4 color : COLOR0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			
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
                tmp1.xyz = tmp0.yyy * unity_MatrixV._m01_m11_m21;
                tmp1.xyz = unity_MatrixV._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_MatrixV._m02_m12_m22 * tmp0.zzz + tmp1.xyz;
                tmp0.xyz = unity_MatrixV._m03_m13_m23 * tmp0.www + tmp0.xyz;
                tmp0.w = 1.0 - UNITY_MATRIX_P._m33;
                tmp1.x = tmp0.w * -0.04 + 0.99;
                tmp0.xyz = tmp0.xyz * tmp1.xxx;
                tmp1 = tmp0.yyyy * UNITY_MATRIX_P._m01_m11_m21_m31;
                tmp1 = UNITY_MATRIX_P._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = UNITY_MATRIX_P._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp1 = tmp1 + UNITY_MATRIX_P._m03_m13_m23_m33;
                tmp0.xy = tmp1.xy / tmp1.ww;
                tmp0.xy = tmp0.xy * float2(0.5, 0.5) + float2(0.5, 0.5);
                tmp1.xy = v.texcoord1.xy * float2(3.5, 3.5);
                tmp0.xy = tmp0.xy * _ScreenParams.xy + tmp1.xy;
                tmp0.xy = tmp0.xy / _ScreenParams.xy;
                tmp0.xy = tmp0.xy - float2(0.5, 0.5);
                tmp0.xy = tmp1.ww * tmp0.xy;
                o.position.xy = tmp0.xy + tmp0.xy;
                o.position.z = -tmp0.w * 0.0001 + tmp1.z;
                o.position.w = tmp1.w;
                o.texcoord.xy = v.texcoord.xy;
                o.color = v.color;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                o.sv_target = inp.color;
                return o;
			}
			ENDCG
		}
	}
}