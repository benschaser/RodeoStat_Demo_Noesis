////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


//#undef NS_LOG_TRACE
//#define NS_LOG_TRACE(...) NS_LOG_(NS_LOG_LEVEL_TRACE, __VA_ARGS__)


#include "MTLRenderDevice.h"

#include <NsRender/RenderTarget.h>
#include <NsRender/Texture.h>
#include <NsApp/FastLZ.h>
#include <NsCore/Ptr.h>
#include <NsCore/Log.h>
#include <NsCore/HighResTimer.h>

#ifdef NS_PLATFORM_IPHONE
#include <UIKit/UIKit.h>
#endif

#include <dispatch/data.h>


using namespace Noesis;
using namespace NoesisApp;


#if __has_feature(objc_arc)
  #error ARC must be disabled for this file!
#endif

#define PREALLOCATED_DYNAMIC_PAGES 1

#define MTL_RELEASE(o) \
    NS_MACRO_BEGIN \
        [o release]; \
    NS_MACRO_END

#ifdef NS_PROFILE
    #define MTL_PUSH_DEBUG_GROUP(n) \
        NS_MACRO_BEGIN \
            if (mCommandEncoder) [mCommandEncoder pushDebugGroup: n]; \
            else if (@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)) [mCommands pushDebugGroup: n]; \
        NS_MACRO_END
    #define MTL_POP_DEBUG_GROUP() \
        NS_MACRO_BEGIN \
            if (mCommandEncoder) [mCommandEncoder popDebugGroup]; \
            else if (@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)) [mCommands popDebugGroup]; \
        NS_MACRO_END
    #define MTL_NAME(o, ...) \
        NS_MACRO_BEGIN \
            o.label = [NSString stringWithFormat:__VA_ARGS__]; \
        NS_MACRO_END
#else
    #define MTL_PUSH_DEBUG_GROUP(n) NS_NOOP
    #define MTL_POP_DEBUG_GROUP() NS_NOOP
    #define MTL_NAME(o, ...) NS_NOOP
#endif

////////////////////////////////////////////////////////////////////////////////////////////////////
class MTLTexture final: public Texture
{
public:
    MTLTexture(id<MTLTexture> object_, uint32_t width_, uint32_t height_, uint32_t levels_,
        bool isInverted_, bool hasAlpha_): object(object_), width(width_), height(height_),
        levels(levels_), isInverted(isInverted_), hasAlpha(hasAlpha_) {}

    ~MTLTexture()
    {
        MTL_RELEASE(object);
    }

    uint32_t GetWidth() const override { return width; }
    uint32_t GetHeight() const override { return height; }
    bool HasMipMaps() const override { return levels > 1; }
    bool IsInverted() const override { return isInverted; }
    bool HasAlpha() const override { return hasAlpha; }

    id<MTLTexture> object;

    const uint32_t width;
    const uint32_t height;
    const uint32_t levels;
    const bool isInverted;
    const bool hasAlpha;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
class MTLRenderTarget final: public RenderTarget
{
public:
    MTLRenderTarget(MTLRenderPassDescriptor* passDesc_, MTLTexture* texture_, uint32_t width_,
        uint32_t height_): passDesc(passDesc_), texture(texture_), width(width_), height(height_) {}

    ~MTLRenderTarget()
    {
        MTL_RELEASE(passDesc);
    }

    Texture* GetTexture() override { return texture; }

    MTLRenderPassDescriptor* passDesc;
    Noesis::Ptr<MTLTexture> texture;

