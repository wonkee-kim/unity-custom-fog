Shader "CustomFog"
{
    Properties
    {
        [Header(Color)][Space(5)]
        _BaseColor ("Base color", Color) = (1, 1, 1, 1)
        _BaseMap ("Albedo Texture", 2D) = "white" { }
        _AmbientIntensity ("Ambient Intensity", Float) = 1

        [Header(Fog)]
        [KeywordEnum(Off, Unity, Custom)] _FogMode ("Fog Mode", Float) = 2
        _FogHeightRange ("Fog Height Range", Vector) = (0, -100, 0, 0)
        _FogHeightColor ("Fog Height Color", Color) = (0.77, 0.48, 0.19, 1)
        _FogTex ("Fog Texture", Cube) = "white" { }
        _FogTexBlur ("Fog Texture Blur", Range(0, 8)) = 4
        _FogTexRotation ("Fog Texture Rotation", Range(0, 360)) = 0
        _FogAdd ("Fog Add", Range(0, 1)) = 0.1
        _NoiseTex ("Noise Texture", 2D) = "white" { }
        _NoiseScale ("Noise Scale", Float) = 0.01
        _NoiseAnimSpeed ("Noise Animation Speed", Vector) = (0.9, -1.7, 1, 1)
        _NoiseIntensityHeight ("Noise Intensity Height", Vector) = (0.5, 1.5, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog
            #pragma multi_compile_local_fragment _FOGMODE_OFF _FOGMODE_UNITY _FOGMODE_CUSTOM

            #pragma shader_feature_local _ LIGHTMAP_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normalOS : NORMAL;
                half4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varying
            {
                float4 positionCS : SV_POSITION;
                float4 uv : TEXCOORD0;
                float fogCoord : TEXCOORD2;

                float3 positionWS : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
                half3 tangentWS : TEXCOORD5;
                half3 binormalWS : TEXCOORD6;

                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NoiseTex);
            SAMPLER(sampler_NoiseTex);
            TEXTURECUBE(_FogTex);
            SAMPLER(sampler_FogTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half4 _BaseColor;
                half _AmbientIntensity;

                half2 _FogHeightRange;
                half4 _FogHeightColor;
                half _FogTexBlur;
                half _FogTexRotation;
                half _FogAdd;
                half _NoiseScale;
                half2 _NoiseAnimSpeed;
                half2 _NoiseIntensityHeight;
            CBUFFER_END

            Varying vert(Attributes IN)
            {
                UNITY_SETUP_INSTANCE_ID(IN);
                Varying OUT = (Varying)0;
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS);

                OUT.positionCS = vertexInput.positionCS;
                OUT.positionWS = vertexInput.positionWS;
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                OUT.tangentWS = normalize(mul((float3x3)unity_ObjectToWorld, IN.tangentOS.xyz));
                OUT.binormalWS = cross(OUT.normalWS, OUT.tangentWS) * IN.tangentOS.w;

                OUT.uv.xy = TRANSFORM_TEX(IN.uv, _BaseMap);
                #if defined(LIGHTMAP_ON)
                    OUT.uv.zw = mad(IN.uv2, unity_LightmapST.xy, unity_LightmapST.zw); // lightmap uv
                #endif

                OUT.fogCoord = ComputeFogFactor(OUT.positionCS.z);
                return OUT;
            }

            #define UNITY_PI 3.14159265359

            float3 RotateAroundYInDegrees(float3 vertex, float degrees)
            {
                float alpha = degrees * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return float3(mul(m, vertex.xz), vertex.y).xzy;
            }

            void MixCustomFog(float3 color, float fogCoord, float3 viewDirWS, float3 positionWS, out float3 result)
            {
                // Sample fog color from cubemap (skybox)
                viewDirWS = RotateAroundYInDegrees(viewDirWS, -_FogTexRotation);
                half3 fogColor = SAMPLE_TEXTURECUBE_LOD(_FogTex, sampler_FogTex, -viewDirWS, _FogTexBlur).rgb;
                
                half noise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, positionWS.xz * _NoiseScale + _Time.x * _NoiseAnimSpeed.xy).r;
                noise += SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, positionWS.yz * _NoiseScale + _Time.x * _NoiseAnimSpeed.xy).r;
                noise *= 0.5;
                
                // Fog (height)
                half fogHeightIntensity = smoothstep(_FogHeightRange.x, _FogHeightRange.y, positionWS.y);
                fogHeightIntensity = fogHeightIntensity * fogHeightIntensity; // Exponential
                fogHeightIntensity *= noise * (_NoiseIntensityHeight.y - _NoiseIntensityHeight.x) + _NoiseIntensityHeight.x;
                half3 fogHeightColor = saturate((fogColor + fogColor) + _FogHeightColor.rgb) * saturate(fogColor + 0.5); // mix appoximately
                color = lerp(color, fogHeightColor, saturate(fogHeightIntensity * _FogHeightColor.a + _FogAdd));
                
                // Fog (distance)
                // fogColor *= saturate(unity_FogColor.rgb + 0.5);
                // half3 fogColorDistance = fogColor * saturate(fogColor + 0.5);
                half3 fogColorDistance = fogColor;
                
                result = color;
                #if (defined(FOG_EXP) || defined(FOG_EXP2))
                    result = lerp(color, fogColorDistance, saturate(fogCoord - _FogAdd));
                #elif defined(FOG_LINEAR) // reverse
                    result = lerp(fogColorDistance, color, saturate(fogCoord - _FogAdd));
                #endif
            }

            half4 frag(Varying IN) : SV_Target
            {
                // Surface Data
                float3 positionWS = IN.positionWS;
                float3 normalWS = normalize(IN.normalWS);
                half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
                
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv.xy) * _BaseColor;
                #if defined(LIGHTMAP_ON)
                    // Lightmap
                    real4 encodedIlluminance = SAMPLE_TEXTURE2D_LIGHTMAP(unity_Lightmap, samplerunity_Lightmap, IN.uv.zw).rgba;
                    half4 decodeInstructions = half4(LIGHTMAP_HDR_MULTIPLIER, LIGHTMAP_HDR_EXPONENT, 0.0h, 0.0h);
                    half3 lightmap = DecodeLightmap(encodedIlluminance, decodeInstructions);
                    color.rgb *= lightmap;
                #else
                    // Diffuse
                    half3 diffuse = saturate(dot(normalWS, _MainLightPosition.xyz)) * _MainLightColor.rgb;
                    LIGHT_LOOP_BEGIN(GetAdditionalLightsCount())
                    Light light = GetAdditionalLight(lightIndex, positionWS);
                    half3 lightColor = light.color * light.distanceAttenuation;
                    diffuse += LightingLambert(lightColor, light.direction, normalWS);
                    LIGHT_LOOP_END
                    color.rgb *= diffuse;

                    // SH Lighting
                    half3 shLight = SampleSH(normalWS);
                    color.rgb *= shLight * _AmbientIntensity;
                #endif


                // Fog
                #if defined(_FOGMODE_UNITY)
                    color.rgb = MixFog(color.rgb, IN.fogCoord);
                #elif defined(_FOGMODE_CUSTOM)
                    MixCustomFog(color.rgb, IN.fogCoord, viewDirWS, positionWS, color.rgb);
                #endif

                return color;
            }
            ENDHLSL
        }
    }
}