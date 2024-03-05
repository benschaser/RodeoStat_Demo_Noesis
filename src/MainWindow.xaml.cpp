#include "MainWindow.xaml.h"
#include "ViewModel.h"

#include <NsGui/IntegrationAPI.h>
#include <NsGui/Uri.h>
#include <NsCore/ReflectionImplementEmpty.h>


using namespace RS;
using namespace Noesis;


////////////////////////////////////////////////////////////////////////////////////////////////////
MainWindow::MainWindow()
{
    Initialized() += MakeDelegate(this, &MainWindow::OnInitialized);
    InitializeComponent();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MainWindow::InitializeComponent()
{
    GUI::LoadComponent(this, "MainWindow.xaml");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MainWindow::OnInitialized(BaseComponent*, const EventArgs&)
{
    SetDataContext(MakePtr<ViewModel>());
}

////////////////////////////////////////////////////////////////////////////////////////////////////
NS_BEGIN_COLD_REGION

NS_IMPLEMENT_REFLECTION_(RS::MainWindow, "RodeoStat.MainWindow")

NS_END_COLD_REGION