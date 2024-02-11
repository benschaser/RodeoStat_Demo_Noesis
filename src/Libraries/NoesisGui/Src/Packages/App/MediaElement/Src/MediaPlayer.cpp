////////////////////////////////////////////////////////////////////////////////////////////////////
// NoesisGUI - http://www.noesisengine.com
// Copyright (c) 2013 Noesis Technologies S.L. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////////////////////////


#include <NsApp/MediaPlayer.h>


using namespace NoesisApp;


////////////////////////////////////////////////////////////////////////////////////////////////////
MediaPlayer::MediaPlayer()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
uint32_t MediaPlayer::GetWidth() const
{
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
uint32_t MediaPlayer::GetHeight() const
{
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool MediaPlayer::CanPause() const
{
    return false;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool MediaPlayer::HasAudio() const
{
    return false;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool MediaPlayer::HasVideo() const
{
    return false;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
float MediaPlayer::GetBufferingProgress() const
{
    return 0.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
float MediaPlayer::GetDownloadProgress() const
{
    return 0.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
double MediaPlayer::GetDuration() const
{
    return 0.0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
double MediaPlayer::GetPosition() const
{
    return 0.0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::SetPosition(double)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
float MediaPlayer::GetSpeedRatio() const
{
    return 1.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::SetSpeedRatio(float)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
float MediaPlayer::GetVolume() const
{
    return 0.5f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::SetVolume(float)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
float MediaPlayer::GetBalance() const
{
    return 0.0f;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::SetBalance(float)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool MediaPlayer::GetIsMuted() const
{
    return false;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::SetIsMuted(bool)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
bool MediaPlayer::GetScrubbingEnabled() const
{
    return false;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::SetScrubbingEnabled(bool)
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::Play()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::Pause()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
void MediaPlayer::Stop()
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Delegate<MediaPlayer::BufferingStartedT>& MediaPlayer::BufferingStarted()
{
    return mBufferingStarted;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Delegate<MediaPlayer::BufferingEndedT>& MediaPlayer::BufferingEnded()
{
    return mBufferingEnded;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Delegate<MediaPlayer::MediaFailedT>& MediaPlayer::MediaFailed()
{
    return mMediaFailed;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Delegate<MediaPlayer::MediaOpenedT>& MediaPlayer::MediaOpened()
{
    return mMediaOpened;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
Noesis::Delegate<MediaPlayer::MediaEndedT>& MediaPlayer::MediaEnded()
{
    return mMediaEnded;
}
