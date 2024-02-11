#include <metal_stdlib>
using namespace metal;

#if PAINT_SOLID
    #define HAS_COLOR 1
#endif

#if PAINT_LINEAR || PAINT_RADIAL || PAINT_PATTERN
    #define HAS_UV0 1
#endif

#if CLAMP_PATTERN
    #define HAS_RECT 1
#endif

#if REPEAT_PATTERN || MIRRORU_PATTERN || MIRRORV_PATTERN || MIRROR_PATTERN
    #define HAS_RECT 1
    #define HAS_TILE 1
#endif

#if EFFECT_PATH_AA
    #define HAS_COVERAGE 1
#endif

#if EFFECT_SDF || EFFECT_SDF_LCD
    #define HAS_UV1 1
    #define HAS_ST1 1
    #define SDF_SCALE 7.96875h
    #define SDF_BIAS 0.50196078431h
    #define SDF_AA_FACTOR 0.65h
    #define SDF_BASE_MIN 0.125h
    #define SDF_BASE_MAX 0.25h
    #define SDF_BASE_DEV -0.65h
#endif

#if EFFECT_OPACITY
    #define HAS_UV1 1
#endif

#if EFFECT_SHADOW
    #define HAS_UV1 1
    #define HAS_RECT 1
#endif

#if EFFECT_BLUR
    #define HAS_UV1 1
#endif

#if EFFECT_DOWNSAMPLE
    #define HAS_UV0 1
    #define HAS_UV1 1
    #define HAS_UV2 1
    #define HAS_UV3 1
#endif

#if EFFECT_UPSAMPLE
    #define HAS_COLOR 1
    #define HAS_UV0 1
    #define HAS_UV1 1
#endif

struct U0
{
#if EFFECT_RGBA
    float4 rgba;
#endif

#if PAINT_LINEAR || PAINT_PATTERN
    float opacity;
#endif

#if PAINT_RADIAL
    packed_float4 radialGrad0;
    packed_float3 radialGrad1;
#endif
};

#if EFFECT_BLUR
struct U1
{
    float blend;
};
#endif

#if EFFECT_SHADOW
struct U1
{
    packed_float4 shadowColor;
    packed_float2 shadowOffset;
    float blend;
};
#endif

