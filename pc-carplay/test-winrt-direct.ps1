try {
    [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null

    $asyncOp = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()
    
    Write-Host "AsyncOp criado: $asyncOp"
    Write-Host "Status: $($asyncOp.Status)"
    
    # Aguarda completion
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($asyncOp.Status -eq 'Started' -and $sw.ElapsedMilliseconds -lt 3000) {
        [System.Threading.Thread]::Sleep(10)
    }
    
    Write-Host "Depois de wait - Status: $($asyncOp.Status)"
    
    if ($asyncOp.Status -ne 'Completed') {
        Write-Host "Falhou: Status é $($asyncOp.Status)"
        exit
    }
    
    # Obtém o resultado
    $asyncOp.Completed.Invoke($asyncOp, $null)
    $manager = $asyncOp.GetResults()
    
    Write-Host "Manager: $manager"
    
    if (-not $manager) {
        Write-Host "Manager é null"
        exit
    }
    
    $sessions = @($manager.GetSessions())
    Write-Host "Total de sessões: $($sessions.Count)"
    
    foreach ($session in $sessions) {
        Write-Host "Processando sessão..."
        try {
            $propsOp = $session.TryGetMediaPropertiesAsync()
            
            Write-Host "PropsOp criado: $propsOp"
            
            $sw2 = [System.Diagnostics.Stopwatch]::StartNew()
            while ($propsOp.Status -eq 'Started' -and $sw2.ElapsedMilliseconds -lt 2000) {
                [System.Threading.Thread]::Sleep(10)
            }
            
            Write-Host "Props Status: $($propsOp.Status)"
            
            if ($propsOp.Status -eq 'Completed') {
                $propsOp.Completed.Invoke($propsOp, $null)
                $props = $propsOp.GetResults()
                
                Write-Host "Props: $props"
                Write-Host "Título: $($props.Title)"
                
                if ($props -and $props.Title -and $props.Title.Trim() -ne '') {
                    $playback = $session.GetPlaybackInfo()
                    
                    $result = @{
                        title = $props.Title
                        artist = if ($props.Artist -and $props.Artist.Trim() -ne '') { $props.Artist } else { '' }
                        album = if ($props.AlbumTitle -and $props.AlbumTitle.Trim() -ne '') { $props.AlbumTitle } else { '' }
                        cover = ''
                        playing = ($playback.PlaybackStatus -eq 'Playing')
                    }
                    
                    Write-Host "Resultado: $($result | ConvertTo-Json)"
                    $result | ConvertTo-Json
                    exit 0
                }
            }
        } catch {
            Write-Host "Erro na sessão: $_"
        }
    }
} catch {
    Write-Host "Erro geral: $_"
    Write-Host "Stack: $($_.ScriptStackTrace)"
}
