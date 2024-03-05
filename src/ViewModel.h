#pragma once

#include <NsCore/Noesis.h>
#include <NsCore/ReflectionDeclare.h>
#include <NsCore/BaseComponent.h>
#include <NsApp/NotifyPropertyChangedBase.h>
#include <NsGui/ObservableCollection.h>
#include <NsApp/DelegateCommand.h>
#include <NsGui/DynamicTextureSource.h>
#include <string>

// #include <RodeoStat/rodeostat.h>


namespace RS
{

////////////////////////////////////////////////////////////////////////////////////////////////////
// class ViewModel final: public Noesis::BaseComponent
// {
// public:
//     ViewModel();
    

// private:
//     const NoesisApp::DelegateCommand* GetStartCommand() const;
//     const NoesisApp::DelegateCommand* GetSettingsCommand() const;
//     const NoesisApp::DelegateCommand* GetExitCommand() const;

//     void Start(BaseComponent* param);
//     void Settings(BaseComponent* param);
//     void Exit(BaseComponent* param);

// private:
//     NoesisApp::DelegateCommand _startCommand;
//     NoesisApp::DelegateCommand _settingsCommand;
//     NoesisApp::DelegateCommand _exitCommand;

//     NS_DECLARE_REFLECTION(ViewModel, BaseComponent)
// };

enum class Event {
    BullRiding,
    BarebackRiding,
    SaddleBroncRiding,
    SteerWrestling,
    BarrelRacing,
    TeamRoping,
    TieDownRoping,
    BreakawayRoping
};

class ViewModel final: public NoesisApp::NotifyPropertyChangedBase
{
public:
    ViewModel();
private:
    // RodeoStat rs;
    // Graphics graphics;
    // Control control;
    struct Contestant;

    void SetSelectedContestant(Contestant* value);
    Contestant* GetSelectedContestant() const;

    void add_contestant(Noesis::String fname, Noesis::String lname, Noesis::String event);

    Noesis::Ptr<Noesis::ObservableCollection<Contestant>> contestants;
    Contestant* selected_contestant;
    // Noesis::DynamicTextureSource display_frame;

    
private:
    
    NS_DECLARE_REFLECTION(ViewModel, NotifyPropertyChangedBase)
};


}