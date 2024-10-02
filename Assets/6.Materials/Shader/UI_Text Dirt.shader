Shader "UI/Text Dirt" {
	Properties {
		_NoiseIntensity ("Noise Intensity", Float) = 1
		_NoiseScale ("Noise Texture Scale", Float) = 1
		_NoiseTexture ("Noise", 2D) = "white" {}
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_RandomNoise ("Random Noise", Float) = 0
		[PerRendererData] _RandNum ("Random", Vector) = (0,0,0,0)
	}
	SubShader {
		Tags { "FORCENOSHADOWCASTING" = "true" "IGNOREPROJECTOR" = "true" "QUEUE" = "Geometry" "RenderType" = "Opaque" }
		Pass {
			Tags { "FORCENOSHADOWCASTING" = "true" "IGNOREPROJECTOR" = "true" "QUEUE" = "Geometry" "RenderType" = "Opaque" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Stencil {
				Ref 1
				Comp NotEqual
				Pass Keep
				Fail Keep
				ZFail Keep
			}
			GpuProgramID 16107
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
			float _NoiseIntensity;
			float _NoiseScale;
			float _RandomNoise;
			float2 _RandNum;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _NoiseTexture;
			
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
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy;
                o.color = v.color;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0.xy = _RandNum * _RandomNoise.xx + inp.texcoord.xy;
                tmp0.xy = tmp0.xy * _NoiseScale.xx;
                tmp0 = tex2D(_NoiseTexture, tmp0.xy);
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.x = tmp0.x * tmp1.w;
                o.sv_target.w = tmp0.x * _NoiseIntensity;
                o.sv_target.xyz = inp.color.xyz;
                return o;
			}
			ENDCG
		}
	}
}