$winRtLoaded = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager,Windows.Media.Control,ContentType=WindowsRuntime] -is [type]

if ($winRtLoaded) {
    try {
        $null = [Windows.Foundation.AsyncOperationWaitHandle]
        $asyncOp = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()
        $asyncOp.AsTask().Wait()
        $manager = $asyncOp.GetResults()
        
        if ($manager) {
            $sessions = @($manager.GetSessions())
            
            foreach ($session in $sessions) {
                try {
                    $propsAsync = $session.TryGetMediaPropertiesAsync()
                    $propsAsync.AsTask().Wait()
                    $props = $propsAsync.GetResults()
                    
                    $playback = $session.GetPlaybackInfo()
                    
                    if ($props -and $props.Title) {
                        $title = $props.Title
                        $artist = $props.Artist
                        $album = $props.AlbumTitle
                        
                        @{
                            title = if ($title) { $title } else { "" }
                            artist = if ($artist) { $artist } else { "" }
                            album = if ($album) { $album } else { "" }
                            cover = ""
                            playing = ($playback.PlaybackStatus -eq 'Playing')
                        } | ConvertTo-Json
                        
                        exit 0
                    }
                } catch {
                }
            }
        }
    } catch {
    }
}
