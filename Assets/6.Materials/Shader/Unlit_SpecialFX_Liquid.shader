Shader "Unlit/SpecialFX/Liquid" {
	Properties {
		_Tint ("Tint", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_FillAmount ("Fill Amount", Range(-10, 10)) = 0
		[HideInInspector] _WobbleX ("WobbleX", Range(-1, 1)) = 0
		[HideInInspector] _WobbleZ ("WobbleZ", Range(-1, 1)) = 0
		_TopColor ("Top Color", Color) = (1,1,1,1)
		_FoamColor ("Foam Line Color", Color) = (1,1,1,1)
		_Rim ("Foam Line Width", Range(0, 0.1)) = 0
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimPower ("Rim Power", Range(0, 10)) = 0
	}
	SubShader {
		Tags { "DisableBatching" = "true" "QUEUE" = "Geometry" }
		Pass {
			Tags { "DisableBatching" = "true" "QUEUE" = "Geometry" }
			AlphaToMask On
			Cull Off
			GpuProgramID 31754
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float2 texcoord : TEXCOORD0;
				float texcoord2 : TEXCOORD2;
				float4 position : SV_POSITION0;
				float3 color : COLOR0;
				float3 color2 : COLOR2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float _FillAmount;
			float _WobbleX;
			float _WobbleZ;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _TopColor;
			float4 _RimColor;
			float4 _FoamColor;
			float4 _Tint;
			float _Rim;
			float _RimPower;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
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
                tmp1.x = dot(float2(1.0, 0.0000002), tmp0.xy);
                tmp1.x = tmp1.x * _WobbleX + tmp0.y;
                tmp1.x = tmp0.z * _WobbleZ + tmp1.x;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord2.x = tmp1.x + _FillAmount;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                tmp0.xyz = _WorldSpaceCameraPos * unity_WorldToObject._m01_m11_m21;
                tmp0.xyz = unity_WorldToObject._m00_m10_m20 * _WorldSpaceCameraPos + tmp0.xyz;
                tmp0.xyz = unity_WorldToObject._m02_m12_m22 * _WorldSpaceCameraPos + tmp0.xyz;
                tmp0.xyz = tmp0.xyz + unity_WorldToObject._m03_m13_m23;
                tmp0.xyz = tmp0.xyz - v.vertex.xyz;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                o.color.xyz = tmp0.www * tmp0.xyz;
                o.color2.xyz = v.normal.xyz;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp, float facing: VFACE)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.x = dot(inp.color2.xyz, inp.color.xyz);
                tmp0.x = log(tmp0.x);
                tmp0.x = tmp0.x * _RimPower;
                tmp0.x = exp(tmp0.x);
                tmp0.x = 0.5 - tmp0.x;
                tmp0.x = tmp0.x + tmp0.x;
                tmp0.x = max(tmp0.x, 0.0);
                tmp0.y = tmp0.x * -2.0 + 3.0;
                tmp0.x = tmp0.x * tmp0.x;
                tmp0.x = tmp0.x * tmp0.y;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1 = tmp1 * _Tint;
                tmp0.y = 0.5 - _Rim;
                tmp0.y = tmp0.y >= inp.texcoord2.x;
                tmp0.y = tmp0.y ? -1.0 : -0.0;
                tmp0.z = inp.texcoord2.x <= 0.5;
                tmp0.z = tmp0.z ? 1.0 : 0.0;
                tmp0.y = tmp0.y + tmp0.z;
                tmp0.w = tmp0.z - tmp0.y;
                tmp2 = tmp0.yyyy * _FoamColor;
                tmp2 = tmp2 * float4(0.9, 0.9, 0.9, 0.9);
                tmp1 = tmp0.wwww * tmp1 + tmp2;
                tmp2 = tmp0.zzzz * _TopColor;
                tmp1.xyz = tmp0.xxx * _RimColor.xyz + tmp1.xyz;
                o.sv_target = facing.xxxx ? tmp1 : tmp2;
                return o;
			}
			ENDCG
		}
	}
}