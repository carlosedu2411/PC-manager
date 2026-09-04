package media

import (
	"bytes"
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
)

type MediaInfo struct {
	Title   string `json:"title"`
	Artist  string `json:"artist"`
	Album   string `json:"album"`
	Cover   string `json:"cover"`
	Playing bool   `json:"playing"`
}

var (
	user32         = syscall.NewLazyDLL("user32.dll")
	procKeybdEvent = user32.NewProc("keybd_event")
)

const (
	VK_MEDIA_NEXT_TRACK = 0xB0
	VK_MEDIA_PREV_TRACK = 0xB1
	VK_MEDIA_PLAY_PAUSE = 0xB3
	KEYEVENTF_KEYUP     = 0x0002
)

func sendMediaKey(vk byte) {
	procKeybdEvent.Call(uintptr(vk), 0, 0, 0)
	procKeybdEvent.Call(uintptr(vk), 0, KEYEVENTF_KEYUP, 0)
}

func GetCurrentMedia() MediaInfo {
	// Tenta usar o MediaHelper.exe se existir
	helperPaths := []string{
		filepath.Join(filepath.Dir(os.Args[0]), "MediaHelper.exe"),
		"c:\\Users\\Carlos\\Desktop\\Pc-carplay\\build\\bin\\MediaHelper.exe",
		filepath.Join(os.Getenv("LOCALAPPDATA"), "Pc-carplay", "MediaHelper.exe"),
	}

	for _, helperPath := range helperPaths {
		if _, err := os.Stat(helperPath); err == nil {
			cmd := exec.Command(helperPath)
			cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}

			var out bytes.Buffer
			cmd.Stdout = &out
			cmd.Run()

			output := out.String()
			if output != "" {
				var info MediaInfo
				if err := json.Unmarshal([]byte(output), &info); err == nil && info.Title != "" && info.Title != "YouTube" {
					return info
				}
			}
		}
	}

	return MediaInfo{Title: "Nenhuma música"}
}

func getMediaViaWinRT() MediaInfo {
	// Script PowerShell que funciona com async/await do WinRT
	psScript := `
try {
    [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime] | Out-Null

    $asyncOp = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager]::RequestAsync()
    
    # Aguarda completion
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while ($asyncOp.Status -eq 'Started' -and $sw.ElapsedMilliseconds -lt 3000) {
        [System.Threading.Thread]::Sleep(10)
    }
    
    if ($asyncOp.Status -ne 'Completed') {
        exit
    }
    
    # Obtém o resultado
    $asyncOp.Completed.Invoke($asyncOp, $null)
    $manager = $asyncOp.GetResults()
    
    if (-not $manager) {
        exit
    }
    
    $sessions = @($manager.GetSessions())
    
    foreach ($session in $sessions) {
        try {
            $propsOp = $session.TryGetMediaPropertiesAsync()
            
            $sw2 = [System.Diagnostics.Stopwatch]::StartNew()
            while ($propsOp.Status -eq 'Started' -and $sw2.ElapsedMilliseconds -lt 2000) {
                [System.Threading.Thread]::Sleep(10)
            }
            
            if ($propsOp.Status -eq 'Completed') {
                $propsOp.Completed.Invoke($propsOp, $null)
                $props = $propsOp.GetResults()
                
                if ($props -and $props.Title -and $props.Title.Trim() -ne '') {
                    $playback = $session.GetPlaybackInfo()
                    
                    $result = @{
                        title = $props.Title
                        artist = if ($props.Artist -and $props.Artist.Trim() -ne '') { $props.Artist } else { '' }
                        album = if ($props.AlbumTitle -and $props.AlbumTitle.Trim() -ne '') { $props.AlbumTitle } else { '' }
                        cover = ''
                        playing = ($playback.PlaybackStatus -eq 'Playing')
                    }
                    
                    $result | ConvertTo-Json
                    exit 0
                }
            }
        } catch {
            # Silent continue
        }
    }
} catch {
    # Silent continue
}
`

	cmd := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", psScript)
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}

	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Run()

	output := out.String()
	if output == "" {
		return MediaInfo{}
	}

	var info MediaInfo
	if err := json.Unmarshal([]byte(output), &info); err != nil {
		return MediaInfo{}
	}

	return info
}



func PlayPause() {
	sendMediaKey(VK_MEDIA_PLAY_PAUSE)
}

func Next() {
	sendMediaKey(VK_MEDIA_NEXT_TRACK)
}

func Previous() {
	sendMediaKey(VK_MEDIA_PREV_TRACK)
}