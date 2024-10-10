Shader "Skybox/Cubemap Stenciled" {
	Properties {
		_Tint ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		[Gamma] _Exposure ("Exposure", Range(0, 8)) = 1
		_Rotation ("Rotation", Range(0, 360)) = 0
		[NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" {}
		_StencilLayer ("Stencil Layer", Float) = 2
	}
	SubShader {
		Tags { "PreviewType" = "Skybox" "QUEUE" = "Background" "RenderType" = "Background" }
		Pass {
			Tags { "PreviewType" = "Skybox" "QUEUE" = "Background" "RenderType" = "Background" }
			ZWrite Off
			Cull Front
			Stencil {
				Comp Equal
				Pass Keep
				Fail Keep
				ZFail DecrementWrap
			}
			GpuProgramID 6254
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float3 texcoord : TEXCOORD0;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float _Rotation;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _Tex_HDR;
			float4 _Tint;
			float _Exposure;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			samplerCUBE _Tex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.x = _Rotation * 0.0174533;
                tmp0.x = sin(tmp0.x);
                tmp1.x = cos(tmp0.x);
                tmp2.x = -tmp0.x;
                tmp2.y = tmp1.x;
                tmp2.z = tmp0.x;
                tmp0.x = dot(tmp2.xy, v.vertex.xy);
                tmp0.y = dot(tmp2.xy, v.vertex.xy);
                tmp1 = v.vertex.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.yyyy + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.xxxx + tmp1;
                tmp0 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                tmp1 = tmp0.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp1 = unity_MatrixVP._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp1 = unity_MatrixVP._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                o.position = unity_MatrixVP._m03_m13_m23_m33 * tmp0.wwww + tmp1;
                o.texcoord.xyz = v.vertex.xyz;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                tmp0 = texCUBE(_Tex, inp.texcoord.xyz);
                tmp0.w = tmp0.w - 1.0;
                tmp0.w = _Tex_HDR.w * tmp0.w + 1.0;
                tmp0.w = log(tmp0.w);
                tmp0.w = tmp0.w * _Tex_HDR.y;
                tmp0.w = exp(tmp0.w);
                tmp0.w = tmp0.w * _Tex_HDR.x;
                tmp0.xyz = tmp0.xyz * tmp0.www;
                tmp0.xyz = tmp0.xyz * _Tint.xyz;
                tmp0.xyz = tmp0.xyz * _Exposure.xxx;
                o.sv_target.xyz = tmp0.xyz * float3(4.594794, 4.594794, 4.594794);
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
	}
}