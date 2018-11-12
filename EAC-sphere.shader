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

				if (la >= 0.25 * pi && la <= 0.75 * pi) { // left, front, right and back
					if (lo >= 0.25 * pi && lo <= 0.75 * pi) { // front
						u = 3.0 + tan(0.5 * pi - lo);
					} else if (lo >= 0.75 * pi && lo <= 1.25 * pi) { // left
						u = 1.0 + tan(pi - lo);
					} else if (lo >= 1.25 * pi && lo <= 1.75 * pi) { // back
            v = 1.0 + tan(lo - 1.5 * pi);
          } else { // [0, 0.25pi] and [1.75pi, 2pi], right
						u = 5.0 - tan(lo);
					}

          if ((lo >= 0 && lo <= 1.25 * pi) || (lo >= 1.75 * pi && lo <= 2 * pi)) { // left, front and right
						v = 3.0 + tan(0.5 * pi - la);
					} else { // back
						u = 3.0 + tan(0.5 * pi - la);
					}
				} else if (la <= 0.25 * pi) { // top
          float t = tan(la);
					if (lo >= 0.25 * pi && lo <= 0.75 * pi) { // right quarter of texture square, top of front direction
						u = 5.0 + t;
            v = 1.0 + t * tan(0.5 * pi - lo);
					} else if (lo >= 0.75 * pi && lo <= 1.25 * pi) { // bottom quarter of texture square, top of left direction
						u = 5.0 - t * tan(lo - pi);
						v = 1.0 - t;
					} else if (lo >= 1.25 * pi && lo <= 1.75 * pi) { // left quarter of texture square, top of back direction
						u = 5.0 - t;
						v = 1.0 - t * tan(1.5 * pi - lo);
					} else { // top quarter of texture square, top of right direction
						u = 5.0 + t * tan(lo);
						v = 1.0 + t;
					}
				} else { // bottom
          float t = tan(pi - la);
					if (lo >= 0.25 * pi && lo <= 0.75 * pi) { // left quarter of texture square, bottom of front direction
						u = 1.0 - t;
            v = 1.0 - t * tan(lo - 0.5 * pi);
					} else if (lo >= 0.75 * pi && lo <= 1.25 * pi) { // bottom quarter of texture square, bottom of left direction
						v = 1.0 - t;
            u = 1.0 - t * tan(pi - lo);
					} else if (lo >= 1.25 * pi && lo <= 1.75 * pi) { // right quarter of texture square, bottom of back direction
						u = 1.0 + t;
            v = 1.0 + t * tan(lo - 1.5 * pi);
					} else { // top quarter of texture square, bottom of right direction
						v = 1.0 + t;
						u = 1.0 + t * tan(2.0 * pi - lo);
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
