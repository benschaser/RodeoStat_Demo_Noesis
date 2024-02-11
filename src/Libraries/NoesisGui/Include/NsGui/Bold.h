////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#ifndef __GUI_BOLD_H__
#define __GUI_BOLD_H__


#include <NsCore/Noesis.h>
#include <NsCore/ReflectionDeclare.h>
#include <NsGui/Span.h>


namespace Noesis
{

////////////////////////////////////////////////////////////////////////////////////////////////////
/// An inline-level flow content element which causes content to render with a *bold* font weight.
///
/// https://msdn.microsoft.com/en-us/library/system.windows.documents.bold.aspx
////////////////////////////////////////////////////////////////////////////////////////////////////
class NS_GUI_CORE_API Bold: public Span
{
public:
    Bold();
    Bold(Inline* childInline);

    NS_DECLARE_REFLECTION(Bold, Span)
};

}

#endif
