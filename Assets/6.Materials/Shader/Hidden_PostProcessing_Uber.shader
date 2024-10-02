Shader "Hidden/PostProcessing/Uber" {
	Properties {
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 65264
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float _RenderViewportScaleFactor;
			float4 _UVTransform;
			// $Globals ConstantBuffers for Fragment Shader
			float _LumaInAlpha;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _AutoExposureTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                o.position.xy = v.vertex.xy;
                o.position.zw = float2(0.0, 1.0);
                tmp0.xy = v.vertex.xy + float2(1.0, 1.0);
                tmp0.xy = tmp0.xy * _UVTransform.xy;
                tmp0.xy = tmp0.xy * float2(0.5, 0.5) + _UVTransform.zw;
                o.texcoord1.xy = tmp0.xy * _RenderViewportScaleFactor.xx;
                o.texcoord.xy = tmp0.xy;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                tmp0 = tex2D(_AutoExposureTex, inp.texcoord.xy);
                tmp1 = tex2D(_MainTex, inp.texcoord1.xy);
                tmp1.xyz = tmp0.xxx * tmp1.xyz;
                tmp0.x = _LumaInAlpha > 0.5;
                if (tmp0.x) {
                    tmp0.xyz = saturate(tmp1.xyz);
                    tmp1.w = dot(tmp0.xyz, float3(0.2126729, 0.7151522, 0.072175));
                }
                o.sv_target = tmp1;
                return o;
			}
			ENDCG
		}
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 121926
			// No subprograms found
		}
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 143262
			// No subprograms found
		}
	}
}