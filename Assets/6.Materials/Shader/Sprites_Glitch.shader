Shader "Sprites/Glitch" {
	Properties {
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_GlitchInterval ("Glitch interval time [seconds]", Float) = 0.16
		_DispProbability ("Displacement Glitch Probability", Float) = 0.022
		_DispIntensity ("Displacement Glitch Intensity", Float) = 0.09
		_ColorProbability ("Color Glitch Probability", Float) = 0.02
		_ColorIntensity ("Color Glitch Intensity", Float) = 0.07
		[MaterialToggle] _WrapDispCoords ("Wrap disp glitch (off = clamp)", Float) = 1
		[MaterialToggle] _DispGlitchOn ("Displacement Glitch On", Float) = 1
		[MaterialToggle] _ColorGlitchOn ("Color Glitch On", Float) = 1
		_Glow ("Glow", Float) = 1
	}
	SubShader {
		Tags { "CanUseSpriteAtlas" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Tags { "CanUseSpriteAtlas" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			Cull Off
			Fog {
				Mode 0
			}
			GpuProgramID 20364
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 color : COLOR0;
				float2 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _Color;
			// $Globals ConstantBuffers for Fragment Shader
			float _GlitchInterval;
			float _DispIntensity;
			float _DispProbability;
			float _ColorIntensity;
			float _ColorProbability;
			float _DispGlitchOn;
			float _ColorGlitchOn;
			float _WrapDispCoords;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: DUMMY
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
                o.color = v.color * _Color;
                o.texcoord.xy = v.texcoord.xy;
                return o;
			}
			// Keywords: DUMMY
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                tmp0.x = _Time.y / _GlitchInterval;
                tmp0.x = floor(tmp0.x);
                tmp0.yz = unity_ObjectToWorld._m13_m13 * unity_MatrixV._m01_m11;
                tmp0.yz = unity_MatrixV._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp0.yz;
                tmp0.yz = unity_MatrixV._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp0.yz;
                tmp0.yz = unity_MatrixV._m03_m13 * unity_ObjectToWorld._m33_m33 + tmp0.yz;
                tmp0.x = tmp0.x * _GlitchInterval + tmp0.y;
                tmp0.x = tmp0.z + tmp0.x;
                tmp0.y = tmp0.x + 2.793;
                tmp0.yz = tmp0.yy * float2(-91.2228, 91.2228);
                tmp0.yz = sin(tmp0.yz);
                tmp0.yz = tmp0.yz * float2(43758.55, 43758.55);
                tmp0.yz = frac(tmp0.yz);
                tmp0.yz = tmp0.yz - float2(0.5, 0.5);
                tmp0.z = tmp0.z * 0.02 + 0.2;
                tmp0.z = inp.texcoord.y / tmp0.z;
                tmp0.z = floor(tmp0.z);
                tmp0.w = tmp0.x + tmp0.z;
                tmp0.z = tmp0.z - tmp0.x;
                tmp1 = tmp0.xxxx * float4(-65.2432, 91.2228, 65.2432, -91.2228);
                tmp1 = sin(tmp1);
                tmp1 = tmp1 * float4(43758.55, 43758.55, 43758.55, 43758.55);
                tmp1 = frac(tmp1);
                tmp0.x = tmp0.w * 78.233;
                tmp0.x = tmp0.z * 12.9898 + tmp0.x;
                tmp0.x = sin(tmp0.x);
                tmp0.x = tmp0.x * 43758.55;
                tmp0.x = frac(tmp0.x);
                tmp0.x = tmp0.x - 0.5;
                tmp0.x = tmp0.x * _DispIntensity + inp.texcoord.x;
                tmp0.z = tmp0.x >= -tmp0.x;
                tmp0.w = frac(abs(tmp0.x));
                tmp0.x = saturate(tmp0.x);
                tmp0.z = tmp0.z ? tmp0.w : -tmp0.w;
                tmp2.xyz = float3(_DispGlitchOn.x, _ColorGlitchOn.x, _WrapDispCoords.x) == float3(1.0, 1.0, 1.0);
                tmp0.x = tmp2.y ? tmp0.z : tmp0.x;
                tmp0.z = tmp1.x < _DispProbability;
                tmp0.z = tmp2.x ? tmp0.z : 0.0;
                tmp2.x = tmp0.z ? tmp0.x : inp.texcoord.x;
                tmp3.x = tmp0.y * _ColorIntensity + tmp2.x;
                tmp3.y = tmp0.y * _ColorIntensity + inp.texcoord.y;
                tmp0 = tex2D(_MainTex, tmp3.xy);
                tmp1.xz = tmp1.zw - float2(0.5, 0.5);
                tmp1.y = tmp1.y < _ColorProbability;
                tmp1.y = tmp2.z ? tmp1.y : 0.0;
                tmp3.xy = tmp1.xz * _ColorIntensity.xx + tmp2.xx;
                tmp3.zw = tmp1.xz * _ColorIntensity.xx + inp.texcoord.yy;
                tmp4 = tex2D(_MainTex, tmp3.xz);
                tmp3 = tex2D(_MainTex, tmp3.yw);
                tmp1.x = tmp3.w + tmp4.w;
                tmp0.x = tmp4.x;
                tmp0.y = tmp3.y;
                tmp1.x = tmp0.w + tmp1.x;
                tmp0.w = tmp1.x * 0.3333333;
                tmp2.y = inp.texcoord.y;
                tmp2 = tex2D(_MainTex, tmp2.xy);
                tmp0 = tmp1.yyyy ? tmp0 : tmp2;
                tmp0 = tmp0 * inp.color;
                tmp1.x = tmp0.w * _Glow;
                o.sv_target.xyz = tmp0.xyz * tmp1.xxx;
                o.sv_target.w = tmp0.w;
                return o;
			}
			ENDCG
		}
	}
	SubShader {
		Tags { "CanUseSpriteAtlas" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Tags { "CanUseSpriteAtlas" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			Cull Off
			Fog {
				Mode 0
			}
			GpuProgramID 125884
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 color : COLOR0;
				float2 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _Color;
			// $Globals ConstantBuffers for Fragment Shader
			float _DispIntensity;
			float _DispProbability;
			float _GlitchInterval;
			float _DispGlitchOn;
			float _WrapDispCoords;
			float _Glow;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: DUMMY
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
                o.color = v.color * _Color;
                o.texcoord.xy = v.texcoord.xy;
                return o;
			}
			// Keywords: DUMMY
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
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
                tmp0.x = tmp0.x * _DispIntensity + inp.texcoord.x;
                tmp0.z = tmp0.x >= -tmp0.x;
                tmp0.w = frac(abs(tmp0.x));
                tmp0.x = saturate(tmp0.x);
                tmp0.z = tmp0.z ? tmp0.w : -tmp0.w;
                tmp0.w = _WrapDispCoords == 1.0;
                tmp0.x = tmp0.w ? tmp0.z : tmp0.x;
                tmp0.zw = unity_ObjectToWorld._m13_m13 * unity_MatrixV._m01_m11;
                tmp0.zw = unity_MatrixV._m00_m10 * unity_ObjectToWorld._m03_m03 + tmp0.zw;
                tmp0.zw = unity_MatrixV._m02_m12 * unity_ObjectToWorld._m23_m23 + tmp0.zw;
                tmp0.zw = unity_MatrixV._m03_m13 * unity_ObjectToWorld._m33_m33 + tmp0.zw;
                tmp0.y = tmp0.y * _GlitchInterval + tmp0.z;
                tmp0.y = tmp0.w + tmp0.y;
                tmp0.y = tmp0.y * -65.2432;
                tmp0.y = sin(tmp0.y);
                tmp0.y = tmp0.y * 43758.55;
                tmp0.y = frac(tmp0.y);
                tmp0.y = tmp0.y < _DispProbability;
                tmp0.z = _DispGlitchOn == 1.0;
                tmp0.y = tmp0.z ? tmp0.y : 0.0;
                tmp0.x = tmp0.y ? tmp0.x : inp.texcoord.x;
                tmp0.y = inp.texcoord.y;
                tmp0 = tex2D(_MainTex, tmp0.xy);
                tmp0 = tmp0 * inp.color;
                tmp0.w = tmp0.w * inp.color.w;
                tmp1.x = tmp0.w * _Glow;
                o.sv_target.w = tmp0.w;
                o.sv_target.xyz = tmp0.xyz * tmp1.xxx;
                return o;
			}
			ENDCG
		}
	}
}