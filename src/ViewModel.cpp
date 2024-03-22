#include "ViewModel.h"

#include <NsCore/ReflectionImplement.h>
#include <NsCore/ReflectionImplementEnum.h>

#include <NsCore/Log.h>
#include <NsCore/TypeClassCreator.h>
#include <NsGui/DynamicTextureSource.h>
#include <NsApp/DelegateCommand.h>
#include <NsGui/Popup.h>
#include <NsGui/ComboBox.h>
#include <NsGui/TextureSource.h>
#include <NsGui/TextureProvider.h>
#include <iostream>


#include <RodeoStat/rodeostat.h>


using namespace Noesis;
using namespace RS;

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

////////////////////////////////////////////////////////////////////////////////////////////////////

struct ViewModel::RSContestant: BaseComponent {
public:
    String fname, lname, name, event, hometown, homestate, backtag, bucking_order, stock_name, stock_contractor;
    double time{0.0}, score{0.0};
private:
    NS_IMPLEMENT_INLINE_REFLECTION(RSContestant, BaseComponent)
    {
        NsProp("Fname", &RSContestant::fname);
        NsProp("Lname", &RSContestant::lname);
        NsProp("Name", &RSContestant::name);
        NsProp("Event", &RSContestant::event);
        NsProp("Hometown", &RSContestant::hometown);
        NsProp("Homestate", &RSContestant::homestate);
        NsProp("Backtag", &RSContestant::backtag);
        NsProp("BuckingOrder", &RSContestant::bucking_order);
        NsProp("StockName", &RSContestant::stock_name);
        NsProp("StockContractor", &RSContestant::stock_contractor);

        NsProp("Time", &RSContestant::time);
        NsProp("Score", &RSContestant::score);
    }
};
// struct ViewModel::RSFrame: FrameworkElement {
// public:
//     RSContestant contestant;
//     // void Update() override;
// private:
//     NS_IMPLEMENT_INLINE_REFLECTION(RSContestant, BaseComponent)
//     {
//         NsProp("Contestant", &RSFrame::contestant);
//     }
// };


ViewModel::ViewModel() {
    _OpenAddContestantPopupCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::OpenAddContestantPopup));
    _CloseAddContestantPopupCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::CloseAddContestantPopup));
    _AddContestantCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::AddContestant));
    _RemoveContestantCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::RemoveContestant));

    contestants = *new ObservableCollection<RSContestant>();
    // Ptr<BitmapSource> prev;
    // auto prev = preview_bitmap->Create(preview_width, preview_height, 1.0f, 1.0f, graphics.frame_img.getPixelsPtr(), preview_width*4, BitmapSource::Format::Format_RGBA8);    
    // std::cout << prev->GetPixelWidth() << '\n';

    Ptr<RSContestant> c = *new RSContestant();
    c->fname = "Ben";
    c->lname = "Schaser";
    c->name = "Ben Schaser";
    c->event = "Bull Riding";
    c->time = 4.237;
    c->score = 12.3;
    contestants->Add(c);

    Ptr<RSContestant> m = *new RSContestant();
    m->fname = "Michael";
    m->lname = "Sell";
    m->name = "Michael Sell";
    m->event = "Tie Down Roping";
    m->time = 5.123;
    m->score = 12.771;
    contestants->Add(m);

    Ptr<RSContestant> a = *new RSContestant();
    a->fname = "Josh";
    a->lname = "Hennen";
    a->name = "Josh Hennen";
    a->event = "Barrel Racing";
    a->time = 9.211;
    a->score = 4.352;
    contestants->Add(a);

    selected_contestant = contestants->Get(0);
    graphics.make_frame(selected_contestant->name.Str(), selected_contestant->event.Str(), selected_contestant->score, selected_contestant->time);
    preview_bitmap = preview_bitmap->Create(preview_width, preview_height, 1.0f, 1.0f, graphics.frame_img.getPixelsPtr(), preview_width*4, BitmapSource::Format::Format_RGBA8);

}

void ViewModel::SetSelectedContestant(RSContestant* value) {
    if (selected_contestant != value) {
        selected_contestant = value;
        OnPropertyChanged("SelectedContestant");

        graphics.make_frame(value->name.Str(), value->event.Str(), value->score, value->time);
        preview_bitmap = preview_bitmap->Create(preview_width, preview_height, 1.0f, 1.0f, graphics.frame_img.getPixelsPtr(), preview_width*4, BitmapSource::Format::Format_RGBA8);
        OnPropertyChanged("PreviewFrame");
    }
}
ViewModel::RSContestant* ViewModel::GetSelectedContestant() const {
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
    Ptr<RSContestant> c = *new RSContestant();
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

    OnPropertyChanged("Contestants");
    OnPropertyChanged("AddContestantFName");
    OnPropertyChanged("AddContestantLName");
}

const NoesisApp::DelegateCommand* ViewModel::GetRemoveContestantCommand() const {
    return &_RemoveContestantCommand;
}
void ViewModel::RemoveContestant(BaseComponent* param) {
    int i = contestants->IndexOf(selected_contestant);
    int s = contestants->Count();
    if (s > 1) {
        int n = (i + 1) % s;
        selected_contestant = contestants->Get(n);
    }
    else {
        selected_contestant = nullptr;
    }
    OnPropertyChanged("SelectedContestant");
    contestants->RemoveAt(i);

    OnPropertyChanged("Contestants");
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

    NsProp("RemoveContestantCommand", &ViewModel::GetRemoveContestantCommand);

    NsProp("PreviewFrame", &ViewModel::preview_bitmap);
}

NS_END_COLD_REGION

NS_IMPLEMENT_REFLECTION_ENUM(Event)
{
    NsVal("Bull Riding", Event::BullRiding);
    NsVal("Bareback Riding", Event::BarebackRiding);
    NsVal("Saddle Bronc Riding", Event::SaddleBroncRiding);
    NsVal("Steer Wrestling", Event::SteerWrestling);
    NsVal("Barrel Racing", Event::BarrelRacing);
    NsVal("Team Roping", Event::TeamRoping);
    NsVal("Tie Down Roping", Event::TieDownRoping);
    NsVal("Breakaway Roping", Event::BreakawayRoping);
}
