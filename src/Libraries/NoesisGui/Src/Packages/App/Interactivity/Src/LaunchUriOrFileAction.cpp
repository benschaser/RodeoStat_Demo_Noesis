////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#include <NsApp/LaunchUriOrFileAction.h>
#include <NsGui/DependencyData.h>
#include <NsGui/IntegrationAPI.h>
#include <NsCore/ReflectionImplement.h>


using namespace NoesisApp;


////////////////////////////////////////////////////////////////////////////////////////////////////
LaunchUriOrFileAction::LaunchUriOrFileAction()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
LaunchUriOrFileAction::~LaunchUriOrFileAction()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
const char* LaunchUriOrFileAction::GetPath() const
{
    return GetValue<Noesis::String>(PathProperty).Str();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void LaunchUriOrFileAction::SetPath(const char* path)
{
    SetValue<Noesis::String>(PathProperty, path);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Ptr<Noesis::Freezable> LaunchUriOrFileAction::CreateInstanceCore() const
{
    return *new LaunchUriOrFileAction();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void LaunchUriOrFileAction::Invoke(Noesis::BaseComponent*)
{
    const char* path = GetPath();
    DependencyObject* associatedObject = GetAssociatedObject();
    if (associatedObject != 0 && !Noesis::StrIsNullOrEmpty(path))
    {
        Noesis::GUI::OpenUrl(path);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
NS_BEGIN_COLD_REGION

NS_IMPLEMENT_REFLECTION(LaunchUriOrFileAction, "NoesisApp.LaunchUriOrFileAction")
{
    Noesis::DependencyData* data = NsMeta<Noesis::DependencyData>(Noesis::TypeOf<SelfClass>());
    data->RegisterProperty<Noesis::String>(PathProperty, "Path",
        Noesis::PropertyMetadata::Create(Noesis::String()));
}

NS_END_COLD_REGION

////////////////////////////////////////////////////////////////////////////////////////////////////
const Noesis::DependencyProperty* LaunchUriOrFileAction::PathProperty;
