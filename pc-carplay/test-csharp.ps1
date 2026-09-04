$csharpCode = @"
using System;
using System.Threading.Tasks;
using Windows.Media.Control;

public class MediaController {
    public static string GetMediaInfo() {
        try {
            var manager = GlobalSystemMediaTransportControlsSessionManager.RequestAsync().AsTask().Result;
            if (manager == null) return "";
            
            var sessions = manager.GetSessions();
            foreach (var session in sessions) {
                try {
                    var props = session.TryGetMediaPropertiesAsync().AsTask().Result;
                    var playback = session.GetPlaybackInfo();
                    
                    if (props != null && !string.IsNullOrEmpty(props.Title)) {
                        string title = props.Title ?? "";
                        string artist = props.Artist ?? "";
                        string album = props.AlbumTitle ?? "";
                        bool isPlaying = playback.PlaybackStatus == MediaPlaybackStatus.Playing;
                        
                        string json = $"{{\"title\":\"{title.Replace("\"", "\\\"")}\",\"artist\":\"{artist.Replace("\"", "\\\"")}\",\"album\":\"{album.Replace("\"", "\\\"")}\",\"cover\":\"\",\"playing\":{isPlaying.ToString().ToLower()}}}";
                        return json;
                    }
                } catch { }
            }
        } catch { }
        return "";
    }
}
"@

Add-Type -TypeDefinition $csharpCode -ReferencedAssemblies Windows.Media.Control, System.Runtime.WindowsRuntime

$result = [MediaController]::GetMediaInfo()
if ($result) {
    Write-Output $result
}
