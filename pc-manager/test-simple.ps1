Add-Type -AssemblyName Windows.Media.Control
$sessionManager = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync().GetResults()
$sessions = $sessionManager.GetSessions()

Write-Host "Total de sessoes: $($sessions.Count)"

foreach ($session in $sessions) {
    $props = $session.TryGetMediaPropertiesAsync().GetResults()
    $playback = $session.GetPlaybackInfo()
    
    Write-Host "Titulo: $($props.Title)"
    Write-Host "Artista: $($props.Artist)"
    Write-Host "Status: $($playback.PlaybackStatus)"
    Write-Host "---"
}
