Shader "Custom/EAC-sphere"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Front ZWrite Off ZTest Always // Cull front will flip normals

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
        float4 vertex : POSITION;
        float3 normal : NORMAL;
			};

			struct v2f
			{
        float4 vertex : SV_POSITION;
				float3 normal_uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal_uv = v.normal; // this will lately be transformed to real uv coordinates
				return o;
			}

      inline float2 ToRadialCoords (float3 coords)
      {
        float3 normalizedCoords = normalize(coords);
        float latitude = acos(normalizedCoords.y);
        float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
				return float2(longitude, latitude);
      }
			
			sampler2D _MainTex;

			float4 frag (v2f i) : SV_Target
			{
				float pi = UNITY_PI;
        float2 xy = ToRadialCoords(i.normal_uv); // longtitude and latitude
				float lo = xy.x;
				if (lo < 0) {
					lo = lo + 2 * pi;
				}
				float la = xy.y;
				float u = 0;
				float v = 0;

				if (la >= 0.25 * pi && la <= 0.75 * pi) {
					if (lo >= 0 && lo <= 0.25 * pi) {
						u = 5.0 - tan(lo);
					} else if (lo >= 0.25 * pi && lo <= 0.5 * pi) {
						u = 3.0 + tan(0.5 * pi - lo);
					} else if (lo >= 0.5 * pi && lo <= 0.75 * pi) {
						u = 3.0 - tan(lo - 0.5 * pi);
					} else if (lo >= 0.75 * pi && lo <= pi) {
						u = 1.0 + tan(pi - lo);
					} else if (lo >= pi && lo <= 1.25 * pi) {
						u = 1.0 - tan(lo - pi);
					} else if (lo >= 1.75 * pi && lo <= 2 * pi) {
						u = 5.0 + tan(2 * pi - lo);
					} else if (lo >= 1.25 * pi && lo <= 1.5 * pi) {
						v = 1.0 - tan(1.5 * pi - lo);
					} else {
						v = 1.0 + tan(lo - 1.5 * pi);
					}
				}
				if (la >= 0.25 * pi && la <= 0.5 * pi) {
					if ((lo >= 0 && lo <= 1.25 * pi) || (lo >= 1.75 * pi && lo <= 2 * pi)) {
						v = 3.0 + tan(0.5 * pi - la);
					} else {
						u = 3.0 + tan(0.5 * pi - la);
					}
				} else if (la >= 0.5 * pi && la <= 0.75 * pi) {
					if ((lo >= 0 && lo <= 1.25 * pi) || (lo >= 1.75 * pi && lo <= 2 * pi)) {
						v = 3.0 - tan(la - 0.5 * pi);
					} else {
						u = 3.0 - tan(la - 0.5 * pi);
					}
				} else if (la <= 0.25 * pi) {
					if (lo >= 0.25 * pi && lo <= 0.75 * pi) {
						u = 5.0 + tan(la);
						float tx = u - 5.0; // if x of center of this face is 0, and right is positive direction
						if (lo <= 0.5 * pi) {
							v = tx * tan(pi / 2.0 - lo) + 1.0;
						} else {
							v = 1.0 - tx * tan(lo - pi / 2.0);
						}
					} else if (lo >= 0.75 * pi && lo <= 1.25 * pi) {
						v = 1.0 - tan(la);
						float ty = 1.0 - v; // if y of center of this face is 0, and down is positive direction
						if (lo <= pi) {
							u = 5.0 + ty * tan(pi - lo);
						} else {
							u = 5.0 - ty * tan(lo - pi);
						}
					} else if (lo >= 1.25 * pi && lo <= 1.75 * pi) {
						u = 5.0 - tan(la);
						float tx = 5.0 - u;
						if (lo <= 1.5 * pi) {
							v = 1.0 - tx * tan(1.5 * pi - lo);
						} else {
							v = 1.0 + tx * tan(lo - 1.5 * pi);
						}
					} else {
						v = 1.0 + tan(la);
						float ty = v - 1.0;
						if (lo <= 0.25 * pi) {
							u = 5.0 + ty * tan(lo);
						} else {
							u = 5.0 - ty * tan(2 * pi - lo);
						}
					}
				} else {
					if (lo >= 0.25 * pi && lo <= 0.75 * pi) {
						u = 1.0 - tan(pi - la);
						float tx = 1.0 - u;
						if (lo <= 0.5 * pi) {
							v = 1.0 + tx * tan(pi / 2.0 - lo);
						} else {
							v = 1.0 - tx * tan(lo - pi / 2.0);
						}
					} else if (lo >= 0.75 * pi && lo <= 1.25 * pi) {
						v = 1.0 - tan(pi - la);
						float ty = 1.0 - v;
						if (lo <= pi) {
							u = 1.0 - ty * tan(pi - lo);
						} else {
							u = 1.0 + ty * tan(lo - pi);
						}
					} else if (lo >= 1.25 * pi && lo <= 1.75 * pi) {
						u = 1.0 + tan(pi - la);
						float tx = u - 1.0;
						if (lo <= 1.5 * pi) {
							v = 1.0 - tx * tan(1.5 * pi - lo);
						} else {
							v = 1.0 + tx * tan(lo - 1.5 * pi);
						}
					} else {
						v = 1.0 + tan(pi - la);
						float ty = v - 1.0;
						if (lo <= 0.25 * pi) {
							u = 1.0 - ty * tan(lo);
						} else {
							u = 1.0 + ty * tan(2.0 * pi - lo);
						}
					}
				}

				u = u / 6.0;
				v = v / 4.0;
				
        return tex2D(_MainTex, float2(u, v));
			}
			ENDCG
		}
	}
}
