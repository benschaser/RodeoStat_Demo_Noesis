#pragma once

#include <NsCore/Noesis.h>
#include <NsCore/ReflectionDeclare.h>
#include <NsCore/ReflectionDeclareEnum.h>
#include <NsCore/BaseComponent.h>
#include <NsApp/NotifyPropertyChangedBase.h>
#include <NsGui/ObservableCollection.h>
#include <NsApp/DelegateCommand.h>
#include <NsGui/DynamicTextureSource.h>
#include <NsGui/ComboBox.h>
#include <vector>
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

std::vector<Noesis::String> events{
    "Bull Riding",
    "Bareback Riding",
    "Saddle Bronc Riding",
    "Steer Wrestling",
    "Barrel Racing",
    "Team Roping",
    "Tie Down Roping",
    "Breakaway Roping"
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

    

    const NoesisApp::DelegateCommand* GetOpenAddContestantPopupCommand() const;
    void OpenAddContestantPopup(BaseComponent* param);
    const NoesisApp::DelegateCommand* GetCloseAddContestantPopupCommand() const;
    void CloseAddContestantPopup(BaseComponent* param);
    const NoesisApp::DelegateCommand* GetAddContestantCommand() const;
    void AddContestant(BaseComponent* param);



    Noesis::Ptr<Noesis::ObservableCollection<Contestant>> contestants;
    Contestant* selected_contestant;
    Noesis::String add_contestant_fname;
    Noesis::String add_contestant_lname;
    Noesis::String add_contestant_event_str;
    int add_contestant_event_index;
    // Noesis::Ptr<Noesis::ComboBoxItem> add_contestant_event;
    bool add_contestant_popup_open = false;
    // Noesis::DynamicTextureSource display_frame;

    
private:
    NoesisApp::DelegateCommand _OpenAddContestantPopupCommand;
    NoesisApp::DelegateCommand _CloseAddContestantPopupCommand;
    NoesisApp::DelegateCommand _AddContestantCommand;

    NS_DECLARE_REFLECTION(ViewModel, NotifyPropertyChangedBase)
};


}
// NS_DECLARE_REFLECTION_ENUM(RS::Event)
