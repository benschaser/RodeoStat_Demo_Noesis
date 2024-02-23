// RodeoStat Demo Application
// Created by Ben Schaser - 2024

#include <iostream>
#include <NoesisLicense.h>
#include <NoesisPCH.h>

#include "MainWindow.xaml.h"
#include "App.xaml.h"

#include "NexaHeavy.ttf.bin.h"
#include "App.xaml.bin.h"
#include "Resources.xaml.bin.h"
#include "MainWindow.xaml.bin.h"

#ifndef NS_LICENSE_NAME
    #define NS_LICENSE_NAME "RodeoStat"
#endif

#ifndef NS_LICENSE_KEY
    #define NS_LICENSE_KEY "mo4N48fDDePglc8nF/19ZzfxyamkorTdIdhDaw1wOO1DW28R"
#endif

using namespace Noesis;
using namespace NoesisApp;

class AppLauncher final: public ApplicationLauncher {
private:
    void RegisterComponents() const override {
        RegisterComponent<RodeoStat::MainWindow>();
        RegisterComponent<RodeoStat::App>();
    }

    Noesis::Ptr<XamlProvider> GetXamlProvider() const override {
        EmbeddedXaml xamls[] = 
        {
            { "App.xaml", App_xaml },
            { "Resources.xaml", Resources_xaml },
            { "MainWindow.xaml", MainWindow_xaml }
        };

        return *new EmbeddedXamlProvider(xamls);
    }

    Noesis::Ptr<FontProvider> GetFontProvider() const override {
        EmbeddedFont fonts[] = 
        {
            { "", Nexa_Heavy_ttf }
        };

        return *new EmbeddedFontProvider(fonts);
    }
};

////////////////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv) {
    AppLauncher launcher;
    launcher.SetArguments(argc, argv);
    launcher.SetApplicationFile("App.xaml");
    return launcher.Run();
}