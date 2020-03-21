Shader "Water/SimpleShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _WaterTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGINCLUDE

        #include "UnityCG.cginc"

        fixed4 _Color;
        sampler2D _WaterTex;
        float4 _WaterTex_ST;

        struct a2v{
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
        };

        struct v2f{
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vert(a2v v){
            v2f o;
            // float4 offset = (0,0,0,0);
            // offset.y = sin(v.vertex.x * _Time.y);
            // v.vertex.y = sin(v.vertex.x * _Time.y * 0.1);
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.texcoord, _WaterTex);
            return o;
        }


        fixed4 frag(v2f i) : SV_Target{
            return tex2D(_WaterTex, i.uv);
        }
        ENDCG

        Pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            

            ENDCG
        }
    }
    FallBack "Diffuse"
}
