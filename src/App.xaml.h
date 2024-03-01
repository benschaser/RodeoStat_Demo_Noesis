#pragma once

#include <NsCore/Noesis.h>
#include <NsCore/ReflectionDeclare.h>
#include <NsApp/Application.h>


namespace RS
{

////////////////////////////////////////////////////////////////////////////////////////////////////
class App final: public NoesisApp::Application
{
    NS_DECLARE_REFLECTION(App, Application)
};

}
