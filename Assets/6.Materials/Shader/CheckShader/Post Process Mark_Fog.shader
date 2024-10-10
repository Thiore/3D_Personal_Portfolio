Shader "Post Process Mark/Fog" {
	Properties {
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 46070
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4x4 unity_CameraProjection;
			float4x4 unity_WorldToCamera;
			float _RenderViewportScaleFactor;
			// $Globals ConstantBuffers for Fragment Shader
			float _StartDist;
			float _Max;
			float _YMulti;
			float4 _FogColor;
			float4 _VoidColor;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;
			sampler2D _NoiseTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                o.position.xy = v.vertex.xy;
                o.position.zw = float2(0.0, 1.0);
                tmp0.xy = v.vertex.xy + float2(1.0, 1.0);
                tmp0.xy = tmp0.xy * float2(0.5, -0.5) + float2(0.0, 1.0);
                o.texcoord1.xy = tmp0.xy * _RenderViewportScaleFactor.xx;
                o.texcoord.xy = v.vertex.xy * float2(0.5, -0.5) + float2(0.5, 0.5);
                tmp0.xyz = v.vertex.xyz - _WorldSpaceCameraPos;
                tmp0.w = dot(tmp0.xyz, tmp0.xyz);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.xyz = tmp0.xyz * _ProjectionParams.zzz + _WorldSpaceCameraPos;
                tmp1.xyz = tmp0.yyy * unity_WorldToCamera._m01_m11_m21;
                tmp0.xyw = unity_WorldToCamera._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = unity_WorldToCamera._m02_m12_m22 * tmp0.zzz + tmp0.xyw;
                tmp0.z = tmp0.z + tmp0.z;
                tmp0.z = tmp0.z / unity_CameraProjection._m11;
                tmp0.y = tmp0.z * 0.5 + tmp0.y;
                o.texcoord2.y = tmp0.y / tmp0.z;
                tmp0.y = _ScreenParams.x / _ScreenParams.y;
                tmp0.y = tmp0.z * tmp0.y;
                tmp0.x = tmp0.y * 0.5 + tmp0.x;
                o.texcoord2.x = tmp0.x / tmp0.y;
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.xy = _Time.xx * float2(0.2, 0.2) + inp.texcoord.xy;
                tmp0.xy = inp.texcoord2.xy - tmp0.xy;
                tmp0 = tex2D(_NoiseTex, tmp0.xy);
                tmp0.yz = -_Time.xx * float2(0.2, 0.2) + inp.texcoord.yx;
                tmp0.yz = inp.texcoord2.yx - tmp0.yz;
                tmp1 = tex2D(_NoiseTex, tmp0.yz);
                tmp0.yz = saturate(inp.texcoord.xy);
                tmp0.yz = tmp0.yz * _RenderViewportScaleFactor.xx;
                tmp2 = tex2Dlod(_CameraDepthTexture, float4(tmp0.yz, 0, 0.0));
                tmp0.y = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                tmp0.y = 1.0 / tmp0.y;
                tmp0.z = 1.0 - inp.texcoord.y;
                tmp0.y = tmp0.z * _YMulti + tmp0.y;
                tmp0.x = tmp0.x + tmp1.x;
                tmp0.z = _SinTime.w + 1.0;
                tmp0.z = tmp0.z * 0.4 + 0.2;
                tmp0.z = saturate(tmp0.z * tmp0.x);
                tmp0.y = tmp0.y - _StartDist;
                tmp0.y = tmp0.y / _Max;
                tmp0.x = tmp0.x + tmp0.z;
                tmp0.x = saturate(tmp0.x * tmp0.y);
                tmp0.y = tmp0.x >= 1.0;
                if (tmp0.y) {
                    o.sv_target = _VoidColor;
                    return o;
                }
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.x = tmp0.x * _FogColor.w;
                tmp2 = _FogColor - tmp1;
                o.sv_target = tmp0.xxxx * tmp2 + tmp1;
                return o;
			}
			ENDCG
		}
	}
}