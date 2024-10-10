Shader "Unlit/Cloud Shader" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_NightColor ("Night Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {}
		_NoiseTex ("Noise Decay", 2D) = "white" {}
		_NewLightDir ("Light Dir", Vector) = (0,0,0,0)
		_Alpha ("Alpha Amount", Range(0, 1)) = 0
		_Glow ("Glow Amount", Range(1, 4)) = 1
		_VertexOffset ("Vertex Offset", Float) = 1
		_VertexAmplitude ("Vertex Amplitude", Range(0, 1)) = 1
		_NoiseOffset ("Noise Offset", Vector) = (0,0,0,0)
		_NoiseScale ("Noise Scale", Float) = 1
	}
	SubShader {
		LOD 100
		Tags { "RenderType" = "Opaque" }
		Pass {
			LOD 100
			Tags { "RenderType" = "Opaque" }
			GpuProgramID 48519
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float2 texcoord : TEXCOORD0;
				float4 position : SV_POSITION0;
				float3 normal : NORMAL0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			float _VertexOffset;
			float _VertexAmplitude;
			float _NoiseScale;
			float2 _NoiseOffset;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Color;
			float4 _NightColor;
			float _Night;
			float _Glow;
			float3 _NewLightDir;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _NoiseTex;
			// Texture params for Fragment Shader
			sampler2D _Ramp;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp0.xw = float2(0.01, 0.02);
                tmp1.xy = v.texcoord.xy;
                tmp1.zw = tmp1.xy * _NoiseScale.xx;
                tmp0.y = tmp1.w;
                tmp2.xy = _NoiseOffset * _Time.xx;
                tmp3.x = tmp2.x * 2.0 + tmp1.z;
                tmp3.y = tmp2.y;
                tmp4 = tmp0.xywy + tmp3.xyxy;
                tmp5 = tex2Dlod(_NoiseTex, float4(tmp4.xy, 0, 0.0));
                tmp4 = tex2Dlod(_NoiseTex, float4(tmp4.zw, 0, 0.0));
                tmp3.yzw = tmp1.xyy * _NoiseScale.xxx + tmp2.xyy;
                tmp1 = tex2Dlod(_NoiseTex, float4(tmp3.xw, 0, 0.0));
                tmp0.z = tmp5.x + tmp1.x;
                tmp0.z = tmp4.x + tmp0.z;
                tmp0.z = tmp0.z * 0.3333333;
                tmp2.z = tmp3.y;
                tmp1 = tex2Dlod(_NoiseTex, float4(tmp3.yz, 0, 0.0));
                tmp2 = tmp0.xywy + tmp2.zyzy;
                tmp3 = tex2Dlod(_NoiseTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_NoiseTex, float4(tmp2.zw, 0, 0.0));
                tmp0.x = tmp1.x + tmp3.x;
                tmp0.x = tmp2.x + tmp0.x;
                tmp0.x = tmp0.x * 0.3333333 + tmp0.z;
                tmp0.x = tmp0.x * v.color.x;
                tmp0.xyz = tmp0.xxx * v.normal.xyz;
                tmp0.w = _SinTime.x * _VertexAmplitude + _VertexOffset;
                tmp0.xyz = tmp0.xyz * tmp0.www + v.vertex.xyz;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.normal.xyz = v.normal.xyz;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = dot(inp.normal.xyz, _NewLightDir);
                tmp0.x = tmp0.x * 0.5 + 0.5;
                tmp0 = tex2D(_Ramp, tmp0.xx);
                tmp1.xyz = _NightColor.xyz - _Color.xyz;
                tmp1.xyz = _Night.xxx * tmp1.xyz + _Color.xyz;
                tmp1.xyz = tmp1.xyz * _Glow.xxx;
                o.sv_target.xyz = tmp0.xyz * tmp1.xyz;
                return o;
			}
			ENDCG
		}
	}
}