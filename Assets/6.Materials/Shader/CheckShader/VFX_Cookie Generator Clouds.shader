Shader "VFX/Cookie Generator Clouds" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_MainTex2 ("Texture 2", 2D) = "white" {}
		_SineStr ("Sine Range", Range(0, 1)) = 0.25
		_SineSpeedX ("Sine Speed X", Float) = 1
		_SineSpeedY ("Sine Speed Y", Float) = 1
		_SineValue ("Sine Value", Float) = 0
		_XScroll ("X Scroll", Float) = 0
		_Dark ("Darkness", Float) = 1
		_RedCloudMulti ("Red Cloud Multi", Float) = 1
		_GreenloudMulti ("Green Cloud Multi", Float) = 1
		_BlueCloudMulti ("Blue Cloud Multi", Float) = 1
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 58275
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
			float _XScroll;
			float _Dark;
			float _RedCloudMulti;
			float _GreenCloudMulti;
			float _BlueCloudMulti;
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
                tmp0.x = _XScroll * _Time.x + inp.texcoord.x;
                tmp1.x = _XScroll * _Time.x;
                tmp0.yzw = tmp1.xxx * float3(0.7, 5.0, 4.0) + inp.texcoord.yxy;
                tmp1 = tex2D(_MainTex, tmp0.xy);
                tmp0 = tex2D(_MainTex, tmp0.zw);
                tmp0.x = dot(tmp1.xy, float2(_XScroll.x, _Dark.x));
                tmp0.x = tmp0.z * tmp0.x;
                tmp0.x = tmp0.x * _BlueCloudMulti;
                o.sv_target = tmp0.xxxx * _Dark.xxxx;
                return o;
			}
			ENDCG
		}
	}
}