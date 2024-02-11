////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef __RENDER_RENDERTARGET_H__
#define __RENDER_RENDERTARGET_H__


#include <NsCore/Noesis.h>
#include <NsCore/BaseComponent.h>
#include <NsCore/ReflectionImplementEmpty.h>


namespace Noesis
{

class Texture;

////////////////////////////////////////////////////////////////////////////////////////////////////
/// Base class for 2D textures that can be used as render target
////////////////////////////////////////////////////////////////////////////////////////////////////
class RenderTarget: public BaseComponent
{
public:
    /// Returns the resolve texture
    virtual Texture* GetTexture() = 0;

    NS_IMPLEMENT_INLINE_REFLECTION_(RenderTarget, BaseComponent)
};

}

#endif
