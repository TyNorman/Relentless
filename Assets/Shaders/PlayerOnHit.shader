﻿Shader "Custom/PlayerOnHit" 
{
	//=================================================================================================================================================
	//	THE FOLLOWING IS A MODIFIED VERSION OF UNITY'S DEFAULT 'Sprites-PixelSnap-AlphaBlended' SHADER.
	//	MODIFICATIONS PRIMARILY EXIST WITHIN THE FRAGMENT SHADER, PROPERTIES, AND BEGINNING OF SUBSHADER FOR RAD AS FUCK VISUAL EFFECTS
	//=================================================================================================================================================

	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Main Color", Color) = (1,1,1,1)
		_OutlineColour ("Outline Colour", Color) = (0, 0, 0, 0)
		_FillColour ("Fill Colour", Color) = (0, 0, 0, 0)
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest Always
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float4 _OutlineColour;
			float4 _FillColour;

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex        : POSITION;
				float2 texcoord      : TEXCOORD0;
			};

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
				OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);

				// Snapping params
				float hpcX = _ScreenParams.x * 0.5;
				float hpcY = _ScreenParams.y * 0.5;
			#ifdef UNITY_HALF_TEXEL_OFFSET
				float hpcOX = -0.5;
				float hpcOY = 0.5;
			#else
				float hpcOX = 0;
				float hpcOY = 0;
			#endif	
				// Snap
				float pos = floor((OUT.vertex.x / OUT.vertex.w) * hpcX + 0.5f) + hpcOX;
				OUT.vertex.x = pos / hpcX * OUT.vertex.w;

				pos = floor((OUT.vertex.y / OUT.vertex.w) * hpcY + 0.5f) + hpcOY;
				OUT.vertex.y = pos / hpcY * OUT.vertex.w;

				return OUT;
			}

			fixed4 frag(v2f IN) : COLOR
			{
				//The following code checks for desired colour values and replaces them according to external scripts (ex. timers)
				float4 result = tex2D( _MainTex, IN.texcoord) * _Color;

				if(result.r < 0.15 && result.g < 0.15 && result.b < 0.15) //Replace dark outlines with the Outline Colour
				{
					result.r = clamp(result.r + _OutlineColour.r, 0, 1);
					result.g = clamp(result.g + _OutlineColour.g, 0, 1);
					result.b = clamp(result.b + _OutlineColour.b, 0, 1);
				}
				else //Replace all other colours with the Fill Colour
				{
					result.r = clamp(result.r + _FillColour.r, 0, 1);
					result.g = clamp(result.g + _FillColour.g, 0, 1);
					result.b = clamp(result.b + _FillColour.b, 0, 1);
				}

				return result;
			}
		ENDCG
		}
	}

}