    const uint32_t width;
    const uint32_t height;
};

////////////////////////////////////////////////////////////////////////////////////////////////////
static uint32_t Hash(MTLPixelFormat colorFormat, MTLPixelFormat stencilFormat, uint8_t sampleCount)
{
    NS_ASSERT(colorFormat < 256);
    NS_ASSERT(stencilFormat != MTLPixelFormatInvalid);
    NS_ASSERT(stencilFormat >= 250 && stencilFormat - 250 < 16);
    NS_ASSERT(sampleCount >= 1 && sampleCount - 1 < 16);

    // A pipeline hash is encoded in 32 bits. The upper 16 bits contains the information about
    // surfaces and sample count. The lower 16 bits contains the shader and render state
    //
    //       COLOR        STENCIL SAMPLES        SHADER        RENDER STATE
    //  xxxxxxxxxxxxxxxx xxxxxxxx xxxxxxxx  xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxx
    //         8            4        4             8                8

    return uint32_t((colorFormat << 24) | ((stencilFormat - 250) << 20) | (sampleCount - 1) << 16);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
static uint32_t Hash(Shader shader, RenderState state)
{
    // In Metal only colorEnable and blendMode are part of the pipeline object
    RenderState mask = {{1, 7, 0, 0}};
    state.v = state.v & mask.v;
    return (uint16_t)(shader.v << 8 | state.v);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
MTLRenderDevice::MTLRenderDevice(id<MTLDevice> device, bool sRGB): mDevice(device), mCommands(0),
    mCommandEncoder(0)
{
    BindAPI();
    FillCaps(sRGB);
    CreateBuffers();
    CreateStateObjects();
    LoadLibrary();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
MTLRenderDevice::~MTLRenderDevice()
{
    MTL_RELEASE(mTextureDesc);

    DestroyBuffer(mDynamicVB);
    DestroyBuffer(mDynamicIB);

    for (auto& pipeline: mPipelines)
    {
        MTL_RELEASE(pipeline.value);
    }

    for (uint32_t i = 0; i < NS_COUNTOF(mSamplers); i++)
    {
        MTL_RELEASE(mSamplers[i]);
    }

    for (uint32_t i = 0; i < NS_COUNTOF(mDepthStencilStates); i++)
    {
        MTL_RELEASE(mDepthStencilStates[i]);
    }

    UnloadLibrary();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Ptr<Texture> MTLRenderDevice::WrapTexture(id<MTLTexture> texture, uint32_t width,
    uint32_t height, uint32_t levels, bool isInverted, bool hasAlpha)
{
    [texture retain];
    return *new MTLTexture(texture, width, height, levels, isInverted, hasAlpha);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::PreCreatePipeline(MTLPixelFormat colorFormat, MTLPixelFormat stencilFormat,
    uint32_t sampleCount_)
{
    uint8_t sampleCount = mSampleCounts[Max(1U, Min(sampleCount_, 16U)) - 1];
    uint32_t hash = Hash(colorFormat, stencilFormat, sampleCount);
    CreatePipelines(colorFormat, stencilFormat, sampleCount, hash);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::UnloadLibrary()
{
    if (mLibrary != 0)
    {
        MTL_RELEASE(mLibrary);
        mLibrary = 0;

        NS_ASSERT(mLibraryData != 0);
        dispatch_release(mLibraryData);
        mLibraryData = 0;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetCommandBuffer(id<MTLCommandBuffer> commands)
{
    mCommands = commands;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetOnScreenEncoder(id<MTLRenderCommandEncoder> encoder,
    MTLPixelFormat colorFormat, MTLPixelFormat stencilFormat, uint32_t sampleCount_)
{
    uint8_t sampleCount = mSampleCounts[Max(1U, Min(sampleCount_, 16U)) - 1];
    mActiveFormat = Hash(colorFormat, stencilFormat, sampleCount);
    CreatePipelines(colorFormat, stencilFormat, sampleCount, mActiveFormat);
    mCommandEncoder = encoder;
    InvalidateStateCache();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
const DeviceCaps& MTLRenderDevice::GetCaps() const
{
    return mCaps;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Ptr<RenderTarget> MTLRenderDevice::CreateRenderTarget(const char* label, uint32_t width,
    uint32_t height, uint32_t sampleCount_, bool needsStencil)
{
    // Stencil is always created because it is cheap (memoryless storage) and simplifies the
    // creation of pipepines
    NS_UNUSED(needsStencil);

    MTLTextureUsage usage = MTLTextureUsageRenderTarget;
    MTLPixelFormat colorFormat = mCaps.linearRendering ? MTLPixelFormatBGRA8Unorm_sRGB : MTLPixelFormatBGRA8Unorm;
    MTLPixelFormat stencilFormat = MTLPixelFormatStencil8;
    uint8_t sampleCount = mSampleCounts[Max(1U, Min(sampleCount_, 16U)) - 1];

    // ColorAA
    id<MTLTexture> colorAA = nil;

    if (sampleCount > 1)
    {
        colorAA = CreateAttachment(width, height, sampleCount, colorFormat, usage);
        MTL_NAME(colorAA, @"Noesis_%s_AA", label);
    }

    // Stencil
    id<MTLTexture> stencil = CreateAttachment(width, height, sampleCount, stencilFormat, usage);
    MTL_NAME(stencil, @"Noesis_%s_Stencil", label);

    Noesis::Ptr<RenderTarget> rt = CreateRenderTarget(label, width, height, colorFormat, colorAA, stencil);
    MTL_RELEASE(colorAA);
    MTL_RELEASE(stencil);
    return rt;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Ptr<RenderTarget> MTLRenderDevice::CloneRenderTarget(const char* label, RenderTarget* surface_)
{
    MTLRenderTarget* surface = (MTLRenderTarget*)surface_;
    NSUInteger sampleCount = surface->passDesc.colorAttachments[0].texture.sampleCount;
    MTLPixelFormat format = surface->passDesc.colorAttachments[0].texture.pixelFormat;

    id<MTLTexture> colorAA = sampleCount > 1 ? surface->passDesc.colorAttachments[0].texture : 0;
    id<MTLTexture> stencil = surface->passDesc.stencilAttachment.texture;

    return CreateRenderTarget(label, surface->width, surface->height, format, colorAA, stencil);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
static MTLPixelFormat ToMTL(TextureFormat::Enum format, bool sRGB)
{
    switch (format)
    {
        case TextureFormat::RGBA8:
        case TextureFormat::RGBX8:
        {
            return sRGB? MTLPixelFormatRGBA8Unorm_sRGB : MTLPixelFormatRGBA8Unorm;
        }
        case TextureFormat::R8:
        {
            return MTLPixelFormatR8Unorm;
        }
        default:
        {
            NS_ASSERT_UNREACHABLE;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Ptr<Texture> MTLRenderDevice::CreateTexture(const char* label, uint32_t width,
    uint32_t height, uint32_t numLevels, TextureFormat::Enum format, const void** data)
{
    mTextureDesc.textureType = MTLTextureType2D;
    mTextureDesc.width = width;
    mTextureDesc.height = height;
    mTextureDesc.sampleCount = 1;
    mTextureDesc.mipmapLevelCount = numLevels;
    mTextureDesc.pixelFormat = ToMTL(format, mCaps.linearRendering);

    bool immutable = data != nullptr;

    if (@available(macOS 10.11, iOS 9, *))
    {
        mTextureDesc.usage = MTLTextureUsageShaderRead;
        if (immutable)
        {
            mTextureDesc.resourceOptions = MTLResourceStorageModePrivate;
            mTextureDesc.storageMode = MTLStorageModePrivate;
        }
        else
        {
#if defined(NS_PLATFORM_IPHONE)
            mTextureDesc.resourceOptions = MTLResourceStorageModeShared;
            mTextureDesc.storageMode = MTLStorageModeShared;
#elif defined(NS_PLATFORM_OSX)
            mTextureDesc.resourceOptions = MTLResourceStorageModeManaged | MTLResourceCPUCacheModeWriteCombined;
            mTextureDesc.storageMode = MTLStorageModeManaged;
#endif
        }
    }

    id<MTLTexture> texture = [mDevice newTextureWithDescriptor:mTextureDesc];
    MTL_NAME(texture, @"Noesis_%s", label);

    bool hasAlpha = format == TextureFormat::RGBA8;
    Noesis::Ptr<MTLTexture> ret = *new MTLTexture(texture, width, height, numLevels, false, hasAlpha);

    if (immutable)
    {
        if (mTextureDesc.storageMode != MTLStorageModePrivate)
        {
            for (uint32_t i = 0; i < numLevels; i++)
            {
                UpdateTexture(ret, i, 0, 0, Max(width >> i, 1U), Max(height >> i, 1U), data[i]);
            }
        }
        else
        {
            id<MTLCommandQueue> queue = [mCommands commandQueue];
            id<MTLCommandBuffer> commands = [queue commandBuffer];
            id<MTLBlitCommandEncoder> encoder = [commands blitCommandEncoder];

#if defined(NS_PLATFORM_IPHONE)
            mTextureDesc.resourceOptions = MTLResourceStorageModeShared;
            mTextureDesc.storageMode = MTLStorageModeShared;
#elif defined(NS_PLATFORM_OSX)
            mTextureDesc.resourceOptions = MTLResourceStorageModeManaged;
            mTextureDesc.storageMode = MTLStorageModeManaged;
#endif

            for (uint32_t i = 0; i < numLevels; i++)
            {
                uint32_t mipWidth = Max(width >> i, 1U);
                uint32_t mipHeight = Max(height >> i, 1U);
                NSUInteger pitch = format == TextureFormat::R8 ? mipWidth : mipWidth * 4;

                mTextureDesc.width = mipWidth;
                mTextureDesc.height = mipHeight;
                mTextureDesc.mipmapLevelCount = 1;
                id<MTLTexture> source = [mDevice newTextureWithDescriptor:mTextureDesc];

                MTLRegion region = {{0, 0}, {mipWidth, mipHeight, 1}};
                [source replaceRegion:region mipmapLevel:0 withBytes:data[i] bytesPerRow:pitch];

                [encoder copyFromTexture:source sourceSlice:0 sourceLevel:0
                    sourceOrigin:region.origin sourceSize:region.size toTexture:texture
                    destinationSlice:0 destinationLevel:i destinationOrigin:region.origin];

                MTL_RELEASE(source);
            }

            [encoder endEncoding];
            [commands commit];
        }
    }

    return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::UpdateTexture(Texture* texture_, uint32_t level, uint32_t x, uint32_t y,
    uint32_t width, uint32_t height, const void* data)
{
    MTLTexture* texture = (MTLTexture*)texture_;
    MTLRegion region = {{x, y}, {width, height, 1}};
    NSUInteger pitch = texture->object.pixelFormat == MTLPixelFormatR8Unorm ? width : width * 4;
    [texture->object replaceRegion:region mipmapLevel:level withBytes:data bytesPerRow:pitch];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::BeginOffscreenRender()
{
    NS_ASSERT(mCommands != nullptr);
    mCommandEncoder = nullptr;
    MTL_PUSH_DEBUG_GROUP(@"Noesis.Offscreen");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::EndOffscreenRender()
{
    MTL_POP_DEBUG_GROUP();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::BeginOnscreenRender()
{
    NS_ASSERT(mCommands != nullptr);
    MTL_PUSH_DEBUG_GROUP(@"Noesis");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::EndOnscreenRender()
{
    MTL_POP_DEBUG_GROUP();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetRenderTarget(RenderTarget* surface_)
{
    MTLRenderTarget* surface = (MTLRenderTarget*)surface_;

    MTLPixelFormat colorFormat = surface->passDesc.colorAttachments[0].texture.pixelFormat;
    MTLPixelFormat stencilFormat = surface->passDesc.stencilAttachment.texture.pixelFormat;
    uint8_t sampleCount = (uint8_t)surface->passDesc.colorAttachments[0].texture.sampleCount;
    mActiveFormat = Hash(colorFormat, stencilFormat, sampleCount);

    CreatePipelines(colorFormat, stencilFormat, sampleCount, mActiveFormat);
    mCommandEncoder = [mCommands renderCommandEncoderWithDescriptor:surface->passDesc];
    MTL_NAME(mCommandEncoder, @"[R] SetRenderTarget");

    InvalidateStateCache();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::BeginTile(RenderTarget* surface_, const Tile& tile)
{
    MTLRenderTarget* surface = (MTLRenderTarget*)surface_;

    MTLScissorRect rect;
    rect.x = tile.x;
    rect.y = surface->height - (tile.y + tile.height);
    rect.width = tile.width;
    rect.height = tile.height;

    [mCommandEncoder setScissorRect:rect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::EndTile(RenderTarget* surface)
{

}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::ResolveRenderTarget(RenderTarget* surface_, const Tile* tiles, uint32_t size)
{
    NS_ASSERT(mCommandEncoder != nullptr);
    //[mCommandEncoder textureBarrier];
    [mCommandEncoder endEncoding];
    mCommandEncoder = 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void* MTLRenderDevice::MapVertices(uint32_t bytes)
{
    return MapBuffer(mDynamicVB, bytes);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::UnmapVertices()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void* MTLRenderDevice::MapIndices(uint32_t bytes)
{
    return MapBuffer(mDynamicIB, bytes);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::UnmapIndices()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::DrawBatch(const Batch& batch)
{
    SetRenderState(batch);
    SetBuffers(batch);
    SetTextures(batch);

    NS_ASSERT(mCommandEncoder != nullptr);
    id<MTLBuffer> indexbuffer = mDynamicIB.currentPage->object;
    NSUInteger offset = batch.startIndex * 2 + mDynamicIB.drawPos;
    [mCommandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:batch.numIndices
        indexType:MTLIndexTypeUInt16 indexBuffer:indexbuffer indexBufferOffset:offset];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::InvalidateStateCache()
{
    mCachedVertexBuffer = 0;
    mCachedPipelineState = 0;
    mCachedDepthStencilState = 0;
    mCachedStencilRef = (uint32_t)-1;
    mCachedFillMode = (MTLTriangleFillMode)-1;

    memset(mCachedVertexCBHash, 0, sizeof(mCachedVertexCBHash));
    memset(mCachedPixelCBHash, 0, sizeof(mCachedPixelCBHash));

    memset(mCachedSamplerStates, 0, sizeof(mCachedSamplerStates));
    memset(mCachedTextures, 0, sizeof(mCachedTextures));

    NS_ASSERT(mCommandEncoder != 0);
    [mCommandEncoder setCullMode:MTLCullModeNone];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetRenderPipelineState(id<MTLRenderPipelineState> pipeline)
{
    if (mCachedPipelineState != pipeline)
    {
        [mCommandEncoder setRenderPipelineState:pipeline];
        mCachedPipelineState = pipeline;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetDepthStencilState(id<MTLDepthStencilState> state, uint32_t stencilRef)
{
    if (mCachedDepthStencilState != state)
    {
        [mCommandEncoder setDepthStencilState:state];
        mCachedDepthStencilState = state;
    }

    if (mCachedStencilRef != stencilRef)
    {
        [mCommandEncoder setStencilReferenceValue:stencilRef];
        mCachedStencilRef = stencilRef;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetFillMode(MTLTriangleFillMode fillMode)
{
    if (mCachedFillMode != fillMode)
    {
        [mCommandEncoder setTriangleFillMode:fillMode];
        mCachedFillMode = fillMode;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetRenderState(const Batch& batch)
{
    uint32_t pipelineHash = Hash(batch.shader, batch.renderState) | mActiveFormat;
    NS_ASSERT(mPipelines.Find(pipelineHash) != mPipelines.End());
    SetRenderPipelineState(mPipelines[pipelineHash]);

    NS_ASSERT(batch.renderState.f.stencilMode < NS_COUNTOF(mDepthStencilStates));
    SetDepthStencilState(mDepthStencilStates[batch.renderState.f.stencilMode], batch.stencilRef);

    SetFillMode(batch.renderState.f.wireframe ? MTLTriangleFillModeLines: MTLTriangleFillModeFill);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetBuffers(const Batch& batch)
{
    // Vertices
    NSUInteger offset = batch.vertexOffset + mDynamicVB.drawPos;
    if (mCachedVertexBuffer != mDynamicVB.currentPage->object)
    {
        [mCommandEncoder setVertexBuffer:mDynamicVB.currentPage->object offset:offset atIndex:0];
        mCachedVertexBuffer = mDynamicVB.currentPage->object;
    }
    else
    {
        [mCommandEncoder setVertexBufferOffset:offset atIndex:0];
    }

    static_assert(NS_COUNTOF(mCachedVertexCBHash) == NS_COUNTOF(Batch::vertexUniforms), "");
    static_assert(NS_COUNTOF(mCachedPixelCBHash) == NS_COUNTOF(Batch::pixelUniforms), "");

    // Vertex constants
    for (uint32_t i = 0; i < NS_COUNTOF(mCachedVertexCBHash); i++)
    {
        if (batch.vertexUniforms[i].numDwords > 0)
        {
            if (mCachedVertexCBHash[i] != batch.vertexUniforms[i].hash)
            {
                uint32_t size = batch.vertexUniforms[i].numDwords * sizeof(uint32_t);
                const void* ptr = batch.vertexUniforms[i].values;
                [mCommandEncoder setVertexBytes:ptr length:size atIndex:i + 1];
                mCachedVertexCBHash[i] = batch.vertexUniforms[i].hash;
            }
        }
    }

    // Pixel constants
    for (uint32_t i = 0; i < NS_COUNTOF(mCachedPixelCBHash); i++)
    {
        if (batch.pixelUniforms[i].numDwords > 0)
        {
            if (mCachedPixelCBHash[i] != batch.pixelUniforms[i].hash)
            {
                uint32_t size = batch.pixelUniforms[i].numDwords * sizeof(uint32_t);
                const void* ptr = batch.pixelUniforms[i].values;
                [mCommandEncoder setFragmentBytes:ptr length:size atIndex:i];
                mCachedPixelCBHash[i] = batch.pixelUniforms[i].hash;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetFragmentTexture(uint32_t index, id<MTLTexture> texture)
{
    NS_ASSERT(index < NS_COUNTOF(mCachedTextures));
    if (mCachedTextures[index] != texture)
    {
        [mCommandEncoder setFragmentTexture:texture atIndex:index];
        mCachedTextures[index] = texture;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetFragmentSamplerState(uint32_t index, id<MTLSamplerState> sampler)
{
    NS_ASSERT(index < NS_COUNTOF(mCachedSamplerStates));
    if (mCachedSamplerStates[index] != sampler)
    {
        [mCommandEncoder setFragmentSamplerState:sampler atIndex:index];
        mCachedSamplerStates[index] = sampler;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetTexture(uint32_t index, MTLTexture* texture, SamplerState state)
{
    NS_ASSERT(state.v < NS_COUNTOF(mSamplers));
    SetFragmentSamplerState(index, mSamplers[state.v]);
    SetFragmentTexture(index, texture->object);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::SetTextures(const Batch& batch)
{
    if (batch.pattern != 0)
    {
        SetTexture(TextureIndex::Pattern, (MTLTexture*)batch.pattern, batch.patternSampler);
    }

    if (batch.ramps != 0)
    {
        SetTexture(TextureIndex::Ramps, (MTLTexture*)batch.ramps, batch.rampsSampler);
    }

    if (batch.image != 0)
    {
        SetTexture(TextureIndex::Image, (MTLTexture*)batch.image, batch.imageSampler);
    }

    if (batch.glyphs != 0)
    {
        SetTexture(TextureIndex::Glyphs, (MTLTexture*)batch.glyphs, batch.glyphsSampler);
    }

    if (batch.shadow != 0)
    {
        SetTexture(TextureIndex::Shadow, (MTLTexture*)batch.shadow, batch.shadowSampler);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
id<MTLTexture> MTLRenderDevice::CreateAttachment(uint32_t width, uint32_t height,
    uint32_t sampleCount, MTLPixelFormat format, MTLTextureUsage usage) const
{
    mTextureDesc.textureType = sampleCount > 1 ? MTLTextureType2DMultisample : MTLTextureType2D;
    mTextureDesc.width = width;
    mTextureDesc.height = height;
    mTextureDesc.sampleCount = sampleCount;
    mTextureDesc.mipmapLevelCount = 1;
    mTextureDesc.pixelFormat = format;

    if (@available(macOS 10.11, iOS 9, *))
    {
        mTextureDesc.resourceOptions = MTLResourceStorageModePrivate;
        mTextureDesc.storageMode = MTLStorageModePrivate;
        mTextureDesc.usage = usage;
    }


    if ((usage & MTLTextureUsageShaderRead) == 0)
    {
        if (@available(macOS 11.0, iOS 13, tvOS 13, *))
        {
            if ([mDevice supportsFamily:MTLGPUFamilyApple1])
            {
                mTextureDesc.storageMode = MTLStorageModeMemoryless;
            }
        }
        else
        {
        #ifdef NS_PLATFORM_IPHONE
          #ifdef NS_PLATFORM_IOS
            if ([mDevice supportsFeatureSet:MTLFeatureSet_iOS_GPUFamily1_v3])
          #else
            if ([mDevice supportsFeatureSet:MTLFeatureSet_tvOS_GPUFamily1_v2])
          #endif
            {
                mTextureDesc.storageMode = MTLStorageModeMemoryless;
            }
        #endif
        }
    }

    return [mDevice newTextureWithDescriptor:mTextureDesc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Ptr<RenderTarget> MTLRenderDevice::CreateRenderTarget(const char* label, uint32_t width,
    uint32_t height, MTLPixelFormat format, id<MTLTexture> colorAA, id<MTLTexture> stencil) const
{
    MTLRenderPassDescriptor* passDesc = [[MTLRenderPassDescriptorClass renderPassDescriptor] retain];
    NSUInteger sampleCount = colorAA ? colorAA.sampleCount : 1;

    id<MTLTexture> color = CreateAttachment(width, height, 1, format,
        MTLTextureUsageShaderRead | (sampleCount == 1 ? MTLTextureUsageRenderTarget : 0));
    MTL_NAME(color, @"Noesis_%s", label);

    if (sampleCount > 1)
    {
        NS_ASSERT(colorAA != 0);
        passDesc.colorAttachments[0].texture = colorAA;
        passDesc.colorAttachments[0].loadAction = MTLLoadActionDontCare;
        passDesc.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
        passDesc.colorAttachments[0].resolveTexture = color;
    }
    else
    {
        NS_ASSERT(colorAA == 0);
        passDesc.colorAttachments[0].texture = color;
        passDesc.colorAttachments[0].loadAction = MTLLoadActionDontCare;
        passDesc.colorAttachments[0].storeAction = MTLStoreActionStore;
    }

    passDesc.stencilAttachment.texture = stencil;
    passDesc.stencilAttachment.loadAction = MTLLoadActionDontCare;
    passDesc.stencilAttachment.storeAction = MTLStoreActionDontCare;

    // For combined depth-stencil formats, we need to set the depth texture (even if unused)
    // For stencil-only formats, the depth format is set to Invalid
    if (stencil.pixelFormat != MTLPixelFormatStencil8)
    {
        passDesc.depthAttachment.texture = stencil;
        passDesc.depthAttachment.loadAction = MTLLoadActionDontCare;
        passDesc.depthAttachment.storeAction = MTLStoreActionDontCare;
    }

    Noesis::Ptr<MTLTexture> texture = *new MTLTexture(color, width, height, 1, false, true);
    return *new MTLRenderTarget(passDesc, texture, width, height);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
static void SetAddressMode(uint8_t wrapMode, MTLSamplerDescriptor* desc)
{
    switch (wrapMode)
    {
        case WrapMode::ClampToEdge:
        {
            desc.sAddressMode = MTLSamplerAddressModeClampToEdge;
            desc.tAddressMode = MTLSamplerAddressModeClampToEdge;
            break;
        }
        case WrapMode::ClampToZero:
        {
            desc.sAddressMode = MTLSamplerAddressModeClampToZero;
            desc.tAddressMode = MTLSamplerAddressModeClampToZero;
            break;
        }
        case WrapMode::Repeat:
        {
            desc.sAddressMode = MTLSamplerAddressModeRepeat;
            desc.tAddressMode = MTLSamplerAddressModeRepeat;
            break;
        }
        case WrapMode::MirrorU:
        {
            desc.sAddressMode = MTLSamplerAddressModeMirrorRepeat;
            desc.tAddressMode = MTLSamplerAddressModeRepeat;
            break;
        }
        case WrapMode::MirrorV:
        {
            desc.sAddressMode = MTLSamplerAddressModeRepeat;
            desc.tAddressMode = MTLSamplerAddressModeMirrorRepeat;
            break;
        }
        case WrapMode::Mirror:
        {
            desc.sAddressMode = MTLSamplerAddressModeMirrorRepeat;
            desc.tAddressMode = MTLSamplerAddressModeMirrorRepeat;
            break;
        }
        default:
        {
            NS_ASSERT_UNREACHABLE;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
static void SetMipFilter(uint8_t mipFilter, MTLSamplerDescriptor* desc)
{
    switch (mipFilter)
    {
        case MipFilter::Disabled:
        {
            desc.mipFilter = MTLSamplerMipFilterNotMipmapped;
            break;
        }
        case MipFilter::Nearest:
        {
            desc.mipFilter = MTLSamplerMipFilterNearest;
            break;
        }
        case MipFilter::Linear:
        {
            desc.mipFilter = MTLSamplerMipFilterLinear;
            break;
        }
        default:
        {
            NS_ASSERT_UNREACHABLE;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
static void SetMinMagFilter(uint8_t minmagFilter, MTLSamplerDescriptor* desc)
{
    switch (minmagFilter)
    {
        case MinMagFilter::Nearest:
        {
            desc.minFilter =  MTLSamplerMinMagFilterNearest;
            desc.magFilter =  MTLSamplerMinMagFilterNearest;
            break;
        }
        case MinMagFilter::Linear:
        {
            desc.minFilter = MTLSamplerMinMagFilterLinear;
            desc.magFilter = MTLSamplerMinMagFilterLinear;
            break;
        }
        default:
        {
            NS_ASSERT_UNREACHABLE;
        }
    }
}

#if defined(NS_PLATFORM_IOS)
  #include "Shaders.ios.h"
#elif defined(NS_PLATFORM_TVOS)
  #include "Shaders.tvos.h"
#elif defined(NS_PLATFORM_OSX)
  #include "Shaders.macos.h"
#endif


////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::LoadLibrary()
{
    uint32_t size = FastLZ::DecompressBufferSize(Shaders);
    void* buffer = Alloc(size);
    FastLZ::Decompress(Shaders, sizeof(Shaders), buffer);
    mLibraryData = dispatch_data_create(buffer, size, dispatch_get_main_queue(), NULL);
    Dealloc(buffer);

    NSError* error;
    mLibrary = [mDevice newLibraryWithData:mLibraryData error:&error];
    NS_ASSERT(error == 0);
    MTL_NAME(mLibrary, @"Noesis_Library");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::CreateStateObjects()
{
    mTextureDesc = [[MTLTextureDescriptorClass alloc] init];

    // Sampler states
    {
        memset(mSamplers, 0, sizeof(mSamplers));
        MTLSamplerDescriptor* desc = [[MTLSamplerDescriptorClass alloc] init];

        for (uint8_t minmag = 0; minmag < MinMagFilter::Count; minmag++)
        {
            for (uint8_t mip = 0; mip < MipFilter::Count; mip++)
            {
                for (uint8_t uv = 0; uv < WrapMode::Count; uv++)
                {
                    SamplerState s = {{uv, minmag, mip}};

                    SetMipFilter(s.f.mipFilter, desc);
                    SetMinMagFilter(s.f.minmagFilter, desc);
                    SetAddressMode(s.f.wrapMode, desc);

                    NS_ASSERT(s.v < NS_COUNTOF(mSamplers));
                    mSamplers[s.v] = [mDevice newSamplerStateWithDescriptor:desc];
                }
            }
        }

        MTL_RELEASE(desc);
    }

    // DepthStencil states
    {
        MTLDepthStencilDescriptor* desc = [[MTLDepthStencilDescriptorClass alloc] init];

        desc.depthCompareFunction = MTLCompareFunctionAlways;
        desc.backFaceStencil = nil;
        desc.frontFaceStencil = nil;
        MTL_NAME(desc, @"Noesis_Disabled");
        mDepthStencilStates[StencilMode::Disabled] = [mDevice newDepthStencilStateWithDescriptor:desc];

        desc.depthCompareFunction = MTLCompareFunctionAlways;
        desc.backFaceStencil.stencilCompareFunction = MTLCompareFunctionEqual;
        desc.backFaceStencil.depthStencilPassOperation = MTLStencilOperationKeep;
        desc.frontFaceStencil = desc.backFaceStencil;
        MTL_NAME(desc, @"Noesis_Equal_Keep");
        mDepthStencilStates[StencilMode::Equal_Keep] = [mDevice newDepthStencilStateWithDescriptor:desc];

        desc.depthCompareFunction = MTLCompareFunctionAlways;
        desc.backFaceStencil.stencilCompareFunction = MTLCompareFunctionEqual;
        desc.backFaceStencil.depthStencilPassOperation = MTLStencilOperationIncrementWrap;
        desc.frontFaceStencil = desc.backFaceStencil;
        MTL_NAME(desc, @"Noesis_Equal_Incr");
        mDepthStencilStates[StencilMode::Equal_Incr] = [mDevice newDepthStencilStateWithDescriptor:desc];

        desc.depthCompareFunction = MTLCompareFunctionAlways;
        desc.backFaceStencil.stencilCompareFunction = MTLCompareFunctionEqual;
        desc.backFaceStencil.depthStencilPassOperation = MTLStencilOperationDecrementWrap;
        desc.frontFaceStencil = desc.backFaceStencil;
        MTL_NAME(desc, @"Noesis_Equal_Decr");
        mDepthStencilStates[StencilMode::Equal_Decr] = [mDevice newDepthStencilStateWithDescriptor:desc];

        desc.depthCompareFunction = MTLCompareFunctionAlways;
        desc.backFaceStencil.stencilCompareFunction = MTLCompareFunctionAlways;
        desc.backFaceStencil.depthStencilPassOperation = MTLStencilOperationZero;
        desc.frontFaceStencil = desc.backFaceStencil;
        MTL_NAME(desc, @"Noesis_Clear");
        mDepthStencilStates[StencilMode::Clear] = [mDevice newDepthStencilStateWithDescriptor:desc];

        desc.depthCompareFunction = MTLCompareFunctionGreaterEqual;
        desc.backFaceStencil = nil;
        desc.frontFaceStencil = nil;
        MTL_NAME(desc, @"Noesis_Disabled_ZTest");
        mDepthStencilStates[StencilMode::Disabled_ZTest] = [mDevice newDepthStencilStateWithDescriptor:desc];

        desc.depthCompareFunction = MTLCompareFunctionGreaterEqual;
        desc.backFaceStencil.stencilCompareFunction = MTLCompareFunctionEqual;
        desc.backFaceStencil.depthStencilPassOperation = MTLStencilOperationKeep;
        desc.frontFaceStencil = desc.backFaceStencil;
        MTL_NAME(desc, @"Noesis_Equal_Keep_ZTest");
        mDepthStencilStates[StencilMode::Equal_Keep_ZTest] = [mDevice newDepthStencilStateWithDescriptor:desc];

        MTL_RELEASE(desc);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
static MTLVertexFormat Format(uint32_t type)
{
    switch (type)
    {
        case Shader::Vertex::Format::Attr::Type::Float: return MTLVertexFormatFloat;
        case Shader::Vertex::Format::Attr::Type::Float2: return MTLVertexFormatFloat2;
        case Shader::Vertex::Format::Attr::Type::Float4: return MTLVertexFormatFloat4;
        case Shader::Vertex::Format::Attr::Type::UByte4Norm: return MTLVertexFormatUChar4Normalized;
        case Shader::Vertex::Format::Attr::Type::UShort4Norm: return MTLVertexFormatUShort4Normalized;
        default: NS_ASSERT_UNREACHABLE;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::CreatePipelines(MTLPixelFormat colorFormat, MTLPixelFormat stencilFormat,
    uint8_t sampleCount, uint32_t hash)
{
    NS_ASSERT(mRegisteredFormats.Find(hash) != mRegisteredFormats.End() || mLibrary != 0);

    if (mLibrary == 0 || !mRegisteredFormats.Insert(hash).second)
    {
        return;
    }

#ifdef NS_PROFILE
    uint64_t t0 = HighResTimer::Ticks();
#endif

#define VSHADER(n) case Shader::Vertex::n: return ShaderVS { @#n, @#n"_VS" };
#define VSHADER_SRGB(n) case Shader::Vertex::n: return sRGB ? \
    ShaderVS { @#n, @#n"_SRGB_VS" } : ShaderVS { @#n, @#n"_VS" };

    struct ShaderVS
    {
        NSString* label;
        NSString* funcName;
    };

    auto vsShaders = [&](uint32_t shader, bool sRGB)
    {
        switch (shader)
        {
            VSHADER(Pos)
            VSHADER_SRGB(PosColor)
            VSHADER(PosTex0)
            VSHADER(PosTex0Rect)
            VSHADER(PosTex0RectTile)
            VSHADER_SRGB(PosColorCoverage)
            VSHADER(PosTex0Coverage)
            VSHADER(PosTex0CoverageRect)
            VSHADER(PosTex0CoverageRectTile)
            VSHADER_SRGB(PosColorTex1_SDF)
            VSHADER(PosTex0Tex1_SDF)
            VSHADER(PosTex0Tex1Rect_SDF)
            VSHADER(PosTex0Tex1RectTile_SDF)
            VSHADER_SRGB(PosColorTex1)
            VSHADER(PosTex0Tex1)
            VSHADER(PosTex0Tex1Rect)
            VSHADER(PosTex0Tex1RectTile)
            VSHADER_SRGB(PosColorTex0Tex1)
            VSHADER(PosTex0Tex1_Downsample)
            VSHADER_SRGB(PosColorTex1Rect)
            VSHADER_SRGB(PosColorTex0RectImagePos)

            default: NS_ASSERT_UNREACHABLE;
        }
    };

    // Vertex Functions
    id<MTLFunction> vertexFuncs[Shader::Vertex::Count];

    for (uint32_t i = 0; i < Shader::Vertex::Count; i++)
    {
        const ShaderVS& vsShader = vsShaders(i, mCaps.linearRendering);
        vertexFuncs[i] = [mLibrary newFunctionWithName:vsShader.funcName];
        NS_ASSERT(vertexFuncs[i] != nil);
        MTL_NAME(vertexFuncs[i], @"Noesis_%@", vsShader.label);
    }

    // Vertex descriptors
    MTLVertexDescriptor* vertexDescriptors[Shader::Vertex::Format::Count];

    for (uint32_t i = 0; i < Shader::Vertex::Format::Count; i++)
    {
        uint32_t attributes = AttributesForFormat[i];
        vertexDescriptors[i] = [MTLVertexDescriptorClass vertexDescriptor];

        NSUInteger offset = 0;

        for (uint32_t j = 0; j < Shader::Vertex::Format::Attr::Count; j++)
        {
            if (attributes & (1 << j))
            {
                uint32_t type = TypeForAttr[j];
                vertexDescriptors[i].attributes[j].format = Format(type);
                vertexDescriptors[i].attributes[j].offset = offset;
                offset += SizeForType[type];
            }
        }

        NS_ASSERT(offset == SizeForFormat[i]);
        vertexDescriptors[i].layouts[0].stride = offset;
    }

    // Main Pipeline
    MTLRenderPipelineDescriptor* desc = [[MTLRenderPipelineDescriptorClass alloc] init];
    MTLPixelFormat depthFormat = stencilFormat == MTLPixelFormatStencil8 ? MTLPixelFormatInvalid : stencilFormat;
    NSError* error;

#define PSHADER(n) case Shader::n: return ShaderPS { @#n, @#n"_PS" };

    struct ShaderPS
    {
        NSString* label;
        NSString* funcName;
    };

    auto psShaders = [&](uint32_t shader)
    {
        switch (shader)
        {
            PSHADER(RGBA)
            PSHADER(Mask)
            PSHADER(Clear)

            PSHADER(Path_Solid)
            PSHADER(Path_Linear)
            PSHADER(Path_Radial)
            PSHADER(Path_Pattern)
            PSHADER(Path_Pattern_Clamp)
            PSHADER(Path_Pattern_Repeat)
            PSHADER(Path_Pattern_MirrorU)
            PSHADER(Path_Pattern_MirrorV)
            PSHADER(Path_Pattern_Mirror)

            PSHADER(Path_AA_Solid)
            PSHADER(Path_AA_Linear)
            PSHADER(Path_AA_Radial)
            PSHADER(Path_AA_Pattern)
            PSHADER(Path_AA_Pattern_Clamp)
            PSHADER(Path_AA_Pattern_Repeat)
            PSHADER(Path_AA_Pattern_MirrorU)
            PSHADER(Path_AA_Pattern_MirrorV)
            PSHADER(Path_AA_Pattern_Mirror)

            PSHADER(SDF_Solid)
            PSHADER(SDF_Linear)
            PSHADER(SDF_Radial)
            PSHADER(SDF_Pattern)
            PSHADER(SDF_Pattern_Clamp)
            PSHADER(SDF_Pattern_Repeat)
            PSHADER(SDF_Pattern_MirrorU)
            PSHADER(SDF_Pattern_MirrorV)
            PSHADER(SDF_Pattern_Mirror)

            PSHADER(Opacity_Solid)
            PSHADER(Opacity_Linear)
            PSHADER(Opacity_Radial)
            PSHADER(Opacity_Pattern)
            PSHADER(Opacity_Pattern_Clamp)
            PSHADER(Opacity_Pattern_Repeat)
            PSHADER(Opacity_Pattern_MirrorU)
            PSHADER(Opacity_Pattern_MirrorV)
            PSHADER(Opacity_Pattern_Mirror)

            PSHADER(Upsample)
            PSHADER(Downsample)

            PSHADER(Shadow)
            PSHADER(Blur)

            default: return ShaderPS{};
        }
    };

    for (uint32_t i = 0; i < Shader::Count; i++)
    {
        const ShaderPS& psShader = psShaders(i);

        if (psShader.funcName == nullptr)
        {
            continue;
        }

        id<MTLFunction> func = [mLibrary newFunctionWithName:psShader.funcName];
        NS_ASSERT(func != nil);
        MTL_NAME(func, @"Noesis_%@", psShader.funcName);

        int8_t vsShader = VertexForShader[i];
        NS_ASSERT(vsShader < NS_COUNTOF(vertexFuncs));

        int8_t format = FormatForVertex[vsShader];
        NS_ASSERT(format < NS_COUNTOF(vertexDescriptors));

        Shader shader = { .v = (uint8_t)i };

        for (uint32_t j = 0; j < 256; j++)
        {
            RenderState state = { .v = (uint8_t)j };

            if (!IsValidState(shader, state))
            {
                continue;
            }

            NS_ASSERT((hash & Hash(shader, state)) == 0);
            Pipelines::InsertResult f = mPipelines.Insert(hash | Hash(shader, state));
            if (!f.second)
            {
                continue;
            }

            [desc reset];
            desc.vertexDescriptor = vertexDescriptors[format];
            desc.vertexFunction = vertexFuncs[vsShader];
            desc.fragmentFunction = state.f.colorEnable ? func : nil;
            desc.sampleCount = sampleCount;
            desc.depthAttachmentPixelFormat = depthFormat;
            desc.stencilAttachmentPixelFormat = stencilFormat;
            desc.colorAttachments[0].pixelFormat = colorFormat;

            desc.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
            desc.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
            desc.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorOne;
            desc.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;

            switch (state.f.blendMode)
            {
                case BlendMode::Src:
                {
                    desc.colorAttachments[0].blendingEnabled = false;
                    MTL_NAME(desc, @"Noesis_%@", psShader.label);
                    break;
                }
                case BlendMode::SrcOver:
                {
                    desc.colorAttachments[0].blendingEnabled = true;
                    desc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorOne;
                    desc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
                    MTL_NAME(desc, @"Noesis_%@_Blend", psShader.label);
                    break;
                }
                case BlendMode::SrcOver_Multiply:
                {
                    desc.colorAttachments[0].blendingEnabled = true;
                    desc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorDestinationColor;
                    desc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
                    MTL_NAME(desc, @"Noesis_%@_Multiply", psShader.label);
                    break;
                }
                case BlendMode::SrcOver_Screen:
                {
                    desc.colorAttachments[0].blendingEnabled = true;
                    desc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorOne;
                    desc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceColor;
                    MTL_NAME(desc, @"Noesis_%@_Screen", psShader.label);
                    break;
                }
                case BlendMode::SrcOver_Additive:
                {
                    desc.colorAttachments[0].blendingEnabled = true;
                    desc.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorOne;
                    desc.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOne;
                    MTL_NAME(desc, @"Noesis_%@_Additive", psShader.label);
                    break;
                }
                default:
                    NS_ASSERT_UNREACHABLE;
            }

            f.first->value = [mDevice newRenderPipelineStateWithDescriptor:desc error:&error];
            NS_ASSERT(error == 0);
        }

        MTL_RELEASE(func);
    }

    for (uint32_t i = 0; i < NS_COUNTOF(vertexFuncs); i++)
    {
        MTL_RELEASE(vertexFuncs[i]);
    }

    MTL_RELEASE(desc);

#ifdef NS_PROFILE
    NS_LOG_TRACE("Pipeline '0x%x' compiled in %.0f ms", hash >> 16, 1000.0 * HighResTimer::Seconds(
        HighResTimer::Ticks() - t0));
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////
MTLRenderDevice::Page* MTLRenderDevice::AllocatePage(DynamicBuffer& buffer)
{
    Page* page = (Page*)Alloc(sizeof(Page));
    memset(page, 0, sizeof(Page));

    page->inUse = false;
    page->object = [mDevice newBufferWithLength:buffer.size options:0];

    MTL_NAME(page->object, @"Noesis_%s[%d]", buffer.label, buffer.numPages);
    NS_LOG_TRACE("Page '%s[%d]' created (%d KB)", buffer.label, buffer.numPages, buffer.size / 1024);

    buffer.numPages++;
    return page;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::CreateBuffer(DynamicBuffer& buffer, uint32_t size, const char* label)
{
    buffer.size = size;
    buffer.pos = 0;
    buffer.drawPos = 0;
    buffer.label = label;

    buffer.numPages = 0;
    buffer.pendingPages = nullptr;
    buffer.freePages = nullptr;

    for (uint32_t i = 0; i < PREALLOCATED_DYNAMIC_PAGES; i++)
    {
        Page* page = AllocatePage(buffer);
        page->next = buffer.freePages;
        buffer.freePages = page;
    }

    NS_ASSERT(buffer.freePages != nullptr);
    buffer.currentPage = buffer.freePages;
    buffer.freePages = buffer.freePages->next;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::CreateBuffers()
{
   CreateBuffer(mDynamicVB, DYNAMIC_VB_SIZE, "Vertices");
   CreateBuffer(mDynamicIB, DYNAMIC_IB_SIZE, "Indices");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::DestroyBuffer(DynamicBuffer& buffer)
{
    if (buffer.currentPage)
    {
        MTL_RELEASE(buffer.currentPage->object);
        Dealloc(buffer.currentPage);
    }

    for (Page* page = buffer.pendingPages; page != nullptr;)
    {
        Page* next = page->next;
        MTL_RELEASE(page->object);
        Dealloc(page);
        page = next;
    }

    for (Page* page = buffer.freePages; page != nullptr;)
    {
        Page* next = page->next;
        MTL_RELEASE(page->object);
        Dealloc(page);
        page = next;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void* MTLRenderDevice::MapBuffer(DynamicBuffer& buffer, uint32_t size)
{
    NS_ASSERT(size <= buffer.size);

    if (buffer.pos + size > buffer.size)
    {
        // We ran out of space in the current page, get a new one
        // Move the current one to pending and insert a GPU fence
        buffer.currentPage->inUse = true;
        Page* currentPage = buffer.currentPage;
        [mCommands addCompletedHandler:^(id<MTLCommandBuffer>)
        {
            currentPage->inUse = false;
        }];

        buffer.currentPage->next = buffer.pendingPages;
        buffer.pendingPages = buffer.currentPage;

        // If there is one free slot get it
        if (buffer.freePages != nullptr)
        {
            buffer.currentPage = buffer.freePages;
            buffer.freePages = buffer.freePages->next;
        }
        else
        {
            // Move pages already processed by GPU from pending to free
            Page** it = &buffer.pendingPages->next;
            while (*it != nullptr)
            {
                if ((*it)->inUse)
                {
                    it = &((*it)->next);
                }
                else
                {
                    // Once we find a processed page, the rest of pages must be also processed.
                    // Although this is not exactly true in Metal when addCompleteHandler needs
                    // to be invoked for several pages belonging to the same command buffer. Those
                    // invocations are not necessarily done in order of completion. But at the time
                    // those free pages are going to be used the inUse flag must be already false
                    Page* page = *it;
                    *it = nullptr;

                    NS_ASSERT(buffer.freePages == nullptr);
                    buffer.freePages = page;
                    break;
                }
            }

            if (buffer.freePages != nullptr)
            {
                buffer.currentPage = buffer.freePages;
                buffer.freePages = buffer.freePages->next;
            }
            else
            {
                buffer.currentPage = AllocatePage(buffer);
            }
        }

        NS_ASSERT(!buffer.currentPage->inUse);
        buffer.pos = 0;
    }

    buffer.drawPos = buffer.pos;
    buffer.pos += size;
    return (uint8_t*)[buffer.currentPage->object contents] + buffer.drawPos;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::CheckMultisample()
{
    uint8_t sampleCount = 0;

    for (uint8_t i = 0; i < 16; i++)
    {
        if ([mDevice supportsTextureSampleCount: i + 1])
        {
            sampleCount = i + 1;
        }

        mSampleCounts[i] = sampleCount;
    }

    NS_ASSERT(mSampleCounts[0] == 1);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::FillCaps(bool sRGB)
{
    CheckMultisample();

    mCaps.centerPixelOffset = 0.0f;
    mCaps.linearRendering = sRGB;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MTLRenderDevice::BindAPI()
{
    MTLTextureDescriptorClass = NSClassFromString(@"MTLTextureDescriptor");
    MTLRenderPipelineDescriptorClass = NSClassFromString(@"MTLRenderPipelineDescriptor");
    MTLRenderPassDescriptorClass = NSClassFromString(@"MTLRenderPassDescriptor");
    MTLDepthStencilDescriptorClass = NSClassFromString(@"MTLDepthStencilDescriptor");
    MTLVertexDescriptorClass = NSClassFromString(@"MTLVertexDescriptor");
    MTLSamplerDescriptorClass = NSClassFromString(@"MTLSamplerDescriptor");

    NS_ASSERT(MTLTextureDescriptorClass != nullptr);
    NS_ASSERT(MTLRenderPipelineDescriptorClass != nullptr);
    NS_ASSERT(MTLRenderPassDescriptorClass != nullptr);
    NS_ASSERT(MTLDepthStencilDescriptorClass != nullptr);
    NS_ASSERT(MTLVertexDescriptorClass != nullptr);
    NS_ASSERT(MTLSamplerDescriptorClass != nullptr);
}
