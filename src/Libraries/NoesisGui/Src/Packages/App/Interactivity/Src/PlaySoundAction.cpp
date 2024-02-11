////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#include <NsApp/PlaySoundAction.h>
#include <NsGui/DependencyData.h>
#include <NsGui/Storyboard.h>
#include <NsGui/IntegrationAPI.h>
#include <NsGui/Uri.h>
#include <NsCore/ReflectionImplement.h>


using namespace NoesisApp;


////////////////////////////////////////////////////////////////////////////////////////////////////
PlaySoundAction::PlaySoundAction()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
PlaySoundAction::~PlaySoundAction()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
const Noesis::Uri& PlaySoundAction::GetSource() const
{
    return GetValue<Noesis::Uri>(SourceProperty);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void PlaySoundAction::SetSource(const Noesis::Uri& source)
{
    SetValue<Noesis::Uri>(SourceProperty, source);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
float PlaySoundAction::GetVolume() const
{
    return GetValue<float>(VolumeProperty);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void PlaySoundAction::SetVolume(float volume)
{
    SetValue<float>(VolumeProperty, volume);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Ptr<Noesis::Freezable> PlaySoundAction::CreateInstanceCore() const
{
    return *new PlaySoundAction();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void PlaySoundAction::Invoke(Noesis::BaseComponent*)
{
    const Noesis::Uri& source = GetSource();
    if (GetAssociatedObject() != 0 && !Noesis::StrIsEmpty(source.Str()))
    {
        Noesis::GUI::PlayAudio(source, GetVolume());
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
NS_BEGIN_COLD_REGION

NS_IMPLEMENT_REFLECTION(PlaySoundAction, "NoesisApp.PlaySoundAction")
{
    Noesis::DependencyData* data = NsMeta<Noesis::DependencyData>(Noesis::TypeOf<SelfClass>());
    data->RegisterProperty<Noesis::Uri>(SourceProperty, "Source", Noesis::PropertyMetadata::Create(Noesis::Uri()));
    data->RegisterProperty<float>(VolumeProperty, "Volume", Noesis::PropertyMetadata::Create(0.5f));
}

NS_END_COLD_REGION

////////////////////////////////////////////////////////////////////////////////////////////////////
const Noesis::DependencyProperty* PlaySoundAction::SourceProperty;
const Noesis::DependencyProperty* PlaySoundAction::VolumeProperty;
