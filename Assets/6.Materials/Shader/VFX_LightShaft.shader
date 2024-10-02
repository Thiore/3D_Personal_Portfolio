Shader "VFX/LightShaft" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_xSpeed ("X Speed", Float) = 1
		_ySpeed ("Y Speed", Float) = 1
		_Glow ("Glow", Float) = 1
		_Power ("Power", Range(0, 1)) = 1
	}
	SubShader {
		LOD 100
		Tags { "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		Pass {
			LOD 100
			Tags { "QUEUE" = "Transparent" "RenderType" = "Transparent" }
			Blend One One, One One
			ZWrite Off
			Cull Off
			GpuProgramID 28893
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float2 texcoord : TEXCOORD0;
				float4 position : SV_POSITION0;
				float4 color : COLOR0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _MainTex_ST;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Color;
			float _xSpeed;
			float _ySpeed;
			float _Glow;
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
                o.texcoord.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                tmp0 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * v.vertex.xxxx + tmp0;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * v.vertex.zzzz + tmp0;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.color = v.color;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = -_Time.x * _xSpeed + inp.texcoord.x;
                tmp1.xy = _Time.xx * float2(_xSpeed.x, _ySpeed.x) + inp.texcoord.xy;
                tmp0.y = tmp1.y + 0.5;
                tmp0 = tex2D(_MainTex, tmp0.xy);
                tmp1.z = -_Time.x * _ySpeed + inp.texcoord.y;
                tmp1 = tex2D(_MainTex, tmp1.xz);
                tmp1 = tmp1.xxxx * _Color;
                tmp0 = tmp0.xxxx * tmp1;
                tmp1.x = inp.color.x * inp.color.x;
                tmp1.x = tmp1.x * tmp1.x;
                tmp1.x = tmp1.x * tmp1.x;
                tmp0 = tmp0 * tmp1.xxxx;
                tmp1.x = tmp1.x * _Glow + _Glow;
                tmp0 = tmp0 * tmp1.xxxx;
                o.sv_target = tmp0 * _Power.xxxx;
                return o;
			}
			ENDCG
		}
	}
}