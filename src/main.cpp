// RodeoStat Demo Application
// Created by Ben Schaser - 2024

#include <iostream>
#include <NoesisLicense.h>
#include <NoesisPCH.h>

#include "MainWindow.xaml.h"
#include "App.xaml.h"

#include "bin.h"

using namespace Noesis;
using namespace NoesisApp;

class AppLauncher final: public ApplicationLauncher {
private:
    void RegisterComponents() const override {
        RegisterComponent<RS::MainWindow>();
        RegisterComponent<RS::App>();
    }

    Noesis::Ptr<XamlProvider> GetXamlProvider() const override {
        EmbeddedXaml xamls[] = 
        {
            { "App.xaml", APP_XAML },
            { "MainWindow.xaml", MAINWINDOW_XAML },
            { "Resources.xaml", RESOURCES_XAML },
            { "Resources/Themes/NoesisTheme.Styles.xaml", NOESISTHEME_STYLES_XAML },
            { "Resources/Themes/NoesisTheme.Colors.Dark.xaml", NOESISTHEME_COLORS_DARK_XAML },
            { "Resources/Themes/NoesisTheme.Brushes.DarkRed.xaml", NOESISTHEME_BRUSHES_DARKRED_XAML },
            { "Resources/Themes/NoesisTheme.DarkRed.xaml", NOESISTHEME_DARKRED_XAML },
            { "Resources/Themes/NoesisTheme.Fonts.xaml", NOESISTHEME_FONTS_XAML },
        };

        return *new EmbeddedXamlProvider(xamls);
    }

    Noesis::Ptr<FontProvider> GetFontProvider() const override {
        EmbeddedFont fonts[] = 
        {
            { "", NOTOSANS_REGULAR_TTF },
            { "", SEGMDL2_TTF}
        };

        return *new EmbeddedFontProvider(fonts);
    }

    Noesis::Ptr<TextureProvider> GetTextureProvider() const override
    {
        EmbeddedTexture textures[] = 
        {
            { "Resources/Images/RS_logo.png", RS_LOGO },
        };

        return *new EmbeddedTextureProvider(textures);
    }
};

////////////////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char **argv) {
    AppLauncher launcher;
    launcher.SetArguments(argc, argv);
    launcher.SetApplicationFile("App.xaml");
    return launcher.Run();
}