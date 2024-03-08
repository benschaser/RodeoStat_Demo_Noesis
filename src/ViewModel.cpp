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
#include <iostream>


#include <RodeoStat/rodeostat.h>


using namespace Noesis;
using namespace RS;

////////////////////////////////////////////////////////////////////////////////////////////////////

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
    _OpenAddContestantPopupCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::OpenAddContestantPopup));
    _CloseAddContestantPopupCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::CloseAddContestantPopup));
    _AddContestantCommand.SetExecuteFunc(MakeDelegate(this, &ViewModel::AddContestant));

    contestants = *new ObservableCollection<Contestant>();
    // display_frame = *new DynamicTextureSource(display_width, display_height);
    
    // const sf::Uint8* pixels = graphics.frame_img.getPixelsPtr();
    // const uint8_t pix = *pixels;


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

}

void ViewModel::SetSelectedContestant(Contestant* value) {
    if (selected_contestant != value)
    {
        selected_contestant = value;
        OnPropertyChanged("SelectedContestant");

        graphics.make_frame(value->name.Str(), value->event.Str(), value->score, value->time);
        // graphics.make_frame("JH", "Barrel", 12.1, 39.9);
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

    OnPropertyChanged("Contestants");
    OnPropertyChanged("AddContestantFName");
    OnPropertyChanged("AddContestantLName");
}

// Ptr<Noesis::Image> ConvertSfmlImageToNoesisImage(const sf::Image& sfmlImage) {
//     // Get the size of the image
//     sf::Vector2u size = sfmlImage.getSize();
//     unsigned int width = size.x;
//     unsigned int height = size.y;

//     // Get the pixel data from the SFML image
//     const sf::Uint8* pixels = sfmlImage.getPixelsPtr();
//     const uint8_t* pix = pixels;
//     // ConvertUInt8ArrayToInt32Array(pixels, pixels2, width*height);

//     // Create a texture source
//     Noesis::TextureSource texture;
//     texture.Create(width, height, 72, 72, *pix, 8, BitmapSource.Format.RGBA8);
//     Ptr<Noesis::TextureSource> textureSource = *new Noesis::TextureSource();

//     // Update the texture data
//     // static_cast<Noesis::TextureSource*>(textureSource.GetPtr())->UpdateTextureData(pixels);

//     // Create a Noesis image
//     Ptr<Noesis::Image> image = *new Noesis::Image();
//     image->SetSource(textureSource);

//     return image;
// }



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
    NsProp("PreviewFrame", &ViewModel::preview_image);
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
