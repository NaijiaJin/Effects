Shader "Unlit/Blood"
{
   
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size("gridsize",float)=1 
        _Wiggle("wiggle",float)=10
        _Distortion("Distortion",Range(-5,5))=0
        _DColor("DropColor",Color)=(1,1,1,1)
        _BColor("bloodcolor",Color)=(1,1,1,1)
        _Trailnum("trailnum",float)=150
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100


        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
          
            #pragma fragment frag

            // make fog work
            #pragma multi_compile_fog
            #define S(a,b,c) smoothstep(a,b,c)
            #include "UnityCG.cginc"
            
          
            
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Size,_Distortion,_Wiggle,_Trailnum;
            float4 _BColor,_DColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            float N21(float2 p)// generate random snow 
            {
                p=frac(p*float2(123.34,345.45));
                p+=dot(p,p+34.345);
                return frac(p.x*p.y);
            
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float t=_Time.y*.3;
                // sample the texture
                float4 col=0;

                
                float2 aspect=float2(2,1);
                float2 uv=i.uv*_Size*aspect;// congrol the grid 
                uv.y+=t*.25;
                float2 gv=frac(uv)-.5;
                float2 id=floor(uv);


                float n= N21(id); // 0 or 1 random 
                t+=n*6.28;// drops time offset; 
                
                float w=i.uv.y*_Wiggle;// wiggle param the 10 
                float x=(n-.5)*.8; //sin(3*w)*pow(sin(w),6)*.45; // to random the x axis pos of the drops
                x+=(.4-abs(x))*sin(3*w)*pow(sin(w),6)*.45;//wiggles 
                float y=-sin(t+sin(t+sin(t)*.5))*.4;
                y-=(gv.x-x)*(gv.x-x)*(gv.x-x);// give the drop a drop shape

                float2 dropPos=(gv-float2(x,y))/aspect; // drop position              
                float drop=S(.05,.03,length(dropPos));// drop size and shape


                float2 trailPos=(gv-float2(x,t*.25))/aspect; // trail drops position
                trailPos.y=(frac(trailPos.y*_Trailnum)-.5)/_Trailnum; // trail drops like a string             
                float trail=S(.05,.01,length(trailPos)); // trail drops shape and size
                float bloodtrail=S(-.05,.05,dropPos.y); // trail shows only behind drop
                bloodtrail*=S(.5,y,gv.y)*1.5;// trail drop dimmer at top 
                trail*=bloodtrail;
                bloodtrail*=S(.05,.01,abs(dropPos.x));// bloodtrail 


                col.rgb = _BColor.rgb;
                col.a += bloodtrail*0.5 + trail;
                col += drop*_DColor;

                //col+=bloodtrail*.5*_BColor;
                //col+=trail*_BColor;
                //col+=drop*_DColor;
                //col.rg=gv;
              //  if(gv.x>.49||gv.y>.49) col=float4(1,1,0,1);
                float2 offs=drop*dropPos+trail*trailPos; 
                //col=tex2D(_MainTex,(i.uv+offs*_Distortion));
               
             //  col=_BColor*float4((offs*_Distortion),0,0);
                // col=0; col+=N21(id);
                return col;
            }
            ENDCG
        }
    }
}
