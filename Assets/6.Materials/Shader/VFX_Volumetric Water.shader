Shader "VFX/Volumetric Water" {
	Properties {
		_BloodColor ("Blood color", Color) = (1,1,1,1)
		_SliceGuide ("Slice Guide (RGB)", 2D) = "white" {}
		_SliceAmount ("Slice Amount", Range(0, 1)) = 0.5
		_OffsetMulti ("Vertex Displacement", Float) = 1
	}
	SubShader {
		LOD 100
		Tags { "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
		Pass {
			LOD 100
			Tags { "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
			Cull Off
			GpuProgramID 37137
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float2 texcoord : TEXCOORD0;
				float4 position : SV_POSITION0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _SliceGuide_ST;
			float _OffsetMulti;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _BloodColor;
			float _SliceAmount;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _SliceGuide;
			// Texture params for Fragment Shader
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                o.texcoord.xy = v.texcoord.xy * _SliceGuide_ST.xy + _SliceGuide_ST.zw;
                tmp0 = tex2Dlod(_SliceGuide, float4(v.texcoord.xy, 0, 0.0));
                tmp0.xyz = tmp0.xxx * v.normal.xyz;
                tmp0.xyz = tmp0.xyz * _OffsetMulti.xxx + v.vertex.xyz;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                tmp0 = tex2D(_SliceGuide, inp.texcoord.xy);
                tmp0.x = tmp0.y - _SliceAmount;
                tmp0.x = tmp0.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                o.sv_target = _BloodColor;
                return o;
			}
			ENDCG
		}
	}
}