struct In
{
#if HAS_COLOR
    half4 color [[ flat ]];
#endif

#if HAS_UV0
    float2 uv0;
#endif

#if HAS_UV1
    float2 uv1;
#endif

#if HAS_UV2
    float2 uv2;
#endif

#if HAS_UV3
    float2 uv3;
#endif

#if HAS_ST1
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
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fragment half4 FNAME(In i [[ stage_in ]], constant U0& u0 [[ buffer(0) ]], 

    #if EFFECT_BLUR || EFFECT_SHADOW
        constant U1& u1 [[ buffer(1) ]],
    #endif

    texture2d<half> pattern [[ texture(0) ]], sampler patternSampler [[ sampler(0) ]],
    texture2d<half> ramps   [[ texture(1) ]], sampler rampsSampler   [[ sampler(1) ]],
    texture2d<half> image   [[ texture(2) ]], sampler imageSampler   [[ sampler(2) ]],
    texture2d<half> glyphs  [[ texture(3) ]], sampler glyphsSampler  [[ sampler(3) ]],
    texture2d<half> shadow  [[ texture(4) ]], sampler shadowSampler  [[ sampler(4) ]]
    )
{
    /////////////////////////////////////////////////////
    // Fetch paint color and opacity
    /////////////////////////////////////////////////////
    #if PAINT_SOLID
        half4 paint = i.color;
        half opacity_ = 1.0h;

    #elif PAINT_LINEAR
        half4 paint = ramps.sample(rampsSampler, i.uv0);
        half opacity_ = u0.opacity;

    #elif PAINT_RADIAL
        half dd = u0.radialGrad1[0] * i.uv0.x - u0.radialGrad1[1] * i.uv0.y;
        half u = u0.radialGrad0[0] * i.uv0.x + u0.radialGrad0[1] * i.uv0.y + u0.radialGrad0[2] *
            sqrt(i.uv0.x * i.uv0.x + i.uv0.y * i.uv0.y - dd * dd);
        half4 paint = ramps.sample(rampsSampler, float2(u, u0.radialGrad1[2]));
        half opacity_ = u0.radialGrad0[3];

    #elif PAINT_PATTERN
        #if CUSTOM_PATTERN
            half4 paint = GetCustomPattern(i);
        #elif CLAMP_PATTERN
            float inside = all(i.uv0 == clamp(i.uv0, i.rect.xy, i.rect.zw));
            half4 paint = inside * pattern.sample(patternSampler, i.uv0);
        #elif REPEAT_PATTERN || MIRRORU_PATTERN || MIRRORV_PATTERN || MIRROR_PATTERN
            float2 uv = (i.uv0 - i.tile.xy) / i.tile.zw;
            #if REPEAT_PATTERN
                uv = fract(uv);
            #elif MIRRORU_PATTERN
                uv.x = abs(uv.x - 2.0 * floor((uv.x - 1.0) / 2.0) - 2.0);
                uv.y = fract(uv.y);
            #elif MIRRORV_PATTERN
                uv.x = fract(uv.x);
                uv.y = abs(uv.y - 2.0 * floor((uv.y - 1.0) / 2.0) - 2.0);
            #else 
                uv = abs(uv - 2.0 * floor((uv - 1.0) / 2.0) - 2.0);
            #endif
            uv = uv * i.tile.zw + i.tile.xy;
            float inside = all(uv == clamp(uv, i.rect.xy, i.rect.zw));
            half4 paint = inside * pattern.sample(patternSampler, uv, gradient2d(dfdx(i.uv0), dfdy(i.uv0)));
        #else
            half4 paint = pattern.sample(patternSampler, i.uv0);
        #endif
        half opacity_ = u0.opacity;
    #endif

    /////////////////////////////////////////////////////
    // Apply selected effect
    /////////////////////////////////////////////////////
    #if EFFECT_RGBA
        return (half4)u0.rgba;

    #elif EFFECT_MASK
        return half4(1, 1, 1, 1);

    #elif EFFECT_CLEAR
        return half4(0, 0, 0, 0);

    #elif EFFECT_PATH
        return opacity_ * paint;

    #elif EFFECT_PATH_AA
        return (opacity_ * i.coverage) * paint;

    #elif EFFECT_OPACITY
        return image.sample(imageSampler, i.uv1) * (opacity_ * paint.a);

    #elif EFFECT_SHADOW
        float2 uv = clamp(i.uv1 - u1.shadowOffset, i.rect.xy, i.rect.zw);
        half alpha = mix(image.sample(imageSampler, uv).a, shadow.sample(shadowSampler, uv).a, (half)u1.blend);
        half4 img = image.sample(imageSampler, clamp(i.uv1, i.rect.xy, i.rect.zw));
        return (img + (1.0h - img.a) * ((half4)u1.shadowColor * alpha)) * (opacity_ * paint.a);

    #elif EFFECT_BLUR
        return mix(image.sample(imageSampler, i.uv1), shadow.sample(shadowSampler, i.uv1), (half)u1.blend) * (opacity_ * paint.a);

    #elif EFFECT_SDF
        half4 color = glyphs.sample(glyphsSampler, i.uv1);
        half distance = SDF_SCALE * (color.r - SDF_BIAS);
        half2 grad = (half2)dfdx(i.st1);
        half gradLen = length(grad);

      #if __METAL_MACOS__
        // Workaround to avoid shader compiler internal error on MacBooks with AMD Radeon
        half scale = 1.0h / clamp(gradLen, 1.0h / SDF_BASE_MAX, 1.0h / SDF_BASE_MIN);
      #else
        half scale = clamp(1.0h / gradLen, SDF_BASE_MIN, SDF_BASE_MAX);
      #endif

        half base = SDF_BASE_DEV * (1.0h - (scale - SDF_BASE_MIN) / (SDF_BASE_MAX - SDF_BASE_MIN));
        half range = SDF_AA_FACTOR * gradLen;
        half alpha = smoothstep(base - range, base + range, distance);
        return (alpha * opacity_) * paint;

    #elif EFFECT_DOWNSAMPLE
        return half4
        (
            pattern.sample(patternSampler, i.uv0) +
            pattern.sample(patternSampler, i.uv1) +
            pattern.sample(patternSampler, i.uv2) +
            pattern.sample(patternSampler, i.uv3)
        ) * 0.25h;

    #elif EFFECT_UPSAMPLE
        return (half4)mix(image.sample(imageSampler, i.uv1), pattern.sample(patternSampler, i.uv0), i.color.a);

    #else
        #error EFFECT not defined
    #endif
}
