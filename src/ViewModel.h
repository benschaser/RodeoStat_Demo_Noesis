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
#include <NsRender/Texture.h>
#include <NsGui/BitmapSource.h>
#include <NsGui/Image.h>
#include <vector>
#include <string>

#include <RodeoStat/rodeostat.h>


namespace RS
{

////////////////////////////////////////////////////////////////////////////////////////////////////

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
    Graphics graphics{840, 472};
    // Control control;
    struct RSContestant;
    // struct RSFrame;

    void SetSelectedContestant(RSContestant* value);
    RSContestant* GetSelectedContestant() const;


    const NoesisApp::DelegateCommand* GetOpenAddContestantPopupCommand() const;
    void OpenAddContestantPopup(BaseComponent* param);
    const NoesisApp::DelegateCommand* GetCloseAddContestantPopupCommand() const;
    void CloseAddContestantPopup(BaseComponent* param);
    const NoesisApp::DelegateCommand* GetAddContestantCommand() const;
    void AddContestant(BaseComponent* param);
    const NoesisApp::DelegateCommand* GetRemoveContestantCommand() const;
    void RemoveContestant(BaseComponent* param);

    Noesis::Ptr<Noesis::ObservableCollection<RSContestant>> contestants;
    RSContestant* selected_contestant;
    Noesis::String add_contestant_fname;
    Noesis::String add_contestant_lname;
    Noesis::String add_contestant_event_str;
    Noesis::Ptr<Noesis::BitmapSource> preview_bitmap;
    Noesis::Ptr<Noesis::ImageSource> preview_image;
    int add_contestant_event_index;
    bool add_contestant_popup_open = false;
    int preview_width = 840;
    int preview_height = 472;

    // Noesis::DynamicTexture display_frame;
    // Noesis::Ptr<Noesis::DynamicTextureSource> display_frame;
    
private:
    NoesisApp::DelegateCommand _OpenAddContestantPopupCommand;
    NoesisApp::DelegateCommand _CloseAddContestantPopupCommand;
    NoesisApp::DelegateCommand _AddContestantCommand;
    NoesisApp::DelegateCommand _RemoveContestantCommand;

    NS_DECLARE_REFLECTION(ViewModel, NotifyPropertyChangedBase)
};

// NS_DECLARE_REFLECTION_ENUM(RS::Event)

}
NS_DECLARE_REFLECTION_ENUM(RS::Event)