#pragma once

#include <NsCore/Noesis.h>
#include <NsCore/ReflectionDeclare.h>
#include <NsCore/BaseComponent.h>
#include <NsApp/DelegateCommand.h>
#include "rodeostat.h"


namespace RS
{

////////////////////////////////////////////////////////////////////////////////////////////////////
class ViewModel final: public Noesis::BaseComponent
{
public:
    ViewModel();
    RodeoStat rs;

private:
    const NoesisApp::DelegateCommand* GetStartCommand() const;
    const NoesisApp::DelegateCommand* GetSettingsCommand() const;
    const NoesisApp::DelegateCommand* GetExitCommand() const;

    void Start(BaseComponent* param);
    void Settings(BaseComponent* param);
    void Exit(BaseComponent* param);

private:
    NoesisApp::DelegateCommand _startCommand;
    NoesisApp::DelegateCommand _settingsCommand;
    NoesisApp::DelegateCommand _exitCommand;

    NS_DECLARE_REFLECTION(ViewModel, BaseComponent)
};

}