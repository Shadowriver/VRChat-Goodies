//Hu In Heat the normal map based distorition shader By Shadowriver

Shader "Shadowriver/Hu In Heat" {
	Properties
	{

		//I implmented range sliders for easier use, feel free to change ranges if you like 

		[KeywordEnum(Mesh,Screen)] _UVMode ("UV Map Source", Float) = 0.0

		//Channel A Property set
		[Normal]_NormalMapA ("Normal Map A", 2D) = "white" {}
		_ScaleMapA ("Scale Map A", 2D) = "white" {}
		_ScaleA ("Distortion Scale", Range(0.0,10.0)) = 1.0
		[MaterialToggle] _InvertA ("Invert Normal Map", Float) = 0.0
		[MaterialToggle] _ApplyZA ("Apply Z angle", Float) = 1.0
		_PanningXA ("Panning X", Range(-10.0,10.0)) = 1.0
		_PanningYA ("Panning Y", Range(-10.0,10.0)) = 0.0
		_AngleA ("Angle", Range(-180.0,180.0)) = 0.0
		_RotationA ("Rotation", Range(-10.0,10.0)) = 0.0
		_WaveXA ("Wave Amplitude X", Range(-3.0,3.0)) = 0.0
		_WaveFreqXA ("Wave Frequency X", Range(0.0,50.0)) = 1.0
		_WaveOffsetXA ("Wave Offset X", Range(0.0,1.0)) = 0.0
		_WaveYA ("Wave Amplitude Y", Range(-3.0,3.0)) = 0.0
		_WaveFreqYA ("Wave Frequency Y", Range(0.0,50.0)) = 1.0
		_WaveOffsetYA ("Wave Offset Y", Range(0.0,1.0)) = 0.0
		////////////////////////////////////////////////////////

		[KeywordEnum(Add,Substract,Multiply,Minimum,Maximum,OnlyA,OnlyB)] _ABOperation ("A <-> B Operation", Float) = 0.0

		//Channel B Property set (delete if not needed)
		[Normal]_NormalMapB ("Normal Map B", 2D) = "black" {}
		_ScaleMapB ("Scale Map B", 2D) = "white" {}
		_ScaleB ("Distortion Scale", Range(0.0,10.0)) = 0.0
		[MaterialToggle] _InvertB ("Invert Normal Map", Float) = 0.0
		[MaterialToggle] _ApplyZB ("Apply Z angle", Float) = 1.0
		_PanningXB ("Panning X", Range(-10.0,10.0)) = 1.0
		_PanningYB ("Panning Y", Range(-10.0,10.0)) = 0.0
		_AngleB ("Angle", Range(-180.0,180.0)) = 0.0
		_RotationB ("Rotation", Range(-10.0,10.0)) = 0.0
		_WaveXB ("Wave Amplitude X", Range(-3.0,3.0)) = 0.0
		_WaveFreqXB ("Wave Frequency X", Range(0.0,50.0)) = 1.0
		_WaveOffsetXB ("Wave Offset X", Range(0.0,1.0)) = 0.0
		_WaveYB ("Wave Amplitude Y", Range(-3.0,3.0)) = 0.0
		_WaveFreqYB ("Wave Frequency Y", Range(0.0,50.0)) = 1.0
		_WaveOffsetYB ("Wave Offset Y", Range(0.0,1.0)) = 0.0
		////////////////////////////////////////////////////////

	}
	SubShader {
	    Tags {
            "Queue" = "Transparent"
        }

        GrabPass
        {
        	"bg"
        }

        CGPROGRAM


        #pragma surface surf Lambert

        struct Input {
            float4 color : COLOR;
        };
        void surf(Input IN, inout SurfaceOutput o) {
            o.Albedo = 0;
        }
        ENDCG
		Pass {

			CGPROGRAM
			#pragma fragment frag
			#pragma vertex vert
			#pragma multi_compile _UVMODE_MESH _UVMODE_SCREEN
			#pragma multi_compile _ABOPERATION_ADD _ABOPERATION_SUBSTRACT _ABOPERATION_MULTIPLY _ABOPERATION_MINIMUM _ABOPERATION_MAXIMUM _ABOPERATION_ONLYA _ABOPERATION_ONLYB
			#include "UnityCG.cginc"   
			#include "UnityCG.cginc"   

			float4 _NormalMapA_ST;//Only one needed as B will produce same UV anyway
			sampler2D bg;

			//Channel A property declerations
			sampler2D _NormalMapA;
			sampler2D _ScaleMapA;
			float _ScaleA;
			float _PanningXA;
			float _PanningYA;
			float _WaveXA;
			float _WaveYA;
			float _WaveFreqXA;
			float _WaveFreqYA;
			float _WaveOffsetXA;
			float _WaveOffsetYA;
			float _InvertA;
			float _AngleA;
			float _RotationA;
			float _ApplyZA;
			//////////////////////////////////

			//Channel B property declerations (delete if you not using B)
			sampler2D _NormalMapB;
			sampler2D _ScaleMapB;
			float _ScaleB;
			float _PanningXB;
			float _PanningYB;
			float _WaveXB;
			float _WaveYB;
			float _WaveFreqXB;
			float _WaveFreqYB;
			float _WaveOffsetXB;
			float _WaveOffsetYB;
			float _InvertB;
			float _AngleB;
			float _RotationB;
			float _ApplyZB;
			/////////////////////////////////////////////////////////////

			struct vertInput {
        		float4 pos : POSITION;
        		float2 uv : TEXCOORD0;
    		};  

    		struct vertOutput {
        		float4 pos : SV_POSITION;
        		float2 uv : TEXCOORD0;
        		float4 screenPos : TEXCOORD1;
        		float4 objPos : TEXCOORD2;
    		};

    		vertOutput vert(vertInput input) {
        		vertOutput o;
        		o.pos = UnityObjectToClipPos(input.pos);
        		o.screenPos = ComputeScreenPos(o.pos);
        		o.uv = TRANSFORM_TEX(input.uv, _NormalMapA);
        		o.objPos = mul (unity_ObjectToWorld, input.pos);

        		return o;
    		}


			half4 frag(vertOutput output) : COLOR {

				float2 screenPos = output.screenPos.xy/output.screenPos.w;

				float2 ratio = float2(0.0,0.0);
				float2 panningA = float2(_PanningXA,_PanningYA);
				float2 panningB = float2(_PanningXB,_PanningYB);

				//UV map computations

				#if _UVMODE_MESH
				float2 normaluv = output.uv;
				#endif

				#if _UVMODE_SCREEN && UNITY_SINGLE_PASS_STEREO
				ratio = _ScreenParams.zw/max(_ScreenParams.z/2,_ScreenParams.w);
				screenPos *= ratio;
				screenPos.x -= unity_StereoScaleOffset[unity_StereoEyeIndex].z;
				screenPos.y -= unity_StereoScaleOffset[unity_StereoEyeIndex].w;
				screenPos.x += (unity_StereoEyeIndex*(0.056));
				screenPos /= unity_StereoScaleOffset[unity_StereoEyeIndex].xy;
				#else
				ratio = _ScreenParams.zw/max(_ScreenParams.z,_ScreenParams.w);
				screenPos *= ratio;
				#endif

				#if _UVMODE_SCREEN
				float2 normaluv = screenPos;
				#endif

				float2 normaluvA = normaluv;
				float2 normaluvB = normaluv;

				//Computing Channel A normal map
				normaluvA -= 0.5;
				//Applying Rotation
				float rotA = _AngleA / (180.0 / UNITY_PI);
				rotA += (_Time*(_RotationA * 25.0));
				normaluvA = mul(normaluvA, float2x2(cos(rotA), sin(rotA), -sin(rotA),cos(rotA)));
				//Applying Wave
				float2 waveuvA;
				waveuvA.x = sin((normaluvA.y + _WaveOffsetXA)*(_WaveFreqXA * UNITY_PI)) * _WaveXA;
				waveuvA.y = sin((normaluvA.x + _WaveOffsetYA)*(_WaveFreqYA * UNITY_PI)) * _WaveYA;
				normaluvA += (normaluvA + 0.5) + waveuvA;
				normaluvA += _Time * panningA; //Panning

				float4 scalemapA = tex2D(_ScaleMapA, normaluv);
				float4 normalA = tex2D(_NormalMapA,normaluvA);
				if(_InvertA > 0.5) normalA.xy = 1.0 - normalA.xy;
				normalA.z = (normalA.z - 0.5) * (2.0 * _ApplyZA);
				normalA.z = 1.0-normalA.z;
				normalA.x = ((((normalA.x - 0.5) / 50.0) * 2.0)) * ((_ScaleA * normalA.z) * scalemapA.x);
				normalA.y = ((((normalA.y - 0.5) / 50.0) * 2.0)) * ((_ScaleA * normalA.z) * scalemapA.y);
				//////////////////////////////////////

				//Computing Channel B normal map
				normaluvB -= 0.5;
				//Applying Rotation
				float rotB = _AngleB/(180.0/UNITY_PI);
				rotB += (_Time*(_RotationB * 25.0));
				normaluvB = mul(normaluvB, float2x2(cos(rotB), sin(rotB), -sin(rotB),cos(rotB)));
				//Applying Wave
				float2 waveuvB;
				waveuvB.x = sin((normaluvA.y + _WaveOffsetXB) * (_WaveFreqXB * UNITY_PI)) * _WaveXB;
				waveuvB.y = sin((normaluvA.x + _WaveOffsetYB) * (_WaveFreqYB * UNITY_PI)) * _WaveYB;
				normaluvB += (normaluvB + 0.5) + waveuvB;
				normaluvB += _Time*panningB; //Panning

				float4 scalemapB = tex2D(_ScaleMapB,normaluv);
				float4 normalB = tex2D(_NormalMapB,normaluvB);
				if(_InvertB > 0.5) normalB.xy = 1.0 - normalB.xy;
				normalB.z = (normalB.z - 0.5) * (2.0 * _ApplyZB);
				normalB.z = 1.0-normalB.z;
				normalB.x = ((((normalB.x - 0.5) / 50) * 2.0)) * ((_ScaleB * normalB.z) * scalemapB.x);
				normalB.y = ((((normalB.y - 0.5) / 50) * 2.0)) * ((_ScaleB * normalB.z) * scalemapB.y);
				//////////////////////////////////////


				//Applying channels toghther, if you not using B delete entire section with #if s and uncomment line before return

				#if _ABOPERATION_ADD 
				screenPos += normalA.xy + normalB.xy;
				#endif

				#if _ABOPERATION_SUBSTRACT 
				screenPos += normalA.xy - normalB.xy;
				#endif

				#if _ABOPERATION_MULTIPLY 
				screenPos += normalA.xy * normalB.xy;
				#endif

				#if _ABOPERATION_MINIMUM 
				screenPos += min(normalA.xy,normalB.xy);
				#endif

				#if _ABOPERATION_MAXIMUM 
				screenPos += max(normalA.xy,normalB.xy);
				#endif

				#if _ABOPERATION_ONLYA
				screenPos += normalA.xy;
				#endif

				#if _ABOPERATION_ONLYB
				screenPos += normalB.xy;
				#endif

				//screenPos += normalA.xy;

	        	return tex2D(bg, screenPos);

	    	}
			ENDCG
		} 
	}

}