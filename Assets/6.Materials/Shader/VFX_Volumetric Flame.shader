Shader "VFX/Volumetric Flame" {
	Properties {
		_Color ("color", Color) = (1,1,1,1)
		_Speed ("Speed", Float) = 1
		_Noise ("Noise (RGB)", 2D) = "white" {}
		_OffsetMulti ("Vertex Displacement", Float) = 1
		_Cutoff ("Cutoff", Float) = 1
		_Glow ("Glow", Float) = 1
	}
	SubShader {
		LOD 100
		Tags { "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
		Pass {
			LOD 100
			Tags { "QUEUE" = "Transparent+1" "RenderType" = "Transparent" }
			Cull Off
			GpuProgramID 5569
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
			float4 _Noise_ST;
			float _OffsetMulti;
			float _Speed;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Color;
			float _Cutoff;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _Noise;
			// Texture params for Fragment Shader
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.xy = v.texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;
                o.texcoord.xy = tmp0.xy;
                tmp0.xy = _Time.xy * _Speed.xx + tmp0.xy;
                tmp0 = tex2Dlod(_Noise, float4(tmp0.xy, 0, 0.0));
                tmp1.xyz = tmp0.yyy * v.normal.xyz;
                tmp0.xz = float2(0.0, 0.0);
                tmp0.xyz = tmp1.xyz * float3(0.5, 0.5, 0.5) + tmp0.xyz;
                tmp0.xyz = tmp0.xyz * _OffsetMulti.xxx;
                tmp0.w = saturate(v.normal.y);
                tmp0.xyz = tmp0.xyz * tmp0.www + v.vertex.xyz;
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
                tmp0 = tex2D(_Noise, inp.texcoord.xy);
                tmp0.x = tmp0.x - _Cutoff;
                tmp0.x = tmp0.x < 0.0;
                if (tmp0.x) {
                    discard;
                }
                o.sv_target = _Color * _Glow.xxxx;
                return o;
			}
			ENDCG
		}
	}
}