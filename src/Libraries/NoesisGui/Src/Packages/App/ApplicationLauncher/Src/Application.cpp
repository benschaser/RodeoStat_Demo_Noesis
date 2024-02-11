////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#include <NsApp/Application.h>
#include <NsApp/Window.h>
#include <NsApp/Display.h>
#include <NsApp/DisplayLauncher.h>
#include <NsGui/DependencyProperty.h>
#include <NsGui/ResourceDictionary.h>
#include <NsGui/IntegrationAPI.h>
#include <NsGui/IView.h>
#include <NsCore/ReflectionImplement.h>
#include <NsRender/RenderContext.h>
#include <NsRender/RenderDevice.h>


using namespace Noesis;
using namespace NoesisApp;


static Application* gInstance;


////////////////////////////////////////////////////////////////////////////////////////////////////
Application::Application()
{
    // More than one instantation is possible, for example when dropping App.xaml into XamlPlayer
    if (gInstance == 0)
    {
        gInstance = this;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Application::~Application()
{
    mExit(this, EventArgs::Empty);

    if (mMainWindow != 0)
    {
        // Make sure the View is destroyed after the Window element tree
        Ptr<IView> view(mMainWindow->GetView());

        mMainWindow->Shutdown();
        mMainWindow.Reset();
    }

    if (mRenderContext != 0)
    {
        mRenderContext->Shutdown();
        mRenderContext.Reset();
    }

    if (mResources != 0)
    {
        mResources->RemoveDictionaryChangedListeners();
        mResources.Reset();
    }

    if (gInstance == this)
    {
        gInstance = 0;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Application* Application::Current()
{
    NS_ASSERT(gInstance != 0);
    return gInstance;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
const Uri& Application::GetStartupUri() const
{
    return mStartupUri;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void Application::SetStartupUri(const Uri& startupUri)
{
    mStartupUri = startupUri;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
ResourceDictionary* Application::GetResources() const
{
    EnsureResources();
    return mResources;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void Application::SetResources(ResourceDictionary* resources)
{
    if (mResources != resources)
    {
        mResources.Reset(resources);
        GUI::SetApplicationResources(mResources);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Window* Application::GetMainWindow() const
{
    return mMainWindow;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
const CommandLine& Application::GetArguments() const
{
    return mArguments;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void Application::Init(Display* display, const CommandLine& arguments)
{
    mArguments = arguments;

    // Create RenderContext
    mRenderContext = GetRenderContextOverride();
    uint32_t samples = GetSamplesOverride();
    uint32_t offscreenSamples = Min(GetOffscreenSamplesOverride(), samples);
    bool vSync = GetVSyncOverride();
    bool sRGB = GetsRGBOverride();

    mRenderContext->Init(display->GetNativeHandle(), samples, vSync, sRGB);
    mRenderContext->GetDevice()->SetOffscreenSampleCount(offscreenSamples);

    // Application resources
    GUI::SetApplicationResources(GetResources());

    // Redirect integration callbacks to display
    GUI::SetSoftwareKeyboardCallback(display, [](void* user, UIElement* focused, bool open)
    {
        if (open)
        {
            ((Display*)user)->OpenSoftwareKeyboard(focused);
        }
        else
        {
            ((Display*)user)->CloseSoftwareKeyboard();
        }
    });

    GUI::SetCursorCallback(display, [](void* user, IView*, Cursor* cursor)
    {
        ((Display*)user)->SetCursor(cursor);
    });

    GUI::SetOpenUrlCallback(display, [](void* user, const char* url)
    {
        ((Display*)user)->OpenUrl(url);
    });

    GUI::SetPlayAudioCallback(display, [](void* user, const Uri& uri, float volume)
    {
        ((Display*)user)->PlayAudio(uri, volume);
    });

    display->Activated() += [this](Display*)
    {
        mActivated(this, EventArgs::Empty);
    };

    display->Deactivated() += [this](Display*)
    {
        mDeactivated(this, EventArgs::Empty);
    };

    display->NativeHandleChanged() += [this](Display*, void* window)
    {
        mRenderContext->SetWindow(window);
    };

    display->SaveState() += [this](Display*)
    {
        mRenderContext->SaveState();
    };

    // Load startup URI as main window
    if (!StrIsNullOrEmpty(mStartupUri.Str()))
    {
        Ptr<BaseComponent> root = GUI::LoadXaml(mStartupUri.Str());
        mMainWindow = DynamicPtrCast<Window>(root);

        // Non window roots are allowed
        if (mMainWindow == 0)
        {
            mMainWindow = *new Window();
            mMainWindow->DependencyObject::Init();
            mMainWindow->SetContent(root);
            mMainWindow->SetTitle(GetTitleOverride(DynamicPtrCast<UIElement>(root)));
        }
    }
    else
    {
        NS_FATAL("Startup window not defined");
    }

    // Initialize main window
    bool ppaa = GetPPAAOverride();
    bool lcd = GetLCDOverride();
    bool emulateTouch = GetEmulateTouchOverride();

    mMainWindow->Init(display, mRenderContext, Max(samples, 1U), ppaa, lcd, emulateTouch);

    // Raise StartUp event
    mStartUp(this, EventArgs::Empty);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void Application::Tick(double time)
{
    mMainWindow->Render(time);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void Application::Shutdown(int exitCode)
{
    ((DisplayLauncher*)Launcher::Current())->Quit(exitCode);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
EventHandler& Application::Activated()
{
    return mActivated;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
EventHandler& Application::Deactivated()
{
    return mDeactivated;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
EventHandler& Application::StartUp()
{
    return mStartUp;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
EventHandler& Application::Exit()
{
    return mExit;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
IUITreeNode* Application::GetNodeParent() const
{
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void Application::SetNodeParent(IUITreeNode*)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
BaseComponent* Application::FindNodeResource(const char* key, bool) const
{
    if (mResources != 0)
    {
        BaseComponent* resource = mResources->Get(key);

        if (resource != 0)
        {
            return resource;
        }
    }

    return DependencyProperty::GetUnsetValue();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
ObjectWithNameScope Application::FindNodeName(const char*) const
{
    return ObjectWithNameScope { };
}

////////////////////////////////////////////////////////////////////////////////////////////////////
const char* Application::GetTitleOverride(UIElement* root) const
{
    Window* window = DynamicCast<Window*>(root);
    return window ? window->GetTitle() : "";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Ptr<RenderContext> Application::GetRenderContextOverride() const
{
    if (mArguments.HasOption("render"))
    {
        return RenderContext::Create(mArguments.FindOption("render", ""));
    }
    else
    {
        return RenderContext::Create();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool Application::GetPPAAOverride() const
{
    return GetSamplesOverride() == 1 && atoi(mArguments.FindOption("ppaa", "1")) != 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool Application::GetLCDOverride() const
{
    return atoi(mArguments.FindOption("lcd", "1")) != 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
uint32_t Application::GetSamplesOverride() const
{
    return atoi(mArguments.FindOption("samples", "1"));
}

////////////////////////////////////////////////////////////////////////////////////////////////////
uint32_t Application::GetOffscreenSamplesOverride() const
{
    return GetSamplesOverride();
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool Application::GetVSyncOverride() const
{
    return atoi(mArguments.FindOption("vsync", "1")) != 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool Application::GetsRGBOverride() const
{
    return mArguments.HasOption("linear");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool Application::GetEmulateTouchOverride() const
{
    return mArguments.HasOption("emulate_touch");
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void Application::EnsureResources() const
{
    if (mResources == 0)
    {
        mResources = *new ResourceDictionary();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
NS_BEGIN_COLD_REGION

NS_IMPLEMENT_REFLECTION(Application)
{
    NsImpl<IUITreeNode>();

    NsProp("Resources", &Application::GetResources, &Application::SetResources);
    NsProp("MainWindow", &Application::GetMainWindow);
    NsProp("StartupUri", &Application::mStartupUri);
    NsEvent("Activated", &Application::mActivated);
    NsEvent("Deactivated", &Application::mDeactivated);
    NsEvent("StartUp", &Application::mStartUp);
    NsEvent("Exit", &Application::mExit);
}

NS_END_COLD_REGION
