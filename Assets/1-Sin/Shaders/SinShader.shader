// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Water/SinShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _WaterTex ("Albedo (RGB)", 2D) = "white" {}

        peak ("peak", Float) = 3
        dir ("dir", Float) = 0.2
        amp ("amp", Float) = 0.5
        speed ("speed", Float) = 1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGINCLUDE
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
// Upgrade NOTE: excluded shader from DX11 because it uses wrong array syntax (type[size] name)
#pragma exclude_renderers d3d11

        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        fixed4 _Color;
        sampler2D _WaterTex;
        float4 _WaterTex_ST;

        float Wave1[4];
        float Wave2[4];
        float Wave3[4];
        float Wave4[4];

        struct a2v{
            float4 vertex : POSITION;
            float2 texcoord : TEXCOORD0;
        };

        struct v2f{
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 worldNormal : TEXCOORD1;
        };

        // float GenSingleSinWave(float3 vertex){
        //     return peak*sin(amp * (dir * vertex.x + vertex.z) + speed * _Time.y);
        // }

        float4 GenSingleSinWave(float3 vertex, float wave[4]){
            float4 finalWave;
            float peak = wave[0];
            float dir = wave[1];
            float amp = wave[2];
            float speed = wave[3];

            // 计算高度
            finalWave.x = peak*sin(amp * (dir * vertex.x + sqrt(1 - dir * dir) * vertex.z) + speed * _Time.y);

            // 计算法线
            finalWave.y = -peak*cos(amp * (dir * vertex.x + sqrt(1 - dir * dir) * vertex.z) + speed * _Time.y) * amp * dir;
            finalWave.z = -peak*cos(amp * (dir * vertex.x + sqrt(1 - dir * dir) * vertex.z) + speed * _Time.y) * amp * sqrt(1  - dir * dir);
            finalWave.w = 1;
            return finalWave;
        }

        // float GenSingleSinWave2(float3 vertex){
        //     float peak = peak2;
        //     float dir = dir2;
        //     float amp = amp2;
        //     float speed = speed2;

        //     return peak*sin(amp * (dir * vertex.x + vertex.z) + speed * _Time.y);
        // }

        // float GenSingleSinWave3(float3 vertex){
        //     float peak = peak3;
        //     float dir = dir3;
        //     float amp = amp3;
        //     float speed = speed3;

        //     return peak*sin(amp * (dir * vertex.x + vertex.z) + speed * _Time.y);
        // }

        // 计算一个高度信息和一个法线信息存在float4中
        float4 GenSinWave(float3 vertex){
            float4 h = float4(0,0,0,0);
            float4 waveh1 = 1/4.0 * GenSingleSinWave(vertex, Wave1);
            float4 waveh2 = 1/4.0 * GenSingleSinWave(vertex, Wave1);
            float4 waveh3 = 1/4.0 * GenSingleSinWave(vertex, Wave1);
            float4 waveh4 = 1/4.0 * GenSingleSinWave(vertex, Wave1);
            h = waveh1 + waveh2 + waveh3 + waveh4;
            return h;
        }

        v2f vert(a2v v){
            v2f o;

            // float4 wave = GenSinWave(v.vertex);
            float4 wave;
            wave.x = sin(v.vertex);
            wave.yzw = (-cos(v.vertex), 0, 1);
            v.vertex.y = wave.x;
            float3 normal = wave.yzw;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.texcoord, _WaterTex);
            o.worldNormal = mul(normal, (float3x3)unity_WorldToObject);
            return o;
        }


        fixed4 frag(v2f i) : SV_Target{
            float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
            float3 worldNormal = normalize(i.worldNormal);
            fixed4 color = tex2D(_WaterTex, i.uv);
            fixed3 diffuse = _LightColor0.rgb * color.rgb * saturate(dot(worldNormal, worldLightDir));
            return fixed4(diffuse, 1);
        }
        ENDCG

        Pass{
            Cull Off
            CGPROGRAM


            #pragma vertex vert
            #pragma fragment frag
            

            ENDCG
        }
    }
    FallBack "Diffuse"
}
