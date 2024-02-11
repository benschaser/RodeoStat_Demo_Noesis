#include <metal_stdlib>
using namespace metal;

struct In
{
    float2 position [[ attribute(0) ]];

#if HAS_COLOR
    half4 color [[ attribute(1) ]];
#endif

#if HAS_UV0
    float2 uv0 [[ attribute(2) ]];
#endif

#if HAS_UV1
    float2 uv1 [[ attribute(3) ]];
#endif

#if HAS_COVERAGE
    half coverage [[ attribute(4) ]];
#endif

#if HAS_RECT
    float4 rect [[ attribute(5) ]];
#endif

#if HAS_TILE
    float4 tile [[ attribute(6) ]];
#endif

#if HAS_IMAGE_POSITION
    float4 imagePos [[ attribute(7) ]];
#endif
};

struct Out
{
    float4 position [[ position ]];

#if HAS_COLOR
    half4 color [[ flat ]];
#endif

#if HAS_UV0
    float2 uv0;
#endif

#if HAS_UV1
    float2 uv1;
#endif

#if DOWNSAMPLE
    float2 uv2;
    float2 uv3;
#endif

#if SDF
    float2 st1;
#endif

#if HAS_COVERAGE
    half coverage;
#endif

#if HAS_RECT
    float4 rect [[ flat ]];
#endif

#if HAS_TILE
    float4 tile [[ flat ]];
#endif

#if HAS_IMAGE_POSITION
    float4 imagePos;
#endif
};

struct U0
{
   float4x4 projectionMtx;
};

struct U1
{
    float2 textureSize;
};

#if SRGB
static float SRGBToLinear(float v)
{
    if (v <= 0.04045)
    {
    return v * (1.0 / 12.92);
    }
    else
    {
    return pow( v * (1.0 / 1.055) + 0.0521327, 2.4);
    }
}
#endif

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
vertex Out FNAME(In i [[ stage_in ]], constant U0& u0 [[ buffer(1) ]], constant U1& u1 [[ buffer(2) ]])
{
    Out o;
    o.position = (float4(i.position, 0, 1) * u0.projectionMtx);

#if HAS_COLOR
    o.color = i.color;
#endif

#if HAS_COLOR
  #if SRGB
    o.color.r = SRGBToLinear(i.color.r);
    o.color.g = SRGBToLinear(i.color.g);
    o.color.b = SRGBToLinear(i.color.b);
    o.color.a = i.color.a;
  #else
    o.color = i.color;
  #endif
#endif

#if DOWNSAMPLE
    o.uv0 = i.uv0 + float2(i.uv1.x, i.uv1.y);
    o.uv1 = i.uv0 + float2(i.uv1.x, -i.uv1.y);
    o.uv2 = i.uv0 + float2(-i.uv1.x, i.uv1.y);
    o.uv3 = i.uv0 + float2(-i.uv1.x, -i.uv1.y);
#else
    #if HAS_UV0
      o.uv0 = i.uv0;
    #endif
    #if HAS_UV1
      o.uv1 = i.uv1;
    #endif
#endif

#if SDF
    o.st1 = i.uv1 * u1.textureSize;
#endif

#if HAS_COVERAGE
    o.coverage = i.coverage;
#endif

#if HAS_RECT
    o.rect = i.rect;
#endif

#if HAS_TILE
    o.tile = i.tile;
#endif

#if HAS_IMAGE_POSITION
    o.imagePos = i.imagePos;
#endif

    return o;
}
