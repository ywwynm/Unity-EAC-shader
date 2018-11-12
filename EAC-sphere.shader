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

        float D_1_4_M_PI = 0.785398163397448309615;
        float D_3_4_M_PI = 2.356194490192344928845;
        float D_5_4_M_PI = 3.926990816987241548075;
        float D_7_4_M_PI = 5.497787143782138167305;
        float D_1_2_M_PI = 1.570796326794896619230;
        float D_3_2_M_PI = 4.712388980384689857690;
        float M_2_PI     = 6.283185307179586476920;
        float D_4_PI     = 1.273239544735162686152;

				if (la >= D_1_4_M_PI && la <= D_3_4_M_PI) { // left, front, right and back
					if (lo <= D_5_4_M_PI) {
						u = 5.0 - D_4_PI * lo;
						v = 5.0 - D_4_PI * la;
					} else if (lo >= 1.75 * pi && lo <= 2.0 * pi) {
						u = 13.0 - D_4_PI * lo;
						v = 5.0  - D_4_PI * la;
					} else { // back
						v = D_4_PI * lo - 5.0;
            u = 5.0 - D_4_PI * la;
					}
				} else if (la < D_1_4_M_PI) { // top
					float t = la * D_4_PI;
					if (lo <= D_1_4_M_PI) {
						v = 1 + t;
						u = 5 + lo * t * D_4_PI;
					} else if (lo <= D_3_4_M_PI) {
						u = 5 + t;
						v = 1 + (D_1_2_M_PI - lo) * t * D_4_PI;
					} else if (lo <= D_5_4_M_PI) {
						v = 1 - t;
						u = 5 + (pi - lo) * t * D_4_PI;
					} else if (lo <= D_7_4_M_PI) {
						u = 5 - t;
						v = 1 + (lo - D_3_2_M_PI) * t * D_4_PI;
					} else {
						v = 1 + t;
						u = 5 - (M_2_PI - lo) * t * D_4_PI;
					}
				} else { // bottom
					float t = 4.0 - la * D_4_PI;
					if (lo <= D_1_4_M_PI) {
						v = 1 + t;
						u = 1 - t * lo * D_4_PI;
					} else if (lo <= D_3_4_M_PI) {
						u = 1 - t;
						v = 1 - (lo - D_1_2_M_PI) * t * D_4_PI;
					} else if (lo <= D_5_4_M_PI) {
						v = 1 - t;
						u = 1 - (pi - lo) * t * D_4_PI;
					} else if (lo <= D_7_4_M_PI) {
						u = 1 + t;
						v = 1 + (lo - D_3_2_M_PI) * t * D_4_PI;
					} else {
						v = 1 + t;
						u = 1 + (M_2_PI - lo) * t * D_4_PI;
					}
				}

				u = u / 6.0;
				v = v * 0.25;
				
        return tex2D(_MainTex, float2(u, v));
			}
			ENDCG
		}
	}
}
