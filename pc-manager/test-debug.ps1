Write-Host "Iniciando teste..."

$type = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager,Windows.Media.Control,ContentType=WindowsRuntime]
Write-Host "Tipo carregado: $type"

if ($type) {
    Write-Host "WinRT carregado com sucesso"
    
    try {
        $asyncOp = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()
        Write-Host "AsyncOp criado"
        Write-Host "Tipo do AsyncOp: $($asyncOp.GetType())"
        
        # Tentar esperar o resultado
        while ($asyncOp.Status -eq 'Started') {
            Start-Sleep -Milliseconds 10
        }
        Write-Host "AsyncOp completado com status: $($asyncOp.Status)"
        
        $manager = $asyncOp.GetResults()
        Write-Host "Manager obtido: $manager"
        
        if ($manager) {
            $sessions = @($manager.GetSessions())
            Write-Host "Total de sessoes: $($sessions.Count)"
            
            foreach ($session in $sessions) {
                Write-Host "Processando sessao..."
                $propsAsync = $session.TryGetMediaPropertiesAsync()
                
                while ($propsAsync.Status -eq 'Started') {
                    Start-Sleep -Milliseconds 10
                }
                
                $props = $propsAsync.GetResults()
                Write-Host "Props: $props"
                Write-Host "Titulo: $($props.Title)"
                
                if ($props.Title) {
                    $playback = $session.GetPlaybackInfo()
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
        } else {
            Write-Host "Manager é null"
        }
    } catch {
        Write-Host "Erro: $_"
        Write-Host "Stack: $($_.ScriptStackTrace)"
    }
} else {
    Write-Host "Tipo não carregado"
}
