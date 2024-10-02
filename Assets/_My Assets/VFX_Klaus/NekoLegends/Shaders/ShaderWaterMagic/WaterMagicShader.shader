Shader "Neko Legends/Water Magic Shader"
{
    Properties
    {
        [NoScaleOffset] _Main_Texture("Main Texture", 2D) = "white" {}
        [HDR]_Color("Main Color", Color) = (1, 1, 1, 0)
        _Texture_Strength("Texture Strength", Range(-5, 5)) = 0
        _Specular_Color("Specular Color", Color) = (0.5019608, 0.5019608, 0.5019608, 0)
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Fresenel_Power("Fresenel Power", Range(-10, 10)) = 5
        [HDR]_Fresenel_Color("Fresenel Color", Color) = (1, 1, 1, 0)
        _Distortion_Speed("Distortion Speed", Range(-10, 10)) = 0.25
        _Noise_Strength("Noise Strength", Range(-2, 2)) = 0.1
        _Wobble_Speed("Wobble_Speed", Float) = 0.2
        _Wobble("Wobble", Range(0, 50)) = 0
        _Wobble_Size("Wobble Size", Range(0, 2)) = 0.1
        [NoScaleOffset]_NormalMap("Normal Map", 2D) = "white" {}
        [NoScaleOffset]_NormalMap_2("Normal Map 2", 2D) = "white" {}
        _Normal_Map_Tile("Normal Map Tile", Vector) = (1, 1, 0, 0)
        _Normal_Map_Tile_2("Normal Map Tile 2", Vector) = (1, 1, 0, 0)
        _Normal_Strength("Normal Strength", Range(0, 20)) = 1
        _Normal_Map_Speed("Normal Map Speed", Range(-5, 5)) = 0.1
        _Normal_Map_Speed_2("Normal Map Speed 2", Range(-5, 5)) = -0.05
        _Dissolve_Threshold("Dissolve Threshold", Range(-3, 3)) = 0
        _Dissolve_Noise_Scale("Dissolve Noise Scale", Float) = 50
        _Dissolve_Edge_Width("Dissolve Edge Width", Float) = 0.05
        [HDR]_Dissolve_Edge_Color("Dissolve Edge Color", Color) = (0, 1.711776, 4.237508, 1)
        _Dissolve_Height("Dissolve Height", Range(-10, 10)) = 0
        _Dissolve_Strength_X("Dissolve Strength X", Float) = 1
        _Dissolve_Strength_Y("Dissolve Strength Y", Float) = 1
        _Dissolve_Strength_Z("Dissolve Strength Z", Float) = 1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue" = "AlphaTest"
            "DisableBatching" = "False"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Off
        Blend One Zero
        ZTest LEqual
        ZWrite On
        AlphaToMask On

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_MEDIUM
        #pragma multi_compile_fragment _ _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        #define _SPECULAR_SETUP 1
        #define REQUIRE_OPAQUE_TEXTURE


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpaceNormal;
             float3 TangentSpaceNormal;
             float3 WorldSpaceViewDirection;
             float3 ObjectSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _Main_Texture_TexelSize;
        float _Texture_Strength;
        float4 _Specular_Color;
        float _Smoothness;
        float _Fresenel_Power;
        float4 _Fresenel_Color;
        float _Distortion_Speed;
        float _Noise_Strength;
        float _Wobble_Speed;
        float _Wobble;
        float _Wobble_Size;
        float4 _NormalMap_2_TexelSize;
        float4 _NormalMap_TexelSize;
        float2 _Normal_Map_Tile_2;
        float2 _Normal_Map_Tile;
        float _Normal_Strength;
        float _Normal_Map_Speed;
        float _Normal_Map_Speed_2;
        float _Dissolve_Threshold;
        float _Dissolve_Noise_Scale;
        float _Dissolve_Edge_Width;
        float4 _Dissolve_Edge_Color;
        float _Dissolve_Height;
        float _Dissolve_Strength_X;
        float _Dissolve_Strength_Y;
        float _Dissolve_Strength_Z;
        CBUFFER_END


            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Main_Texture);
            SAMPLER(sampler_Main_Texture);
            TEXTURE2D(_NormalMap_2);
            SAMPLER(sampler_NormalMap_2);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            // Graph Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
            {
                float x; Hash_LegacyMod_2_1_float(p, x);
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
            {
                float2 p = UV * Scale.xy;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }

            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }

            void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
            {
                Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }

            void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
            {
                Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
            }

            float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
            {
                Hash_LegacySine_2_2_float(UV, UV);
                return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
            }

            void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float t = 8.0;
                float3 res = float3(8.0, 0.0, 0.0);
                for (int y = -1; y <= 1; y++)
                {
                    for (int x = -1; x <= 1; x++)
                    {
                        float2 lattice = float2(x, y);
                        float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);
                        if (d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
            }

            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Negate_float(float In, out float Out)
            {
                Out = -1 * In;
            }

            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
            {
                Out = clamp(In, Min, Max);
            }

            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float3 Specular;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_5504698f499d44d597ec29e40414d968_Out_0_Float = _Fresenel_Power;
                float _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float;
                Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5504698f499d44d597ec29e40414d968_Out_0_Float, _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float);
                float4 _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Fresenel_Color) : _Fresenel_Color;
                float4 _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4;
                Unity_Multiply_float4_float4((_FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float.xxxx), _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4, _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4);
                float4 _Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
                float4 _ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                float _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float;
                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 10, _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float);
                float _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float = _Noise_Strength;
                float _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float;
                Unity_Multiply_float_float(_GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float, _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float, _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float);
                float4 _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4;
                Unity_Add_float4(_ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4, (_Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float.xxxx), _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4);
                float3 _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3;
                Unity_SceneColor_float(_Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4, _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3);
                float3 _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3;
                Unity_Multiply_float3_float3((_Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4.xyz), _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3, _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3);
                float3 _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3;
                Unity_Add_float3((_Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4.xyz), _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3, _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3);
                UnityTexture2D _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                float4 _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.tex, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.samplerstate, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_R_4_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.r;
                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_G_5_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.g;
                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_B_6_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.b;
                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_A_7_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.a;
                float _Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float = _Texture_Strength;
                float4 _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4;
                Unity_Multiply_float4_float4(_SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4, (_Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float.xxxx), _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4);
                float3 _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                Unity_Add_float3(_Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3, (_Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4.xyz), _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3);
                UnityTexture2D _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                float2 _Property_f031b2f1d604463c88ad3452a21c1f01_Out_0_Vector2 = _Normal_Map_Tile;
                float _Property_0182a6a2a31e48328866ef16f2656034_Out_0_Float = _Normal_Map_Speed;
                float _Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_0182a6a2a31e48328866ef16f2656034_Out_0_Float, _Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float);
                float2 _TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f031b2f1d604463c88ad3452a21c1f01_Out_0_Vector2, (_Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float.xx), _TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2);
                float4 _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.tex, _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.samplerstate, _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2));
                _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4);
                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_R_4_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.r;
                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_G_5_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.g;
                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_B_6_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.b;
                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_A_7_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.a;
                UnityTexture2D _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap_2);
                float2 _Property_8f15b0b3be3c4303a3e8878ff8594166_Out_0_Vector2 = _Normal_Map_Tile_2;
                float _Property_d858c5be643d41f0bf4c14666ed7268a_Out_0_Float = _Normal_Map_Speed_2;
                float _Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d858c5be643d41f0bf4c14666ed7268a_Out_0_Float, _Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float);
                float2 _TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_8f15b0b3be3c4303a3e8878ff8594166_Out_0_Vector2, (_Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float.xx), _TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2);
                float4 _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.tex, _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.samplerstate, _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2));
                _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4);
                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_R_4_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.r;
                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_G_5_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.g;
                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_B_6_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.b;
                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_A_7_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.a;
                float4 _Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4;
                Unity_Add_float4(_SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4, _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4, _Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4);
                float _Property_af926359f8394a60a147ccf481508759_Out_0_Float = _Normal_Strength;
                float3 _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3;
                Unity_NormalStrength_float((_Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4.xyz), _Property_af926359f8394a60a147ccf481508759_Out_0_Float, _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3);
                float4 _Property_c71e222507ec4b278909b8f19ea5975d_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Dissolve_Edge_Color) : _Dissolve_Edge_Color;
                float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                float _Property_10ac528f811d4129ba8dcff5d8984eaf_Out_0_Float = _Dissolve_Edge_Width;
                float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                float _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float;
                Unity_Add_float(_Property_10ac528f811d4129ba8dcff5d8984eaf_Out_0_Float, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float);
                float _Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float;
                Unity_Step_float(_Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float, _Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float);
                float4 _Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Property_c71e222507ec4b278909b8f19ea5975d_Out_0_Vector4, (_Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float.xxxx), _Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4);
                float3 _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3;
                Unity_Add_float3(_Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3, (_Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4.xyz), _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3);
                float4 _Property_35803908170541d9b8752775f8be8800_Out_0_Vector4 = _Specular_Color;
                float _Property_a668355ac279409da361bc3af4411d28_Out_0_Float = _Smoothness;
                float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                surface.BaseColor = _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                surface.NormalTS = _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3;
                surface.Emission = _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3;
                surface.Specular = (_Property_35803908170541d9b8752775f8be8800_Out_0_Vector4.xyz);
                surface.Smoothness = _Property_a668355ac279409da361bc3af4411d28_Out_0_Float;
                surface.Occlusion = 1;
                surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                surface.AlphaClipThreshold = 1;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;
                output.uv0 = input.uv0;
                output.TimeParameters = _TimeParameters.xyz;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
            #if VFX_USE_GRAPH_VALUES
                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
            #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif



                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                #if UNITY_UV_STARTS_AT_TOP
                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #else
                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #endif

                output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                output.uv0 = input.texCoord0;
                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
            }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Off
                Blend One Zero
                ZTest LEqual
                ZWrite On

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT
                #pragma multi_compile_fragment _ _SHADOWS_SOFT_LOW
                #pragma multi_compile_fragment _ _SHADOWS_SOFT_MEDIUM
                #pragma multi_compile_fragment _ _SHADOWS_SOFT_HIGH
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define _ALPHATEST_ON 1
                #define _SPECULAR_SETUP 1
                #define REQUIRE_OPAQUE_TEXTURE


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 TangentSpaceNormal;
                     float3 WorldSpaceViewDirection;
                     float3 ObjectSpacePosition;
                     float2 NDCPosition;
                     float2 PixelPosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV : INTERP0;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV : INTERP1;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh : INTERP2;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord : INTERP3;
                    #endif
                     float4 tangentWS : INTERP4;
                     float4 texCoord0 : INTERP5;
                     float4 fogFactorAndVertexLight : INTERP6;
                     float3 positionWS : INTERP7;
                     float3 normalWS : INTERP8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                    output.positionWS.xyz = input.positionWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _Main_Texture_TexelSize;
                float _Texture_Strength;
                float4 _Specular_Color;
                float _Smoothness;
                float _Fresenel_Power;
                float4 _Fresenel_Color;
                float _Distortion_Speed;
                float _Noise_Strength;
                float _Wobble_Speed;
                float _Wobble;
                float _Wobble_Size;
                float4 _NormalMap_2_TexelSize;
                float4 _NormalMap_TexelSize;
                float2 _Normal_Map_Tile_2;
                float2 _Normal_Map_Tile;
                float _Normal_Strength;
                float _Normal_Map_Speed;
                float _Normal_Map_Speed_2;
                float _Dissolve_Threshold;
                float _Dissolve_Noise_Scale;
                float _Dissolve_Edge_Width;
                float4 _Dissolve_Edge_Color;
                float _Dissolve_Height;
                float _Dissolve_Strength_X;
                float _Dissolve_Strength_Y;
                float _Dissolve_Strength_Z;
                CBUFFER_END


                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_Main_Texture);
                    SAMPLER(sampler_Main_Texture);
                    TEXTURE2D(_NormalMap_2);
                    SAMPLER(sampler_NormalMap_2);
                    TEXTURE2D(_NormalMap);
                    SAMPLER(sampler_NormalMap);

                    // Graph Includes
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                    {
                        float x; Hash_LegacyMod_2_1_float(p, x);
                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                    }

                    void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                    {
                        float2 p = UV * Scale.xy;
                        float2 ip = floor(p);
                        float2 fp = frac(p);
                        float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                        float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                        float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                        float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                    }

                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                    {
                        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                    }

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_SceneColor_float(float4 UV, out float3 Out)
                    {
                        Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
                    }

                    void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
                    {
                        Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
                    }

                    float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                    {
                        Hash_LegacySine_2_2_float(UV, UV);
                        return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                    }

                    void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                    {
                        float2 g = floor(UV * CellDensity);
                        float2 f = frac(UV * CellDensity);
                        float t = 8.0;
                        float3 res = float3(8.0, 0.0, 0.0);
                        for (int y = -1; y <= 1; y++)
                        {
                            for (int x = -1; x <= 1; x++)
                            {
                                float2 lattice = float2(x, y);
                                float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                float d = distance(lattice + offset, f);
                                if (d < res.x)
                                {
                                    res = float3(d, offset.x, offset.y);
                                    Out = res.x;
                                    Cells = res.y;
                                }
                            }
                        }
                    }

                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                    {
                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                    }

                    void Unity_Add_float(float A, float B, out float Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Negate_float(float In, out float Out)
                    {
                        Out = -1 * In;
                    }

                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                    {
                        Out = clamp(In, Min, Max);
                    }

                    void Unity_Step_float(float Edge, float In, out float Out)
                    {
                        Out = step(Edge, In);
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                        float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                        float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                        float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                        float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                        float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                        float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                        float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                        Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                        float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                        Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                        float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                        Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                        description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float3 BaseColor;
                        float3 NormalTS;
                        float3 Emission;
                        float3 Specular;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                        float AlphaClipThreshold;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float _Property_5504698f499d44d597ec29e40414d968_Out_0_Float = _Fresenel_Power;
                        float _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float;
                        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5504698f499d44d597ec29e40414d968_Out_0_Float, _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float);
                        float4 _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Fresenel_Color) : _Fresenel_Color;
                        float4 _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4;
                        Unity_Multiply_float4_float4((_FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float.xxxx), _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4, _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4);
                        float4 _Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
                        float4 _ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                        float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                        float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                        float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                        float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                        float _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float;
                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 10, _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float);
                        float _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float = _Noise_Strength;
                        float _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float;
                        Unity_Multiply_float_float(_GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float, _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float, _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float);
                        float4 _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4;
                        Unity_Add_float4(_ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4, (_Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float.xxxx), _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4);
                        float3 _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3;
                        Unity_SceneColor_float(_Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4, _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3);
                        float3 _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3;
                        Unity_Multiply_float3_float3((_Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4.xyz), _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3, _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3);
                        float3 _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3;
                        Unity_Add_float3((_Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4.xyz), _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3, _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3);
                        UnityTexture2D _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                        float4 _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.tex, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.samplerstate, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_R_4_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.r;
                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_G_5_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.g;
                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_B_6_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.b;
                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_A_7_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.a;
                        float _Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float = _Texture_Strength;
                        float4 _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4, (_Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float.xxxx), _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4);
                        float3 _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                        Unity_Add_float3(_Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3, (_Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4.xyz), _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3);
                        UnityTexture2D _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                        float2 _Property_f031b2f1d604463c88ad3452a21c1f01_Out_0_Vector2 = _Normal_Map_Tile;
                        float _Property_0182a6a2a31e48328866ef16f2656034_Out_0_Float = _Normal_Map_Speed;
                        float _Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_0182a6a2a31e48328866ef16f2656034_Out_0_Float, _Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float);
                        float2 _TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f031b2f1d604463c88ad3452a21c1f01_Out_0_Vector2, (_Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float.xx), _TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2);
                        float4 _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.tex, _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.samplerstate, _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2));
                        _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4);
                        float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_R_4_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.r;
                        float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_G_5_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.g;
                        float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_B_6_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.b;
                        float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_A_7_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.a;
                        UnityTexture2D _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap_2);
                        float2 _Property_8f15b0b3be3c4303a3e8878ff8594166_Out_0_Vector2 = _Normal_Map_Tile_2;
                        float _Property_d858c5be643d41f0bf4c14666ed7268a_Out_0_Float = _Normal_Map_Speed_2;
                        float _Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d858c5be643d41f0bf4c14666ed7268a_Out_0_Float, _Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float);
                        float2 _TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, _Property_8f15b0b3be3c4303a3e8878ff8594166_Out_0_Vector2, (_Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float.xx), _TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2);
                        float4 _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.tex, _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.samplerstate, _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2));
                        _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4);
                        float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_R_4_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.r;
                        float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_G_5_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.g;
                        float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_B_6_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.b;
                        float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_A_7_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.a;
                        float4 _Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4;
                        Unity_Add_float4(_SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4, _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4, _Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4);
                        float _Property_af926359f8394a60a147ccf481508759_Out_0_Float = _Normal_Strength;
                        float3 _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3;
                        Unity_NormalStrength_float((_Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4.xyz), _Property_af926359f8394a60a147ccf481508759_Out_0_Float, _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3);
                        float4 _Property_c71e222507ec4b278909b8f19ea5975d_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Dissolve_Edge_Color) : _Dissolve_Edge_Color;
                        float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                        Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                        float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                        float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                        Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                        float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                        Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                        float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                        float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                        Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                        float _Property_10ac528f811d4129ba8dcff5d8984eaf_Out_0_Float = _Dissolve_Edge_Width;
                        float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                        float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                        float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                        float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                        float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                        float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                        float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                        Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                        float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                        float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                        float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                        Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                        float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                        float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                        float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                        Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                        float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                        Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                        float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                        Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                        float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                        float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                        Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                        float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                        Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                        float _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float;
                        Unity_Add_float(_Property_10ac528f811d4129ba8dcff5d8984eaf_Out_0_Float, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float);
                        float _Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float;
                        Unity_Step_float(_Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float, _Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float);
                        float4 _Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_Property_c71e222507ec4b278909b8f19ea5975d_Out_0_Vector4, (_Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float.xxxx), _Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4);
                        float3 _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3;
                        Unity_Add_float3(_Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3, (_Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4.xyz), _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3);
                        float4 _Property_35803908170541d9b8752775f8be8800_Out_0_Vector4 = _Specular_Color;
                        float _Property_a668355ac279409da361bc3af4411d28_Out_0_Float = _Smoothness;
                        float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                        Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                        surface.BaseColor = _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                        surface.NormalTS = _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3;
                        surface.Emission = _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3;
                        surface.Specular = (_Property_35803908170541d9b8752775f8be8800_Out_0_Vector4.xyz);
                        surface.Smoothness = _Property_a668355ac279409da361bc3af4411d28_Out_0_Float;
                        surface.Occlusion = 1;
                        surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                        surface.AlphaClipThreshold = 1;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;
                        output.uv0 = input.uv0;
                        output.TimeParameters = _TimeParameters.xyz;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif



                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                        float3 unnormalizedNormalWS = input.normalWS;
                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                        output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                        output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                        #if UNITY_UV_STARTS_AT_TOP
                        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                        #else
                        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                        #endif

                        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                        output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                        output.uv0 = input.texCoord0;
                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                    #else
                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                    #endif
                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                    }

                    // --------------------------------------------------
                    // Main

                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

                    ENDHLSL
                    }
                    Pass
                    {
                        Name "ShadowCaster"
                        Tags
                        {
                            "LightMode" = "ShadowCaster"
                        }

                        // Render State
                        Cull Off
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 2.0
                        #pragma multi_compile_instancing
                        #pragma vertex vert
                        #pragma fragment frag

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_TS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TEXCOORD0
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER
                        #define _ALPHATEST_ON 1


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 positionWS;
                             float3 normalWS;
                             float4 texCoord0;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float3 ObjectSpacePosition;
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float4 texCoord0 : INTERP0;
                             float3 positionWS : INTERP1;
                             float3 normalWS : INTERP2;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.texCoord0.xyzw = input.texCoord0;
                            output.positionWS.xyz = input.positionWS;
                            output.normalWS.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.texCoord0 = input.texCoord0.xyzw;
                            output.positionWS = input.positionWS.xyz;
                            output.normalWS = input.normalWS.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float4 _Color;
                        float4 _Main_Texture_TexelSize;
                        float _Texture_Strength;
                        float4 _Specular_Color;
                        float _Smoothness;
                        float _Fresenel_Power;
                        float4 _Fresenel_Color;
                        float _Distortion_Speed;
                        float _Noise_Strength;
                        float _Wobble_Speed;
                        float _Wobble;
                        float _Wobble_Size;
                        float4 _NormalMap_2_TexelSize;
                        float4 _NormalMap_TexelSize;
                        float2 _Normal_Map_Tile_2;
                        float2 _Normal_Map_Tile;
                        float _Normal_Strength;
                        float _Normal_Map_Speed;
                        float _Normal_Map_Speed_2;
                        float _Dissolve_Threshold;
                        float _Dissolve_Noise_Scale;
                        float _Dissolve_Edge_Width;
                        float4 _Dissolve_Edge_Color;
                        float _Dissolve_Height;
                        float _Dissolve_Strength_X;
                        float _Dissolve_Strength_Y;
                        float _Dissolve_Strength_Z;
                        CBUFFER_END


                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_Main_Texture);
                            SAMPLER(sampler_Main_Texture);
                            TEXTURE2D(_NormalMap_2);
                            SAMPLER(sampler_NormalMap_2);
                            TEXTURE2D(_NormalMap);
                            SAMPLER(sampler_NormalMap);

                            // Graph Includes
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }

                            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                            {
                                float x; Hash_LegacyMod_2_1_float(p, x);
                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                            }

                            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                            {
                                float2 p = UV * Scale.xy;
                                float2 ip = floor(p);
                                float2 fp = frac(p);
                                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                            }

                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Negate_float(float In, out float Out)
                            {
                                Out = -1 * In;
                            }

                            void Unity_Add_float(float A, float B, out float Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                            {
                                Out = clamp(In, Min, Max);
                            }

                            float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                            {
                                Hash_LegacySine_2_2_float(UV, UV);
                                return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                            }

                            void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                            {
                                float2 g = floor(UV * CellDensity);
                                float2 f = frac(UV * CellDensity);
                                float t = 8.0;
                                float3 res = float3(8.0, 0.0, 0.0);
                                for (int y = -1; y <= 1; y++)
                                {
                                    for (int x = -1; x <= 1; x++)
                                    {
                                        float2 lattice = float2(x, y);
                                        float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                        float d = distance(lattice + offset, f);
                                        if (d < res.x)
                                        {
                                            res = float3(d, offset.x, offset.y);
                                            Out = res.x;
                                            Cells = res.y;
                                        }
                                    }
                                }
                            }

                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                            {
                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                            }

                            void Unity_Step_float(float Edge, float In, out float Out)
                            {
                                Out = step(Edge, In);
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                                float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                                float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                                float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                                float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                                float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                                Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                                float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                                Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                                float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                                description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                                float AlphaClipThreshold;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                                float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                                float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                                float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                                float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                                float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                                float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                                Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                                float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                                float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                                float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                                Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                                float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                                float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                                float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                                Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                                float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                                Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                                float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                                Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                                float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                                float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                                Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                                float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                                Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                                float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                                float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                                float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                                Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                                float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                                float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                                Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                                float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                                Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                                float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                                float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                                Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                                float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                                surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                surface.AlphaClipThreshold = 1;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;
                                output.uv0 = input.uv0;
                                output.TimeParameters = _TimeParameters.xyz;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                            #if VFX_USE_GRAPH_VALUES
                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                            #endif
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif







                                output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                #if UNITY_UV_STARTS_AT_TOP
                                #else
                                #endif


                                output.uv0 = input.texCoord0;
                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                            #else
                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                            #endif
                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                            }

                            // --------------------------------------------------
                            // Main

                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "DepthOnly"
                                Tags
                                {
                                    "LightMode" = "DepthOnly"
                                }

                                // Render State
                                Cull Off
                                ZTest LEqual
                                ZWrite On
                                ColorMask R

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 2.0
                                #pragma multi_compile_instancing
                                #pragma vertex vert
                                #pragma fragment frag

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_TS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define VARYINGS_NEED_POSITION_WS
                                #define VARYINGS_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                #define _ALPHATEST_ON 1


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
                                     float4 texCoord0;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float3 ObjectSpacePosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float4 texCoord0 : INTERP0;
                                     float3 positionWS : INTERP1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.texCoord0.xyzw = input.texCoord0;
                                    output.positionWS.xyz = input.positionWS;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.texCoord0 = input.texCoord0.xyzw;
                                    output.positionWS = input.positionWS.xyz;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float4 _Color;
                                float4 _Main_Texture_TexelSize;
                                float _Texture_Strength;
                                float4 _Specular_Color;
                                float _Smoothness;
                                float _Fresenel_Power;
                                float4 _Fresenel_Color;
                                float _Distortion_Speed;
                                float _Noise_Strength;
                                float _Wobble_Speed;
                                float _Wobble;
                                float _Wobble_Size;
                                float4 _NormalMap_2_TexelSize;
                                float4 _NormalMap_TexelSize;
                                float2 _Normal_Map_Tile_2;
                                float2 _Normal_Map_Tile;
                                float _Normal_Strength;
                                float _Normal_Map_Speed;
                                float _Normal_Map_Speed_2;
                                float _Dissolve_Threshold;
                                float _Dissolve_Noise_Scale;
                                float _Dissolve_Edge_Width;
                                float4 _Dissolve_Edge_Color;
                                float _Dissolve_Height;
                                float _Dissolve_Strength_X;
                                float _Dissolve_Strength_Y;
                                float _Dissolve_Strength_Z;
                                CBUFFER_END


                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_Main_Texture);
                                    SAMPLER(sampler_Main_Texture);
                                    TEXTURE2D(_NormalMap_2);
                                    SAMPLER(sampler_NormalMap_2);
                                    TEXTURE2D(_NormalMap);
                                    SAMPLER(sampler_NormalMap);

                                    // Graph Includes
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }

                                    float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                    {
                                        float x; Hash_LegacyMod_2_1_float(p, x);
                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                    }

                                    void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                    {
                                        float2 p = UV * Scale.xy;
                                        float2 ip = floor(p);
                                        float2 fp = frac(p);
                                        float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                        float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                        float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                        float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                    }

                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Negate_float(float In, out float Out)
                                    {
                                        Out = -1 * In;
                                    }

                                    void Unity_Add_float(float A, float B, out float Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                    {
                                        Out = clamp(In, Min, Max);
                                    }

                                    float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                                    {
                                        Hash_LegacySine_2_2_float(UV, UV);
                                        return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                                    }

                                    void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                                    {
                                        float2 g = floor(UV * CellDensity);
                                        float2 f = frac(UV * CellDensity);
                                        float t = 8.0;
                                        float3 res = float3(8.0, 0.0, 0.0);
                                        for (int y = -1; y <= 1; y++)
                                        {
                                            for (int x = -1; x <= 1; x++)
                                            {
                                                float2 lattice = float2(x, y);
                                                float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                                float d = distance(lattice + offset, f);
                                                if (d < res.x)
                                                {
                                                    res = float3(d, offset.x, offset.y);
                                                    Out = res.x;
                                                    Cells = res.y;
                                                }
                                            }
                                        }
                                    }

                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                    {
                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                    }

                                    void Unity_Step_float(float Edge, float In, out float Out)
                                    {
                                        Out = step(Edge, In);
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                                        float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                        float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                        float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                                        float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                                        float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                                        float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                                        float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                                        Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                                        float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                                        Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                                        float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                        Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                                        description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float Alpha;
                                        float AlphaClipThreshold;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                                        float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                                        float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                                        float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                                        Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                                        float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                                        float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                                        float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                                        Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                                        float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                                        float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                                        float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                                        Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                                        float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                                        Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                                        float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                                        Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                                        float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                                        float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                                        Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                                        float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                                        Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                                        float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                                        float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                        float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                        float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                                        float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                                        Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                                        float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                                        float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                                        Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                                        float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                                        Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                                        float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                                        float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                                        Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                                        float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                        Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                                        surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                        surface.AlphaClipThreshold = 1;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;
                                        output.uv0 = input.uv0;
                                        output.TimeParameters = _TimeParameters.xyz;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                    #if VFX_USE_GRAPH_VALUES
                                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                    #endif
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif







                                        output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                        #if UNITY_UV_STARTS_AT_TOP
                                        #else
                                        #endif


                                        output.uv0 = input.texCoord0;
                                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                    #else
                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                    #endif
                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                    }

                                    // --------------------------------------------------
                                    // Main

                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "DepthNormals"
                                        Tags
                                        {
                                            "LightMode" = "DepthNormals"
                                        }

                                        // Render State
                                        Cull Off
                                        ZTest LEqual
                                        ZWrite On

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 2.0
                                        #pragma multi_compile_instancing
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // Keywords
                                        // PassKeywords: <None>
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_TS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_POSITION_WS
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_DEPTHNORMALS
                                        #define _ALPHATEST_ON 1


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 uv1 : TEXCOORD1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 positionWS;
                                             float3 normalWS;
                                             float4 tangentWS;
                                             float4 texCoord0;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float3 TangentSpaceNormal;
                                             float3 ObjectSpacePosition;
                                             float4 uv0;
                                             float3 TimeParameters;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                             float4 uv0;
                                             float3 TimeParameters;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float4 tangentWS : INTERP0;
                                             float4 texCoord0 : INTERP1;
                                             float3 positionWS : INTERP2;
                                             float3 normalWS : INTERP3;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.tangentWS.xyzw = input.tangentWS;
                                            output.texCoord0.xyzw = input.texCoord0;
                                            output.positionWS.xyz = input.positionWS;
                                            output.normalWS.xyz = input.normalWS;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.tangentWS = input.tangentWS.xyzw;
                                            output.texCoord0 = input.texCoord0.xyzw;
                                            output.positionWS = input.positionWS.xyz;
                                            output.normalWS = input.normalWS.xyz;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float4 _Color;
                                        float4 _Main_Texture_TexelSize;
                                        float _Texture_Strength;
                                        float4 _Specular_Color;
                                        float _Smoothness;
                                        float _Fresenel_Power;
                                        float4 _Fresenel_Color;
                                        float _Distortion_Speed;
                                        float _Noise_Strength;
                                        float _Wobble_Speed;
                                        float _Wobble;
                                        float _Wobble_Size;
                                        float4 _NormalMap_2_TexelSize;
                                        float4 _NormalMap_TexelSize;
                                        float2 _Normal_Map_Tile_2;
                                        float2 _Normal_Map_Tile;
                                        float _Normal_Strength;
                                        float _Normal_Map_Speed;
                                        float _Normal_Map_Speed_2;
                                        float _Dissolve_Threshold;
                                        float _Dissolve_Noise_Scale;
                                        float _Dissolve_Edge_Width;
                                        float4 _Dissolve_Edge_Color;
                                        float _Dissolve_Height;
                                        float _Dissolve_Strength_X;
                                        float _Dissolve_Strength_Y;
                                        float _Dissolve_Strength_Z;
                                        CBUFFER_END


                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_Main_Texture);
                                            SAMPLER(sampler_Main_Texture);
                                            TEXTURE2D(_NormalMap_2);
                                            SAMPLER(sampler_NormalMap_2);
                                            TEXTURE2D(_NormalMap);
                                            SAMPLER(sampler_NormalMap);

                                            // Graph Includes
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                            {
                                                float x; Hash_LegacyMod_2_1_float(p, x);
                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                            }

                                            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                            {
                                                float2 p = UV * Scale.xy;
                                                float2 ip = floor(p);
                                                float2 fp = frac(p);
                                                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                            }

                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
                                            {
                                                Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
                                            }

                                            void Unity_Negate_float(float In, out float Out)
                                            {
                                                Out = -1 * In;
                                            }

                                            void Unity_Add_float(float A, float B, out float Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                            {
                                                Out = clamp(In, Min, Max);
                                            }

                                            float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                                            {
                                                Hash_LegacySine_2_2_float(UV, UV);
                                                return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                                            }

                                            void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                                            {
                                                float2 g = floor(UV * CellDensity);
                                                float2 f = frac(UV * CellDensity);
                                                float t = 8.0;
                                                float3 res = float3(8.0, 0.0, 0.0);
                                                for (int y = -1; y <= 1; y++)
                                                {
                                                    for (int x = -1; x <= 1; x++)
                                                    {
                                                        float2 lattice = float2(x, y);
                                                        float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                                        float d = distance(lattice + offset, f);
                                                        if (d < res.x)
                                                        {
                                                            res = float3(d, offset.x, offset.y);
                                                            Out = res.x;
                                                            Cells = res.y;
                                                        }
                                                    }
                                                }
                                            }

                                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                            {
                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                            }

                                            void Unity_Step_float(float Edge, float In, out float Out)
                                            {
                                                Out = step(Edge, In);
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                                                float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                                                float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                                                float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                                                float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                                                float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                                                Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                                                float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                                                Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                                                float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                                                description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float3 NormalTS;
                                                float Alpha;
                                                float AlphaClipThreshold;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                UnityTexture2D _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap);
                                                float2 _Property_f031b2f1d604463c88ad3452a21c1f01_Out_0_Vector2 = _Normal_Map_Tile;
                                                float _Property_0182a6a2a31e48328866ef16f2656034_Out_0_Float = _Normal_Map_Speed;
                                                float _Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_0182a6a2a31e48328866ef16f2656034_Out_0_Float, _Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float);
                                                float2 _TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f031b2f1d604463c88ad3452a21c1f01_Out_0_Vector2, (_Multiply_95cb4454225d4ab88b2dab3d2db4106f_Out_2_Float.xx), _TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2);
                                                float4 _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.tex, _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.samplerstate, _Property_4d9092fa86c04daf801e6e87a11dee8d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a9695c221f1f406d819643a71eb8c39b_Out_3_Vector2));
                                                _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4);
                                                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_R_4_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.r;
                                                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_G_5_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.g;
                                                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_B_6_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.b;
                                                float _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_A_7_Float = _SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4.a;
                                                UnityTexture2D _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_NormalMap_2);
                                                float2 _Property_8f15b0b3be3c4303a3e8878ff8594166_Out_0_Vector2 = _Normal_Map_Tile_2;
                                                float _Property_d858c5be643d41f0bf4c14666ed7268a_Out_0_Float = _Normal_Map_Speed_2;
                                                float _Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_d858c5be643d41f0bf4c14666ed7268a_Out_0_Float, _Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float);
                                                float2 _TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, _Property_8f15b0b3be3c4303a3e8878ff8594166_Out_0_Vector2, (_Multiply_c09a1535cd76476fb42aa01de7f87e0a_Out_2_Float.xx), _TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2);
                                                float4 _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.tex, _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.samplerstate, _Property_774f59576b1e479ba7255a87f693cd5d_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_0d6b2a035e1e498f80698729ddc41cee_Out_3_Vector2));
                                                _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4);
                                                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_R_4_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.r;
                                                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_G_5_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.g;
                                                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_B_6_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.b;
                                                float _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_A_7_Float = _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4.a;
                                                float4 _Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4;
                                                Unity_Add_float4(_SampleTexture2D_06eb15c18c0f4c909ec899a61667bdf0_RGBA_0_Vector4, _SampleTexture2D_747fd2517b924e83bd01f005151d12ef_RGBA_0_Vector4, _Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4);
                                                float _Property_af926359f8394a60a147ccf481508759_Out_0_Float = _Normal_Strength;
                                                float3 _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3;
                                                Unity_NormalStrength_float((_Add_32ac4a05ea7f470f910a8a95954a1cd1_Out_2_Vector4.xyz), _Property_af926359f8394a60a147ccf481508759_Out_0_Float, _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3);
                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                                                float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                                                float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                                                float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                                                Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                                                float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                                                float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                                                float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                                                Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                                                float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                                                float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                                                float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                                                Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                                                float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                                                Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                                                float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                                                Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                                                float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                                                float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                                                Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                                                float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                                                Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                                                float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                                                float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                                                float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                                                Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                                                float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                                                float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                                                Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                                                float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                                                Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                                                float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                                                float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                                                Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                                                float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                                                surface.NormalTS = _NormalStrength_8eeaa5ff529343a3b3b01d3275e0f86e_Out_2_Vector3;
                                                surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                surface.AlphaClipThreshold = 1;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;
                                                output.uv0 = input.uv0;
                                                output.TimeParameters = _TimeParameters.xyz;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                            #if VFX_USE_GRAPH_VALUES
                                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                            #endif
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif





                                                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                                output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                                #if UNITY_UV_STARTS_AT_TOP
                                                #else
                                                #endif


                                                output.uv0 = input.texCoord0;
                                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                            #else
                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                            #endif
                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                            }

                                            // --------------------------------------------------
                                            // Main

                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
                                            Pass
                                            {
                                                Name "Meta"
                                                Tags
                                                {
                                                    "LightMode" = "Meta"
                                                }

                                                // Render State
                                                Cull Off

                                                // Debug
                                                // <None>

                                                // --------------------------------------------------
                                                // Pass

                                                HLSLPROGRAM

                                                // Pragmas
                                                #pragma target 2.0
                                                #pragma vertex vert
                                                #pragma fragment frag

                                                // Keywords
                                                #pragma shader_feature _ EDITOR_VISUALIZATION
                                                // GraphKeywords: <None>

                                                // Defines

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_TS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define ATTRIBUTES_NEED_TEXCOORD1
                                                #define ATTRIBUTES_NEED_TEXCOORD2
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_NORMAL_WS
                                                #define VARYINGS_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_TEXCOORD1
                                                #define VARYINGS_NEED_TEXCOORD2
                                                #define FEATURES_GRAPH_VERTEX
                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                #define SHADERPASS SHADERPASS_META
                                                #define _FOG_FRAGMENT 1
                                                #define _ALPHATEST_ON 1
                                                #define REQUIRE_OPAQUE_TEXTURE


                                                // custom interpolator pre-include
                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                // Includes
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                // --------------------------------------------------
                                                // Structs and Packing

                                                // custom interpolators pre packing
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                struct Attributes
                                                {
                                                     float3 positionOS : POSITION;
                                                     float3 normalOS : NORMAL;
                                                     float4 tangentOS : TANGENT;
                                                     float4 uv0 : TEXCOORD0;
                                                     float4 uv1 : TEXCOORD1;
                                                     float4 uv2 : TEXCOORD2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float3 normalWS;
                                                     float4 texCoord0;
                                                     float4 texCoord1;
                                                     float4 texCoord2;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };
                                                struct SurfaceDescriptionInputs
                                                {
                                                     float3 WorldSpaceNormal;
                                                     float3 WorldSpaceViewDirection;
                                                     float3 ObjectSpacePosition;
                                                     float2 NDCPosition;
                                                     float2 PixelPosition;
                                                     float4 uv0;
                                                     float3 TimeParameters;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                     float4 uv0;
                                                     float3 TimeParameters;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float4 texCoord0 : INTERP0;
                                                     float4 texCoord1 : INTERP1;
                                                     float4 texCoord2 : INTERP2;
                                                     float3 positionWS : INTERP3;
                                                     float3 normalWS : INTERP4;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                    #endif
                                                };

                                                PackedVaryings PackVaryings(Varyings input)
                                                {
                                                    PackedVaryings output;
                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                    output.positionCS = input.positionCS;
                                                    output.texCoord0.xyzw = input.texCoord0;
                                                    output.texCoord1.xyzw = input.texCoord1;
                                                    output.texCoord2.xyzw = input.texCoord2;
                                                    output.positionWS.xyz = input.positionWS;
                                                    output.normalWS.xyz = input.normalWS;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }

                                                Varyings UnpackVaryings(PackedVaryings input)
                                                {
                                                    Varyings output;
                                                    output.positionCS = input.positionCS;
                                                    output.texCoord0 = input.texCoord0.xyzw;
                                                    output.texCoord1 = input.texCoord1.xyzw;
                                                    output.texCoord2 = input.texCoord2.xyzw;
                                                    output.positionWS = input.positionWS.xyz;
                                                    output.normalWS = input.normalWS.xyz;
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    output.instanceID = input.instanceID;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                    #endif
                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                    #endif
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    output.cullFace = input.cullFace;
                                                    #endif
                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Graph

                                                // Graph Properties
                                                CBUFFER_START(UnityPerMaterial)
                                                float4 _Color;
                                                float4 _Main_Texture_TexelSize;
                                                float _Texture_Strength;
                                                float4 _Specular_Color;
                                                float _Smoothness;
                                                float _Fresenel_Power;
                                                float4 _Fresenel_Color;
                                                float _Distortion_Speed;
                                                float _Noise_Strength;
                                                float _Wobble_Speed;
                                                float _Wobble;
                                                float _Wobble_Size;
                                                float4 _NormalMap_2_TexelSize;
                                                float4 _NormalMap_TexelSize;
                                                float2 _Normal_Map_Tile_2;
                                                float2 _Normal_Map_Tile;
                                                float _Normal_Strength;
                                                float _Normal_Map_Speed;
                                                float _Normal_Map_Speed_2;
                                                float _Dissolve_Threshold;
                                                float _Dissolve_Noise_Scale;
                                                float _Dissolve_Edge_Width;
                                                float4 _Dissolve_Edge_Color;
                                                float _Dissolve_Height;
                                                float _Dissolve_Strength_X;
                                                float _Dissolve_Strength_Y;
                                                float _Dissolve_Strength_Z;
                                                CBUFFER_END


                                                    // Object and Global properties
                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                    TEXTURE2D(_Main_Texture);
                                                    SAMPLER(sampler_Main_Texture);
                                                    TEXTURE2D(_NormalMap_2);
                                                    SAMPLER(sampler_NormalMap_2);
                                                    TEXTURE2D(_NormalMap);
                                                    SAMPLER(sampler_NormalMap);

                                                    // Graph Includes
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                                    // -- Property used by ScenePickingPass
                                                    #ifdef SCENEPICKINGPASS
                                                    float4 _SelectionID;
                                                    #endif

                                                    // -- Properties used by SceneSelectionPass
                                                    #ifdef SCENESELECTIONPASS
                                                    int _ObjectId;
                                                    int _PassValue;
                                                    #endif

                                                    // Graph Functions

                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                    {
                                                        Out = UV * Tiling + Offset;
                                                    }

                                                    float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                                    {
                                                        float x; Hash_LegacyMod_2_1_float(p, x);
                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                    }

                                                    void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                                    {
                                                        float2 p = UV * Scale.xy;
                                                        float2 ip = floor(p);
                                                        float2 fp = frac(p);
                                                        float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                                        float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                        float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                        float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                    }

                                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                                    {
                                                        Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                                    }

                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_SceneColor_float(float4 UV, out float3 Out)
                                                    {
                                                        Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
                                                    }

                                                    float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                                                    {
                                                        Hash_LegacySine_2_2_float(UV, UV);
                                                        return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                                                    }

                                                    void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                                                    {
                                                        float2 g = floor(UV * CellDensity);
                                                        float2 f = frac(UV * CellDensity);
                                                        float t = 8.0;
                                                        float3 res = float3(8.0, 0.0, 0.0);
                                                        for (int y = -1; y <= 1; y++)
                                                        {
                                                            for (int x = -1; x <= 1; x++)
                                                            {
                                                                float2 lattice = float2(x, y);
                                                                float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                                                float d = distance(lattice + offset, f);
                                                                if (d < res.x)
                                                                {
                                                                    res = float3(d, offset.x, offset.y);
                                                                    Out = res.x;
                                                                    Cells = res.y;
                                                                }
                                                            }
                                                        }
                                                    }

                                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                    {
                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                    }

                                                    void Unity_Add_float(float A, float B, out float Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Negate_float(float In, out float Out)
                                                    {
                                                        Out = -1 * In;
                                                    }

                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                    {
                                                        Out = clamp(In, Min, Max);
                                                    }

                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                    {
                                                        Out = step(Edge, In);
                                                    }

                                                    // Custom interpolators pre vertex
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                    // Graph Vertex
                                                    struct VertexDescription
                                                    {
                                                        float3 Position;
                                                        float3 Normal;
                                                        float3 Tangent;
                                                    };

                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                    {
                                                        VertexDescription description = (VertexDescription)0;
                                                        float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                                                        float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                        float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                        float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                                                        float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                                                        float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                                                        float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                                                        float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                                                        Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                                                        float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                                                        Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                                                        float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                        Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                                                        description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                        description.Normal = IN.ObjectSpaceNormal;
                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                        return description;
                                                    }

                                                    // Custom interpolators, pre surface
                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                    {
                                                    return output;
                                                    }
                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                    #endif

                                                    // Graph Pixel
                                                    struct SurfaceDescription
                                                    {
                                                        float3 BaseColor;
                                                        float3 Emission;
                                                        float Alpha;
                                                        float AlphaClipThreshold;
                                                    };

                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                    {
                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                        float _Property_5504698f499d44d597ec29e40414d968_Out_0_Float = _Fresenel_Power;
                                                        float _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float;
                                                        Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5504698f499d44d597ec29e40414d968_Out_0_Float, _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float);
                                                        float4 _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Fresenel_Color) : _Fresenel_Color;
                                                        float4 _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4((_FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float.xxxx), _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4, _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4);
                                                        float4 _Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
                                                        float4 _ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                                        float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                                                        float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                        float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                        float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                                                        float _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float;
                                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 10, _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float);
                                                        float _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float = _Noise_Strength;
                                                        float _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float;
                                                        Unity_Multiply_float_float(_GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float, _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float, _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float);
                                                        float4 _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4;
                                                        Unity_Add_float4(_ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4, (_Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float.xxxx), _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4);
                                                        float3 _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3;
                                                        Unity_SceneColor_float(_Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4, _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3);
                                                        float3 _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3;
                                                        Unity_Multiply_float3_float3((_Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4.xyz), _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3, _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3);
                                                        float3 _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3;
                                                        Unity_Add_float3((_Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4.xyz), _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3, _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3);
                                                        UnityTexture2D _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                                        float4 _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.tex, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.samplerstate, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_R_4_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.r;
                                                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_G_5_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.g;
                                                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_B_6_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.b;
                                                        float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_A_7_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.a;
                                                        float _Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float = _Texture_Strength;
                                                        float4 _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4(_SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4, (_Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float.xxxx), _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4);
                                                        float3 _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                                                        Unity_Add_float3(_Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3, (_Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4.xyz), _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3);
                                                        float4 _Property_c71e222507ec4b278909b8f19ea5975d_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Dissolve_Edge_Color) : _Dissolve_Edge_Color;
                                                        float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                                                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                                                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                                                        Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                                                        float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                                                        float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                                                        Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                                                        float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                                                        Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                                                        float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                                                        float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                                                        Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                                                        float _Property_10ac528f811d4129ba8dcff5d8984eaf_Out_0_Float = _Dissolve_Edge_Width;
                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                                                        float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                                                        float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                                                        float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                                                        Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                                                        float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                                                        float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                                                        float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                                                        Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                                                        float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                                                        float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                                                        float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                                                        Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                                                        float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                                                        Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                                                        float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                                                        Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                                                        float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                                                        float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                                                        Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                                                        float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                                                        Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                                                        float _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float;
                                                        Unity_Add_float(_Property_10ac528f811d4129ba8dcff5d8984eaf_Out_0_Float, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float);
                                                        float _Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float;
                                                        Unity_Step_float(_Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Add_764e668f505446d98603ef6cb07402a6_Out_2_Float, _Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float);
                                                        float4 _Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4(_Property_c71e222507ec4b278909b8f19ea5975d_Out_0_Vector4, (_Step_30c2ba4abc8f4032a1e31042f6dc0a8b_Out_2_Float.xxxx), _Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4);
                                                        float3 _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3;
                                                        Unity_Add_float3(_Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3, (_Multiply_0d8af34e363741148b183c5eaae56958_Out_2_Vector4.xyz), _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3);
                                                        float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                        Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                                                        surface.BaseColor = _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                                                        surface.Emission = _Add_9315887211934dc6b37ca2846fe06023_Out_2_Vector3;
                                                        surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                        surface.AlphaClipThreshold = 1;
                                                        return surface;
                                                    }

                                                    // --------------------------------------------------
                                                    // Build Graph Inputs
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                    #define VFX_SRP_VARYINGS Varyings
                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                    #endif
                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                    {
                                                        VertexDescriptionInputs output;
                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                        output.ObjectSpaceNormal = input.normalOS;
                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                        output.ObjectSpacePosition = input.positionOS;
                                                        output.uv0 = input.uv0;
                                                        output.TimeParameters = _TimeParameters.xyz;

                                                        return output;
                                                    }
                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                    {
                                                        SurfaceDescriptionInputs output;
                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #if VFX_USE_GRAPH_VALUES
                                                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                    #endif
                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                    #endif



                                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                        float3 unnormalizedNormalWS = input.normalWS;
                                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                        output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                                                        output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                                        #if UNITY_UV_STARTS_AT_TOP
                                                        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                        #else
                                                        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                        #endif

                                                        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                                                        output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                                        output.uv0 = input.texCoord0;
                                                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                    #else
                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                    #endif
                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                            return output;
                                                    }

                                                    // --------------------------------------------------
                                                    // Main

                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                    // --------------------------------------------------
                                                    // Visual Effect Vertex Invocations
                                                    #ifdef HAVE_VFX_MODIFICATION
                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                    #endif

                                                    ENDHLSL
                                                    }
                                                    Pass
                                                    {
                                                        Name "SceneSelectionPass"
                                                        Tags
                                                        {
                                                            "LightMode" = "SceneSelectionPass"
                                                        }

                                                        // Render State
                                                        Cull Off

                                                        // Debug
                                                        // <None>

                                                        // --------------------------------------------------
                                                        // Pass

                                                        HLSLPROGRAM

                                                        // Pragmas
                                                        #pragma target 2.0
                                                        #pragma vertex vert
                                                        #pragma fragment frag

                                                        // Keywords
                                                        // PassKeywords: <None>
                                                        // GraphKeywords: <None>

                                                        // Defines

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_TS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_POSITION_WS
                                                        #define VARYINGS_NEED_TEXCOORD0
                                                        #define FEATURES_GRAPH_VERTEX
                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                                        #define SCENESELECTIONPASS 1
                                                        #define ALPHA_CLIP_THRESHOLD 1
                                                        #define _ALPHATEST_ON 1


                                                        // custom interpolator pre-include
                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                        // Includes
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                        // --------------------------------------------------
                                                        // Structs and Packing

                                                        // custom interpolators pre packing
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                        struct Attributes
                                                        {
                                                             float3 positionOS : POSITION;
                                                             float3 normalOS : NORMAL;
                                                             float4 tangentOS : TANGENT;
                                                             float4 uv0 : TEXCOORD0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 positionWS;
                                                             float4 texCoord0;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct SurfaceDescriptionInputs
                                                        {
                                                             float3 ObjectSpacePosition;
                                                             float4 uv0;
                                                             float3 TimeParameters;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                             float4 uv0;
                                                             float3 TimeParameters;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float4 texCoord0 : INTERP0;
                                                             float3 positionWS : INTERP1;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                            #endif
                                                        };

                                                        PackedVaryings PackVaryings(Varyings input)
                                                        {
                                                            PackedVaryings output;
                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                            output.positionCS = input.positionCS;
                                                            output.texCoord0.xyzw = input.texCoord0;
                                                            output.positionWS.xyz = input.positionWS;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }

                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                        {
                                                            Varyings output;
                                                            output.positionCS = input.positionCS;
                                                            output.texCoord0 = input.texCoord0.xyzw;
                                                            output.positionWS = input.positionWS.xyz;
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            output.instanceID = input.instanceID;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                            #endif
                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                            #endif
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            output.cullFace = input.cullFace;
                                                            #endif
                                                            return output;
                                                        }


                                                        // --------------------------------------------------
                                                        // Graph

                                                        // Graph Properties
                                                        CBUFFER_START(UnityPerMaterial)
                                                        float4 _Color;
                                                        float4 _Main_Texture_TexelSize;
                                                        float _Texture_Strength;
                                                        float4 _Specular_Color;
                                                        float _Smoothness;
                                                        float _Fresenel_Power;
                                                        float4 _Fresenel_Color;
                                                        float _Distortion_Speed;
                                                        float _Noise_Strength;
                                                        float _Wobble_Speed;
                                                        float _Wobble;
                                                        float _Wobble_Size;
                                                        float4 _NormalMap_2_TexelSize;
                                                        float4 _NormalMap_TexelSize;
                                                        float2 _Normal_Map_Tile_2;
                                                        float2 _Normal_Map_Tile;
                                                        float _Normal_Strength;
                                                        float _Normal_Map_Speed;
                                                        float _Normal_Map_Speed_2;
                                                        float _Dissolve_Threshold;
                                                        float _Dissolve_Noise_Scale;
                                                        float _Dissolve_Edge_Width;
                                                        float4 _Dissolve_Edge_Color;
                                                        float _Dissolve_Height;
                                                        float _Dissolve_Strength_X;
                                                        float _Dissolve_Strength_Y;
                                                        float _Dissolve_Strength_Z;
                                                        CBUFFER_END


                                                            // Object and Global properties
                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                            TEXTURE2D(_Main_Texture);
                                                            SAMPLER(sampler_Main_Texture);
                                                            TEXTURE2D(_NormalMap_2);
                                                            SAMPLER(sampler_NormalMap_2);
                                                            TEXTURE2D(_NormalMap);
                                                            SAMPLER(sampler_NormalMap);

                                                            // Graph Includes
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                                            // -- Property used by ScenePickingPass
                                                            #ifdef SCENEPICKINGPASS
                                                            float4 _SelectionID;
                                                            #endif

                                                            // -- Properties used by SceneSelectionPass
                                                            #ifdef SCENESELECTIONPASS
                                                            int _ObjectId;
                                                            int _PassValue;
                                                            #endif

                                                            // Graph Functions

                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                            {
                                                                Out = UV * Tiling + Offset;
                                                            }

                                                            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                                            {
                                                                float x; Hash_LegacyMod_2_1_float(p, x);
                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                            }

                                                            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                                            {
                                                                float2 p = UV * Scale.xy;
                                                                float2 ip = floor(p);
                                                                float2 fp = frac(p);
                                                                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                                                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                            }

                                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Negate_float(float In, out float Out)
                                                            {
                                                                Out = -1 * In;
                                                            }

                                                            void Unity_Add_float(float A, float B, out float Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                            {
                                                                Out = clamp(In, Min, Max);
                                                            }

                                                            float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                                                            {
                                                                Hash_LegacySine_2_2_float(UV, UV);
                                                                return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                                                            }

                                                            void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                                                            {
                                                                float2 g = floor(UV * CellDensity);
                                                                float2 f = frac(UV * CellDensity);
                                                                float t = 8.0;
                                                                float3 res = float3(8.0, 0.0, 0.0);
                                                                for (int y = -1; y <= 1; y++)
                                                                {
                                                                    for (int x = -1; x <= 1; x++)
                                                                    {
                                                                        float2 lattice = float2(x, y);
                                                                        float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                                                        float d = distance(lattice + offset, f);
                                                                        if (d < res.x)
                                                                        {
                                                                            res = float3(d, offset.x, offset.y);
                                                                            Out = res.x;
                                                                            Cells = res.y;
                                                                        }
                                                                    }
                                                                }
                                                            }

                                                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                            {
                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                            }

                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                            {
                                                                Out = step(Edge, In);
                                                            }

                                                            // Custom interpolators pre vertex
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                            // Graph Vertex
                                                            struct VertexDescription
                                                            {
                                                                float3 Position;
                                                                float3 Normal;
                                                                float3 Tangent;
                                                            };

                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                            {
                                                                VertexDescription description = (VertexDescription)0;
                                                                float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                                                                float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                                float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                                float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                                                                float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                                                                float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                                                                float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                                                                float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                                                                Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                                                                float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                                                                Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                                                                float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                                Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                                                                description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                return description;
                                                            }

                                                            // Custom interpolators, pre surface
                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                            {
                                                            return output;
                                                            }
                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                            #endif

                                                            // Graph Pixel
                                                            struct SurfaceDescription
                                                            {
                                                                float Alpha;
                                                                float AlphaClipThreshold;
                                                            };

                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                            {
                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                                                                float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                                                                float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                                                                float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                                                                Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                                                                float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                                                                float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                                                                float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                                                                Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                                                                float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                                                                float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                                                                float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                                                                Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                                                                float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                                                                Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                                                                float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                                                                Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                                                                float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                                                                float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                                                                Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                                                                float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                                                                Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                                                                float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                                                                float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                                float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                                float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                                                                float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                                                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                                                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                                                                Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                                                                float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                                                                float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                                                                Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                                                                float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                                                                Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                                                                float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                                                                float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                                                                Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                                                                float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                                Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                                                                surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                                surface.AlphaClipThreshold = 1;
                                                                return surface;
                                                            }

                                                            // --------------------------------------------------
                                                            // Build Graph Inputs
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                            #define VFX_SRP_VARYINGS Varyings
                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                            #endif
                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                            {
                                                                VertexDescriptionInputs output;
                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                output.ObjectSpacePosition = input.positionOS;
                                                                output.uv0 = input.uv0;
                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                return output;
                                                            }
                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                            {
                                                                SurfaceDescriptionInputs output;
                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #if VFX_USE_GRAPH_VALUES
                                                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                            #endif
                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                            #endif







                                                                output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                #else
                                                                #endif


                                                                output.uv0 = input.texCoord0;
                                                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                            #else
                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                            #endif
                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                    return output;
                                                            }

                                                            // --------------------------------------------------
                                                            // Main

                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                            // --------------------------------------------------
                                                            // Visual Effect Vertex Invocations
                                                            #ifdef HAVE_VFX_MODIFICATION
                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                            #endif

                                                            ENDHLSL
                                                            }
                                                            Pass
                                                            {
                                                                Name "ScenePickingPass"
                                                                Tags
                                                                {
                                                                    "LightMode" = "Picking"
                                                                }

                                                                // Render State
                                                                Cull Off

                                                                // Debug
                                                                // <None>

                                                                // --------------------------------------------------
                                                                // Pass

                                                                HLSLPROGRAM

                                                                // Pragmas
                                                                #pragma target 2.0
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_TS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                                                #define SCENEPICKINGPASS 1
                                                                #define ALPHA_CLIP_THRESHOLD 1
                                                                #define _ALPHATEST_ON 1


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                // --------------------------------------------------
                                                                // Structs and Packing

                                                                // custom interpolators pre packing
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                struct Attributes
                                                                {
                                                                     float3 positionOS : POSITION;
                                                                     float3 normalOS : NORMAL;
                                                                     float4 tangentOS : TANGENT;
                                                                     float4 uv0 : TEXCOORD0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 positionWS;
                                                                     float4 texCoord0;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct SurfaceDescriptionInputs
                                                                {
                                                                     float3 ObjectSpacePosition;
                                                                     float4 uv0;
                                                                     float3 TimeParameters;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                     float4 uv0;
                                                                     float3 TimeParameters;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float4 texCoord0 : INTERP0;
                                                                     float3 positionWS : INTERP1;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                    #endif
                                                                };

                                                                PackedVaryings PackVaryings(Varyings input)
                                                                {
                                                                    PackedVaryings output;
                                                                    ZERO_INITIALIZE(PackedVaryings, output);
                                                                    output.positionCS = input.positionCS;
                                                                    output.texCoord0.xyzw = input.texCoord0;
                                                                    output.positionWS.xyz = input.positionWS;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }

                                                                Varyings UnpackVaryings(PackedVaryings input)
                                                                {
                                                                    Varyings output;
                                                                    output.positionCS = input.positionCS;
                                                                    output.texCoord0 = input.texCoord0.xyzw;
                                                                    output.positionWS = input.positionWS.xyz;
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    output.instanceID = input.instanceID;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                    #endif
                                                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                    #endif
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    output.cullFace = input.cullFace;
                                                                    #endif
                                                                    return output;
                                                                }


                                                                // --------------------------------------------------
                                                                // Graph

                                                                // Graph Properties
                                                                CBUFFER_START(UnityPerMaterial)
                                                                float4 _Color;
                                                                float4 _Main_Texture_TexelSize;
                                                                float _Texture_Strength;
                                                                float4 _Specular_Color;
                                                                float _Smoothness;
                                                                float _Fresenel_Power;
                                                                float4 _Fresenel_Color;
                                                                float _Distortion_Speed;
                                                                float _Noise_Strength;
                                                                float _Wobble_Speed;
                                                                float _Wobble;
                                                                float _Wobble_Size;
                                                                float4 _NormalMap_2_TexelSize;
                                                                float4 _NormalMap_TexelSize;
                                                                float2 _Normal_Map_Tile_2;
                                                                float2 _Normal_Map_Tile;
                                                                float _Normal_Strength;
                                                                float _Normal_Map_Speed;
                                                                float _Normal_Map_Speed_2;
                                                                float _Dissolve_Threshold;
                                                                float _Dissolve_Noise_Scale;
                                                                float _Dissolve_Edge_Width;
                                                                float4 _Dissolve_Edge_Color;
                                                                float _Dissolve_Height;
                                                                float _Dissolve_Strength_X;
                                                                float _Dissolve_Strength_Y;
                                                                float _Dissolve_Strength_Z;
                                                                CBUFFER_END


                                                                    // Object and Global properties
                                                                    SAMPLER(SamplerState_Linear_Repeat);
                                                                    TEXTURE2D(_Main_Texture);
                                                                    SAMPLER(sampler_Main_Texture);
                                                                    TEXTURE2D(_NormalMap_2);
                                                                    SAMPLER(sampler_NormalMap_2);
                                                                    TEXTURE2D(_NormalMap);
                                                                    SAMPLER(sampler_NormalMap);

                                                                    // Graph Includes
                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                                                    // -- Property used by ScenePickingPass
                                                                    #ifdef SCENEPICKINGPASS
                                                                    float4 _SelectionID;
                                                                    #endif

                                                                    // -- Properties used by SceneSelectionPass
                                                                    #ifdef SCENESELECTIONPASS
                                                                    int _ObjectId;
                                                                    int _PassValue;
                                                                    #endif

                                                                    // Graph Functions

                                                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                    {
                                                                        Out = UV * Tiling + Offset;
                                                                    }

                                                                    float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                                                    {
                                                                        float x; Hash_LegacyMod_2_1_float(p, x);
                                                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                    }

                                                                    void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                                                    {
                                                                        float2 p = UV * Scale.xy;
                                                                        float2 ip = floor(p);
                                                                        float2 fp = frac(p);
                                                                        float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                                                        float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                        float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                        float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                    }

                                                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Negate_float(float In, out float Out)
                                                                    {
                                                                        Out = -1 * In;
                                                                    }

                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                    {
                                                                        Out = clamp(In, Min, Max);
                                                                    }

                                                                    float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                                                                    {
                                                                        Hash_LegacySine_2_2_float(UV, UV);
                                                                        return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                                                                    }

                                                                    void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                                                                    {
                                                                        float2 g = floor(UV * CellDensity);
                                                                        float2 f = frac(UV * CellDensity);
                                                                        float t = 8.0;
                                                                        float3 res = float3(8.0, 0.0, 0.0);
                                                                        for (int y = -1; y <= 1; y++)
                                                                        {
                                                                            for (int x = -1; x <= 1; x++)
                                                                            {
                                                                                float2 lattice = float2(x, y);
                                                                                float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                                                                float d = distance(lattice + offset, f);
                                                                                if (d < res.x)
                                                                                {
                                                                                    res = float3(d, offset.x, offset.y);
                                                                                    Out = res.x;
                                                                                    Cells = res.y;
                                                                                }
                                                                            }
                                                                        }
                                                                    }

                                                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                                    {
                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                    }

                                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                                    {
                                                                        Out = step(Edge, In);
                                                                    }

                                                                    // Custom interpolators pre vertex
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                    // Graph Vertex
                                                                    struct VertexDescription
                                                                    {
                                                                        float3 Position;
                                                                        float3 Normal;
                                                                        float3 Tangent;
                                                                    };

                                                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                    {
                                                                        VertexDescription description = (VertexDescription)0;
                                                                        float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                                                                        float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                                        float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                                        float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                                                                        float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                                                                        float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                                                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                                                                        float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                                                                        float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                                                                        Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                                                                        float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                                                                        Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                                                                        float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                                        Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                                                                        description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                                        description.Normal = IN.ObjectSpaceNormal;
                                                                        description.Tangent = IN.ObjectSpaceTangent;
                                                                        return description;
                                                                    }

                                                                    // Custom interpolators, pre surface
                                                                    #ifdef FEATURES_GRAPH_VERTEX
                                                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                    {
                                                                    return output;
                                                                    }
                                                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                    #endif

                                                                    // Graph Pixel
                                                                    struct SurfaceDescription
                                                                    {
                                                                        float Alpha;
                                                                        float AlphaClipThreshold;
                                                                    };

                                                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                    {
                                                                        SurfaceDescription surface = (SurfaceDescription)0;
                                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                                                                        float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                                                                        float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                                                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                                                                        float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                                                                        float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                                                                        float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                                                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                                                                        float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                                                                        float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                                                                        float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                                                                        Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                                                                        float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                                                                        float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                                                                        float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                                                                        Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                                                                        float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                                                                        Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                                                                        float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                                                                        float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                                                                        Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                                                                        float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                                                                        Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                                                                        float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                                                                        float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                                        float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                                        float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                                                                        float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                                                                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                                                                        float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                                                                        Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                                                                        float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                                                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                                                                        float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                                                                        float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                                                                        Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                                                                        float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                                                                        float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                                                                        Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                                                                        float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                                        Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                                                                        surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                                        surface.AlphaClipThreshold = 1;
                                                                        return surface;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Build Graph Inputs
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #define VFX_SRP_ATTRIBUTES Attributes
                                                                    #define VFX_SRP_VARYINGS Varyings
                                                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                    #endif
                                                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                    {
                                                                        VertexDescriptionInputs output;
                                                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                        output.ObjectSpaceNormal = input.normalOS;
                                                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                        output.ObjectSpacePosition = input.positionOS;
                                                                        output.uv0 = input.uv0;
                                                                        output.TimeParameters = _TimeParameters.xyz;

                                                                        return output;
                                                                    }
                                                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                    {
                                                                        SurfaceDescriptionInputs output;
                                                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #if VFX_USE_GRAPH_VALUES
                                                                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                                    #endif
                                                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                    #endif







                                                                        output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                        #else
                                                                        #endif


                                                                        output.uv0 = input.texCoord0;
                                                                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                    #else
                                                                    #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                    #endif
                                                                    #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                            return output;
                                                                    }

                                                                    // --------------------------------------------------
                                                                    // Main

                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
                                                                    Pass
                                                                    {
                                                                        // Name: <None>
                                                                        Tags
                                                                        {
                                                                            "LightMode" = "Universal2D"
                                                                        }

                                                                        // Render State
                                                                        Cull Off
                                                                        Blend One Zero
                                                                        ZTest LEqual
                                                                        ZWrite On

                                                                        // Debug
                                                                        // <None>

                                                                        // --------------------------------------------------
                                                                        // Pass

                                                                        HLSLPROGRAM

                                                                        // Pragmas
                                                                        #pragma target 2.0
                                                                        #pragma vertex vert
                                                                        #pragma fragment frag

                                                                        // Keywords
                                                                        // PassKeywords: <None>
                                                                        // GraphKeywords: <None>

                                                                        // Defines

                                                                        #define _NORMALMAP 1
                                                                        #define _NORMAL_DROPOFF_TS 1
                                                                        #define ATTRIBUTES_NEED_NORMAL
                                                                        #define ATTRIBUTES_NEED_TANGENT
                                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                                        #define VARYINGS_NEED_POSITION_WS
                                                                        #define VARYINGS_NEED_NORMAL_WS
                                                                        #define VARYINGS_NEED_TEXCOORD0
                                                                        #define FEATURES_GRAPH_VERTEX
                                                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                        #define SHADERPASS SHADERPASS_2D
                                                                        #define _ALPHATEST_ON 1
                                                                        #define REQUIRE_OPAQUE_TEXTURE


                                                                        // custom interpolator pre-include
                                                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                        // Includes
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                                                        // --------------------------------------------------
                                                                        // Structs and Packing

                                                                        // custom interpolators pre packing
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                        struct Attributes
                                                                        {
                                                                             float3 positionOS : POSITION;
                                                                             float3 normalOS : NORMAL;
                                                                             float4 tangentOS : TANGENT;
                                                                             float4 uv0 : TEXCOORD0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct Varyings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float3 positionWS;
                                                                             float3 normalWS;
                                                                             float4 texCoord0;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };
                                                                        struct SurfaceDescriptionInputs
                                                                        {
                                                                             float3 WorldSpaceNormal;
                                                                             float3 WorldSpaceViewDirection;
                                                                             float3 ObjectSpacePosition;
                                                                             float2 NDCPosition;
                                                                             float2 PixelPosition;
                                                                             float4 uv0;
                                                                             float3 TimeParameters;
                                                                        };
                                                                        struct VertexDescriptionInputs
                                                                        {
                                                                             float3 ObjectSpaceNormal;
                                                                             float3 ObjectSpaceTangent;
                                                                             float3 ObjectSpacePosition;
                                                                             float4 uv0;
                                                                             float3 TimeParameters;
                                                                        };
                                                                        struct PackedVaryings
                                                                        {
                                                                             float4 positionCS : SV_POSITION;
                                                                             float4 texCoord0 : INTERP0;
                                                                             float3 positionWS : INTERP1;
                                                                             float3 normalWS : INTERP2;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                            #endif
                                                                        };

                                                                        PackedVaryings PackVaryings(Varyings input)
                                                                        {
                                                                            PackedVaryings output;
                                                                            ZERO_INITIALIZE(PackedVaryings, output);
                                                                            output.positionCS = input.positionCS;
                                                                            output.texCoord0.xyzw = input.texCoord0;
                                                                            output.positionWS.xyz = input.positionWS;
                                                                            output.normalWS.xyz = input.normalWS;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }

                                                                        Varyings UnpackVaryings(PackedVaryings input)
                                                                        {
                                                                            Varyings output;
                                                                            output.positionCS = input.positionCS;
                                                                            output.texCoord0 = input.texCoord0.xyzw;
                                                                            output.positionWS = input.positionWS.xyz;
                                                                            output.normalWS = input.normalWS.xyz;
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            output.instanceID = input.instanceID;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                            #endif
                                                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                            #endif
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            output.cullFace = input.cullFace;
                                                                            #endif
                                                                            return output;
                                                                        }


                                                                        // --------------------------------------------------
                                                                        // Graph

                                                                        // Graph Properties
                                                                        CBUFFER_START(UnityPerMaterial)
                                                                        float4 _Color;
                                                                        float4 _Main_Texture_TexelSize;
                                                                        float _Texture_Strength;
                                                                        float4 _Specular_Color;
                                                                        float _Smoothness;
                                                                        float _Fresenel_Power;
                                                                        float4 _Fresenel_Color;
                                                                        float _Distortion_Speed;
                                                                        float _Noise_Strength;
                                                                        float _Wobble_Speed;
                                                                        float _Wobble;
                                                                        float _Wobble_Size;
                                                                        float4 _NormalMap_2_TexelSize;
                                                                        float4 _NormalMap_TexelSize;
                                                                        float2 _Normal_Map_Tile_2;
                                                                        float2 _Normal_Map_Tile;
                                                                        float _Normal_Strength;
                                                                        float _Normal_Map_Speed;
                                                                        float _Normal_Map_Speed_2;
                                                                        float _Dissolve_Threshold;
                                                                        float _Dissolve_Noise_Scale;
                                                                        float _Dissolve_Edge_Width;
                                                                        float4 _Dissolve_Edge_Color;
                                                                        float _Dissolve_Height;
                                                                        float _Dissolve_Strength_X;
                                                                        float _Dissolve_Strength_Y;
                                                                        float _Dissolve_Strength_Z;
                                                                        CBUFFER_END


                                                                            // Object and Global properties
                                                                            SAMPLER(SamplerState_Linear_Repeat);
                                                                            TEXTURE2D(_Main_Texture);
                                                                            SAMPLER(sampler_Main_Texture);
                                                                            TEXTURE2D(_NormalMap_2);
                                                                            SAMPLER(sampler_NormalMap_2);
                                                                            TEXTURE2D(_NormalMap);
                                                                            SAMPLER(sampler_NormalMap);

                                                                            // Graph Includes
                                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                                                            // -- Property used by ScenePickingPass
                                                                            #ifdef SCENEPICKINGPASS
                                                                            float4 _SelectionID;
                                                                            #endif

                                                                            // -- Properties used by SceneSelectionPass
                                                                            #ifdef SCENESELECTIONPASS
                                                                            int _ObjectId;
                                                                            int _PassValue;
                                                                            #endif

                                                                            // Graph Functions

                                                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                            {
                                                                                Out = UV * Tiling + Offset;
                                                                            }

                                                                            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                                                            {
                                                                                float x; Hash_LegacyMod_2_1_float(p, x);
                                                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                                                            }

                                                                            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                                                            {
                                                                                float2 p = UV * Scale.xy;
                                                                                float2 ip = floor(p);
                                                                                float2 fp = frac(p);
                                                                                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                                                                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                                                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                                                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                                                            }

                                                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
                                                                            {
                                                                                Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
                                                                            }

                                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A * B;
                                                                            }

                                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_SceneColor_float(float4 UV, out float3 Out)
                                                                            {
                                                                                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
                                                                            }

                                                                            void Unity_Negate_float(float In, out float Out)
                                                                            {
                                                                                Out = -1 * In;
                                                                            }

                                                                            void Unity_Add_float(float A, float B, out float Out)
                                                                            {
                                                                                Out = A + B;
                                                                            }

                                                                            void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                                                                            {
                                                                                Out = clamp(In, Min, Max);
                                                                            }

                                                                            float2 Unity_Voronoi_RandomVector_LegacySine_float(float2 UV, float offset)
                                                                            {
                                                                                Hash_LegacySine_2_2_float(UV, UV);
                                                                                return float2(sin(UV.y * offset), cos(UV.x * offset)) * 0.5 + 0.5;
                                                                            }

                                                                            void Unity_Voronoi_LegacySine_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
                                                                            {
                                                                                float2 g = floor(UV * CellDensity);
                                                                                float2 f = frac(UV * CellDensity);
                                                                                float t = 8.0;
                                                                                float3 res = float3(8.0, 0.0, 0.0);
                                                                                for (int y = -1; y <= 1; y++)
                                                                                {
                                                                                    for (int x = -1; x <= 1; x++)
                                                                                    {
                                                                                        float2 lattice = float2(x, y);
                                                                                        float2 offset = Unity_Voronoi_RandomVector_LegacySine_float(lattice + g, AngleOffset);
                                                                                        float d = distance(lattice + offset, f);
                                                                                        if (d < res.x)
                                                                                        {
                                                                                            res = float3(d, offset.x, offset.y);
                                                                                            Out = res.x;
                                                                                            Cells = res.y;
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }

                                                                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                                            {
                                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                            }

                                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                                            {
                                                                                Out = step(Edge, In);
                                                                            }

                                                                            // Custom interpolators pre vertex
                                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                            // Graph Vertex
                                                                            struct VertexDescription
                                                                            {
                                                                                float3 Position;
                                                                                float3 Normal;
                                                                                float3 Tangent;
                                                                            };

                                                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                            {
                                                                                VertexDescription description = (VertexDescription)0;
                                                                                float _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float = _Wobble_Speed;
                                                                                float _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float;
                                                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_3b5dd621186942bfb97e21dc2ba3e5a7_Out_0_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                                                float2 _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2 = float2(_Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float, _Multiply_c5272776178e4fd2985d00e1c074e99f_Out_2_Float);
                                                                                float2 _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (0, 1), _Vector2_23b7c04725cb4f66b7c4787bbf360336_Out_0_Vector2, _TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2);
                                                                                float _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float = _Wobble;
                                                                                float _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float;
                                                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_24b4c52aff7a46549cba6cb5a14e97f0_Out_3_Vector2, _Property_02af696a9c0d478f8a67e332a0406a03_Out_0_Float, _GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float);
                                                                                float _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float = _Wobble_Size;
                                                                                float _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float;
                                                                                Unity_Multiply_float_float(_GradientNoise_c1cd912cdd324bbda414408ec24a98bb_Out_2_Float, _Property_92ce8313e0dc45fd83df7482a6e8dfde_Out_0_Float, _Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float);
                                                                                float3 _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3;
                                                                                Unity_Multiply_float3_float3((_Multiply_63343ce39422455eaa1a8f69849c2270_Out_2_Float.xxx), IN.ObjectSpaceNormal, _Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3);
                                                                                float3 _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                                                Unity_Add_float3(_Multiply_9ab0faa48ff041f69519821f43d8d108_Out_2_Vector3, IN.ObjectSpacePosition, _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3);
                                                                                description.Position = _Add_500fcd2b31cd47cb8d2142f67e190d6d_Out_2_Vector3;
                                                                                description.Normal = IN.ObjectSpaceNormal;
                                                                                description.Tangent = IN.ObjectSpaceTangent;
                                                                                return description;
                                                                            }

                                                                            // Custom interpolators, pre surface
                                                                            #ifdef FEATURES_GRAPH_VERTEX
                                                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                            {
                                                                            return output;
                                                                            }
                                                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                            #endif

                                                                            // Graph Pixel
                                                                            struct SurfaceDescription
                                                                            {
                                                                                float3 BaseColor;
                                                                                float Alpha;
                                                                                float AlphaClipThreshold;
                                                                            };

                                                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                            {
                                                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                                                float _Property_5504698f499d44d597ec29e40414d968_Out_0_Float = _Fresenel_Power;
                                                                                float _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float;
                                                                                Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_5504698f499d44d597ec29e40414d968_Out_0_Float, _FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float);
                                                                                float4 _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Fresenel_Color) : _Fresenel_Color;
                                                                                float4 _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4;
                                                                                Unity_Multiply_float4_float4((_FresnelEffect_d74d8ec22ad54c65a41f58f92603b11b_Out_3_Float.xxxx), _Property_ad638dd4afd14cb0bd8cc7da59dc57ff_Out_0_Vector4, _Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4);
                                                                                float4 _Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
                                                                                float4 _ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                                                                float _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float = _Distortion_Speed;
                                                                                float _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float;
                                                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_a1182db81c6b490ea70e0696134c62ad_Out_0_Float, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                                                float2 _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2 = float2(0, _Multiply_505b61d4d487488585acd90a0e7ac25d_Out_2_Float);
                                                                                float2 _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2;
                                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), _Vector2_e06f457010394100bef36fe70eef9023_Out_0_Vector2, _TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2);
                                                                                float _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float;
                                                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 10, _GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float);
                                                                                float _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float = _Noise_Strength;
                                                                                float _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float;
                                                                                Unity_Multiply_float_float(_GradientNoise_b03feb7daad84433891f42f465555490_Out_2_Float, _Property_342411bc4c7846d7af63f9b4ebe9125b_Out_0_Float, _Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float);
                                                                                float4 _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4;
                                                                                Unity_Add_float4(_ScreenPosition_90abef7d15464a8aa9a2b47460240f61_Out_0_Vector4, (_Multiply_85f0abb444a7405bb8f010c43c8c1331_Out_2_Float.xxxx), _Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4);
                                                                                float3 _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3;
                                                                                Unity_SceneColor_float(_Add_f7888c6583ed4b88a6a859231f3ebb41_Out_2_Vector4, _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3);
                                                                                float3 _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3;
                                                                                Unity_Multiply_float3_float3((_Property_df94601580bc4f6eb6b4d1df201b5296_Out_0_Vector4.xyz), _SceneColor_0f559b3ebbf74215a15804c313c7ceb0_Out_1_Vector3, _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3);
                                                                                float3 _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3;
                                                                                Unity_Add_float3((_Multiply_9564883842584bcc9ee007b3b52dd078_Out_2_Vector4.xyz), _Multiply_dace753bf56d4e39b589d516c7f924dd_Out_2_Vector3, _Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3);
                                                                                UnityTexture2D _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
                                                                                float4 _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.tex, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.samplerstate, _Property_f334206f78b849df979f101e7fb58433_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                                                                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_R_4_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.r;
                                                                                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_G_5_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.g;
                                                                                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_B_6_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.b;
                                                                                float _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_A_7_Float = _SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4.a;
                                                                                float _Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float = _Texture_Strength;
                                                                                float4 _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4;
                                                                                Unity_Multiply_float4_float4(_SampleTexture2D_015c7c7d977846eca570136bd9a525d0_RGBA_0_Vector4, (_Property_33c606453cd94b24a0045532520e4f5b_Out_0_Float.xxxx), _Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4);
                                                                                float3 _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                                                                                Unity_Add_float3(_Add_f956d8e3ead6447c92e47410e2cfc42b_Out_2_Vector3, (_Multiply_b214ab6f24dc4c1eac08d59b485a7a69_Out_2_Vector4.xyz), _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3);
                                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float = IN.ObjectSpacePosition[0];
                                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float = IN.ObjectSpacePosition[1];
                                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float = IN.ObjectSpacePosition[2];
                                                                                float _Split_200456fcb0f1422b9cd21055c4a97db9_A_4_Float = 0;
                                                                                float _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float;
                                                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_R_1_Float, _Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float);
                                                                                float _Property_bd66deb161284a309f36189b0520061d_Out_0_Float = _Dissolve_Strength_X;
                                                                                float _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float;
                                                                                Unity_Multiply_float_float(_Negate_2efa219b3def49ebb6b54dc9475c2334_Out_1_Float, _Property_bd66deb161284a309f36189b0520061d_Out_0_Float, _Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float);
                                                                                float _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float;
                                                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_G_2_Float, _Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float);
                                                                                float _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float = _Dissolve_Strength_Y;
                                                                                float _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float;
                                                                                Unity_Multiply_float_float(_Negate_bb87fe33a8e44ea3a3ffe387e2341488_Out_1_Float, _Property_3ed36cf9c44a40439f3c761ed4ddb9b4_Out_0_Float, _Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float);
                                                                                float _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float;
                                                                                Unity_Negate_float(_Split_200456fcb0f1422b9cd21055c4a97db9_B_3_Float, _Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float);
                                                                                float _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float = _Dissolve_Strength_Z;
                                                                                float _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float;
                                                                                Unity_Multiply_float_float(_Negate_6458f0b939dd44cbaa36bfd5cbe896c6_Out_1_Float, _Property_7e03977ee564485392f9ab0bc8169fb7_Out_0_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float);
                                                                                float _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float;
                                                                                Unity_Add_float(_Multiply_bdd5da1a3e5a40a2a1a875cbce109ddc_Out_2_Float, _Multiply_342318be1eda4db39cff89b0d253d86b_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float);
                                                                                float _Add_44380228df7646a19537366c7cae6245_Out_2_Float;
                                                                                Unity_Add_float(_Multiply_5687ae7ee9ef4dcab52314fcb9534d55_Out_2_Float, _Add_80cf4c612bab4b4fb0add10c47ae516c_Out_2_Float, _Add_44380228df7646a19537366c7cae6245_Out_2_Float);
                                                                                float _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float = _Dissolve_Height;
                                                                                float _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float;
                                                                                Unity_Add_float(_Add_44380228df7646a19537366c7cae6245_Out_2_Float, _Property_7e98870077ce48dbb932f602c5f8819c_Out_0_Float, _Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float);
                                                                                float _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float;
                                                                                Unity_Clamp_float(_Add_d5e394ad91bb430c9c1eae1c68ecdae0_Out_2_Float, -1, 1, _Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float);
                                                                                float _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float = _Dissolve_Noise_Scale;
                                                                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float;
                                                                                float _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float;
                                                                                Unity_Voronoi_LegacySine_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, 2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _Voronoi_bc3a3e97b8d444d48da7288c747f1146_Cells_4_Float);
                                                                                float _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float;
                                                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_9a34782671b046e7949979e2488f72ab_Out_3_Vector2, _Property_f6db3201402d4cb39fe2261e6e5e8989_Out_0_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float);
                                                                                float _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float;
                                                                                Unity_Multiply_float_float(_Voronoi_bc3a3e97b8d444d48da7288c747f1146_Out_3_Float, _GradientNoise_af002b4c00bc43dbbf10fd35b641d3d0_Out_2_Float, _Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float);
                                                                                float _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float;
                                                                                Unity_Remap_float(_Multiply_a10d7fa79f1d4f26a5e9c08a6692eb55_Out_2_Float, float2 (0, 1), float2 (-1, 1), _Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float);
                                                                                float _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float = _Dissolve_Threshold;
                                                                                float _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float;
                                                                                Unity_Add_float(_Remap_8208f28029444838a3ac725c8a916a60_Out_3_Float, _Property_e8b83c48717d4f2aa7bd853c855fd8bc_Out_0_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float);
                                                                                float _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                                                Unity_Step_float(_Clamp_d14c5a69922d4f65be2a626ee17fbb5f_Out_3_Float, _Add_d517cb8cb7f24f80a144246fecfa0ae4_Out_2_Float, _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float);
                                                                                surface.BaseColor = _Add_724e3af54d694a42b47a324d31a52802_Out_2_Vector3;
                                                                                surface.Alpha = _Step_8a25cd9b719f4c1eac5e6cf6197f66cd_Out_2_Float;
                                                                                surface.AlphaClipThreshold = 1;
                                                                                return surface;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Build Graph Inputs
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #define VFX_SRP_ATTRIBUTES Attributes
                                                                            #define VFX_SRP_VARYINGS Varyings
                                                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                                                            #endif
                                                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                            {
                                                                                VertexDescriptionInputs output;
                                                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                                output.ObjectSpaceNormal = input.normalOS;
                                                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                                output.ObjectSpacePosition = input.positionOS;
                                                                                output.uv0 = input.uv0;
                                                                                output.TimeParameters = _TimeParameters.xyz;

                                                                                return output;
                                                                            }
                                                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                            {
                                                                                SurfaceDescriptionInputs output;
                                                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #if VFX_USE_GRAPH_VALUES
                                                                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                                                            #endif
                                                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                                                            #endif



                                                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                                                float3 unnormalizedNormalWS = input.normalWS;
                                                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                                                output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                                                                                output.ObjectSpacePosition = TransformWorldToObject(input.positionWS);

                                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                                                #else
                                                                                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                                                #endif

                                                                                output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                                                                                output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                                                                output.uv0 = input.texCoord0;
                                                                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                                                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                            #else
                                                                            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                            #endif
                                                                            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                    return output;
                                                                            }

                                                                            // --------------------------------------------------
                                                                            // Main

                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                            // --------------------------------------------------
                                                                            // Visual Effect Vertex Invocations
                                                                            #ifdef HAVE_VFX_MODIFICATION
                                                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                            #endif

                                                                            ENDHLSL
                                                                            }
    }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                                CustomEditorForRenderPipeline "NekoLegends.WaterMagicShaderInspector" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                                FallBack "Hidden/Shader Graph/FallbackError"
}