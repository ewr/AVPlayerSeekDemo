# AVPlayerSeekDemo

Demo app for AVPlayer seek issue on IOS9 beta

On IOS9 beta 5, seeking a paused player and then calling `.play()` in the completion handler causes playback to reset to live. This is a change from ios8.
