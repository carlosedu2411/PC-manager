$ErrorActionPreference = 'SilentlyContinue'

Add-Type -AssemblyName Windows.Media.Control

Write-Host "Testando acesso aos dados de mídia do Windows..."
Write-Host ""

try {
    [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null
    
    $sessionManager = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync().GetResults()
    
    if ($sessionManager -eq $null) {
        Write-Host "ERRO: Session Manager é null"
        exit
    }
    
    Write-Host "✓ Session Manager obtido"
    
    $sessions = $sessionManager.GetSessions()
    Write-Host "✓ Total de sessões: $($sessions.Count)"
    Write-Host ""
    
    $found = $false
    $sessionCount = 0
    
    foreach ($session in $sessions) {
        $sessionCount++
        Write-Host "Sessão $($sessionCount):"
        
        try {
            $mediaProperties = $session.TryGetMediaPropertiesAsync().GetResults()
            $playbackInfo = $session.GetPlaybackInfo()
            
            Write-Host "  Título: $($mediaProperties.Title)"
            Write-Host "  Artista: $($mediaProperties.Artist)"
            Write-Host "  Álbum: $($mediaProperties.AlbumTitle)"
            Write-Host "  Estado: $($playbackInfo.PlaybackStatus)"
            
            if ($mediaProperties -ne $null -and -not [string]::IsNullOrWhiteSpace($mediaProperties.Title)) {
                Write-Host "  ✓ Dados encontrados!"
                $found = $true
                
                $title = $mediaProperties.Title
                $artist = $mediaProperties.Artist
                $album = $mediaProperties.AlbumTitle
                $isPlaying = $playbackInfo.PlaybackStatus -eq 'Playing'
                
                $result = @{
                    title = if ([string]::IsNullOrWhiteSpace($title)) { '' } else { $title }
                    artist = if ([string]::IsNullOrWhiteSpace($artist)) { '' } else { $artist }
                    album = if ([string]::IsNullOrWhiteSpace($album)) { '' } else { $album }
                    cover = ''
                    playing = $isPlaying
                }
                
                Write-Host ""
                Write-Host "JSON resultante:"
                $result | ConvertTo-Json
            }
        } catch {
            Write-Host "  ✗ Erro ao ler sessão: $_"
        }
        Write-Host ""
    }
    
    if (-not $found) {
        Write-Host "Nenhuma música encontrada em todas as sessões"
    }
    
} catch {
    Write-Host "ERRO GERAL: $_"
}
