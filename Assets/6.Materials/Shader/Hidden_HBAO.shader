Shader "Hidden/HBAO" {
	Properties {
		_MainTex ("", 2D) = "" {}
		_HBAOTex ("", 2D) = "" {}
		_NoiseTex ("", 2D) = "" {}
		_DepthTex ("", 2D) = "" {}
		_NormalsTex ("", 2D) = "" {}
		_rt0Tex ("", 2D) = "" {}
		_rt3Tex ("", 2D) = "" {}
	}
	SubShader {
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 11610
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4x4 _WorldToCameraMatrix;
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _NoiseTexSize;
				float _MaxDistance;
				float _DistanceFalloff;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			sampler2D _NoiseTex;
			sampler2D _CameraGBufferTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.xy;
                tmp0 = tex2D(_CameraDepthTexture, tmp0.xy);
                tmp0.x = _ZBufferParams.z * tmp0.x + _ZBufferParams.w;
                tmp0.z = 1.0 / tmp0.x;
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp1 = tex2D(_CameraGBufferTexture2, inp.texcoord1.xy);
                tmp1.xyz = tmp1.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp2.xyz = tmp1.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp1.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp1.xxx + tmp2.xyz;
                tmp1.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp1.zzz + tmp1.xyw;
                tmp1.xyz = tmp1.xyz * float3(1.0, -1.0, -1.0);
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.w = tmp0.w * 0.3333333;
                tmp2.xy = inp.position.xy / _NoiseTexSize.xx;
                tmp2 = tex2D(_NoiseTex, tmp2.xy);
                tmp1.w = tmp2.z * tmp1.w + 1.0;
                tmp0.w = tmp0.w * 0.3333333 + tmp1.w;
                tmp2.zw = tmp2.xy * tmp0.ww;
                tmp2.zw = round(tmp2.zw);
                tmp3.xy = _ScreenParams.zw - float2(1.0, 1.0);
                tmp2.zw = tmp2.zw * tmp3.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.zw * _TargetScale.xy;
                tmp2.zw = tmp2.zw * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp4.x + _ZBufferParams.w;
                tmp4.z = 1.0 / tmp3.z;
                tmp4.xy = tmp2.zw * tmp4.zz;
                tmp2.zw = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp2.zw;
                tmp4.xyz = tmp4.xyz - tmp0.xyz;
                tmp2.z = dot(tmp1.xyz, tmp4.xyz);
                tmp2.w = dot(tmp4.xyz, tmp4.xyz);
                tmp3.z = rsqrt(tmp2.w);
                tmp2.w = saturate(tmp2.w * _NegInvRadius2 + 1.0);
                tmp2.z = saturate(tmp2.z * tmp3.z + -_AngleBias);
                tmp2.z = tmp2.w * tmp2.z;
                tmp3.zw = tmp2.xy * tmp1.ww;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp3.xy + inp.texcoord1.xy;
                tmp4.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_CameraDepthTexture, tmp4.xy);
                tmp2.w = _ZBufferParams.z * tmp4.x + _ZBufferParams.w;
                tmp4.z = 1.0 / tmp2.w;
                tmp4.xy = tmp3.zw * tmp4.zz;
                tmp4.xyz = tmp4.xyz - tmp0.xyz;
                tmp2.w = dot(tmp1.xyz, tmp4.xyz);
                tmp3.z = dot(tmp4.xyz, tmp4.xyz);
                tmp3.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp2.w = saturate(tmp2.w * tmp3.w + -_AngleBias);
                tmp2.z = tmp2.w * tmp3.z + tmp2.z;
                tmp3.zw = tmp2.yy * float2(0.8660254, -0.8660254);
                tmp4.xy = tmp2.xx * float2(-0.5000001, -0.4999999) + -tmp3.zw;
                tmp4.z = dot(tmp2.xy, float2(-0.5000001, 0.8660254));
                tmp4.w = dot(tmp2.xy, float2(-0.4999999, -0.8660254));
                tmp2.xy = tmp1.ww * tmp4.xz;
                tmp3.zw = tmp0.ww * tmp4.xz;
                tmp4.xz = tmp0.ww * tmp4.yw;
                tmp4.yw = tmp1.ww * tmp4.yw;
                tmp4 = round(tmp4);
                tmp4.yw = tmp4.yw * tmp3.xy + inp.texcoord1.xy;
                tmp4.xz = tmp4.xz * tmp3.xy + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp3.xy + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp3.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _TargetScale.xy;
                tmp2.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.xy);
                tmp0.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp0.w;
                tmp5.xy = tmp2.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp2.xyz);
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp0.w = saturate(tmp0.w * tmp2.x + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.w + tmp2.z;
                tmp2.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp2.zw = tmp3.zw * _TargetScale.xy;
                tmp3 = tex2D(_CameraDepthTexture, tmp2.zw);
                tmp1.w = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp1.w;
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xyz = tmp3.xyz - tmp0.xyz;
                tmp1.w = dot(tmp1.xyz, tmp2.xyz);
                tmp2.x = dot(tmp2.xyz, tmp2.xyz);
                tmp2.y = rsqrt(tmp2.x);
                tmp2.x = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp2.y + -_AngleBias);
                tmp0.w = tmp1.w * tmp2.x + tmp0.w;
                tmp2.xy = tmp4.yw * _UVToView.xy + _UVToView.zw;
                tmp2.zw = tmp4.yw * _TargetScale.xy;
                tmp3 = tex2D(_CameraDepthTexture, tmp2.zw);
                tmp1.w = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp1.w;
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xyz = tmp3.xyz - tmp0.xyz;
                tmp1.w = dot(tmp1.xyz, tmp2.xyz);
                tmp2.x = dot(tmp2.xyz, tmp2.xyz);
                tmp2.y = rsqrt(tmp2.x);
                tmp2.x = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp2.y + -_AngleBias);
                tmp0.w = tmp1.w * tmp2.x + tmp0.w;
                tmp2.xy = tmp4.xz * _UVToView.xy + _UVToView.zw;
                tmp2.zw = tmp4.xz * _TargetScale.xy;
                tmp3 = tex2D(_CameraDepthTexture, tmp2.zw);
                tmp1.w = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp1.w;
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xyz = tmp3.xyz - tmp0.xyz;
                tmp0.x = dot(tmp1.xyz, tmp2.xyz);
                tmp0.y = dot(tmp2.xyz, tmp2.xyz);
                tmp1.x = rsqrt(tmp0.y);
                tmp0.y = saturate(tmp0.y * _NegInvRadius2 + 1.0);
                tmp0.x = saturate(tmp0.x * tmp1.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp0.y + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.1666667 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 79225
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4x4 _WorldToCameraMatrix;
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _NoiseTexSize;
				float _MaxDistance;
				float _DistanceFalloff;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			sampler2D _NoiseTex;
			sampler2D _CameraGBufferTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.xy;
                tmp0 = tex2D(_CameraDepthTexture, tmp0.xy);
                tmp0.x = _ZBufferParams.z * tmp0.x + _ZBufferParams.w;
                tmp0.z = 1.0 / tmp0.x;
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.25;
                tmp1.yz = inp.position.xy / _NoiseTexSize.xx;
                tmp2 = tex2D(_NoiseTex, tmp1.yz);
                tmp1.x = tmp2.z * tmp1.x + 1.0;
                tmp1.y = tmp0.w * 0.25 + tmp1.x;
                tmp0.w = tmp0.w * 0.25 + tmp1.y;
                tmp1.zw = tmp2.xy * tmp1.yy;
                tmp1.zw = round(tmp1.zw);
                tmp2.zw = _ScreenParams.zw - float2(1.0, 1.0);
                tmp1.zw = tmp1.zw * tmp2.zw + inp.texcoord1.xy;
                tmp3.xy = tmp1.zw * _TargetScale.xy;
                tmp1.zw = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_CameraDepthTexture, tmp3.xy);
                tmp3.x = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp3.x;
                tmp3.xy = tmp1.zw * tmp3.zz;
                tmp1.zw = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.zw;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp1.z = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp4 = tex2D(_CameraGBufferTexture2, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp5.xyz = tmp4.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp4.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp4.xxx + tmp5.xyz;
                tmp4.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp4.zzz + tmp4.xyw;
                tmp4.xyz = tmp4.xyz * float3(1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp1.w = saturate(tmp3.x * tmp1.w + -_AngleBias);
                tmp1.z = tmp1.z * tmp1.w;
                tmp3.xy = tmp2.xy * tmp1.xx;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp1.w + tmp1.z;
                tmp3.xy = tmp2.xy * tmp0.ww;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = dot(tmp3.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp3.y + -_AngleBias);
                tmp1.z = tmp1.w * tmp3.x + tmp1.z;
                tmp3.w = tmp2.y * -0.0 + tmp2.x;
                tmp3.yz = tmp2.xx * float2(-0.0, -0.0000001) + -tmp2.yy;
                tmp5.xy = tmp1.xx * tmp3.yw;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp1.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.w;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = dot(tmp5.xyz, tmp5.xyz);
                tmp5.x = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp5.x + -_AngleBias);
                tmp1.z = tmp1.w * tmp4.w + tmp1.z;
                tmp5.xy = tmp1.yy * tmp3.yw;
                tmp3.yw = tmp0.ww * tmp3.yw;
                tmp3.yw = round(tmp3.yw);
                tmp3.yw = tmp3.yw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp1.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.w;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = dot(tmp5.xyz, tmp5.xyz);
                tmp5.x = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp5.x + -_AngleBias);
                tmp1.z = tmp1.w * tmp4.w + tmp1.z;
                tmp5.xy = tmp3.yw * _TargetScale.xy;
                tmp3.yw = tmp3.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.yw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.y = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = rsqrt(tmp3.y);
                tmp3.y = saturate(tmp3.y * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp3.w + -_AngleBias);
                tmp1.z = tmp1.w * tmp3.y + tmp1.z;
                tmp3.x = -tmp2.y * -0.0000001 + -tmp2.x;
                tmp3.yw = tmp1.xx * tmp3.xz;
                tmp3.yw = round(tmp3.yw);
                tmp3.yw = tmp3.yw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.yw * _TargetScale.xy;
                tmp3.yw = tmp3.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.yw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.y = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = rsqrt(tmp3.y);
                tmp3.y = saturate(tmp3.y * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp3.w + -_AngleBias);
                tmp1.z = tmp1.w * tmp3.y + tmp1.z;
                tmp3.yw = tmp1.yy * tmp3.xz;
                tmp3.xz = tmp0.ww * tmp3.xz;
                tmp3 = round(tmp3);
                tmp3.xz = tmp3.xz * tmp2.zw + inp.texcoord1.xy;
                tmp3.yw = tmp3.yw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.yw * _TargetScale.xy;
                tmp3.yw = tmp3.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.yw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.y = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = rsqrt(tmp3.y);
                tmp3.y = saturate(tmp3.y * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp3.w + -_AngleBias);
                tmp1.z = tmp1.w * tmp3.y + tmp1.z;
                tmp3.yw = tmp3.xz * _TargetScale.xy;
                tmp3.xz = tmp3.xz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.yw);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.xz * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = dot(tmp3.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp3.y + -_AngleBias);
                tmp1.z = tmp1.w * tmp3.x + tmp1.z;
                tmp3.x = tmp2.x * 0.0 + tmp2.y;
                tmp3.y = tmp2.y * 0.0 + -tmp2.x;
                tmp1.xw = tmp1.xx * tmp3.xy;
                tmp1.xw = round(tmp1.xw);
                tmp1.xw = tmp1.xw * tmp2.zw + inp.texcoord1.xy;
                tmp2.xy = tmp1.xw * _TargetScale.xy;
                tmp1.xw = tmp1.xw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp2.xy);
                tmp2.x = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp2.x;
                tmp5.xy = tmp1.xw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.x = dot(tmp4.xyz, tmp5.xyz);
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.x = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.x = saturate(tmp1.x * tmp2.x + -_AngleBias);
                tmp1.x = tmp1.x * tmp1.w + tmp1.z;
                tmp1.yz = tmp1.yy * tmp3.xy;
                tmp2.xy = tmp0.ww * tmp3.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp2.zw = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp1.yz = tmp1.yz * _TargetScale.xy;
                tmp3 = tex2D(_CameraDepthTexture, tmp1.yz);
                tmp0.w = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp0.w;
                tmp3.xy = tmp2.zw * tmp3.zz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp0.w = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.z = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp0.w = saturate(tmp0.w * tmp1.z + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.y + tmp1.x;
                tmp1.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp1.zw = tmp2.xy * _TargetScale.xy;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.zw);
                tmp1.z = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                tmp2.z = 1.0 / tmp1.z;
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp4.xyz, tmp1.xyz);
                tmp0.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = rsqrt(tmp0.y);
                tmp0.y = saturate(tmp0.y * _NegInvRadius2 + 1.0);
                tmp0.x = saturate(tmp0.x * tmp1.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp0.y + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.0833333 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 151685
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4x4 _WorldToCameraMatrix;
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _NoiseTexSize;
				float _MaxDistance;
				float _DistanceFalloff;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			sampler2D _NoiseTex;
			sampler2D _CameraGBufferTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.xy;
                tmp0 = tex2D(_CameraDepthTexture, tmp0.xy);
                tmp0.x = _ZBufferParams.z * tmp0.x + _ZBufferParams.w;
                tmp0.z = 1.0 / tmp0.x;
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.2;
                tmp1.yz = inp.position.xy / _NoiseTexSize.xx;
                tmp2 = tex2D(_NoiseTex, tmp1.yz);
                tmp1.x = tmp2.z * tmp1.x + 1.0;
                tmp1.y = tmp0.w * 0.2 + tmp1.x;
                tmp1.zw = tmp2.xy * tmp1.yy;
                tmp1.zw = round(tmp1.zw);
                tmp2.zw = _ScreenParams.zw - float2(1.0, 1.0);
                tmp1.zw = tmp1.zw * tmp2.zw + inp.texcoord1.xy;
                tmp3.xy = tmp1.zw * _TargetScale.xy;
                tmp1.zw = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_CameraDepthTexture, tmp3.xy);
                tmp3.x = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp3.x;
                tmp3.xy = tmp1.zw * tmp3.zz;
                tmp1.zw = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.zw;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp1.z = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp4 = tex2D(_CameraGBufferTexture2, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp5.xyz = tmp4.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp4.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp4.xxx + tmp5.xyz;
                tmp4.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp4.zzz + tmp4.xyw;
                tmp4.xyz = tmp4.xyz * float3(1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp1.w = saturate(tmp3.x * tmp1.w + -_AngleBias);
                tmp1.z = tmp1.z * tmp1.w;
                tmp3.xy = tmp2.xy * tmp1.xx;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp1.w + tmp1.z;
                tmp1.w = tmp0.w * 0.2 + tmp1.y;
                tmp0.w = tmp0.w * 0.2 + tmp1.w;
                tmp3.xy = tmp2.xy * tmp1.ww;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.xy = tmp2.xy * tmp0.ww;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.xy = tmp2.yy * float2(0.8660254, 0.8660254);
                tmp3.xy = tmp2.xx * float2(0.5, -0.5000001) + -tmp3.xy;
                tmp3.z = dot(tmp2.xy, float2(0.5, 0.8660254));
                tmp5.xy = tmp1.xx * tmp3.xz;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp5.xyz, tmp5.xyz);
                tmp5.x = dot(tmp4.xyz, tmp5.xyz);
                tmp5.y = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.x = saturate(tmp5.x * tmp5.y + -_AngleBias);
                tmp1.z = tmp5.x * tmp4.w + tmp1.z;
                tmp5.xy = tmp1.yy * tmp3.xz;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp5.xyz, tmp5.xyz);
                tmp5.x = dot(tmp4.xyz, tmp5.xyz);
                tmp5.y = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.x = saturate(tmp5.x * tmp5.y + -_AngleBias);
                tmp1.z = tmp5.x * tmp4.w + tmp1.z;
                tmp5.xy = tmp1.ww * tmp3.xz;
                tmp3.xz = tmp0.ww * tmp3.xz;
                tmp3.xz = round(tmp3.xz);
                tmp3.xz = tmp3.xz * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp5.xyz, tmp5.xyz);
                tmp5.x = dot(tmp4.xyz, tmp5.xyz);
                tmp5.y = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.x = saturate(tmp5.x * tmp5.y + -_AngleBias);
                tmp1.z = tmp5.x * tmp4.w + tmp1.z;
                tmp5.xy = tmp3.xz * _TargetScale.xy;
                tmp3.xz = tmp3.xz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.xz * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.x = dot(tmp5.xyz, tmp5.xyz);
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.z * tmp3.x + tmp1.z;
                tmp3.w = dot(tmp2.xy, float2(-0.5000001, 0.8660254));
                tmp3.xz = tmp1.xx * tmp3.yw;
                tmp3.xz = round(tmp3.xz);
                tmp3.xz = tmp3.xz * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.xz * _TargetScale.xy;
                tmp3.xz = tmp3.xz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.xz * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.x = dot(tmp5.xyz, tmp5.xyz);
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.z * tmp3.x + tmp1.z;
                tmp3.xz = tmp1.yy * tmp3.yw;
                tmp3.xz = round(tmp3.xz);
                tmp3.xz = tmp3.xz * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.xz * _TargetScale.xy;
                tmp3.xz = tmp3.xz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.xz * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.x = dot(tmp5.xyz, tmp5.xyz);
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.z * tmp3.x + tmp1.z;
                tmp3.xz = tmp1.ww * tmp3.yw;
                tmp3.yw = tmp0.ww * tmp3.yw;
                tmp3 = round(tmp3);
                tmp3.yw = tmp3.yw * tmp2.zw + inp.texcoord1.xy;
                tmp3.xz = tmp3.xz * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.xz * _TargetScale.xy;
                tmp3.xz = tmp3.xz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.xz * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.x = dot(tmp5.xyz, tmp5.xyz);
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.z * tmp3.x + tmp1.z;
                tmp3.xz = tmp3.yw * _TargetScale.xy;
                tmp3.yw = tmp3.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.xz);
                tmp3.x = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.x;
                tmp5.xy = tmp3.yw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.x = -tmp2.y * -0.0000001 + -tmp2.x;
                tmp3.y = tmp2.x * -0.0000001 + -tmp2.y;
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.yy * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.ww * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.x = tmp2.y * -0.8660254;
                tmp5.y = tmp2.x * -0.4999999 + -tmp3.x;
                tmp5.x = tmp2.x * 0.4999999 + -tmp3.x;
                tmp3.xyz = tmp2.yxy * float3(-0.4999999, -0.8660254, 0.4999999);
                tmp5.zw = tmp3.yy + tmp3.xz;
                tmp2.xy = tmp1.xx * tmp5.yz;
                tmp3.xy = tmp1.xx * tmp5.xw;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp2.xy * _TargetScale.xy;
                tmp2.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.x = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.x;
                tmp6.xy = tmp2.xy * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.x = dot(tmp4.xyz, tmp6.xyz);
                tmp2.x = dot(tmp6.xyz, tmp6.xyz);
                tmp2.y = rsqrt(tmp2.x);
                tmp2.x = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp1.x = saturate(tmp1.x * tmp2.y + -_AngleBias);
                tmp1.x = tmp1.x * tmp2.x + tmp1.z;
                tmp2.xy = tmp1.yy * tmp5.yz;
                tmp1.yz = tmp1.yy * tmp5.xw;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp2.xy * _TargetScale.xy;
                tmp2.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp2.xy * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp2.x = dot(tmp6.xyz, tmp6.xyz);
                tmp2.y = dot(tmp4.xyz, tmp6.xyz);
                tmp3.z = rsqrt(tmp2.x);
                tmp2.x = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp2.y = saturate(tmp2.y * tmp3.z + -_AngleBias);
                tmp1.x = tmp2.y * tmp2.x + tmp1.x;
                tmp2.xy = tmp1.ww * tmp5.yz;
                tmp3.zw = tmp0.ww * tmp5.yz;
                tmp5.yz = tmp0.ww * tmp5.xw;
                tmp5.xw = tmp1.ww * tmp5.xw;
                tmp5 = round(tmp5);
                tmp5.xw = tmp5.xw * tmp2.zw + inp.texcoord1.xy;
                tmp5.yz = tmp5.yz * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp2.zw = tmp2.xy * _TargetScale.xy;
                tmp2.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp2.zw);
                tmp0.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp0.w;
                tmp6.xy = tmp2.xy * tmp6.zz;
                tmp2.xyz = tmp6.xyz - tmp0.xyz;
                tmp0.w = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = rsqrt(tmp0.w);
                tmp0.w = saturate(tmp0.w * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp2.x + -_AngleBias);
                tmp0.w = tmp1.w * tmp0.w + tmp1.x;
                tmp1.xw = tmp3.zw * _TargetScale.xy;
                tmp2.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp1.xw);
                tmp1.x = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.x;
                tmp6.xy = tmp2.xy * tmp6.zz;
                tmp2.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.x = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = rsqrt(tmp1.x);
                tmp1.x = saturate(tmp1.x * _NegInvRadius2 + 1.0);
                tmp1.w = saturate(tmp1.w * tmp2.x + -_AngleBias);
                tmp0.w = tmp1.w * tmp1.x + tmp0.w;
                tmp1.xw = tmp3.xy * _TargetScale.xy;
                tmp2.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_CameraDepthTexture, tmp1.xw);
                tmp1.x = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp1.x;
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xyz = tmp3.xyz - tmp0.xyz;
                tmp1.x = dot(tmp4.xyz, tmp2.xyz);
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.x = saturate(tmp1.x * tmp2.x + -_AngleBias);
                tmp0.w = tmp1.x * tmp1.w + tmp0.w;
                tmp1.xw = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp1.yz = tmp1.yz * _TargetScale.xy;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.yz);
                tmp1.y = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                tmp2.z = 1.0 / tmp1.y;
                tmp2.xy = tmp1.xw * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = dot(tmp1.xyz, tmp1.xyz);
                tmp1.y = rsqrt(tmp1.x);
                tmp1.x = saturate(tmp1.x * _NegInvRadius2 + 1.0);
                tmp1.y = saturate(tmp1.w * tmp1.y + -_AngleBias);
                tmp0.w = tmp1.y * tmp1.x + tmp0.w;
                tmp1.xy = tmp5.xw * _UVToView.xy + _UVToView.zw;
                tmp1.zw = tmp5.xw * _TargetScale.xy;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.zw);
                tmp1.z = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                tmp2.z = 1.0 / tmp1.z;
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp1.w = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = dot(tmp1.xyz, tmp1.xyz);
                tmp1.y = rsqrt(tmp1.x);
                tmp1.x = saturate(tmp1.x * _NegInvRadius2 + 1.0);
                tmp1.y = saturate(tmp1.w * tmp1.y + -_AngleBias);
                tmp0.w = tmp1.y * tmp1.x + tmp0.w;
                tmp1.xy = tmp5.yz * _UVToView.xy + _UVToView.zw;
                tmp1.zw = tmp5.yz * _TargetScale.xy;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.zw);
                tmp1.z = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                tmp2.z = 1.0 / tmp1.z;
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp4.xyz, tmp1.xyz);
                tmp0.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = rsqrt(tmp0.y);
                tmp0.y = saturate(tmp0.y * _NegInvRadius2 + 1.0);
                tmp0.x = saturate(tmp0.x * tmp1.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp0.y + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.0416667 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 227369
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4x4 _WorldToCameraMatrix;
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _NoiseTexSize;
				float _MaxDistance;
				float _DistanceFalloff;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			sampler2D _NoiseTex;
			sampler2D _CameraGBufferTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.xy;
                tmp0 = tex2D(_CameraDepthTexture, tmp0.xy);
                tmp0.x = _ZBufferParams.z * tmp0.x + _ZBufferParams.w;
                tmp0.z = 1.0 / tmp0.x;
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.2;
                tmp1.yz = inp.position.xy / _NoiseTexSize.xx;
                tmp2 = tex2D(_NoiseTex, tmp1.yz);
                tmp1.x = tmp2.z * tmp1.x + 1.0;
                tmp1.y = tmp0.w * 0.2 + tmp1.x;
                tmp1.zw = tmp2.xy * tmp1.yy;
                tmp1.zw = round(tmp1.zw);
                tmp2.zw = _ScreenParams.zw - float2(1.0, 1.0);
                tmp1.zw = tmp1.zw * tmp2.zw + inp.texcoord1.xy;
                tmp3.xy = tmp1.zw * _TargetScale.xy;
                tmp1.zw = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_CameraDepthTexture, tmp3.xy);
                tmp3.x = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp3.x;
                tmp3.xy = tmp1.zw * tmp3.zz;
                tmp1.zw = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.zw;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp1.z = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp4 = tex2D(_CameraGBufferTexture2, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp5.xyz = tmp4.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp4.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp4.xxx + tmp5.xyz;
                tmp4.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp4.zzz + tmp4.xyw;
                tmp4.xyz = tmp4.xyz * float3(1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp1.w = saturate(tmp3.x * tmp1.w + -_AngleBias);
                tmp1.z = tmp1.z * tmp1.w;
                tmp3.xy = tmp2.xy * tmp1.xx;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.w;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp1.w + tmp1.z;
                tmp1.w = tmp0.w * 0.2 + tmp1.y;
                tmp0.w = tmp0.w * 0.2 + tmp1.w;
                tmp3.xy = tmp2.xy * tmp1.ww;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.xy = tmp2.xy * tmp0.ww;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.xy = tmp2.xy * float2(0.7071068, 0.7071068);
                tmp5.x = tmp2.x * 0.7071068 + -tmp3.y;
                tmp5.y = tmp3.x + tmp3.y;
                tmp3.zw = tmp1.xx * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.yy * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.ww * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp5.x = tmp2.x * -0.0 + -tmp2.y;
                tmp5.y = tmp2.y * -0.0 + tmp2.x;
                tmp3.zw = tmp1.xx * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.yy * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.ww * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp5.x = tmp2.x * -0.7071068 + -tmp3.y;
                tmp5.y = tmp2.y * -0.7071068 + tmp3.x;
                tmp3.xy = tmp1.xx * tmp5.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp3.xy * tmp6.zz;
                tmp3.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.xy = tmp1.yy * tmp5.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp3.xy * tmp6.zz;
                tmp3.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.xy = tmp1.ww * tmp5.xy;
                tmp3.zw = tmp0.ww * tmp5.xy;
                tmp3 = round(tmp3);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.x = dot(tmp5.xyz, tmp5.xyz);
                tmp3.y = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp3.y = saturate(tmp3.y * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.y * tmp3.x + tmp1.z;
                tmp3.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.xy);
                tmp3.x = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.x;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.x = -tmp2.y * -0.0000001 + -tmp2.x;
                tmp3.y = tmp2.x * -0.0000001 + -tmp2.y;
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.yy * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.ww * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.x = tmp2.y * -0.7071069;
                tmp3.x = tmp2.x * -0.7071066 + -tmp3.x;
                tmp3.y = dot(tmp2.xy, float2(-0.7071066, -0.7071069));
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.yy * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp1.ww * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.w * tmp3.z + tmp1.z;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.x * tmp3.z + tmp1.z;
                tmp3.x = tmp2.x * 0.0 + tmp2.y;
                tmp3.y = tmp2.y * 0.0 + -tmp2.x;
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp3.w = dot(tmp5.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.w);
                tmp3.w = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.z * tmp3.w + tmp1.z;
                tmp3.zw = tmp1.yy * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp3.w = dot(tmp5.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.w);
                tmp3.w = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.z * tmp3.w + tmp1.z;
                tmp3.zw = tmp1.ww * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp3.w = dot(tmp5.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.w);
                tmp3.w = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp1.z = tmp3.z * tmp3.w + tmp1.z;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = dot(tmp3.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.x);
                tmp3.x = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp3.y = saturate(tmp3.w * tmp3.y + -_AngleBias);
                tmp1.z = tmp3.y * tmp3.x + tmp1.z;
                tmp3.x = tmp2.y * -0.7071065;
                tmp3.x = tmp2.x * 0.707107 + -tmp3.x;
                tmp3.y = dot(tmp2.xy, float2(0.707107, -0.7071065));
                tmp2.xy = tmp1.xx * tmp3.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp2.xy * _TargetScale.xy;
                tmp2.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.x = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp1.x;
                tmp5.xy = tmp2.xy * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.x = dot(tmp4.xyz, tmp5.xyz);
                tmp2.x = dot(tmp5.xyz, tmp5.xyz);
                tmp2.y = rsqrt(tmp2.x);
                tmp2.x = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp1.x = saturate(tmp1.x * tmp2.y + -_AngleBias);
                tmp1.x = tmp1.x * tmp2.x + tmp1.z;
                tmp1.yz = tmp1.yy * tmp3.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _TargetScale.xy;
                tmp1.yz = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp2.xy);
                tmp2.x = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp2.x;
                tmp5.xy = tmp1.yz * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.y = dot(tmp4.xyz, tmp5.xyz);
                tmp1.z = dot(tmp5.xyz, tmp5.xyz);
                tmp2.x = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.y = saturate(tmp1.y * tmp2.x + -_AngleBias);
                tmp1.x = tmp1.y * tmp1.z + tmp1.x;
                tmp1.yz = tmp1.ww * tmp3.xy;
                tmp2.xy = tmp0.ww * tmp3.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp2.zw = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp1.yz = tmp1.yz * _TargetScale.xy;
                tmp3 = tex2D(_CameraDepthTexture, tmp1.yz);
                tmp0.w = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp0.w;
                tmp3.xy = tmp2.zw * tmp3.zz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp0.w = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.z = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp0.w = saturate(tmp0.w * tmp1.z + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.y + tmp1.x;
                tmp1.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp1.zw = tmp2.xy * _TargetScale.xy;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.zw);
                tmp1.z = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                tmp2.z = 1.0 / tmp1.z;
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp4.xyz, tmp1.xyz);
                tmp0.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = rsqrt(tmp0.y);
                tmp0.y = saturate(tmp0.y * _NegInvRadius2 + 1.0);
                tmp0.x = saturate(tmp0.x * tmp1.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp0.y + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.03125 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 305442
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4x4 _WorldToCameraMatrix;
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _NoiseTexSize;
				float _MaxDistance;
				float _DistanceFalloff;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			sampler2D _NoiseTex;
			sampler2D _CameraGBufferTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.xy;
                tmp0 = tex2D(_CameraDepthTexture, tmp0.xy);
                tmp0.x = _ZBufferParams.z * tmp0.x + _ZBufferParams.w;
                tmp0.z = 1.0 / tmp0.x;
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp1.xy = inp.position.xy / _NoiseTexSize.xx;
                tmp1 = tex2D(_NoiseTex, tmp1.xy);
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.w = tmp0.w * 0.1428571;
                tmp1.z = tmp1.z * tmp1.w + 1.0;
                tmp1.w = tmp0.w * 0.1428571 + tmp1.z;
                tmp2.xy = tmp1.xy * tmp1.ww;
                tmp2.xy = round(tmp2.xy);
                tmp2.zw = _ScreenParams.zw - float2(1.0, 1.0);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _TargetScale.xy;
                tmp2.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_CameraDepthTexture, tmp3.xy);
                tmp3.x = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp3.x;
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xy = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp2.xy;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp2.x = dot(tmp3.xyz, tmp3.xyz);
                tmp2.y = rsqrt(tmp2.x);
                tmp2.x = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp4 = tex2D(_CameraGBufferTexture2, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp5.xyz = tmp4.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp4.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp4.xxx + tmp5.xyz;
                tmp4.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp4.zzz + tmp4.xyw;
                tmp4.xyz = tmp4.xyz * float3(1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp2.y = saturate(tmp3.x * tmp2.y + -_AngleBias);
                tmp2.x = tmp2.x * tmp2.y;
                tmp3.xy = tmp1.xy * tmp1.zz;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp2.y = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp2.y;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp2.x = tmp3.x * tmp2.y + tmp2.x;
                tmp2.y = tmp0.w * 0.1428571 + tmp1.w;
                tmp3.xy = tmp1.xy * tmp2.yy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _TargetScale.xy;
                tmp3.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.z;
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = rsqrt(tmp3.w);
                tmp3.z = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.x = saturate(tmp3.x * tmp3.y + -_AngleBias);
                tmp2.x = tmp3.x * tmp3.z + tmp2.x;
                tmp3.x = tmp0.w * 0.1428571 + tmp2.y;
                tmp3.yz = tmp1.xy * tmp3.xx;
                tmp3.yz = round(tmp3.yz);
                tmp3.yz = tmp3.yz * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.yz * _TargetScale.xy;
                tmp3.yz = tmp3.yz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp3.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp3.w;
                tmp5.xy = tmp3.yz * tmp5.zz;
                tmp3.yzw = tmp5.xyz - tmp0.xyz;
                tmp4.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.y = dot(tmp4.xyz, tmp3.xyz);
                tmp3.z = rsqrt(tmp4.w);
                tmp3.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp3.y = saturate(tmp3.y * tmp3.z + -_AngleBias);
                tmp2.x = tmp3.y * tmp3.w + tmp2.x;
                tmp3.y = tmp0.w * 0.1428571 + tmp3.x;
                tmp0.w = tmp0.w * 0.1428571 + tmp3.y;
                tmp3.zw = tmp1.xy * tmp3.yy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp1.xy * tmp0.ww;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_CameraDepthTexture, tmp5.xy);
                tmp4.w = _ZBufferParams.z * tmp5.x + _ZBufferParams.w;
                tmp5.z = 1.0 / tmp4.w;
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp1.xy * float2(0.7071068, 0.7071068);
                tmp5.x = tmp1.x * 0.7071068 + -tmp3.w;
                tmp5.y = tmp3.z + tmp3.w;
                tmp5.zw = tmp1.zz * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp1.ww * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp2.yy * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp3.xx * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp3.yy * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5 = round(tmp5);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp5.xyz, tmp5.xyz);
                tmp5.x = dot(tmp4.xyz, tmp5.xyz);
                tmp5.y = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.x = saturate(tmp5.x * tmp5.y + -_AngleBias);
                tmp2.x = tmp5.x * tmp4.w + tmp2.x;
                tmp5.x = tmp1.x * -0.0 + -tmp1.y;
                tmp5.y = tmp1.y * -0.0 + tmp1.x;
                tmp5.zw = tmp1.zz * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp1.ww * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp2.yy * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp3.xx * tmp5.xy;
                tmp5.zw = round(tmp5.zw);
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp3.yy * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5 = round(tmp5);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp5.zw * tmp2.zw + inp.texcoord1.xy;
                tmp6.xy = tmp5.zw * _TargetScale.xy;
                tmp5.zw = tmp5.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp6.xy);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp6.xyz, tmp6.xyz);
                tmp5.z = dot(tmp4.xyz, tmp6.xyz);
                tmp5.w = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.z = saturate(tmp5.z * tmp5.w + -_AngleBias);
                tmp2.x = tmp5.z * tmp4.w + tmp2.x;
                tmp5.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp5.xyz, tmp5.xyz);
                tmp5.x = dot(tmp4.xyz, tmp5.xyz);
                tmp5.y = rsqrt(tmp4.w);
                tmp4.w = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp5.x = saturate(tmp5.x * tmp5.y + -_AngleBias);
                tmp2.x = tmp5.x * tmp4.w + tmp2.x;
                tmp5.x = tmp1.x * -0.7071068 + -tmp3.w;
                tmp5.y = tmp1.y * -0.7071068 + tmp3.z;
                tmp3.zw = tmp1.zz * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp1.ww * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp2.yy * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.xx * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.yy * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp5.x = -tmp1.y * -0.0000001 + -tmp1.x;
                tmp5.y = tmp1.x * -0.0000001 + -tmp1.y;
                tmp3.zw = tmp1.zz * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp1.ww * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp2.yy * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.xx * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.yy * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.z = tmp1.y * -0.7071069;
                tmp5.x = tmp1.x * -0.7071066 + -tmp3.z;
                tmp5.y = dot(tmp1.xy, float2(-0.7071066, -0.7071069));
                tmp3.zw = tmp1.zz * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp1.ww * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp2.yy * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.xx * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.yy * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp5.x = tmp1.x * 0.0 + tmp1.y;
                tmp5.y = tmp1.y * 0.0 + -tmp1.x;
                tmp3.zw = tmp1.zz * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp1.ww * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp2.yy * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.xx * tmp5.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp3.yy * tmp5.xy;
                tmp5.xy = tmp0.ww * tmp5.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * tmp2.zw + inp.texcoord1.xy;
                tmp5.zw = tmp3.zw * _TargetScale.xy;
                tmp3.zw = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp5.zw);
                tmp4.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp4.w;
                tmp6.xy = tmp3.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp6.xyz, tmp6.xyz);
                tmp3.w = dot(tmp4.xyz, tmp6.xyz);
                tmp4.w = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.w = saturate(tmp3.w * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.w * tmp3.z + tmp2.x;
                tmp3.zw = tmp5.xy * _TargetScale.xy;
                tmp5.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp3.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp3.z;
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp4.xyz, tmp5.xyz);
                tmp3.w = dot(tmp5.xyz, tmp5.xyz);
                tmp4.w = rsqrt(tmp3.w);
                tmp3.w = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.z = saturate(tmp3.z * tmp4.w + -_AngleBias);
                tmp2.x = tmp3.z * tmp3.w + tmp2.x;
                tmp3.z = tmp1.y * -0.7071065;
                tmp5.x = tmp1.x * 0.707107 + -tmp3.z;
                tmp5.y = dot(tmp1.xy, float2(0.707107, -0.7071065));
                tmp1.xy = tmp1.zz * tmp5.xy;
                tmp1.xy = round(tmp1.xy);
                tmp1.xy = tmp1.xy * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp1.xy * _TargetScale.xy;
                tmp1.xy = tmp1.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.z = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.z;
                tmp6.xy = tmp1.xy * tmp6.zz;
                tmp1.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = dot(tmp1.xyz, tmp1.xyz);
                tmp1.y = rsqrt(tmp1.x);
                tmp1.x = saturate(tmp1.x * _NegInvRadius2 + 1.0);
                tmp1.y = saturate(tmp3.z * tmp1.y + -_AngleBias);
                tmp1.x = tmp1.y * tmp1.x + tmp2.x;
                tmp1.yz = tmp1.ww * tmp5.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp3.zw = tmp1.yz * _TargetScale.xy;
                tmp1.yz = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp3.zw);
                tmp1.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.w;
                tmp6.xy = tmp1.yz * tmp6.zz;
                tmp1.yzw = tmp6.xyz - tmp0.xyz;
                tmp2.x = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.z = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp1.z = saturate(tmp2.x * tmp1.z + -_AngleBias);
                tmp1.x = tmp1.z * tmp1.y + tmp1.x;
                tmp1.yz = tmp2.yy * tmp5.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _TargetScale.xy;
                tmp1.yz = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp2.xy);
                tmp1.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.w;
                tmp6.xy = tmp1.yz * tmp6.zz;
                tmp1.yzw = tmp6.xyz - tmp0.xyz;
                tmp2.x = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.z = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp1.z = saturate(tmp2.x * tmp1.z + -_AngleBias);
                tmp1.x = tmp1.z * tmp1.y + tmp1.x;
                tmp1.yz = tmp3.xx * tmp5.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _TargetScale.xy;
                tmp1.yz = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_CameraDepthTexture, tmp2.xy);
                tmp1.w = _ZBufferParams.z * tmp6.x + _ZBufferParams.w;
                tmp6.z = 1.0 / tmp1.w;
                tmp6.xy = tmp1.yz * tmp6.zz;
                tmp1.yzw = tmp6.xyz - tmp0.xyz;
                tmp2.x = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.z = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp1.z = saturate(tmp2.x * tmp1.z + -_AngleBias);
                tmp1.x = tmp1.z * tmp1.y + tmp1.x;
                tmp1.yz = tmp3.yy * tmp5.xy;
                tmp2.xy = tmp0.ww * tmp5.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * tmp2.zw + inp.texcoord1.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * tmp2.zw + inp.texcoord1.xy;
                tmp2.zw = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp1.yz = tmp1.yz * _TargetScale.xy;
                tmp3 = tex2D(_CameraDepthTexture, tmp1.yz);
                tmp0.w = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp3.z = 1.0 / tmp0.w;
                tmp3.xy = tmp2.zw * tmp3.zz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp0.w = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.z = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp0.w = saturate(tmp0.w * tmp1.z + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.y + tmp1.x;
                tmp1.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp1.zw = tmp2.xy * _TargetScale.xy;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.zw);
                tmp1.z = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                tmp2.z = 1.0 / tmp1.z;
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp4.xyz, tmp1.xyz);
                tmp0.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = rsqrt(tmp0.y);
                tmp0.y = saturate(tmp0.y * _NegInvRadius2 + 1.0);
                tmp0.x = saturate(tmp0.x * tmp1.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp0.y + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.0208333 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 359283
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _MaxDistance;
				float _DistanceFalloff;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float4 _Jitter;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DepthTex;
			sampler2D _NormalsTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                tmp0 = tex2D(_DepthTex, inp.texcoord1.xy);
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.3333333;
                tmp1.x = _Jitter.z * tmp1.x + 1.0;
                tmp0.w = tmp0.w * 0.3333333 + tmp1.x;
                tmp1.yz = tmp0.ww * _Jitter.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp1.yz = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.yz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp2.x = dot(tmp1.xyz, tmp1.xyz);
                tmp2.y = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp2.x = rsqrt(tmp2.x);
                tmp3 = tex2D(_NormalsTex, inp.texcoord1.xy);
                tmp3.xyz = tmp3.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp1.y = dot(tmp3.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.y * tmp2.x + -_AngleBias);
                tmp1.y = tmp2.y * tmp1.y;
                tmp1.zw = tmp1.xx * _Jitter.xy;
                tmp1.zw = round(tmp1.zw);
                tmp1.zw = tmp1.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_DepthTex, tmp1.zw);
                tmp4.xy = tmp2.xy * tmp4.zz;
                tmp2.xyz = tmp4.xyz - tmp0.xyz;
                tmp1.z = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp3.xyz, tmp2.xyz);
                tmp2.x = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.x + tmp1.y;
                tmp2.z = dot(_Jitter.xy, float2(-0.5000001, 0.8660254));
                tmp1.zw = _Jitter.yy * float2(0.8660254, -0.8660254);
                tmp2.xy = _Jitter.xx * float2(-0.5000001, -0.4999999) + -tmp1.zw;
                tmp1.zw = tmp1.xx * tmp2.xz;
                tmp2.xz = tmp0.ww * tmp2.xz;
                tmp2.xz = round(tmp2.xz);
                tmp2.xz = tmp2.xz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp1.zw = round(tmp1.zw);
                tmp1.zw = tmp1.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp4.xy = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.zw);
                tmp5.xy = tmp4.xy * tmp5.zz;
                tmp4.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.z = dot(tmp4.xyz, tmp4.xyz);
                tmp1.w = dot(tmp3.xyz, tmp4.xyz);
                tmp3.w = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp3.w + tmp1.y;
                tmp1.zw = tmp2.xz * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_DepthTex, tmp2.xz);
                tmp4.xy = tmp1.zw * tmp4.zz;
                tmp4.xyz = tmp4.xyz - tmp0.xyz;
                tmp1.z = dot(tmp4.xyz, tmp4.xyz);
                tmp1.w = dot(tmp3.xyz, tmp4.xyz);
                tmp2.x = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.x + tmp1.y;
                tmp2.w = dot(_Jitter.xy, float2(-0.4999999, -0.8660254));
                tmp1.xz = tmp1.xx * tmp2.yw;
                tmp2.xy = tmp0.ww * tmp2.yw;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp1.xz = round(tmp1.xz);
                tmp1.xz = tmp1.xz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.zw = tmp1.xz * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_DepthTex, tmp1.xz);
                tmp4.xy = tmp2.zw * tmp4.zz;
                tmp1.xzw = tmp4.xyz - tmp0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = dot(tmp3.xyz, tmp1.xyz);
                tmp1.z = saturate(tmp0.w * _NegInvRadius2 + 1.0);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.w = saturate(tmp1.x * tmp0.w + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.z + tmp1.y;
                tmp1.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp2 = tex2D(_DepthTex, tmp2.xy);
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp1.xyz, tmp1.xyz);
                tmp0.y = dot(tmp3.xyz, tmp1.xyz);
                tmp1.x = saturate(tmp0.x * _NegInvRadius2 + 1.0);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.x = saturate(tmp0.y * tmp0.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp1.x + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.1666667 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 420012
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _MaxDistance;
				float _DistanceFalloff;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float4 _Jitter;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DepthTex;
			sampler2D _NormalsTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                tmp0 = tex2D(_DepthTex, inp.texcoord1.xy);
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.25;
                tmp1.x = _Jitter.z * tmp1.x + 1.0;
                tmp1.yz = tmp1.xx * _Jitter.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp1.yz = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.yz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp2.x = dot(tmp1.xyz, tmp1.xyz);
                tmp2.y = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp2.x = rsqrt(tmp2.x);
                tmp2.z = tmp0.w * 0.25 + tmp1.x;
                tmp0.w = tmp0.w * 0.25 + tmp2.z;
                tmp3.xy = tmp2.zz * _Jitter.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_DepthTex, tmp3.xy);
                tmp4.xy = tmp3.zw * tmp4.zz;
                tmp3.xyz = tmp4.xyz - tmp0.xyz;
                tmp2.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.w = saturate(tmp2.w * _NegInvRadius2 + 1.0);
                tmp2.w = rsqrt(tmp2.w);
                tmp4 = tex2D(_NormalsTex, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp2.w = saturate(tmp3.x * tmp2.w + -_AngleBias);
                tmp2.w = tmp3.w * tmp2.w;
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.y * tmp2.x + -_AngleBias);
                tmp1.y = tmp1.y * tmp2.y + tmp2.w;
                tmp1.zw = tmp0.ww * _Jitter.xy;
                tmp1.zw = round(tmp1.zw);
                tmp1.zw = tmp1.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.zw);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xyw = tmp3.xyz - tmp0.xyz;
                tmp1.z = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.x + tmp1.y;
                tmp3.w = _Jitter.y * -0.0 + _Jitter.x;
                tmp3.yz = _Jitter.xx * float2(-0.0, -0.0000001) + -_Jitter.yy;
                tmp1.zw = tmp1.xx * tmp3.yw;
                tmp1.zw = round(tmp1.zw);
                tmp1.zw = tmp1.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.zw);
                tmp5.xy = tmp2.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.z = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.x + tmp1.y;
                tmp1.zw = tmp2.zz * tmp3.yw;
                tmp2.xy = tmp0.ww * tmp3.yw;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp1.zw = round(tmp1.zw);
                tmp1.zw = tmp1.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.yw = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.zw);
                tmp5.xy = tmp3.yw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.z = dot(tmp5.xyz, tmp5.xyz);
                tmp1.w = dot(tmp4.xyz, tmp5.xyz);
                tmp2.w = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.w + tmp1.y;
                tmp1.zw = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp1.zw * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.z = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.x + tmp1.y;
                tmp3.x = -_Jitter.y * -0.0000001 + -_Jitter.x;
                tmp1.zw = tmp1.xx * tmp3.xz;
                tmp1.zw = round(tmp1.zw);
                tmp1.zw = tmp1.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.zw);
                tmp5.xy = tmp2.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.z = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.x + tmp1.y;
                tmp1.zw = tmp2.zz * tmp3.xz;
                tmp2.xy = tmp0.ww * tmp3.xz;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp1.zw = round(tmp1.zw);
                tmp1.zw = tmp1.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp1.zw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.zw);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.z = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = dot(tmp4.xyz, tmp3.xyz);
                tmp2.w = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.w + tmp1.y;
                tmp1.zw = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp2.xy);
                tmp3.xy = tmp1.zw * tmp3.zz;
                tmp2.xyw = tmp3.xyz - tmp0.xyz;
                tmp1.z = dot(tmp2.xyz, tmp2.xyz);
                tmp1.w = dot(tmp4.xyz, tmp2.xyz);
                tmp2.x = saturate(tmp1.z * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.z);
                tmp1.z = saturate(tmp1.w * tmp1.z + -_AngleBias);
                tmp1.y = tmp1.z * tmp2.x + tmp1.y;
                tmp2.x = _Jitter.x * 0.0 + _Jitter.y;
                tmp2.y = _Jitter.y * 0.0 + -_Jitter.x;
                tmp1.xz = tmp1.xx * tmp2.xy;
                tmp1.xz = round(tmp1.xz);
                tmp1.xz = tmp1.xz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp1.xz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.xz);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp1.xzw = tmp5.xyz - tmp0.xyz;
                tmp2.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = dot(tmp4.xyz, tmp1.xyz);
                tmp1.z = saturate(tmp2.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp2.w);
                tmp1.x = saturate(tmp1.x * tmp1.w + -_AngleBias);
                tmp1.x = tmp1.x * tmp1.z + tmp1.y;
                tmp1.yz = tmp2.xy * tmp2.zz;
                tmp2.xy = tmp0.ww * tmp2.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.zw = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.zw * tmp3.zz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.z = saturate(tmp0.w * _NegInvRadius2 + 1.0);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.w = saturate(tmp1.y * tmp0.w + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.z + tmp1.x;
                tmp1.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp2 = tex2D(_DepthTex, tmp2.xy);
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp1.xyz, tmp1.xyz);
                tmp0.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = saturate(tmp0.x * _NegInvRadius2 + 1.0);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.x = saturate(tmp0.y * tmp0.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp1.x + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.0833333 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 476536
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _MaxDistance;
				float _DistanceFalloff;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float4 _Jitter;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DepthTex;
			sampler2D _NormalsTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                tmp0 = tex2D(_DepthTex, inp.texcoord1.xy);
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.2;
                tmp1.x = _Jitter.z * tmp1.x + 1.0;
                tmp1.yz = tmp1.xx * _Jitter.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp1.yz = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.yz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp2.x = dot(tmp1.xyz, tmp1.xyz);
                tmp2.y = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp2.x = rsqrt(tmp2.x);
                tmp2.z = tmp0.w * 0.2 + tmp1.x;
                tmp3.xy = tmp2.zz * _Jitter.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_DepthTex, tmp3.xy);
                tmp4.xy = tmp3.zw * tmp4.zz;
                tmp3.xyz = tmp4.xyz - tmp0.xyz;
                tmp2.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.w = saturate(tmp2.w * _NegInvRadius2 + 1.0);
                tmp2.w = rsqrt(tmp2.w);
                tmp4 = tex2D(_NormalsTex, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp2.w = saturate(tmp3.x * tmp2.w + -_AngleBias);
                tmp2.w = tmp3.w * tmp2.w;
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.y * tmp2.x + -_AngleBias);
                tmp1.y = tmp1.y * tmp2.y + tmp2.w;
                tmp1.z = tmp0.w * 0.2 + tmp2.z;
                tmp0.w = tmp0.w * 0.2 + tmp1.z;
                tmp2.xy = tmp1.zz * _Jitter.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp0.ww * _Jitter.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp3.z = dot(_Jitter.xy, float2(0.5, 0.8660254));
                tmp2.xy = _Jitter.yy * float2(0.8660254, 0.8660254);
                tmp3.xy = _Jitter.xx * float2(0.5, -0.5000001) + -tmp2.xy;
                tmp2.xy = tmp1.xx * tmp3.xz;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp2.xy);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp2.xyw = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp2.zz * tmp3.xz;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp2.xy);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp2.xyw = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp1.zz * tmp3.xz;
                tmp3.xz = tmp0.ww * tmp3.xz;
                tmp3.xz = round(tmp3.xz);
                tmp3.xz = tmp3.xz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp2.xy);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp2.xyw = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp3.xz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xz);
                tmp5.xy = tmp2.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp3.w = dot(_Jitter.xy, float2(-0.5000001, 0.8660254));
                tmp2.xy = tmp1.xx * tmp3.yw;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xz = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xz * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp2.zz * tmp3.yw;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xz = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xz * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp1.zz * tmp3.yw;
                tmp3.xy = tmp0.ww * tmp3.yw;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp3.xy);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xyw = tmp3.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.x = -_Jitter.y * -0.0000001 + -_Jitter.x;
                tmp2.y = _Jitter.x * -0.0000001 + -_Jitter.y;
                tmp3.xy = tmp1.xx * tmp2.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * tmp2.zz;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp1.zz * tmp2.xy;
                tmp2.xy = tmp0.ww * tmp2.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp1.w = _Jitter.y * -0.8660254;
                tmp3.y = _Jitter.x * -0.4999999 + -tmp1.w;
                tmp3.x = _Jitter.x * 0.4999999 + -tmp1.w;
                tmp2.xyw = _Jitter.yxy * float3(-0.4999999, -0.8660254, 0.4999999);
                tmp3.zw = tmp2.yy + tmp2.xw;
                tmp2.xy = tmp1.xx * tmp3.yz;
                tmp1.xw = tmp1.xx * tmp3.xw;
                tmp1.xw = round(tmp1.xw);
                tmp1.xw = tmp1.xw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp2.xy);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp2.xyw = tmp6.xyz - tmp0.xyz;
                tmp4.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp4.w * _NegInvRadius2 + 1.0);
                tmp2.w = rsqrt(tmp4.w);
                tmp2.x = saturate(tmp2.x * tmp2.w + -_AngleBias);
                tmp1.y = tmp2.x * tmp2.y + tmp1.y;
                tmp2.xy = tmp2.zz * tmp3.yz;
                tmp2.zw = tmp2.zz * tmp3.xw;
                tmp2 = round(tmp2);
                tmp2.zw = tmp2.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp2.xy);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp2.x = dot(tmp5.xyz, tmp5.xyz);
                tmp2.y = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp2.x = rsqrt(tmp2.x);
                tmp2.x = saturate(tmp2.y * tmp2.x + -_AngleBias);
                tmp1.y = tmp2.x * tmp4.w + tmp1.y;
                tmp2.xy = tmp1.zz * tmp3.yz;
                tmp5.xy = tmp1.zz * tmp3.xw;
                tmp3 = tmp0.wwww * tmp3;
                tmp3 = round(tmp3);
                tmp3.yz = tmp3.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xw = tmp3.xw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = round(tmp5.xy);
                tmp5.xy = tmp5.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.zw = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp2.xy);
                tmp6.xy = tmp5.zw * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp0.w = dot(tmp6.xyz, tmp6.xyz);
                tmp1.z = dot(tmp4.xyz, tmp6.xyz);
                tmp2.x = saturate(tmp0.w * _NegInvRadius2 + 1.0);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.w = saturate(tmp1.z * tmp0.w + -_AngleBias);
                tmp0.w = tmp0.w * tmp2.x + tmp1.y;
                tmp1.yz = tmp3.yz * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.yz);
                tmp6.xy = tmp1.yz * tmp6.zz;
                tmp6.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.y = dot(tmp6.xyz, tmp6.xyz);
                tmp1.z = dot(tmp4.xyz, tmp6.xyz);
                tmp2.x = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp1.y = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.z * tmp1.y + -_AngleBias);
                tmp0.w = tmp1.y * tmp2.x + tmp0.w;
                tmp1.yz = tmp1.xw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp1.xw);
                tmp6.xy = tmp1.yz * tmp6.zz;
                tmp1.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.w);
                tmp1.x = saturate(tmp1.x * tmp1.z + -_AngleBias);
                tmp0.w = tmp1.x * tmp1.y + tmp0.w;
                tmp1.xy = tmp2.zw * _UVToView.xy + _UVToView.zw;
                tmp2 = tex2D(_DepthTex, tmp2.zw);
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.w);
                tmp1.x = saturate(tmp1.x * tmp1.z + -_AngleBias);
                tmp0.w = tmp1.x * tmp1.y + tmp0.w;
                tmp1.xy = tmp5.xy * _UVToView.xy + _UVToView.zw;
                tmp2 = tex2D(_DepthTex, tmp5.xy);
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp1.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.x = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.z = rsqrt(tmp1.w);
                tmp1.x = saturate(tmp1.x * tmp1.z + -_AngleBias);
                tmp0.w = tmp1.x * tmp1.y + tmp0.w;
                tmp1.xy = tmp3.xw * _UVToView.xy + _UVToView.zw;
                tmp2 = tex2D(_DepthTex, tmp3.xw);
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp1.xyz, tmp1.xyz);
                tmp0.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = saturate(tmp0.x * _NegInvRadius2 + 1.0);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.x = saturate(tmp0.y * tmp0.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp1.x + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.0416667 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 554388
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _MaxDistance;
				float _DistanceFalloff;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float4 _Jitter;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DepthTex;
			sampler2D _NormalsTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                tmp0 = tex2D(_DepthTex, inp.texcoord1.xy);
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.2;
                tmp1.x = _Jitter.z * tmp1.x + 1.0;
                tmp1.yz = tmp1.xx * _Jitter.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp1.yz = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.yz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp2.x = dot(tmp1.xyz, tmp1.xyz);
                tmp2.y = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp2.x = rsqrt(tmp2.x);
                tmp2.z = tmp0.w * 0.2 + tmp1.x;
                tmp3.xy = tmp2.zz * _Jitter.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_DepthTex, tmp3.xy);
                tmp4.xy = tmp3.zw * tmp4.zz;
                tmp3.xyz = tmp4.xyz - tmp0.xyz;
                tmp2.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.w = saturate(tmp2.w * _NegInvRadius2 + 1.0);
                tmp2.w = rsqrt(tmp2.w);
                tmp4 = tex2D(_NormalsTex, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp2.w = saturate(tmp3.x * tmp2.w + -_AngleBias);
                tmp2.w = tmp3.w * tmp2.w;
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.y * tmp2.x + -_AngleBias);
                tmp1.y = tmp1.y * tmp2.y + tmp2.w;
                tmp1.z = tmp0.w * 0.2 + tmp2.z;
                tmp0.w = tmp0.w * 0.2 + tmp1.z;
                tmp2.xy = tmp1.zz * _Jitter.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp0.ww * _Jitter.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = _Jitter.xy * float2(0.7071068, 0.7071068);
                tmp3.x = _Jitter.x * 0.7071068 + -tmp2.y;
                tmp3.y = tmp2.x + tmp2.y;
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.z + tmp1.y;
                tmp3.zw = tmp2.zz * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.z + tmp1.y;
                tmp3.zw = tmp1.zz * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.z + tmp1.y;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.x = _Jitter.x * -0.0 + -_Jitter.y;
                tmp3.y = _Jitter.y * -0.0 + _Jitter.x;
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.z + tmp1.y;
                tmp3.zw = tmp2.zz * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.z + tmp1.y;
                tmp3.zw = tmp1.zz * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp1.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.z + tmp1.y;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.x = _Jitter.x * -0.7071068 + -tmp2.y;
                tmp3.y = _Jitter.y * -0.7071068 + tmp2.x;
                tmp2.xy = tmp1.xx * tmp3.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp2.zz * tmp3.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp1.zz * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.xy = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp3.xy);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp2.xyw = tmp3.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.x = -_Jitter.y * -0.0000001 + -_Jitter.x;
                tmp2.y = _Jitter.x * -0.0000001 + -_Jitter.y;
                tmp3.xy = tmp1.xx * tmp2.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * tmp2.zz;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp1.zz * tmp2.xy;
                tmp2.xy = tmp0.ww * tmp2.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp1.w = _Jitter.y * -0.7071069;
                tmp2.x = _Jitter.x * -0.7071066 + -tmp1.w;
                tmp2.y = dot(_Jitter.xy, float2(-0.7071066, -0.7071069));
                tmp3.xy = tmp1.xx * tmp2.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * tmp2.zz;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp1.zz * tmp2.xy;
                tmp2.xy = tmp0.ww * tmp2.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp2.x = _Jitter.x * 0.0 + _Jitter.y;
                tmp2.y = _Jitter.y * 0.0 + -_Jitter.x;
                tmp3.xy = tmp1.xx * tmp2.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * tmp2.zz;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp1.zz * tmp2.xy;
                tmp2.xy = tmp0.ww * tmp2.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.w * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp3.x + tmp1.y;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp1.w = _Jitter.y * -0.7071065;
                tmp2.x = _Jitter.x * 0.707107 + -tmp1.w;
                tmp2.y = dot(_Jitter.xy, float2(0.707107, -0.7071065));
                tmp1.xw = tmp1.xx * tmp2.xy;
                tmp1.xw = round(tmp1.xw);
                tmp1.xw = tmp1.xw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp1.xw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.xw);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.x = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = dot(tmp4.xyz, tmp3.xyz);
                tmp2.w = saturate(tmp1.x * _NegInvRadius2 + 1.0);
                tmp1.x = rsqrt(tmp1.x);
                tmp1.x = saturate(tmp1.w * tmp1.x + -_AngleBias);
                tmp1.x = tmp1.x * tmp2.w + tmp1.y;
                tmp1.yw = tmp2.xy * tmp2.zz;
                tmp1.yw = round(tmp1.yw);
                tmp1.yw = tmp1.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.zw = tmp1.yw * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yw);
                tmp3.xy = tmp2.zw * tmp3.zz;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp1.y = dot(tmp3.xyz, tmp3.xyz);
                tmp1.w = dot(tmp4.xyz, tmp3.xyz);
                tmp2.z = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp1.y = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.w * tmp1.y + -_AngleBias);
                tmp1.x = tmp1.y * tmp2.z + tmp1.x;
                tmp1.yz = tmp1.zz * tmp2.xy;
                tmp2.xy = tmp0.ww * tmp2.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.zw = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.zw * tmp3.zz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.z = saturate(tmp0.w * _NegInvRadius2 + 1.0);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.w = saturate(tmp1.y * tmp0.w + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.z + tmp1.x;
                tmp1.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp2 = tex2D(_DepthTex, tmp2.xy);
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp1.xyz, tmp1.xyz);
                tmp0.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = saturate(tmp0.x * _NegInvRadius2 + 1.0);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.x = saturate(tmp0.y * tmp0.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp1.x + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.03125 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 634973
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _UVToView;
				float _Radius;
				float _MaxRadiusPixels;
				float _NegInvRadius2;
				float _AngleBias;
				float _AOmultiplier;
				float _MaxDistance;
				float _DistanceFalloff;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float4 _Jitter;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _DepthTex;
			sampler2D _NormalsTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                float4 tmp5;
                float4 tmp6;
                tmp0 = tex2D(_DepthTex, inp.texcoord1.xy);
                tmp0.w = _MaxDistance - tmp0.z;
                tmp0.w = tmp0.w < 0.0;
                if (tmp0.w) {
                    discard;
                }
                tmp0.w = _Radius / tmp0.z;
                tmp0.w = min(tmp0.w, _MaxRadiusPixels);
                tmp1.x = tmp0.w * 0.1428571;
                tmp1.x = _Jitter.z * tmp1.x + 1.0;
                tmp1.yz = tmp1.xx * _Jitter.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.xy = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.xy * tmp3.zz;
                tmp1.yz = inp.texcoord1.xy * _UVToView.xy + _UVToView.zw;
                tmp0.xy = tmp0.zz * tmp1.yz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp2.x = dot(tmp1.xyz, tmp1.xyz);
                tmp2.y = saturate(tmp2.x * _NegInvRadius2 + 1.0);
                tmp2.x = rsqrt(tmp2.x);
                tmp2.z = tmp0.w * 0.1428571 + tmp1.x;
                tmp3.xy = tmp2.zz * _Jitter.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp4 = tex2D(_DepthTex, tmp3.xy);
                tmp4.xy = tmp3.zw * tmp4.zz;
                tmp3.xyz = tmp4.xyz - tmp0.xyz;
                tmp2.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.w = saturate(tmp2.w * _NegInvRadius2 + 1.0);
                tmp2.w = rsqrt(tmp2.w);
                tmp4 = tex2D(_NormalsTex, inp.texcoord1.xy);
                tmp4.xyz = tmp4.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp2.w = saturate(tmp3.x * tmp2.w + -_AngleBias);
                tmp2.w = tmp3.w * tmp2.w;
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.y = saturate(tmp1.y * tmp2.x + -_AngleBias);
                tmp1.y = tmp1.y * tmp2.y + tmp2.w;
                tmp1.z = tmp0.w * 0.1428571 + tmp2.z;
                tmp2.xy = tmp1.zz * _Jitter.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp1.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.w * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp1.w);
                tmp1.w = saturate(tmp2.x * tmp1.w + -_AngleBias);
                tmp1.y = tmp1.w * tmp2.y + tmp1.y;
                tmp1.w = tmp0.w * 0.1428571 + tmp1.z;
                tmp2.xy = tmp1.ww * _Jitter.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.xy);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp2.xyw = tmp5.xyz - tmp0.xyz;
                tmp3.x = dot(tmp2.xyz, tmp2.xyz);
                tmp2.x = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp3.x * _NegInvRadius2 + 1.0);
                tmp2.w = rsqrt(tmp3.x);
                tmp2.x = saturate(tmp2.x * tmp2.w + -_AngleBias);
                tmp1.y = tmp2.x * tmp2.y + tmp1.y;
                tmp2.x = tmp0.w * 0.1428571 + tmp1.w;
                tmp0.w = tmp0.w * 0.1428571 + tmp2.x;
                tmp2.yw = tmp2.xx * _Jitter.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.x + tmp1.y;
                tmp2.yw = tmp0.ww * _Jitter.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.xy = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.xy * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.x + tmp1.y;
                tmp2.yw = _Jitter.xy * float2(0.7071068, 0.7071068);
                tmp3.x = _Jitter.x * 0.7071068 + -tmp2.w;
                tmp3.y = tmp2.y + tmp2.w;
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp2.zz * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp1.zz * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp1.ww * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp2.xx * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.w);
                tmp3.x = saturate(tmp3.x * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.x * tmp3.y + tmp1.y;
                tmp3.x = _Jitter.x * -0.0 + -_Jitter.y;
                tmp3.y = _Jitter.y * -0.0 + _Jitter.x;
                tmp3.zw = tmp1.xx * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp2.zz * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp1.zz * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp1.ww * tmp3.xy;
                tmp3.zw = round(tmp3.zw);
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp2.xx * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3 = round(tmp3);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp3.zw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp5.xy = tmp3.zw * _UVToView.xy + _UVToView.zw;
                tmp6 = tex2D(_DepthTex, tmp3.zw);
                tmp6.xy = tmp5.xy * tmp6.zz;
                tmp5.xyz = tmp6.xyz - tmp0.xyz;
                tmp3.z = dot(tmp5.xyz, tmp5.xyz);
                tmp3.w = dot(tmp4.xyz, tmp5.xyz);
                tmp4.w = saturate(tmp3.z * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.z);
                tmp3.z = saturate(tmp3.w * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.z * tmp4.w + tmp1.y;
                tmp3.zw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp3.xy);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp3.xyz = tmp5.xyz - tmp0.xyz;
                tmp3.w = dot(tmp3.xyz, tmp3.xyz);
                tmp3.x = dot(tmp4.xyz, tmp3.xyz);
                tmp3.y = saturate(tmp3.w * _NegInvRadius2 + 1.0);
                tmp3.z = rsqrt(tmp3.w);
                tmp3.x = saturate(tmp3.x * tmp3.z + -_AngleBias);
                tmp1.y = tmp3.x * tmp3.y + tmp1.y;
                tmp3.x = _Jitter.x * -0.7071068 + -tmp2.w;
                tmp3.y = _Jitter.y * -0.7071068 + tmp2.y;
                tmp2.yw = tmp1.xx * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.ww * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.xx * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp3.xy);
                tmp3.xy = tmp2.yw * tmp3.zz;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp2.y = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.x + tmp1.y;
                tmp3.x = -_Jitter.y * -0.0000001 + -_Jitter.x;
                tmp3.y = _Jitter.x * -0.0000001 + -_Jitter.y;
                tmp2.yw = tmp1.xx * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.ww * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.xx * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp3.xy);
                tmp3.xy = tmp2.yw * tmp3.zz;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp2.y = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.x + tmp1.y;
                tmp2.y = _Jitter.y * -0.7071069;
                tmp3.x = _Jitter.x * -0.7071066 + -tmp2.y;
                tmp3.y = dot(_Jitter.xy, float2(-0.7071066, -0.7071069));
                tmp2.yw = tmp1.xx * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.ww * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.xx * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp3.xy);
                tmp3.xy = tmp2.yw * tmp3.zz;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp2.y = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.x + tmp1.y;
                tmp3.x = _Jitter.x * 0.0 + _Jitter.y;
                tmp3.y = _Jitter.y * 0.0 + -_Jitter.x;
                tmp2.yw = tmp1.xx * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.zz * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp1.ww * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp2.xx * tmp3.xy;
                tmp3.xy = tmp0.ww * tmp3.xy;
                tmp3.xy = round(tmp3.xy);
                tmp3.xy = tmp3.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = dot(tmp4.xyz, tmp5.xyz);
                tmp3.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.z + tmp1.y;
                tmp2.yw = tmp3.xy * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp3.xy);
                tmp3.xy = tmp2.yw * tmp3.zz;
                tmp3.xyz = tmp3.xyz - tmp0.xyz;
                tmp2.y = dot(tmp3.xyz, tmp3.xyz);
                tmp2.w = dot(tmp4.xyz, tmp3.xyz);
                tmp3.x = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp2.y = rsqrt(tmp2.y);
                tmp2.y = saturate(tmp2.w * tmp2.y + -_AngleBias);
                tmp1.y = tmp2.y * tmp3.x + tmp1.y;
                tmp2.y = _Jitter.y * -0.7071065;
                tmp3.x = _Jitter.x * 0.707107 + -tmp2.y;
                tmp3.y = dot(_Jitter.xy, float2(0.707107, -0.7071065));
                tmp2.yw = tmp1.xx * tmp3.xy;
                tmp2.yw = round(tmp2.yw);
                tmp2.yw = tmp2.yw * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yw * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yw);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp5.xyz = tmp5.xyz - tmp0.xyz;
                tmp1.x = dot(tmp5.xyz, tmp5.xyz);
                tmp2.y = dot(tmp4.xyz, tmp5.xyz);
                tmp2.w = saturate(tmp1.x * _NegInvRadius2 + 1.0);
                tmp1.x = rsqrt(tmp1.x);
                tmp1.x = saturate(tmp2.y * tmp1.x + -_AngleBias);
                tmp1.x = tmp1.x * tmp2.w + tmp1.y;
                tmp2.yz = tmp2.zz * tmp3.xy;
                tmp2.yz = round(tmp2.yz);
                tmp2.yz = tmp2.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp3.zw = tmp2.yz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp2.yz);
                tmp5.xy = tmp3.zw * tmp5.zz;
                tmp2.yzw = tmp5.xyz - tmp0.xyz;
                tmp1.y = dot(tmp2.xyz, tmp2.xyz);
                tmp2.y = dot(tmp4.xyz, tmp2.xyz);
                tmp2.z = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp1.y = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp2.y * tmp1.y + -_AngleBias);
                tmp1.x = tmp1.y * tmp2.z + tmp1.x;
                tmp1.yz = tmp1.zz * tmp3.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.yz = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.yz);
                tmp5.xy = tmp2.yz * tmp5.zz;
                tmp2.yzw = tmp5.xyz - tmp0.xyz;
                tmp1.y = dot(tmp2.xyz, tmp2.xyz);
                tmp1.z = dot(tmp4.xyz, tmp2.xyz);
                tmp2.y = saturate(tmp1.y * _NegInvRadius2 + 1.0);
                tmp1.y = rsqrt(tmp1.y);
                tmp1.y = saturate(tmp1.z * tmp1.y + -_AngleBias);
                tmp1.x = tmp1.y * tmp2.y + tmp1.x;
                tmp1.yz = tmp1.ww * tmp3.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.yz = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp5 = tex2D(_DepthTex, tmp1.yz);
                tmp5.xy = tmp2.yz * tmp5.zz;
                tmp1.yzw = tmp5.xyz - tmp0.xyz;
                tmp2.y = dot(tmp1.xyz, tmp1.xyz);
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.z = saturate(tmp2.y * _NegInvRadius2 + 1.0);
                tmp1.w = rsqrt(tmp2.y);
                tmp1.y = saturate(tmp1.y * tmp1.w + -_AngleBias);
                tmp1.x = tmp1.y * tmp1.z + tmp1.x;
                tmp1.yz = tmp2.xx * tmp3.xy;
                tmp2.xy = tmp0.ww * tmp3.xy;
                tmp2.xy = round(tmp2.xy);
                tmp2.xy = tmp2.xy * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp1.yz = round(tmp1.yz);
                tmp1.yz = tmp1.yz * _LayerRes_TexelSize.xy + inp.texcoord1.xy;
                tmp2.zw = tmp1.yz * _UVToView.xy + _UVToView.zw;
                tmp3 = tex2D(_DepthTex, tmp1.yz);
                tmp3.xy = tmp2.zw * tmp3.zz;
                tmp1.yzw = tmp3.xyz - tmp0.xyz;
                tmp0.w = dot(tmp1.xyz, tmp1.xyz);
                tmp1.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.z = saturate(tmp0.w * _NegInvRadius2 + 1.0);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.w = saturate(tmp1.y * tmp0.w + -_AngleBias);
                tmp0.w = tmp0.w * tmp1.z + tmp1.x;
                tmp1.xy = tmp2.xy * _UVToView.xy + _UVToView.zw;
                tmp2 = tex2D(_DepthTex, tmp2.xy);
                tmp2.xy = tmp1.xy * tmp2.zz;
                tmp1.xyz = tmp2.xyz - tmp0.xyz;
                tmp0.x = dot(tmp1.xyz, tmp1.xyz);
                tmp0.y = dot(tmp4.xyz, tmp1.xyz);
                tmp1.x = saturate(tmp0.x * _NegInvRadius2 + 1.0);
                tmp0.x = rsqrt(tmp0.x);
                tmp0.x = saturate(tmp0.y * tmp0.x + -_AngleBias);
                tmp0.x = tmp0.x * tmp1.x + tmp0.w;
                tmp0.x = tmp0.x * _AOmultiplier;
                tmp0.x = saturate(-tmp0.x * 0.0208333 + 1.0);
                tmp0.y = 1.0 - tmp0.x;
                tmp0.w = _MaxDistance - _DistanceFalloff;
                tmp1.x = tmp0.z - tmp0.w;
                tmp0.w = _MaxDistance - tmp0.w;
                tmp0.w = saturate(tmp1.x / tmp0.w);
                o.sv_target.w = tmp0.w * tmp0.y + tmp0.x;
                o.sv_target.z = 1.0;
                tmp0.x = 1.0 / _ProjectionParams.z;
                tmp0.x = saturate(tmp0.x * tmp0.z);
                tmp0.xy = tmp0.xx * float2(1.0, 255.0);
                tmp0.xy = frac(tmp0.xy);
                o.sv_target.x = -tmp0.y * 0.0039216 + tmp0.x;
                o.sv_target.y = tmp0.y;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 695088
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
				float4 sv_target1 : SV_Target1;
				float4 sv_target2 : SV_Target2;
				float4 sv_target3 : SV_Target3;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _TargetScale;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _FullRes_TexelSize;
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float2 _Deinterleaving_Offset00;
				float2 _Deinterleaving_Offset10;
				float2 _Deinterleaving_Offset01;
				float2 _Deinterleaving_Offset11;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                tmp0.x = _ProjectionParams.x < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
                o.position = v.vertex * float4(2.0, 2.0, 0.0, 0.0) + float4(0.0, 0.0, 0.0, 1.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0 = inp.texcoord1.xyxy * _LayerRes_TexelSize;
                tmp0 = floor(tmp0);
                tmp1 = tmp0.zwzw * float4(2.0, 2.0, 2.0, 2.0) + float4(_Deinterleaving_Offset00.xy, _Deinterleaving_Offset10.xy);
                tmp0 = tmp0 * float4(2.0, 2.0, 2.0, 2.0) + float4(_Deinterleaving_Offset01.xy, _Deinterleaving_Offset11.xy);
                tmp0 = tmp0 + float4(0.5, 0.5, 0.5, 0.5);
                tmp0 = tmp0 * _FullRes_TexelSize;
                tmp0 = tmp0 * _TargetScale;
                tmp1 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1 = tmp1 * _FullRes_TexelSize;
                tmp1 = tmp1 * _TargetScale;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.xy);
                tmp1 = tex2D(_CameraDepthTexture, tmp1.zw);
                tmp1.x = _ZBufferParams.z * tmp1.x + _ZBufferParams.w;
                o.sv_target1 = float4(1.0, 1.0, 1.0, 1.0) / tmp1.xxxx;
                tmp1.x = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                o.sv_target = float4(1.0, 1.0, 1.0, 1.0) / tmp1.xxxx;
                tmp1 = tex2D(_CameraDepthTexture, tmp0.xy);
                tmp0 = tex2D(_CameraDepthTexture, tmp0.zw);
                tmp0.x = _ZBufferParams.z * tmp0.x + _ZBufferParams.w;
                o.sv_target3 = float4(1.0, 1.0, 1.0, 1.0) / tmp0.xxxx;
                tmp0.x = _ZBufferParams.z * tmp1.x + _ZBufferParams.w;
                o.sv_target2 = float4(1.0, 1.0, 1.0, 1.0) / tmp0.xxxx;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 722891
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
				float4 sv_target1 : SV_Target1;
				float4 sv_target2 : SV_Target2;
				float4 sv_target3 : SV_Target3;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _TargetScale;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _FullRes_TexelSize;
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float2 _Deinterleaving_Offset00;
				float2 _Deinterleaving_Offset10;
				float2 _Deinterleaving_Offset01;
				float2 _Deinterleaving_Offset11;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                tmp0.x = _ProjectionParams.x < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
                o.position = v.vertex * float4(2.0, 2.0, 0.0, 0.0) + float4(0.0, 0.0, 0.0, 1.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0 = inp.texcoord1.xyxy * _LayerRes_TexelSize;
                tmp0 = floor(tmp0);
                tmp1 = tmp0.zwzw * float4(4.0, 4.0, 4.0, 4.0) + float4(_Deinterleaving_Offset00.xy, _Deinterleaving_Offset10.xy);
                tmp0 = tmp0 * float4(4.0, 4.0, 4.0, 4.0) + float4(_Deinterleaving_Offset01.xy, _Deinterleaving_Offset11.xy);
                tmp0 = tmp0 + float4(0.5, 0.5, 0.5, 0.5);
                tmp0 = tmp0 * _FullRes_TexelSize;
                tmp0 = tmp0 * _TargetScale;
                tmp1 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1 = tmp1 * _FullRes_TexelSize;
                tmp1 = tmp1 * _TargetScale;
                tmp2 = tex2D(_CameraDepthTexture, tmp1.xy);
                tmp1 = tex2D(_CameraDepthTexture, tmp1.zw);
                tmp1.x = _ZBufferParams.z * tmp1.x + _ZBufferParams.w;
                o.sv_target1 = float4(1.0, 1.0, 1.0, 1.0) / tmp1.xxxx;
                tmp1.x = _ZBufferParams.z * tmp2.x + _ZBufferParams.w;
                o.sv_target = float4(1.0, 1.0, 1.0, 1.0) / tmp1.xxxx;
                tmp1 = tex2D(_CameraDepthTexture, tmp0.xy);
                tmp0 = tex2D(_CameraDepthTexture, tmp0.zw);
                tmp0.x = _ZBufferParams.z * tmp0.x + _ZBufferParams.w;
                o.sv_target3 = float4(1.0, 1.0, 1.0, 1.0) / tmp0.xxxx;
                tmp0.x = _ZBufferParams.z * tmp1.x + _ZBufferParams.w;
                o.sv_target2 = float4(1.0, 1.0, 1.0, 1.0) / tmp0.xxxx;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 825958
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
				float4 sv_target1 : SV_Target1;
				float4 sv_target2 : SV_Target2;
				float4 sv_target3 : SV_Target3;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4x4 _WorldToCameraMatrix;
				float4 _TargetScale;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _FullRes_TexelSize;
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float2 _Deinterleaving_Offset00;
				float2 _Deinterleaving_Offset10;
				float2 _Deinterleaving_Offset01;
				float2 _Deinterleaving_Offset11;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraGBufferTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                tmp0.x = _ProjectionParams.x < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
                o.position = v.vertex * float4(2.0, 2.0, 0.0, 0.0) + float4(0.0, 0.0, 0.0, 1.0);
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
                tmp0 = inp.texcoord1.xyxy * _LayerRes_TexelSize;
                tmp0 = floor(tmp0);
                tmp1 = tmp0.zwzw * float4(2.0, 2.0, 2.0, 2.0) + float4(_Deinterleaving_Offset00.xy, _Deinterleaving_Offset10.xy);
                tmp0 = tmp0 * float4(2.0, 2.0, 2.0, 2.0) + float4(_Deinterleaving_Offset01.xy, _Deinterleaving_Offset11.xy);
                tmp0 = tmp0 + float4(0.5, 0.5, 0.5, 0.5);
                tmp0 = tmp0 * _FullRes_TexelSize;
                tmp0 = tmp0 * _TargetScale;
                tmp1 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1 = tmp1 * _FullRes_TexelSize;
                tmp1 = tmp1 * _TargetScale;
                tmp2 = tex2D(_CameraGBufferTexture2, tmp1.xy);
                tmp1 = tex2D(_CameraGBufferTexture2, tmp1.zw);
                tmp1.xyz = tmp1.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp2.xyz = tmp2.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp3.xyz = tmp2.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp2.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp2.xxx + tmp3.xyz;
                tmp2.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp2.zzz + tmp2.xyw;
                tmp2.xyz = tmp2.xyz * float3(0.5, -0.5, -0.5);
                tmp2.w = 0.0;
                o.sv_target = tmp2 + float4(0.5, 0.5, 0.5, 0.5);
                tmp2.xyz = tmp1.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp1.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp1.xxx + tmp2.xyz;
                tmp1.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp1.zzz + tmp1.xyw;
                tmp1.xyz = tmp1.xyz * float3(0.5, -0.5, -0.5);
                tmp1.w = 0.0;
                o.sv_target1 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1 = tex2D(_CameraGBufferTexture2, tmp0.xy);
                tmp0 = tex2D(_CameraGBufferTexture2, tmp0.zw);
                tmp0.xyz = tmp0.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp1.xyz = tmp1.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp2.xyz = tmp1.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp1.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp1.xxx + tmp2.xyz;
                tmp1.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp1.zzz + tmp1.xyw;
                tmp1.xyz = tmp1.xyz * float3(0.5, -0.5, -0.5);
                tmp1.w = 0.0;
                o.sv_target2 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1.xyz = tmp0.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp0.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp0.zzz + tmp0.xyw;
                tmp0.xyz = tmp0.xyz * float3(0.5, -0.5, -0.5);
                tmp0.w = 0.0;
                o.sv_target3 = tmp0 + float4(0.5, 0.5, 0.5, 0.5);
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 868059
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
				float4 sv_target1 : SV_Target1;
				float4 sv_target2 : SV_Target2;
				float4 sv_target3 : SV_Target3;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4x4 _WorldToCameraMatrix;
				float4 _TargetScale;
			CBUFFER_END
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _FullRes_TexelSize;
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float2 _Deinterleaving_Offset00;
				float2 _Deinterleaving_Offset10;
				float2 _Deinterleaving_Offset01;
				float2 _Deinterleaving_Offset11;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _CameraGBufferTexture2;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                tmp0.x = _ProjectionParams.x < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
                o.position = v.vertex * float4(2.0, 2.0, 0.0, 0.0) + float4(0.0, 0.0, 0.0, 1.0);
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
                tmp0 = inp.texcoord1.xyxy * _LayerRes_TexelSize;
                tmp0 = floor(tmp0);
                tmp1 = tmp0.zwzw * float4(4.0, 4.0, 4.0, 4.0) + float4(_Deinterleaving_Offset00.xy, _Deinterleaving_Offset10.xy);
                tmp0 = tmp0 * float4(4.0, 4.0, 4.0, 4.0) + float4(_Deinterleaving_Offset01.xy, _Deinterleaving_Offset11.xy);
                tmp0 = tmp0 + float4(0.5, 0.5, 0.5, 0.5);
                tmp0 = tmp0 * _FullRes_TexelSize;
                tmp0 = tmp0 * _TargetScale;
                tmp1 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1 = tmp1 * _FullRes_TexelSize;
                tmp1 = tmp1 * _TargetScale;
                tmp2 = tex2D(_CameraGBufferTexture2, tmp1.xy);
                tmp1 = tex2D(_CameraGBufferTexture2, tmp1.zw);
                tmp1.xyz = tmp1.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp2.xyz = tmp2.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp3.xyz = tmp2.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp2.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp2.xxx + tmp3.xyz;
                tmp2.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp2.zzz + tmp2.xyw;
                tmp2.xyz = tmp2.xyz * float3(0.5, -0.5, -0.5);
                tmp2.w = 0.0;
                o.sv_target = tmp2 + float4(0.5, 0.5, 0.5, 0.5);
                tmp2.xyz = tmp1.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp1.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp1.xxx + tmp2.xyz;
                tmp1.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp1.zzz + tmp1.xyw;
                tmp1.xyz = tmp1.xyz * float3(0.5, -0.5, -0.5);
                tmp1.w = 0.0;
                o.sv_target1 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1 = tex2D(_CameraGBufferTexture2, tmp0.xy);
                tmp0 = tex2D(_CameraGBufferTexture2, tmp0.zw);
                tmp0.xyz = tmp0.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp1.xyz = tmp1.xyz * float3(2.0, 2.0, 2.0) + float3(-1.0, -1.0, -1.0);
                tmp2.xyz = tmp1.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp1.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp1.xxx + tmp2.xyz;
                tmp1.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp1.zzz + tmp1.xyw;
                tmp1.xyz = tmp1.xyz * float3(0.5, -0.5, -0.5);
                tmp1.w = 0.0;
                o.sv_target2 = tmp1 + float4(0.5, 0.5, 0.5, 0.5);
                tmp1.xyz = tmp0.yyy * _WorldToCameraMatrix._m01_m11_m21;
                tmp0.xyw = _WorldToCameraMatrix._m00_m10_m20 * tmp0.xxx + tmp1.xyz;
                tmp0.xyz = _WorldToCameraMatrix._m02_m12_m22 * tmp0.zzz + tmp0.xyw;
                tmp0.xyz = tmp0.xyz * float3(0.5, -0.5, -0.5);
                tmp0.w = 0.0;
                o.sv_target3 = tmp0 + float4(0.5, 0.5, 0.5, 0.5);
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 955160
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _FullRes_TexelSize;
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			CBUFFER_START(PerPassUpdatedDeinterleavingUniforms)
				float2 _LayerOffset;
			CBUFFER_END
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
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
                tmp0.xy = _LayerRes_TexelSize.zw / _FullRes_TexelSize.zw;
                tmp0.zw = _FullRes_TexelSize.xy * _LayerOffset;
                tmp0.xy = v.vertex.xy * tmp0.xy + tmp0.zw;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp0 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
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
                o.sv_target = tex2Dlod(_MainTex, float4(inp.texcoord1.xy, 0, 0.0));
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 989532
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _FullRes_TexelSize;
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _FullRes_TexelSize.zw;
                tmp0.xy = floor(tmp0.xy);
                tmp0.xy = tmp0.xy * float2(0.5, 0.5);
                tmp0.zw = tmp0.xy >= -tmp0.xy;
                tmp0.xy = frac(abs(tmp0.xy));
                tmp0.xy = tmp0.zw ? tmp0.xy : -tmp0.xy;
                tmp0.xy = tmp0.xy * _LayerRes_TexelSize.zw;
                tmp0.zw = inp.texcoord1.xy * _LayerRes_TexelSize.zw;
                tmp0.zw = floor(tmp0.zw);
                tmp0.xy = tmp0.xy * float2(2.0, 2.0) + tmp0.zw;
                tmp0.xy = tmp0.xy + float2(0.5, 0.5);
                tmp0.xy = tmp0.xy * _FullRes_TexelSize.xy;
                o.sv_target = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1072722
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedDeinterleavingUniforms)
				float4 _FullRes_TexelSize;
				float4 _LayerRes_TexelSize;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _FullRes_TexelSize.zw;
                tmp0.xy = floor(tmp0.xy);
                tmp0.xy = tmp0.xy * float2(0.25, 0.25);
                tmp0.zw = tmp0.xy >= -tmp0.xy;
                tmp0.xy = frac(abs(tmp0.xy));
                tmp0.xy = tmp0.zw ? tmp0.xy : -tmp0.xy;
                tmp0.xy = tmp0.xy * _LayerRes_TexelSize.zw;
                tmp0.zw = inp.texcoord1.xy * _LayerRes_TexelSize.zw;
                tmp0.zw = floor(tmp0.zw);
                tmp0.xy = tmp0.xy * float2(4.0, 4.0) + tmp0.zw;
                tmp0.xy = tmp0.xy + float2(0.5, 0.5);
                tmp0.xy = tmp0.xy * _FullRes_TexelSize.xy;
                o.sv_target = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1170131
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.yw = float2(-0.0, 0.0);
                tmp1.x = _ScreenParams.z - 1.0;
                tmp0.x = -tmp1.x;
                tmp0.xy = tmp0.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                tmp0.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp3 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.x = tmp0.x - tmp0.y;
                tmp0.x = tmp0.x * _ProjectionParams.z;
                tmp0.x = tmp0.x * _BlurSharpness;
                tmp0.x = -tmp0.x * tmp0.x + -0.5;
                tmp0.x = exp(tmp0.x);
                tmp1.y = tmp0.x * tmp2.w + tmp3.w;
                tmp0.x = tmp0.x + 1.0;
                o.sv_target.xy = tmp3.xy;
                tmp0.z = tmp1.x * -2.0;
                tmp0.zw = tmp0.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.zw, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -2.0;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp1.y;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.x = tmp1.x + inp.texcoord.x;
                tmp1.x = tmp1.x * 2.0;
                tmp2.y = inp.texcoord.y;
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.5;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp1.y = 0.0;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.z = dot(tmp1.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.z - tmp0.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp1.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1197049
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.yw = float2(-0.0, 0.0);
                tmp1.x = _ScreenParams.z - 1.0;
                tmp0.x = -tmp1.x;
                tmp0.xy = tmp0.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                tmp0.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp3 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.x = tmp0.x - tmp0.y;
                tmp0.x = tmp0.x * _ProjectionParams.z;
                tmp0.x = tmp0.x * _BlurSharpness;
                tmp0.x = -tmp0.x * tmp0.x + -0.2222222;
                tmp0.x = exp(tmp0.x);
                tmp1.y = tmp0.x * tmp2.w + tmp3.w;
                tmp0.x = tmp0.x + 1.0;
                o.sv_target.xy = tmp3.xy;
                tmp0.z = tmp1.x * -2.0;
                tmp0.zw = tmp0.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.zw, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.8888889;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp1.y;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.yw = float2(0.0, 0.0);
                tmp2.xz = tmp1.xx * float2(-3.0, 2.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -2.0;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp3.x = tmp1.x + inp.texcoord.x;
                tmp1.x = tmp1.x * 3.0;
                tmp3.y = inp.texcoord.y;
                tmp3 = tex2Dlod(_MainTex, float4(tmp3.xy, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.2222222;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.8888889;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp1.y = 0.0;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.z = dot(tmp1.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.z - tmp0.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp1.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1270114
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.yw = float2(-0.0, 0.0);
                tmp1.x = _ScreenParams.z - 1.0;
                tmp0.x = -tmp1.x;
                tmp0.xy = tmp0.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                tmp0.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp3 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.x = tmp0.x - tmp0.y;
                tmp0.x = tmp0.x * _ProjectionParams.z;
                tmp0.x = tmp0.x * _BlurSharpness;
                tmp0.x = -tmp0.x * tmp0.x + -0.125;
                tmp0.x = exp(tmp0.x);
                tmp1.y = tmp0.x * tmp2.w + tmp3.w;
                tmp0.x = tmp0.x + 1.0;
                o.sv_target.xy = tmp3.xy;
                tmp0.z = tmp1.x * -2.0;
                tmp0.zw = tmp0.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.zw, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.5;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp1.y;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.yw = float2(0.0, 0.0);
                tmp2.xz = tmp1.xx * float2(-3.0, -4.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -1.125;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -2.0;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.y = inp.texcoord.y;
                tmp2.x = tmp1.x + inp.texcoord.x;
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.125;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.xz = tmp1.xx * float2(2.0, 3.0);
                tmp1.x = tmp1.x * 4.0;
                tmp2.yw = float2(0.0, 0.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.5;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -1.125;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp1.y = 0.0;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.z = dot(tmp1.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.z - tmp0.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp1.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1339219
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                tmp0 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp1.yw = float2(-0.0, 0.0);
                tmp0.z = _ScreenParams.z - 1.0;
                tmp1.x = -tmp0.z;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp1.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp1.y = dot(tmp0.xy, float2(1.0, 0.0039216));
                tmp1.x = tmp1.x - tmp1.y;
                tmp1.x = tmp1.x * _ProjectionParams.z;
                tmp1.x = tmp1.x * _BlurSharpness;
                tmp1.x = -tmp1.x * tmp1.x + -0.08;
                tmp1.x = exp(tmp1.x);
                tmp0.w = tmp1.x * tmp2.w + tmp0.w;
                o.sv_target.xy = tmp0.xy;
                tmp0.x = tmp1.x + 1.0;
                tmp1.z = tmp0.z * -2.0;
                tmp1.xz = tmp1.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp1.xz, 0, 0.0));
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.32;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp2.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp2.yw = float2(0.0, 0.0);
                tmp2.xz = tmp0.zz * float2(-3.0, -4.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.72;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp3.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -1.28;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp2.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp2.yw = float2(0.0, 0.0);
                tmp2.xz = tmp0.zz * float2(-5.0, 2.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp3.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp3.y = inp.texcoord.y;
                tmp3.x = tmp0.z + inp.texcoord.x;
                tmp3 = tex2Dlod(_MainTex, float4(tmp3.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.08;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp3.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.32;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp2.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp2.xz = tmp0.zz * float2(3.0, 4.0);
                tmp3.x = tmp0.z * 5.0;
                tmp2.yw = float2(0.0, 0.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp4 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.y = dot(tmp4.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.72;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp4.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -1.28;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp2.w + tmp0.z;
                tmp0.x = tmp0.y + tmp0.x;
                tmp3.y = 0.0;
                tmp0.yw = tmp3.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.yw, 0, 0.0));
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp2.w + tmp0.z;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1425669
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.xz = float2(-0.0, 0.0);
                tmp1.x = _ScreenParams.w - 1.0;
                tmp0.y = -tmp1.x;
                tmp0.xy = tmp0.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                tmp0.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp3 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.x = tmp0.x - tmp0.y;
                tmp0.x = tmp0.x * _ProjectionParams.z;
                tmp0.x = tmp0.x * _BlurSharpness;
                tmp0.x = -tmp0.x * tmp0.x + -0.5;
                tmp0.x = exp(tmp0.x);
                tmp1.y = tmp0.x * tmp2.w + tmp3.w;
                tmp0.x = tmp0.x + 1.0;
                o.sv_target.xy = tmp3.xy;
                tmp0.w = tmp1.x * -2.0;
                tmp0.zw = tmp0.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.zw, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -2.0;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp1.y;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.y = tmp1.x + inp.texcoord.y;
                tmp1.y = tmp1.x * 2.0;
                tmp2.x = inp.texcoord.x;
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.5;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp1.x = 0.0;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.z = dot(tmp1.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.z - tmp0.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp1.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1502816
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.xz = float2(-0.0, 0.0);
                tmp1.x = _ScreenParams.w - 1.0;
                tmp0.y = -tmp1.x;
                tmp0.xy = tmp0.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                tmp0.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp3 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.x = tmp0.x - tmp0.y;
                tmp0.x = tmp0.x * _ProjectionParams.z;
                tmp0.x = tmp0.x * _BlurSharpness;
                tmp0.x = -tmp0.x * tmp0.x + -0.2222222;
                tmp0.x = exp(tmp0.x);
                tmp1.y = tmp0.x * tmp2.w + tmp3.w;
                tmp0.x = tmp0.x + 1.0;
                o.sv_target.xy = tmp3.xy;
                tmp0.w = tmp1.x * -2.0;
                tmp0.zw = tmp0.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.zw, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.8888889;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp1.y;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.xz = float2(0.0, 0.0);
                tmp2.yw = tmp1.xx * float2(-3.0, 2.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -2.0;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp3.y = tmp1.x + inp.texcoord.y;
                tmp1.y = tmp1.x * 3.0;
                tmp3.x = inp.texcoord.x;
                tmp3 = tex2Dlod(_MainTex, float4(tmp3.xy, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.2222222;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.8888889;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp1.x = 0.0;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.z = dot(tmp1.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.z - tmp0.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp1.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1549462
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.xz = float2(-0.0, 0.0);
                tmp1.x = _ScreenParams.w - 1.0;
                tmp0.y = -tmp1.x;
                tmp0.xy = tmp0.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.xy, 0, 0.0));
                tmp0.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp3 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.x = tmp0.x - tmp0.y;
                tmp0.x = tmp0.x * _ProjectionParams.z;
                tmp0.x = tmp0.x * _BlurSharpness;
                tmp0.x = -tmp0.x * tmp0.x + -0.125;
                tmp0.x = exp(tmp0.x);
                tmp1.y = tmp0.x * tmp2.w + tmp3.w;
                tmp0.x = tmp0.x + 1.0;
                o.sv_target.xy = tmp3.xy;
                tmp0.w = tmp1.x * -2.0;
                tmp0.zw = tmp0.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.zw, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.5;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp1.y;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.xz = float2(0.0, 0.0);
                tmp2.yw = tmp1.xx * float2(-3.0, -4.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -1.125;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -2.0;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.x = inp.texcoord.x;
                tmp2.y = tmp1.x + inp.texcoord.y;
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.125;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp2.yw = tmp1.xx * float2(2.0, 3.0);
                tmp1.y = tmp1.x * 4.0;
                tmp2.xz = float2(0.0, 0.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.z = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -0.5;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp3.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp0.z = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.z = tmp0.z - tmp0.y;
                tmp0.z = tmp0.z * _ProjectionParams.z;
                tmp0.z = tmp0.z * _BlurSharpness;
                tmp0.z = -tmp0.z * tmp0.z + -1.125;
                tmp0.z = exp(tmp0.z);
                tmp0.w = tmp0.z * tmp2.w + tmp0.w;
                tmp0.x = tmp0.z + tmp0.x;
                tmp1.x = 0.0;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp1 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp0.z = dot(tmp1.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.z - tmp0.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp1.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1580508
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _BlurSharpness;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                tmp0 = tex2Dlod(_MainTex, float4(inp.texcoord.xy, 0, 0.0));
                tmp1.xz = float2(-0.0, 0.0);
                tmp0.z = _ScreenParams.w - 1.0;
                tmp1.y = -tmp0.z;
                tmp1.xy = tmp1.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp1.xy, 0, 0.0));
                tmp1.x = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp1.y = dot(tmp0.xy, float2(1.0, 0.0039216));
                tmp1.x = tmp1.x - tmp1.y;
                tmp1.x = tmp1.x * _ProjectionParams.z;
                tmp1.x = tmp1.x * _BlurSharpness;
                tmp1.x = -tmp1.x * tmp1.x + -0.08;
                tmp1.x = exp(tmp1.x);
                tmp0.w = tmp1.x * tmp2.w + tmp0.w;
                o.sv_target.xy = tmp0.xy;
                tmp0.x = tmp1.x + 1.0;
                tmp1.w = tmp0.z * -2.0;
                tmp1.xz = tmp1.zw + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp1.xz, 0, 0.0));
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.32;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp2.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp2.xz = float2(0.0, 0.0);
                tmp2.yw = tmp0.zz * float2(-3.0, -4.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.72;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp3.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -1.28;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp2.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp2.xz = float2(0.0, 0.0);
                tmp2.yw = tmp0.zz * float2(-5.0, 2.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp3 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp3.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp3.x = inp.texcoord.x;
                tmp3.y = tmp0.z + inp.texcoord.y;
                tmp3 = tex2Dlod(_MainTex, float4(tmp3.xy, 0, 0.0));
                tmp0.y = dot(tmp3.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.08;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp3.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.32;
                tmp0.y = exp(tmp0.y);
                tmp0.w = tmp0.y * tmp2.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp2.yw = tmp0.zz * float2(3.0, 4.0);
                tmp3.y = tmp0.z * 5.0;
                tmp2.xz = float2(0.0, 0.0);
                tmp2 = tmp2 + inp.texcoord.xyxy;
                tmp4 = tex2Dlod(_MainTex, float4(tmp2.xy, 0, 0.0));
                tmp2 = tex2Dlod(_MainTex, float4(tmp2.zw, 0, 0.0));
                tmp0.y = dot(tmp4.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -0.72;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp4.w + tmp0.w;
                tmp0.x = tmp0.y + tmp0.x;
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -1.28;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp2.w + tmp0.z;
                tmp0.x = tmp0.y + tmp0.x;
                tmp3.x = 0.0;
                tmp0.yw = tmp3.xy + inp.texcoord.xy;
                tmp2 = tex2Dlod(_MainTex, float4(tmp0.yw, 0, 0.0));
                tmp0.y = dot(tmp2.xy, float2(1.0, 0.0039216));
                tmp0.y = tmp0.y - tmp1.y;
                tmp0.y = tmp0.y * _ProjectionParams.z;
                tmp0.y = tmp0.y * _BlurSharpness;
                tmp0.y = -tmp0.y * tmp0.y + -2.0;
                tmp0.y = exp(tmp0.y);
                tmp0.z = tmp0.y * tmp2.w + tmp0.z;
                tmp0.x = tmp0.y + tmp0.x;
                o.sv_target.w = tmp0.z / tmp0.x;
                o.sv_target.z = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1701576
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp0.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                o.sv_target.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.w = tmp1.w;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1756304
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                tmp0.yzw = _BaseColor.xyz - tmp1.xyz;
                tmp0.yzw = _BaseColor.xyz * tmp0.yzw + tmp1.xyz;
                tmp2.xyz = tmp0.yzw * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp3.xyz = tmp0.yzw * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp0.yzw = tmp0.yzw * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp2.xyz = tmp0.xxx * tmp2.xyz + tmp3.xyz;
                tmp0.yzw = tmp2.xyz * tmp0.xxx + tmp0.yzw;
                tmp0.yzw = tmp0.xxx * tmp0.yzw;
                tmp0.yzw = max(tmp0.yzw, tmp0.xxx);
                tmp2.xyz = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp2.xyz = tmp0.xxx * tmp2.xyz + _BaseColor.xyz;
                tmp0.xyz = tmp0.yzw - tmp2.xyz;
                tmp0.xyz = _MultiBounceInfluence.xxx * tmp0.xyz + tmp2.xyz;
                o.sv_target.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.w = tmp1.w;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1783882
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1866070
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			sampler2D _MainTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.xyz = _BaseColor.xyz - tmp0.xyz;
                tmp0.xyz = _BaseColor.xyz * tmp1.xyz + tmp0.xyz;
                tmp1.xyz = tmp0.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp2.xyz = tmp0.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp0.xyz = tmp0.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp3.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp3 = tex2D(_HBAOTex, tmp3.xy);
                tmp0.w = log(tmp3.w);
                tmp0.w = tmp0.w * _Intensity;
                tmp0.w = exp(tmp0.w);
                tmp0.w = min(tmp0.w, 1.0);
                tmp1.xyz = tmp0.www * tmp1.xyz + tmp2.xyz;
                tmp0.xyz = tmp1.xyz * tmp0.www + tmp0.xyz;
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.xyz = max(tmp0.xyz, tmp0.www);
                tmp1.xyz = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.xyz = tmp0.www * tmp1.xyz + _BaseColor.xyz;
                tmp0.xyz = tmp0.xyz - tmp1.xyz;
                o.sv_target.xyz = _MultiBounceInfluence.xxx * tmp0.xyz + tmp1.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 1911235
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _ColorBleedSaturation;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.xyz = float3(1.0, 1.0, 1.0) - tmp0.xyz;
                tmp0.w = 0.0;
                o.sv_target = _ColorBleedSaturation.xxxx * tmp0 + float4(0.0, 0.0, 0.0, 1.0);
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2011033
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.x = inp.texcoord.x <= 0.4985;
                if (tmp1.x) {
                    o.sv_target = tmp0;
                    return o;
                }
                tmp1.x = inp.texcoord.x > 0.4985;
                tmp1.y = inp.texcoord.x < 0.5015;
                tmp1.x = tmp1.y ? tmp1.x : 0.0;
                if (tmp1.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 1.0);
                    return o;
                }
                tmp1.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp1 = tex2D(_HBAOTex, tmp1.xy);
                tmp1.x = log(tmp1.w);
                tmp1.x = tmp1.x * _Intensity;
                tmp1.x = exp(tmp1.x);
                tmp1.x = min(tmp1.x, 1.0);
                tmp1.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.xyz = tmp1.xxx * tmp1.yzw + _BaseColor.xyz;
                tmp1.w = 1.0;
                o.sv_target = tmp0 * tmp1;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2086102
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.x = inp.texcoord.x <= 0.4985;
                if (tmp1.x) {
                    o.sv_target = tmp0;
                    return o;
                }
                tmp1.x = inp.texcoord.x > 0.4985;
                tmp1.y = inp.texcoord.x < 0.5015;
                tmp1.x = tmp1.y ? tmp1.x : 0.0;
                if (tmp1.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 1.0);
                    return o;
                }
                tmp1.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp1 = tex2D(_HBAOTex, tmp1.xy);
                tmp1.x = log(tmp1.w);
                tmp1.x = tmp1.x * _Intensity;
                tmp1.x = exp(tmp1.x);
                tmp1.x = min(tmp1.x, 1.0);
                tmp1.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.yzw = tmp1.xxx * tmp1.yzw + _BaseColor.xyz;
                tmp2.xyz = _BaseColor.xyz - tmp0.xyz;
                tmp2.xyz = _BaseColor.xyz * tmp2.xyz + tmp0.xyz;
                tmp3.xyz = tmp2.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp4.xyz = tmp2.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp2.xyz = tmp2.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp3.xyz = tmp1.xxx * tmp3.xyz + tmp4.xyz;
                tmp2.xyz = tmp3.xyz * tmp1.xxx + tmp2.xyz;
                tmp2.xyz = tmp1.xxx * tmp2.xyz;
                tmp2.xyz = max(tmp1.xxx, tmp2.xyz);
                tmp2.xyz = tmp2.xyz - tmp1.yzw;
                tmp1.xyz = _MultiBounceInfluence.xxx * tmp2.xyz + tmp1.yzw;
                o.sv_target.xyz = tmp0.xyz * tmp1.xyz;
                o.sv_target.w = tmp0.w;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2117342
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp0.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                tmp1.x = inp.texcoord.x <= 0.4985;
                if (tmp1.x) {
                    tmp1 = tex2D(_MainTex, inp.texcoord.xy);
                    tmp0.w = 1.0;
                    o.sv_target = tmp0 * tmp1;
                    return o;
                }
                tmp0.w = inp.texcoord.x > 0.4985;
                tmp1.x = inp.texcoord.x < 0.5015;
                tmp0.w = tmp0.w ? tmp1.x : 0.0;
                if (tmp0.w) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 1.0);
                    return o;
                }
                o.sv_target.xyz = tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2171225
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                float4 tmp4;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp1 = tex2D(_HBAOTex, tmp1.xy);
                tmp1.x = log(tmp1.w);
                tmp1.x = tmp1.x * _Intensity;
                tmp1.x = exp(tmp1.x);
                tmp1.x = min(tmp1.x, 1.0);
                tmp1.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.yzw = tmp1.xxx * tmp1.yzw + _BaseColor.xyz;
                tmp2.xyz = _BaseColor.xyz - tmp0.xyz;
                tmp2.xyz = _BaseColor.xyz * tmp2.xyz + tmp0.xyz;
                tmp3.xyz = tmp2.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp4.xyz = tmp2.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp2.xyz = tmp2.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp3.xyz = tmp1.xxx * tmp3.xyz + tmp4.xyz;
                tmp2.xyz = tmp3.xyz * tmp1.xxx + tmp2.xyz;
                tmp2.xyz = tmp1.xxx * tmp2.xyz;
                tmp2.xyz = max(tmp1.xxx, tmp2.xyz);
                tmp2.xyz = tmp2.xyz - tmp1.yzw;
                tmp1.xyz = _MultiBounceInfluence.xxx * tmp2.xyz + tmp1.yzw;
                tmp2.x = inp.texcoord.x <= 0.4985;
                if (tmp2.x) {
                    tmp1.w = 1.0;
                    o.sv_target = tmp0 * tmp1;
                    return o;
                }
                tmp0.x = inp.texcoord.x > 0.4985;
                tmp0.y = inp.texcoord.x < 0.5015;
                tmp0.x = tmp0.y ? tmp0.x : 0.0;
                if (tmp0.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 1.0);
                    return o;
                }
                o.sv_target.xyz = tmp1.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2234831
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.x = inp.texcoord.x <= 0.4985;
                if (tmp0.x) {
                    o.sv_target = tex2D(_MainTex, inp.texcoord.xy);
                    return o;
                }
                tmp0.x = inp.texcoord.x > 0.4985;
                tmp0.y = inp.texcoord.x < 0.5015;
                tmp0.x = tmp0.y ? tmp0.x : 0.0;
                if (tmp0.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 1.0);
                    return o;
                }
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2316255
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _MainTex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0 = tex2D(_MainTex, inp.texcoord.xy);
                tmp1.x = inp.texcoord.x <= 0.4985;
                if (tmp1.x) {
                    o.sv_target = tmp0;
                    return o;
                }
                tmp0.w = inp.texcoord.x > 0.4985;
                tmp1.x = inp.texcoord.x < 0.5015;
                tmp0.w = tmp0.w ? tmp1.x : 0.0;
                if (tmp0.w) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 1.0);
                    return o;
                }
                tmp1.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp1 = tex2D(_HBAOTex, tmp1.xy);
                tmp0.w = log(tmp1.w);
                tmp0.w = tmp0.w * _Intensity;
                tmp0.w = exp(tmp0.w);
                tmp0.w = min(tmp0.w, 1.0);
                tmp1.xyz = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.xyz = tmp0.www * tmp1.xyz + _BaseColor.xyz;
                tmp2.xyz = _BaseColor.xyz - tmp0.xyz;
                tmp0.xyz = _BaseColor.xyz * tmp2.xyz + tmp0.xyz;
                tmp2.xyz = tmp0.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp3.xyz = tmp0.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp0.xyz = tmp0.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp2.xyz = tmp0.www * tmp2.xyz + tmp3.xyz;
                tmp0.xyz = tmp2.xyz * tmp0.www + tmp0.xyz;
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.xyz = max(tmp0.xyz, tmp0.www);
                tmp0.xyz = tmp0.xyz - tmp1.xyz;
                o.sv_target.xyz = _MultiBounceInfluence.xxx * tmp0.xyz + tmp1.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2391631
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
				float4 sv_target1 : SV_Target1;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			sampler2D _rt0Tex;
			sampler2D _rt3Tex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                tmp0.x = _ProjectionParams.x < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
                o.position = v.vertex * float4(2.0, 2.0, 0.0, 0.0) + float4(0.0, 0.0, 0.0, 1.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp1 = tex2D(_rt0Tex, inp.texcoord1.xy);
                o.sv_target.w = tmp0.x * tmp1.w;
                o.sv_target.xyz = tmp1.xyz;
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp0.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                tmp1.xyz = float3(1.0, 1.0, 1.0) - tmp0.xyz;
                tmp2 = tex2D(_rt3Tex, inp.texcoord1.xy);
                tmp2.xyz = log(tmp2.xyz);
                o.sv_target1.w = tmp2.w;
                tmp0.w = -tmp2.y - tmp2.x;
                tmp0.w = tmp0.w - tmp2.z;
                tmp0.w = saturate(tmp0.w * 0.3333333);
                tmp0.xyz = tmp0.www * tmp1.xyz + tmp0.xyz;
                tmp0.xyz = tmp0.xyz * -tmp2.xyz;
                o.sv_target1.xyz = exp(-tmp0.xyz);
                return o;
			}
			ENDCG
		}
		Pass {
			Blend DstColor Zero, DstAlpha Zero
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2455712
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
				float4 sv_target1 : SV_Target1;
			};
			// $Globals ConstantBuffers for Vertex Shader
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			sampler2D _rt3Tex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                tmp0.x = _ProjectionParams.x < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
                o.position = v.vertex * float4(2.0, 2.0, 0.0, 0.0) + float4(0.0, 0.0, 0.0, 1.0);
                return o;
			}
			// Keywords: 
			fout frag(v2f inp)
			{
                fout o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                o.sv_target.w = tmp0.x;
                o.sv_target.xyz = float3(1.0, 1.0, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp0.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                tmp1.xyz = float3(1.0, 1.0, 1.0) - tmp0.xyz;
                tmp2 = tex2D(_rt3Tex, inp.texcoord1.xy);
                tmp0.w = tmp2.y + tmp2.x;
                tmp0.w = tmp2.z + tmp0.w;
                tmp0.w = saturate(tmp0.w * 0.3333333);
                o.sv_target1.xyz = tmp0.www * tmp1.xyz + tmp0.xyz;
                o.sv_target1.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2517626
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _rt3Tex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp0.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                tmp1 = tex2D(_rt3Tex, inp.texcoord1.xy);
                tmp1.xyz = log(tmp1.xyz);
                o.sv_target.w = tmp1.w;
                tmp0.xyz = tmp0.xyz * -tmp1.xyz;
                o.sv_target.xyz = exp(-tmp0.xyz);
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2596836
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _rt3Tex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp1 = tex2D(_rt3Tex, inp.texcoord1.xy);
                tmp0.yzw = log(tmp1.xyz);
                o.sv_target.w = tmp1.w;
                tmp1.xyz = tmp0.yzw + _BaseColor.xyz;
                tmp1.xyz = _BaseColor.xyz * tmp1.xyz + -tmp0.yzw;
                tmp2.xyz = tmp1.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp3.xyz = tmp1.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp1.xyz = tmp1.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp2.xyz = tmp0.xxx * tmp2.xyz + tmp3.xyz;
                tmp1.xyz = tmp2.xyz * tmp0.xxx + tmp1.xyz;
                tmp1.xyz = tmp0.xxx * tmp1.xyz;
                tmp1.xyz = max(tmp0.xxx, tmp1.xyz);
                tmp2.xyz = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp2.xyz = tmp0.xxx * tmp2.xyz + _BaseColor.xyz;
                tmp1.xyz = tmp1.xyz - tmp2.xyz;
                tmp1.xyz = _MultiBounceInfluence.xxx * tmp1.xyz + tmp2.xyz;
                tmp0.xyz = -tmp0.yzw * tmp1.xyz;
                o.sv_target.xyz = exp(-tmp0.xyz);
                return o;
			}
			ENDCG
		}
		Pass {
			Blend DstColor Zero, DstColor Zero
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2622584
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Blend DstColor Zero, DstColor Zero
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2690797
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _rt3Tex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0 = tex2D(_rt3Tex, inp.texcoord1.xy);
                tmp1.xyz = _BaseColor.xyz - tmp0.xyz;
                tmp0.xyz = _BaseColor.xyz * tmp1.xyz + tmp0.xyz;
                tmp1.xyz = tmp0.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp2.xyz = tmp0.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp0.xyz = tmp0.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp3.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp3 = tex2D(_HBAOTex, tmp3.xy);
                tmp0.w = log(tmp3.w);
                tmp0.w = tmp0.w * _Intensity;
                tmp0.w = exp(tmp0.w);
                tmp0.w = min(tmp0.w, 1.0);
                tmp1.xyz = tmp0.www * tmp1.xyz + tmp2.xyz;
                tmp0.xyz = tmp1.xyz * tmp0.www + tmp0.xyz;
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.xyz = max(tmp0.xyz, tmp0.www);
                tmp1.xyz = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.xyz = tmp0.www * tmp1.xyz + _BaseColor.xyz;
                tmp0.xyz = tmp0.xyz - tmp1.xyz;
                o.sv_target.xyz = _MultiBounceInfluence.xxx * tmp0.xyz + tmp1.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Blend One One, One One
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2776730
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                o.sv_target.xyz = float3(1.0, 1.0, 1.0) - tmp0.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2826863
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.x = inp.texcoord.x <= 0.4985;
                if (tmp0.x) {
                    discard;
                }
                tmp0.x = inp.texcoord.x > 0.4985;
                tmp0.y = inp.texcoord.x < 0.5015;
                tmp0.x = tmp0.y ? tmp0.x : 0.0;
                if (tmp0.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                    return o;
                }
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2897146
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _rt3Tex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.x = inp.texcoord.x <= 0.4985;
                if (tmp0.x) {
                    discard;
                }
                tmp0.x = inp.texcoord.x > 0.4985;
                tmp0.y = inp.texcoord.x < 0.5015;
                tmp0.x = tmp0.y ? tmp0.x : 0.0;
                if (tmp0.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                    return o;
                }
                tmp0 = tex2D(_rt3Tex, inp.texcoord1.xy);
                tmp1.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp1 = tex2D(_HBAOTex, tmp1.xy);
                tmp0.w = log(tmp1.w);
                tmp0.w = tmp0.w * _Intensity;
                tmp0.w = exp(tmp0.w);
                tmp0.w = min(tmp0.w, 1.0);
                tmp1.xyz = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.xyz = tmp0.www * tmp1.xyz + _BaseColor.xyz;
                tmp2.xyz = _BaseColor.xyz - tmp0.xyz;
                tmp0.xyz = _BaseColor.xyz * tmp2.xyz + tmp0.xyz;
                tmp2.xyz = tmp0.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp3.xyz = tmp0.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp0.xyz = tmp0.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp2.xyz = tmp0.www * tmp2.xyz + tmp3.xyz;
                tmp0.xyz = tmp2.xyz * tmp0.www + tmp0.xyz;
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.xyz = max(tmp0.xyz, tmp0.www);
                tmp0.xyz = tmp0.xyz - tmp1.xyz;
                o.sv_target.xyz = _MultiBounceInfluence.xxx * tmp0.xyz + tmp1.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Blend DstColor Zero, DstColor Zero
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 2987168
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                tmp0.x = inp.texcoord.x <= 0.4985;
                if (tmp0.x) {
                    discard;
                }
                tmp0.x = inp.texcoord.x > 0.4985;
                tmp0.y = inp.texcoord.x < 0.5015;
                tmp0.x = tmp0.y ? tmp0.x : 0.0;
                if (tmp0.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                    return o;
                }
                tmp0.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp0 = tex2D(_HBAOTex, tmp0.xy);
                tmp0.x = log(tmp0.w);
                tmp0.x = tmp0.x * _Intensity;
                tmp0.x = exp(tmp0.x);
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.yzw = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                o.sv_target.xyz = tmp0.xxx * tmp0.yzw + _BaseColor.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
		Pass {
			Blend DstColor Zero, DstColor Zero
			ColorMask RGB
			ZTest Always
			ZWrite Off
			Cull Off
			GpuProgramID 3027335
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
			float4 _MainTex_TexelSize;
			// $Globals ConstantBuffers for Fragment Shader
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			CBUFFER_START(FrequentlyUpdatedUniforms)
				float _Intensity;
				float4 _BaseColor;
				float _MultiBounceInfluence;
				float4 _TargetScale;
			CBUFFER_END
			// Texture params for Vertex Shader
			// Texture params for Fragment Shader
			sampler2D _rt3Tex;
			sampler2D _HBAOTex;
			
			// Keywords: 
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                tmp0.x = _MainTex_TexelSize.y < 0.0;
                tmp0.y = 1.0 - v.texcoord.y;
                o.texcoord1.y = tmp0.x ? tmp0.y : v.texcoord.y;
                o.texcoord1 = v.texcoord.xyx;
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
                float4 tmp2;
                float4 tmp3;
                tmp0.x = inp.texcoord.x <= 0.4985;
                if (tmp0.x) {
                    discard;
                }
                tmp0.x = inp.texcoord.x > 0.4985;
                tmp0.y = inp.texcoord.x < 0.5015;
                tmp0.x = tmp0.y ? tmp0.x : 0.0;
                if (tmp0.x) {
                    o.sv_target = float4(0.0, 0.0, 0.0, 0.0);
                    return o;
                }
                tmp0 = tex2D(_rt3Tex, inp.texcoord1.xy);
                tmp1.xy = inp.texcoord1.xy * _TargetScale.zw;
                tmp1 = tex2D(_HBAOTex, tmp1.xy);
                tmp0.w = log(tmp1.w);
                tmp0.w = tmp0.w * _Intensity;
                tmp0.w = exp(tmp0.w);
                tmp0.w = min(tmp0.w, 1.0);
                tmp1.xyz = float3(1.0, 1.0, 1.0) - _BaseColor.xyz;
                tmp1.xyz = tmp0.www * tmp1.xyz + _BaseColor.xyz;
                tmp2.xyz = _BaseColor.xyz - tmp0.xyz;
                tmp0.xyz = _BaseColor.xyz * tmp2.xyz + tmp0.xyz;
                tmp2.xyz = tmp0.xyz * float3(2.0404, 2.0404, 2.0404) + float3(-0.3324, -0.3324, -0.3324);
                tmp3.xyz = tmp0.xyz * float3(-4.7951, -4.7951, -4.7951) + float3(0.6417, 0.6417, 0.6417);
                tmp0.xyz = tmp0.xyz * float3(2.7552, 2.7552, 2.7552) + float3(0.6903, 0.6903, 0.6903);
                tmp2.xyz = tmp0.www * tmp2.xyz + tmp3.xyz;
                tmp0.xyz = tmp2.xyz * tmp0.www + tmp0.xyz;
                tmp0.xyz = tmp0.www * tmp0.xyz;
                tmp0.xyz = max(tmp0.xyz, tmp0.www);
                tmp0.xyz = tmp0.xyz - tmp1.xyz;
                o.sv_target.xyz = _MultiBounceInfluence.xxx * tmp0.xyz + tmp1.xyz;
                o.sv_target.w = 0.0;
                return o;
			}
			ENDCG
		}
	}
}