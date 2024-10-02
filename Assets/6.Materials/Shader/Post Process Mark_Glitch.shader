Shader "Post Process Mark/Glitch" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Power ("Power", Float) = 0
		_Color ("Tint", Color) = (1,1,1,1)
		_GlitchInterval ("Glitch interval time [seconds]", Float) = 0.16
		_DispProbability ("Displacement Glitch Probability", Float) = 0.022
		_DispIntensity ("Displacement Glitch Intensity", Float) = 0.09
		_ColorProbability ("Color Glitch Probability", Float) = 0.02
		_ColorIntensity ("Color Glitch Intensity", Float) = 0.07
		[MaterialToggle] _WrapDispCoords ("Wrap disp glitch (off = clamp)", Float) = 1
		[MaterialToggle] _DispGlitchOn ("Displacement Glitch On", Float) = 1
		[MaterialToggle] _ColorGlitchOn ("Color Glitch On", Float) = 1
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 52707
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			float _GlitchInterval;
			float _DispIntensity;
			float _DispProbability;
			float _ColorIntensity;
			float _ColorProbability;
			float _DispGlitchOn;
			float _ColorGlitchOn;
			float _WrapDispCoords;
			float _Power;
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
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xy = v.texcoord.xy;
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
                tmp0.x = inp.texcoord.y * 5.0;
                tmp0.y = _Time.y / _GlitchInterval;
                tmp0.xy = floor(tmp0.xy);
                tmp0.z = tmp0.y * _GlitchInterval + tmp0.x;
                tmp0.x = -tmp0.y * _GlitchInterval + tmp0.x;
                tmp0.z = tmp0.z * 78.233;
                tmp0.x = tmp0.x * 12.9898 + tmp0.z;
                tmp0.x = sin(tmp0.x);
                tmp0.x = tmp0.x * 43758.55;
                tmp0.x = frac(tmp0.x);
                tmp0.x = tmp0.x - 0.5;
                tmp0.zw = unity_ObjectToWorld._m13_m13 * unity_MatrixV._m01_m11;
                tmp0.zw = unity_MatrixV._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp0.zw;
                tmp0.zw = unity_MatrixV._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp0.zw;
                tmp0.zw = unity_MatrixV._m03_m13 * unity_ObjectToWorld._m33_m33 + tmp0.zw;
                tmp0.y = tmp0.y * _GlitchInterval + tmp0.z;
                tmp0.y = tmp0.w + tmp0.y;
                tmp0.z = tmp0.y + 2.793;
                tmp0.zw = tmp0.zz * float2(-91.2228, 91.2228);
                tmp0.zw = sin(tmp0.zw);
                tmp0.zw = tmp0.zw * float2(43758.55, 43758.55);
                tmp0.zw = frac(tmp0.zw);
                tmp0.zw = tmp0.zw - float2(0.5, 0.5);
                tmp0.w = tmp0.w * 0.02 + 0.2;
                tmp0.w = inp.texcoord.y / tmp0.w;
                tmp0.w = floor(tmp0.w);
                tmp1.x = tmp0.y + tmp0.w;
                tmp0.w = tmp0.w - tmp0.y;
                tmp2 = tmp0.yyyy * float4(-65.2432, 91.2228, 65.2432, -91.2228);
                tmp2 = sin(tmp2);
                tmp2 = tmp2 * float4(43758.55, 43758.55, 43758.55, 43758.55);
                tmp2 = frac(tmp2);
                tmp0.y = tmp1.x * 78.233;
                tmp0.y = tmp0.w * 12.9898 + tmp0.y;
                tmp0.y = sin(tmp0.y);
                tmp0.y = tmp0.y * 43758.55;
                tmp0.y = frac(tmp0.y);
                tmp0.y = tmp0.y - 0.5;
                tmp0.xyz = tmp0.xyz * float3(_DispIntensity.xx, _ColorIntensity.x);
                tmp0.y = tmp0.y * _Power + inp.texcoord.x;
                tmp0.w = tmp2.x < _DispProbability;
                tmp1.xyz = float3(_DispGlitchOn.x, _ColorGlitchOn.x, _WrapDispCoords.x) == float3(1.0, 1.0, 1.0);
                tmp0.w = tmp0.w ? tmp1.x : 0.0;
                tmp0.y = tmp0.w ? tmp0.y : inp.texcoord.x;
                tmp0.x = tmp0.x * _Power + tmp0.y;
                tmp0.y = tmp0.x >= -tmp0.x;
                tmp1.x = frac(abs(tmp0.x));
                tmp0.x = saturate(tmp0.x);
                tmp0.y = tmp0.y ? tmp1.x : -tmp1.x;
                tmp0.x = tmp1.y ? tmp0.y : tmp0.x;
                tmp0.x = tmp0.w ? tmp0.x : inp.texcoord.x;
                tmp1.x = tmp0.z * _Power + tmp0.x;
                tmp1.y = tmp0.z * _Power + inp.texcoord.y;
                tmp3 = tex2D(_MainTex, tmp1.xy);
                tmp0.zw = tmp2.zw - float2(0.5, 0.5);
                tmp1.x = tmp2.y < _ColorProbability;
                tmp1.x = tmp1.z ? tmp1.x : 0.0;
                tmp0.zw = tmp0.zw * _ColorIntensity.xx;
                tmp2.xy = tmp0.zw * _Power.xx + tmp0.xx;
                tmp2.zw = tmp0.zw * _Power.xx + inp.texcoord.yy;
                tmp4 = tex2D(_MainTex, tmp2.xz);
                tmp2 = tex2D(_MainTex, tmp2.yw);
                tmp0.z = tmp2.w + tmp4.w;
                tmp3.x = tmp4.x;
                tmp3.y = tmp2.y;
                tmp0.z = tmp3.w + tmp0.z;
                tmp3.w = tmp0.z * 0.3333333;
                tmp0.y = inp.texcoord.y;
                tmp0 = tex2D(_MainTex, tmp0.xy);
                o.sv_target = tmp1.xxxx ? tmp3 : tmp0;
                return o;
			}
			ENDCG
		}
	}
}