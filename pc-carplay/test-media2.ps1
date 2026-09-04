[Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager,Windows.Media.Control,ContentType=WindowsRuntime] > $null

$manager = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync().GetResults()

if ($manager) {
    $sessions = $manager.GetSessions()
    
    foreach ($session in $sessions) {
        $props = $session.TryGetMediaPropertiesAsync().GetResults()
        $playback = $session.GetPlaybackInfo()
        
        if ($props) {
            @{
                title = [string]$props.Title
                artist = [string]$props.Artist
                album = [string]$props.AlbumTitle
                cover = ""
                playing = ($playback.PlaybackStatus -eq 'Playing')
            } | ConvertTo-Json
            break
        }
    }
}
