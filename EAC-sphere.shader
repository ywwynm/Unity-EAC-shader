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
					if (lo <= 1.25 * pi) {
						u = 5.0 - 4.0 * lo / pi;
						v = 5.0 - 4.0 * la / pi;
					} else if (lo >= 1.75 * pi && lo <= 2.0 * pi) {
						u = 13.0 - 4.0 * lo / pi;
						v = 5.0 - 4.0 * la / pi;
					} else { // back
						v = 4.0 * lo / pi - 5.0;
            u = 5.0 - 4.0 * la / pi;
					}
				} else if (la < 0.25 * pi) {
					float t = la * 4.0 / pi;
					if (lo <= 0.25 * pi) {
						v = 1 + t;
						u = 5 + lo * 4 * t / pi;
					} else if (lo <= 0.75 * pi) {
						u = 5 + t;
						v = 1 + (0.5 * pi - lo) * 4 * t / pi;
					} else if (lo <= 1.25 * pi) {
						v = 1 - t;
						u = 5 + (pi - lo) * 4 * t / pi;
					} else if (lo <= 1.75 * pi) {
						u = 5 - t;
						v = 1 + (lo - 1.5 * pi) * 4 * t / pi;
					} else {
						v = 1 + t;
						u = 5 - (2 * pi - lo) * 4 * t / pi;
					}
				} else { // bottom
					float t = 4.0 - la * 4 / pi;
					if (lo <= 0.25 * pi) {
						v = 1 + t;
						u = 1 - t * lo * 4 / pi;
					} else if (lo <= 0.75 * pi) {
						u = 1 - t;
						v = 1 - (lo - 0.5 * pi) * 4 * t / pi;
					} else if (lo <= 1.25 * pi) {
						v = 1 - t;
						u = 1 - (pi - lo) * 4 * t / pi;
					} else if (lo <= 1.75 * pi) {
						u = 1 + t;
						v = 1 + (lo - 1.5 * pi) * 4 * t / pi;
					} else {
						v = 1 + t;
						u = 1 + (2.0 * pi - lo) * 4 * t / pi;
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
