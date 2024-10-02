Shader "Sprites/UI_Filler" {
	Properties {
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Basic Color", Color) = (1,1,1,1)
		_FillColor ("Fill Color", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		_MaxDistance ("MaxDistance", Float) = 0
		_SpritePosition ("Position", Vector) = (0,0,0,0)
		_PercentFill ("Percent", Range(0, 1)) = 0
		_EdgePercent ("Edge Percent", Float) = 0
		_EdgeGlow ("Edge Glow", Float) = 1
		_OverallGlow ("Core Glow", Range(0, 1)) = 0
	}
	SubShader {
		Tags { "CanUseSpriteAtlas" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			Tags { "CanUseSpriteAtlas" = "true" "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			Cull Off
			GpuProgramID 29434
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float4 color : COLOR0;
				float2 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			float4 _SpritePosition;
			float4 _Color;
			float4 _FillColor;
			float _PercentFill;
			float _EdgePercent;
			float _EdgeGlow;
			float _OverallGlow;
			float _MaxDistance;
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
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord1 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.color = v.color;
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
                tmp0.xyz = inp.texcoord1.xyz - _SpritePosition.xyz;
                tmp0.x = dot(tmp0.xyz, tmp0.xyz);
                tmp0.x = sqrt(tmp0.x);
                tmp0.x = tmp0.x / _MaxDistance;
                tmp0.y = _PercentFill < tmp0.x;
                tmp0.z = _PercentFill - _EdgePercent;
                tmp0.x = tmp0.z < tmp0.x;
                tmp0.z = _EdgeGlow - 1.0;
                tmp0.z = _OverallGlow * tmp0.z + 1.0;
                tmp1.xyz = inp.color.xyz * _FillColor.xyz;
                tmp2.xyz = tmp0.zzz * tmp1.xyz;
                tmp1.xyz = tmp1.xyz * _EdgeGlow.xxx;
                tmp3 = tex2D(_MainTex, inp.texcoord.xy);
                tmp2.xyz = tmp2.xyz * tmp3.xyz;
                tmp1.xyz = tmp1.xyz * tmp3.xyz;
                tmp1.xyz = tmp0.xxx ? tmp1.xyz : tmp2.xyz;
                tmp2.xyz = inp.color.xyz * _Color.xyz;
                tmp0.xzw = tmp0.zzz * tmp2.xyz;
                tmp2.xyz = tmp0.xzw * tmp3.xyz;
                tmp2.w = tmp3.w * _Color.w;
                tmp1.w = tmp3.w;
                tmp0 = tmp0.yyyy ? tmp2 : tmp1;
                o.sv_target.xyz = tmp0.www * tmp0.xyz;
                o.sv_target.w = tmp0.w;
                return o;
			}
			ENDCG
		}
	}
}