#include "ViewModel.h"

#include <NsCore/ReflectionImplement.h>
#include <NsCore/ReflectionImplementEnum.h>

#include <NsCore/Log.h>
#include <NsCore/TypeClassCreator.h>
#include <NsGui/DynamicTextureSource.h>
#include <NsApp/DelegateCommand.h>
#include <NsGui/Popup.h>
#include <NsGui/ComboBox.h>
#include <iostream>


// #include <RodeoStat/rodeostat.h>


// using namespace NoesisApp;
using namespace Noesis;
using namespace RS;

////////////////////////////////////////////////////////////////////////////////////////////////////
// ViewModel::ViewModel()
// {
//     _startCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::Start));
//     _settingsCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::Settings));
//     _exitCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::Exit));
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////
// const DelegateCommand* ViewModel::GetStartCommand() const
// {
//     return &_startCommand;
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////
// const DelegateCommand* ViewModel::GetSettingsCommand() const
// {
//     return &_settingsCommand;
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////
// const DelegateCommand* ViewModel::GetExitCommand() const
// {
//     return &_exitCommand;
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////
// void ViewModel::Start(BaseComponent*)
// {
//     NS_LOG_INFO("Start App");
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////
// void ViewModel::Settings(BaseComponent*)
// {
//     // NS_LOG_INFO("Change Settings");
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////
// void ViewModel::Exit(BaseComponent*)
// {
//     NS_LOG_INFO("Exit App");
// }

// ////////////////////////////////////////////////////////////////////////////////////////////////////
// NS_BEGIN_COLD_REGION

// NS_IMPLEMENT_REFLECTION(ViewModel)
// {
//     NsProp("StartCommand", &ViewModel::GetStartCommand);
//     NsProp("SettingsCommand", &ViewModel::GetSettingsCommand);
//     NsProp("ExitCommand", &ViewModel::GetExitCommand);
// }

// NS_END_COLD_REGION

struct ViewModel::Contestant: BaseComponent {
public:
    String fname, lname, name, event;
    double time{0.0}, score{0.0};
private:
    NS_IMPLEMENT_INLINE_REFLECTION(Contestant, BaseComponent)
    {
        NsProp("Fname", &Contestant::fname);
        NsProp("Lname", &Contestant::lname);
        NsProp("Name", &Contestant::name);
        NsProp("Event", &Contestant::event);
        NsProp("Time", &Contestant::time);
        NsProp("Score", &Contestant::score);
    }
};


ViewModel::ViewModel() {
    // rs.add_contestant("Ben", "Schaser", "Bullriding", 0.00, 0.00);
    _OpenAddContestantPopupCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::OpenAddContestantPopup));
    _CloseAddContestantPopupCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::CloseAddContestantPopup));
    _AddContestantCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::AddContestant));

    contestants = *new ObservableCollection<Contestant>();

    Ptr<Contestant> c = *new Contestant();
    c->fname = "Ben";
    c->lname = "Schaser";
    c->name = "Ben Schaser";
    c->event = "Bull Riding";
    c->time = 4.237;
    c->score = 12.3;
    contestants->Add(c);

    Ptr<Contestant> a = *new Contestant();
    a->fname = "Josh";
    a->lname = "Hennen";
    a->name = "Josh Hennen";
    a->event = "Barrel Racing";
    a->time = 9.211;
    a->score = 4.35;
    contestants->Add(a);

    selected_contestant = contestants->Get(0);

    // selected_contestant = nullptr;
    // display_frame.BeginInit();
}

void ViewModel::SetSelectedContestant(Contestant* value) {
    if (selected_contestant != value)
    {
        selected_contestant = value;
        OnPropertyChanged("SelectedContestant");
    }
}
ViewModel::Contestant* ViewModel::GetSelectedContestant() const {
    return selected_contestant;
}



const NoesisApp::DelegateCommand* ViewModel::GetOpenAddContestantPopupCommand() const {
    return &_OpenAddContestantPopupCommand;
}
void ViewModel::OpenAddContestantPopup(BaseComponent*) {
    add_contestant_popup_open = true;
    OnPropertyChanged("AddContestantPopupOpen");
}
const NoesisApp::DelegateCommand* ViewModel::GetCloseAddContestantPopupCommand() const {
    return &_CloseAddContestantPopupCommand;
}
void ViewModel::CloseAddContestantPopup(BaseComponent* param) {
    add_contestant_popup_open = false;
    OnPropertyChanged("AddContestantPopupOpen");
}
const NoesisApp::DelegateCommand* ViewModel::GetAddContestantCommand() const {
    return &_AddContestantCommand;
}
void ViewModel::AddContestant(BaseComponent* param) {
    Ptr<Contestant> c = *new Contestant();
    c->fname = add_contestant_fname;
    c->lname = add_contestant_lname;
    c->name = add_contestant_fname + " " + add_contestant_lname;
    c->event = events.at(add_contestant_event_index);
    c->time = 0.0;
    c->score = 0.0;
    if(c->name != " ") {
        contestants->Add(c);
    }
    
    add_contestant_fname = "";
    add_contestant_lname = "";
    // *add_contestant_event = "";

    OnPropertyChanged("Contestants");
    OnPropertyChanged("AddContestantFName");
    OnPropertyChanged("AddContestantLName");
    // OnPropertyChanged("AddContestantEvent");
}


NS_BEGIN_COLD_REGION

NS_IMPLEMENT_REFLECTION(ViewModel) {
    NsProp("Contestants", &ViewModel::contestants);
    NsProp("SelectedContestant", &ViewModel::GetSelectedContestant, &ViewModel::SetSelectedContestant);
    NsProp("AddContestantPopupOpen", &ViewModel::add_contestant_popup_open);
    NsProp("OpenAddContestantPopupCommand", &ViewModel::GetOpenAddContestantPopupCommand);
    NsProp("CloseAddContestantPopupCommand", &ViewModel::GetCloseAddContestantPopupCommand);
    NsProp("AddContestantCommand", &ViewModel::GetAddContestantCommand);
    NsProp("AddContestantFName", &ViewModel::add_contestant_fname);
    NsProp("AddContestantLName", &ViewModel::add_contestant_lname);
    NsProp("AddContestantEventIndex", &ViewModel::add_contestant_event_index);
}

NS_END_COLD_REGION

// NS_IMPLEMENT_REFLECTION_ENUM(Event)
// {
//     NsVal("BullRiding", Event::BullRiding);
//     NsVal("BarebackRiding", Event::BarebackRiding);
//     NsVal("SaddleBroncRiding", Event::SaddleBroncRiding);
//     NsVal("SteerWrestling", Event::SteerWrestling);
//     NsVal("BarrelRacing", Event::BarrelRacing);
//     NsVal("TeamRoping", Event::TeamRoping);
//     NsVal("TieDownRoping", Event::TieDownRoping);
//     NsVal("BreakawayRoping", Event::BreakawayRoping);
// }
