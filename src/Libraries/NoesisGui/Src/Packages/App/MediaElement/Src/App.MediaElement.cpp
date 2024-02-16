////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#include <NsCore/Package.h>
#include <NsCore/EnumConverter.h>
#include <NsApp/MediaElement.h>


NS_BEGIN_COLD_REGION

////////////////////////////////////////////////////////////////////////////////////////////////////
NS_REGISTER_REFLECTION(App, MediaElement)
{
    NS_REGISTER_COMPONENT(NoesisApp::MediaElement)
    NS_REGISTER_COMPONENT(Noesis::EnumConverter<NoesisApp::MediaState>)
}

////////////////////////////////////////////////////////////////////////////////////////////////////
NS_INIT_PACKAGE(App, MediaElement)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
NS_SHUTDOWN_PACKAGE(App, MediaElement)
{
}

NS_END_COLD_REGION