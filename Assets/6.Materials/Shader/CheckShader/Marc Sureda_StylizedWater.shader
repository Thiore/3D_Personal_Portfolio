Shader "Marc Sureda/StylizedWater" {
	Properties {
		_DepthGradient1 ("DepthGradient1", Color) = (0.1098039,0.5960785,0.6196079,1)
		_DepthGradient2 ("DepthGradient2", Color) = (0.05882353,0.1960784,0.4627451,1)
		_DepthGradient3 ("DepthGradient3", Color) = (0,0.0625,0.25,1)
		_GradientPosition1 ("GradientPosition1", Float) = 1.6
		_GradientPosition2 ("GradientPosition2", Float) = 2
		_FresnelColor ("FresnelColor", Color) = (0.5764706,0.6980392,0.8000001,1)
		_FresnelExp ("FresnelExp", Range(0, 10)) = 10
		_Roughness ("Roughness", Range(0.01, 1)) = 0.6357628
		_LightColorIntensity ("LightColorIntensity", Range(0, 1)) = 0.7759457
		_SpecularIntensity ("SpecularIntensity", Range(0, 1)) = 1
		_FoamColor ("FoamColor", Color) = (0.854902,0.9921569,1,1)
		_MainFoamScale ("Main Foam Scale", Float) = 40
		_MainFoamIntensity ("Main Foam Intensity", Range(0, 10)) = 3.84466
		_MainFoamSpeed ("Main Foam Speed", Float) = 0.1
		_MainFoamOpacity ("Main Foam Opacity", Range(0, 1)) = 0.8737864
		_SecondaryFoamScale ("Secondary Foam Scale", Float) = 40
		_SecondaryFoamIntensity ("Secondary Foam Intensity", Range(0, 10)) = 2.330097
		_SecondaryFoamOpacity ("Secondary Foam Opacity", Range(0, 1)) = 0.6310679
		[MaterialToggle] _SecondaryFoamAlwaysVisible ("Secondary Foam Always Visible", Float) = 1
		_TurbulenceDistortionIntesity ("Turbulence Distortion Intesity", Range(0, 6)) = 0.8155341
		_TurbulenceScale ("Turbulence Scale", Float) = 10
		_WaveDistortionIntensity ("WaveDistortion Intensity", Range(0, 4)) = 0.592233
		_WavesDirection ("Waves Direction", Range(0, 360)) = 0
		_WavesAmplitude ("Waves Amplitude", Range(0, 10)) = 4.980582
		_WavesSpeed ("Waves Speed", Float) = 1
		_WavesIntensity ("Waves Intensity", Float) = 2
		[MaterialToggle] _VertexOffset ("Vertex Offset", Float) = 0
		[MaterialToggle] _RealTimeReflection ("Real Time Reflection", Float) = 0
		_ReflectionsIntensity ("ReflectionsIntensity", Range(0, 3)) = 1
		_OpacityDepth ("OpacityDepth", Float) = 5
		_Opacity ("Opacity", Range(0, 1)) = 0.7378641
		_RefractionIntensity ("Refraction Intensity", Float) = 1
		_DistortionTexture ("DistortionTexture", 2D) = "white" {}
		_FoamTexture ("FoamTexture", 2D) = "white" {}
		_ReflectionTex ("ReflectionTex", 2D) = "white" {}
		[HideInInspector] _Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags { "IGNOREPROJECTOR" = "true" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" }
		GrabPass {
			"Refraction"
		}
		Pass {
			Name "FORWARD"
			Tags { "IGNOREPROJECTOR" = "true" "LIGHTMODE" = "FORWARDBASE" "PreviewType" = "Plane" "QUEUE" = "Transparent" "RenderType" = "Transparent" "SHADOWSUPPORT" = "true" }
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			GpuProgramID 2985
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			struct v2f
			{
				float4 position : SV_POSITION0;
				float2 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				float3 texcoord2 : TEXCOORD2;
				float4 texcoord3 : TEXCOORD3;
				float4 texcoord4 : TEXCOORD4;
			};
			struct fout
			{
				float4 sv_target : SV_Target0;
			};
			// $Globals ConstantBuffers for Vertex Shader
			float4 _TimeEditor;
			float4 _DistortionTexture_ST;
			float _WavesDirection;
			float _WavesSpeed;
			float _VertexOffset;
			float _WavesAmplitude;
			float _WavesIntensity;
			// $Globals ConstantBuffers for Fragment Shader
			float4 _LightColor0;
			float4 _DepthGradient2;
			float4 _FoamColor;
			float4 _FresnelColor;
			float _MainFoamIntensity;
			float _FresnelExp;
			float4 _ReflectionTex_ST;
			float _MainFoamScale;
			float _SecondaryFoamScale;
			float _SecondaryFoamIntensity;
			float _SecondaryFoamAlwaysVisible;
			float _SecondaryFoamOpacity;
			float _MainFoamOpacity;
			float _RealTimeReflection;
			float _WaveDistortionIntensity;
			float4 _DepthGradient1;
			float _MainFoamSpeed;
			float _GradientPosition1;
			float _GradientPosition2;
			float4 _DepthGradient3;
			float _TurbulenceDistortionIntesity;
			float _TurbulenceScale;
			float _ReflectionsIntensity;
			float _LightColorIntensity;
			float _Roughness;
			float _SpecularIntensity;
			float _OpacityDepth;
			float _Opacity;
			float _RefractionIntensity;
			float4 _FoamTexture_ST;
			// Custom ConstantBuffers for Vertex Shader
			// Custom ConstantBuffers for Fragment Shader
			// Texture params for Vertex Shader
			sampler2D _DistortionTexture;
			// Texture params for Fragment Shader
			sampler2D _CameraDepthTexture;
			sampler2D Refraction;
			sampler2D _ReflectionTex;
			sampler2D _FoamTexture;
			
			// Keywords: DIRECTIONAL
			v2f vert(appdata_full v)
			{
                v2f o;
                float4 tmp0;
                float4 tmp1;
                float4 tmp2;
                tmp0.x = _WavesDirection * 0.0175439;
                tmp0.x = sin(tmp0.x);
                tmp1.x = cos(tmp0.x);
                tmp2.z = tmp0.x;
                tmp0.yz = v.texcoord.xy - float2(0.5, 0.5);
                tmp2.y = tmp1.x;
                tmp2.x = -tmp0.x;
                tmp1.y = dot(tmp0.xy, tmp2.xy);
                tmp1.x = dot(tmp0.xy, tmp2.xy);
                tmp0.xy = tmp1.xy + float2(0.5, 0.5);
                tmp0.xy = tmp0.xy * _DistortionTexture_ST.xy + _DistortionTexture_ST.zw;
                tmp0 = tex2Dlod(_DistortionTexture, float4(tmp0.xy, 0, 0.0));
                tmp0.x = tmp0.z * _WavesAmplitude;
                tmp0.x = tmp0.x * 30.0;
                tmp0.y = _TimeEditor.y + _Time.y;
                tmp0.x = tmp0.y * _WavesSpeed + -tmp0.x;
                tmp0.x = sin(tmp0.x);
                tmp0.x = tmp0.x * _WavesIntensity;
                tmp0.x = tmp0.x * 0.4;
                tmp0.xyz = tmp0.xxx * v.normal.xyz;
                tmp0.xyz = _VertexOffset.xxx * tmp0.xyz + v.vertex.xyz;
                tmp1 = tmp0.yyyy * unity_ObjectToWorld._m01_m11_m21_m31;
                tmp1 = unity_ObjectToWorld._m00_m10_m20_m30 * tmp0.xxxx + tmp1;
                tmp0 = unity_ObjectToWorld._m02_m12_m22_m32 * tmp0.zzzz + tmp1;
                tmp1 = tmp0 + unity_ObjectToWorld._m03_m13_m23_m33;
                o.texcoord1 = unity_ObjectToWorld._m03_m13_m23_m33 * v.vertex.wwww + tmp0;
                tmp0 = tmp1.yyyy * unity_MatrixVP._m01_m11_m21_m31;
                tmp0 = unity_MatrixVP._m00_m10_m20_m30 * tmp1.xxxx + tmp0;
                tmp0 = unity_MatrixVP._m02_m12_m22_m32 * tmp1.zzzz + tmp0;
                tmp0 = unity_MatrixVP._m03_m13_m23_m33 * tmp1.wwww + tmp0;
                o.position = tmp0;
                o.texcoord.xy = v.texcoord.xy;
                tmp2.x = dot(v.normal.xyz, unity_WorldToObject._m00_m10_m20);
                tmp2.y = dot(v.normal.xyz, unity_WorldToObject._m01_m11_m21);
                tmp2.z = dot(v.normal.xyz, unity_WorldToObject._m02_m12_m22);
                tmp2.w = dot(tmp2.xyz, tmp2.xyz);
                tmp2.w = rsqrt(tmp2.w);
                o.texcoord2.xyz = tmp2.www * tmp2.xyz;
                o.texcoord3 = tmp0;
                tmp0.z = tmp1.y * unity_MatrixV._m21;
                tmp0.z = unity_MatrixV._m20 * tmp1.x + tmp0.z;
                tmp0.z = unity_MatrixV._m22 * tmp1.z + tmp0.z;
                tmp0.z = unity_MatrixV._m23 * tmp1.w + tmp0.z;
                o.texcoord4.z = -tmp0.z;
                tmp0.y = tmp0.y * _ProjectionParams.x;
                tmp1.xzw = tmp0.xwy * float3(0.5, 0.5, 0.5);
                o.texcoord4.w = tmp0.w;
                o.texcoord4.xy = tmp1.zz + tmp1.xw;
                return o;
			}
			// Keywords: DIRECTIONAL
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
                tmp0.x = _WavesDirection * 0.0175439;
                tmp0.x = sin(tmp0.x);
                tmp1.x = cos(tmp0.x);
                tmp2.z = tmp0.x;
                tmp0.yz = inp.texcoord.xy - float2(0.5, 0.5);
                tmp2.y = tmp1.x;
                tmp2.x = -tmp0.x;
                tmp1.y = dot(tmp0.xy, tmp2.xy);
                tmp1.x = dot(tmp0.xy, tmp2.xy);
                tmp0.xy = tmp1.xy + float2(0.5, 0.5);
                tmp0.xy = tmp0.xy * _DistortionTexture_ST.xy + _DistortionTexture_ST.zw;
                tmp0 = tex2D(_DistortionTexture, tmp0.xy);
                tmp0.x = tmp0.z * _WavesAmplitude;
                tmp0.x = tmp0.x * 30.0;
                tmp0.y = _TimeEditor.y + _Time.y;
                tmp0.x = tmp0.y * _WavesSpeed + -tmp0.x;
                tmp0.x = sin(tmp0.x);
                tmp0.z = tmp0.x * _WavesIntensity;
                tmp0.x = tmp0.x * 0.1 + 0.2;
                tmp0.z = tmp0.z * _WaveDistortionIntensity;
                tmp0.w = tmp0.y * 0.01;
                tmp0.y = tmp0.y * _MainFoamSpeed;
                tmp1.xy = inp.texcoord.xy * _TurbulenceScale.xx + tmp0.ww;
                tmp1.zw = inp.texcoord.xy * _SecondaryFoamScale.xx + tmp0.ww;
                tmp1.zw = tmp1.zw * _FoamTexture_ST.xy + _FoamTexture_ST.zw;
                tmp2 = tex2D(_FoamTexture, tmp1.zw);
                tmp0.w = saturate(tmp2.x * 4.0 + -1.0);
                tmp0.w = rsqrt(tmp0.w);
                tmp0.w = 1.0 / tmp0.w;
                tmp1.xy = tmp1.xy * _DistortionTexture_ST.xy + _DistortionTexture_ST.zw;
                tmp1 = tex2D(_DistortionTexture, tmp1.xy);
                tmp1.x = dot(tmp1.xy, float2(_TurbulenceDistortionIntesity.x, _TurbulenceScale.x));
                tmp0.z = tmp0.z * 0.5 + tmp1.x;
                tmp1.xy = tmp0.zz * inp.texcoord.xy;
                tmp1.z = _RefractionIntensity * 0.01;
                tmp1.xy = tmp1.xy * tmp1.zz;
                tmp1.xy = tmp1.xy + tmp1.xy;
                tmp1.z = _ProjectionParams.x * -_ProjectionParams.x;
                tmp2.xy = inp.texcoord3.xy / inp.texcoord3.ww;
                tmp2.z = tmp1.z * tmp2.y;
                tmp1.xy = tmp2.xz * float2(0.5, 0.5) + tmp1.xy;
                tmp1.xy = tmp1.xy + float2(0.5, 0.5);
                tmp1.zw = tmp0.zz * float2(0.01, 0.01) + tmp1.xy;
                tmp2 = tex2D(Refraction, tmp1.xy);
                tmp0.z = tmp0.z / _Roughness;
                tmp0.z = tmp0.z * 0.8 + 0.2;
                tmp1.xy = tmp1.zw * _ReflectionTex_ST.xy + _ReflectionTex_ST.zw;
                tmp1 = tex2D(_ReflectionTex, tmp1.xy);
                tmp1.xyz = tmp1.xyz * _ReflectionsIntensity.xxx;
                tmp1.xyz = tmp1.xyz * float3(0.3, 0.3, 0.3);
                tmp3.xy = inp.texcoord4.xy / inp.texcoord4.ww;
                tmp3 = tex2D(_CameraDepthTexture, tmp3.xy);
                tmp1.w = _ZBufferParams.z * tmp3.x + _ZBufferParams.w;
                tmp1.w = 1.0 / tmp1.w;
                tmp1.w = tmp1.w - _ProjectionParams.y;
                tmp1.w = max(tmp1.w, 0.0);
                tmp2.w = inp.texcoord4.z - _ProjectionParams.y;
                tmp2.w = max(tmp2.w, 0.0);
                tmp1.w = tmp1.w - tmp2.w;
                tmp2.w = _GradientPosition2 + _GradientPosition1;
                tmp2.w = saturate(tmp1.w / tmp2.w);
                tmp3.x = tmp2.w * tmp2.w;
                tmp2.w = tmp2.w * tmp3.x;
                tmp3.xyz = _DepthGradient3.xyz - _DepthGradient2.xyz;
                tmp3.xyz = tmp2.www * tmp3.xyz + _DepthGradient2.xyz;
                tmp3.xyz = tmp3.xyz - _DepthGradient1.xyz;
                tmp2.w = saturate(tmp1.w / _GradientPosition1);
                tmp3.xyz = tmp2.www * tmp3.xyz + _DepthGradient1.xyz;
                tmp4.xyz = _FresnelColor.xyz - tmp3.xyz;
                tmp5.xyz = _WorldSpaceCameraPos - inp.texcoord1.xyz;
                tmp2.w = dot(tmp5.xyz, tmp5.xyz);
                tmp2.w = rsqrt(tmp2.w);
                tmp5.xyz = tmp2.www * tmp5.xyz;
                tmp2.w = dot(inp.texcoord2.xyz, inp.texcoord2.xyz);
                tmp2.w = rsqrt(tmp2.w);
                tmp6.xyz = tmp2.www * inp.texcoord2.xyz;
                tmp2.w = dot(tmp6.xyz, tmp5.xyz);
                tmp2.w = max(tmp2.w, 0.0);
                tmp2.w = 1.0 - tmp2.w;
                tmp2.w = log(tmp2.w);
                tmp2.w = tmp2.w * _FresnelExp;
                tmp2.w = exp(tmp2.w);
                tmp2.w = min(tmp2.w, 1.0);
                tmp3.xyz = tmp2.www * tmp4.xyz + tmp3.xyz;
                tmp1.xyz = saturate(_RealTimeReflection.xxx * tmp1.xyz + tmp3.xyz);
                tmp3.xy = inp.texcoord.xy * _MainFoamScale.xx;
                tmp3.xy = tmp0.yy * float2(0.15, 0.15) + tmp3.xy;
                tmp3.xy = tmp3.xy * _FoamTexture_ST.xy + _FoamTexture_ST.zw;
                tmp3 = tex2D(_FoamTexture, tmp3.xy);
                tmp0.y = tmp3.x * _MainFoamIntensity;
                tmp0.x = tmp0.y * tmp0.x;
                tmp0.x = saturate(tmp1.w / tmp0.x);
                tmp0.x = log(tmp0.x);
                tmp0.x = tmp0.x * 15.0;
                tmp0.x = exp(tmp0.x);
                tmp0.x = tmp0.x * 10.0;
                tmp0.x = min(tmp0.x, 1.0);
                tmp0.x = 1.0 - tmp0.x;
                tmp0.y = tmp0.x * _MainFoamOpacity;
                tmp1.xyz = _FoamColor.xyz * tmp0.yyy + tmp1.xyz;
                tmp0.y = saturate(tmp1.w / _SecondaryFoamIntensity);
                tmp1.w = saturate(tmp1.w / _OpacityDepth);
                tmp0.y = tmp0.y * 1.25;
                tmp0.y = min(tmp0.y, 1.0);
                tmp0.y = 1.0 - tmp0.y;
                tmp2.w = 1.0 - tmp0.y;
                tmp0.y = _SecondaryFoamAlwaysVisible * tmp2.w + tmp0.y;
                tmp0.y = tmp0.y * tmp0.w;
                tmp0.y = tmp0.y * _SecondaryFoamOpacity;
                tmp0.yw = tmp0.yy * float2(0.3, 0.06);
                tmp1.xyz = _FoamColor.xyz * tmp0.yyy + tmp1.xyz;
                tmp0.x = tmp0.x * _MainFoamOpacity + tmp0.w;
                tmp0.x = tmp0.x + _Opacity;
                tmp0.x = tmp1.w + tmp0.x;
                tmp0.y = dot(-tmp5.xyz, tmp6.xyz);
                tmp0.y = tmp0.y + tmp0.y;
                tmp3.xyz = tmp6.xyz * -tmp0.yyy + -tmp5.xyz;
                tmp0.y = dot(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz);
                tmp0.y = rsqrt(tmp0.y);
                tmp4.xyz = tmp0.yyy * _WorldSpaceLightPos0.xyz;
                tmp0.y = dot(tmp4.xyz, tmp3.xyz);
                tmp0.y = log(tmp0.y);
                tmp0.w = 1.0 - _Roughness;
                tmp0.w = tmp0.w * 5.0 + 5.0;
                tmp0.w = exp(tmp0.w);
                tmp0.y = tmp0.y * tmp0.w;
                tmp0.y = exp(tmp0.y);
                tmp0.y = tmp0.y + tmp0.y;
                tmp3.xyz = tmp0.yyy * _LightColor0.xyz;
                tmp0.yzw = saturate(tmp0.zzz * tmp3.xyz);
                tmp3.xyz = tmp0.yzw * _SpecularIntensity.xxx;
                tmp0.xyz = saturate(tmp0.yzw * _SpecularIntensity.xxx + tmp0.xxx);
                tmp4.xyz = max(_LightColor0.xyz, float3(0.3, 0.3, 0.3));
                tmp4.xyz = min(tmp4.xyz, float3(1.0, 1.0, 1.0));
                tmp4.xyz = tmp4.xyz - float3(1.0, 1.0, 1.0);
                tmp4.xyz = _LightColorIntensity.xxx * tmp4.xyz + float3(1.0, 1.0, 1.0);
                tmp1.xyz = tmp1.xyz * tmp4.xyz + tmp3.xyz;
                tmp1.xyz = tmp1.xyz - tmp2.xyz;
                o.sv_target.xyz = tmp0.xyz * tmp1.xyz + tmp2.xyz;
                o.sv_target.w = 1.0;
                return o;
			}
			ENDCG
		}
	}
	CustomEditor "CustomMaterialInspector"
}