////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef __GUI_DISCRETEDOUBLEKEYFRAME_H__
#define __GUI_DISCRETEDOUBLEKEYFRAME_H__


#include <NsCore/Noesis.h>
#include <NsCore/ReflectionDeclare.h>
#include <NsGui/DoubleKeyFrame.h>
#include <NsGui/AnimationApi.h>


namespace Noesis
{

////////////////////////////////////////////////////////////////////////////////////////////////////
/// Animates from the *Single* value of the previous key frame to its own *Value* using discrete
/// interpolation.
///
/// This class is used as part of a DoubleKeyFrameCollection in conjunction with a
/// DoubleAnimationUsingKeyFrames to animate a Double property value along a set of key frames.
///
/// A key frame defines a segment of the DoubleAnimationUsingKeyFrames to which it belongs. Each key
/// frame has a target Value and a KeyTime. The KeyTime specifies the time at which the key frame's
/// Value should be reached. A key frame animates from the target value of the previous key frame to
/// its own target value. It starts when the previous key frame ends and ends when its own key time
/// is reached.
///
/// Discrete key frames like DiscreteDoubleKeyFrame create sudden "jumps" between values (no
/// Interpolation). In other words, the animated property does not change until the key frame's key
/// time is reached at which point the animated property goes suddenly to the target value.
///
/// http://msdn.microsoft.com/en-us/library/system.windows.media.animation.discretedoublekeyframe.aspx
////////////////////////////////////////////////////////////////////////////////////////////////////
class NS_GUI_ANIMATION_API DiscreteDoubleKeyFrame final: public DoubleKeyFrame
{
public:
    // Hides Freezable methods for convenience
    //@{
    Ptr<DiscreteDoubleKeyFrame> Clone() const;
    Ptr<DiscreteDoubleKeyFrame> CloneCurrentValue() const;
    //@}

protected:
    /// From Freezable
    //@{
    Ptr<Freezable> CreateInstanceCore() const override;
    //@}

    /// From KeyFrame
    //@{
    float InterpolateValueCore(float baseValue, float keyFrameProgress) override;
    //@}

    NS_DECLARE_REFLECTION(DiscreteDoubleKeyFrame, DoubleKeyFrame)
};

}


#endif
