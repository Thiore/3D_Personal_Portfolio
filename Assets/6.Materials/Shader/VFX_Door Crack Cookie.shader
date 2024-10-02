Shader "VFX/Door Crack Cookie" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture 2", 2D) = "white" {}
		_Cutoff ("Cutoff", Float) = 0
		_NoisePower ("Noise Power", Float) = 1
		_Scale ("Scale", Float) = 1
		_Clip ("Clip", Float) = 0
	}
	SubShader {
		Pass {
			ZTest Always
			Cull Off
			GpuProgramID 15770
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float4 position : SV_POSITION0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			float _Cutoff;
			float _NoisePower;
			float _Scale;
			int _Clip;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _MainTex2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                o.texcoord.xy = v.texcoord.xy;
                o.texcoord1.xy = v.texcoord1.xy;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
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
                float4 tmp1;
                float4 tmp2;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.xyz = _Time.xxx * float3(8.0, 10.0, 7.0);
                tmp1.xy = inp.texcoord1.xy * _Scale.xx + tmp0.xy;
                tmp1 = tex2D(_MainTex2, tmp1.xy);
                tmp0.xy = inp.texcoord1.xy * _Scale.xx + -tmp0.zx;
                tmp2 = tex2D(_MainTex2, tmp0.xy);
                tmp0.x = tmp1.x + tmp2.x;
                tmp0.x = tmp0.x * tmp0.w;
                tmp0.y = _Clip > 0;
                tmp0.x = tmp0.x * _NoisePower + -_Cutoff;
                tmp0.x = tmp0.x < 0.0;
                tmp0.y = tmp0.y ? tmp0.x : 0.0;
                if (tmp0.y) {
                    discard;
                }
                if (tmp0.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                    return o;
                }
                o.sv_target = float4(1.0, 1.0, 1.0, 1.0);
                return o;
			}
			ENDCG
		}
	}
}