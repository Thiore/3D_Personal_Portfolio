Shader "VFX/Cookie Gen Leaf" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture 2", 2D) = "white" {}
		_Strength ("Strength", Range(0, 1)) = 1
		_SineStr ("Sine Range", Range(0, 1)) = 0.25
		_SineSpeedX ("Sine Speed X", Float) = 1
		_SineSpeedY ("Sine Speed Y", Float) = 1
		_Distance ("Distance Multiplier", Float) = 1
		_SineValue ("Sine Value", Float) = 0
		_OffsetFrequency ("Offset Frequency", Float) = 2
		_SecondTexOffset ("Second Layer Offset", Vector) = (0,0,0,0)
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 64361
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
			// $Globals ConstantBuffers for Fragment Shader
			float _SineSpeedX;
			float _SineSpeedY;
			float _OffsetFrequency;
			float _Strength;
			float _Distance;
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
                o.texcoord.xy = v.texcoord.xy;
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
                tmp0.xy = inp.texcoord.yx * _OffsetFrequency.xx;
                tmp0.xy = _Time.yy * float2(1.5, 1.5) + tmp0.xy;
                tmp0.xy = tmp0.xy * float2(_SineSpeedX.x, _SineSpeedY.x) + float2(2.0, 2.0);
                tmp0.xy = sin(tmp0.xy);
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.xy = tmp0.xy * tmp1.yy;
                tmp0.zw = inp.texcoord.yx + float2(0.5, 0.25);
                tmp0.xy = tmp0.xy * _Distance.xx + tmp0.zw;
                tmp0 = tex2D(_MainTex, tmp0.xy);
                tmp0.x = tmp0.x * 3.0 + -1.0;
                tmp0.x = tmp0.x * _Strength;
                tmp0.x = tmp0.x * 0.8 + 1.0;
                tmp0.yz = inp.texcoord.xy * _OffsetFrequency.xx + _Time.yy;
                tmp0.yz = tmp0.yz * float2(_SineSpeedX.x, _SineSpeedY.x);
                tmp0.yz = sin(tmp0.yz);
                tmp0.yz = tmp1.yy * tmp0.yz;
                tmp0.yz = tmp0.yz * _Distance.xx + inp.texcoord.xy;
                tmp1 = tex2D(_MainTex, tmp0.yz);
                tmp0.y = tmp1.x * 3.0 + -1.0;
                tmp0.y = _Strength * tmp0.y + 1.0;
                o.sv_target = tmp0.yyyy * tmp0.xxxx;
                return o;
			}
			ENDCG
		}
	}
}