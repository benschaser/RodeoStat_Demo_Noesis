#include "ViewModel.h"

#include <NsCore/ReflectionImplement.h>
#include <NsCore/Log.h>
#include <NsCore/TypeClassCreator.h>
#include <NsGui/DynamicTextureSource.h>

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
    contestants = *new ObservableCollection<Contestant>();

    Ptr<Contestant> c = *new Contestant();
    c->fname = "Ben";
    c->lname = "Schaser";
    c->name = "Ben Schaser";
    c->event = "Bullriding";
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
void ViewModel::add_contestant(String fname, String lname, String event) {
    Ptr<Contestant> c = *new Contestant();
    c->fname = fname;
    c->lname = lname;
    c->name = fname + " " + lname;
    c->event = event;
    contestants->Add(c);
}

NS_BEGIN_COLD_REGION

NS_IMPLEMENT_REFLECTION(ViewModel) {
    NsProp("Contestants", &ViewModel::contestants);
    NsProp("SelectedContestant", &ViewModel::GetSelectedContestant, &ViewModel::SetSelectedContestant);
}

NS_END_COLD_REGION

