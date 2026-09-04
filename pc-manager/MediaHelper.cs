using System;
using System.Text.Json;
using System.Threading.Tasks;
using Windows.Media.Control;

class Program {
    static async Task Main() {
        try {
            var manager = await GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
            if (manager == null) return;
            
            var sessions = manager.GetSessions();
            foreach (var session in sessions) {
                try {
                    var props = await session.TryGetMediaPropertiesAsync();
                    if (props != null && !string.IsNullOrEmpty(props.Title)) {
                        var playback = session.GetPlaybackInfo();
                        
                        var result = new {
                            title = props.Title ?? "",
                            artist = props.Artist ?? "",
                            album = props.AlbumTitle ?? "",
                            cover = "",
                            playing = playback.PlaybackStatus == MediaPlaybackStatus.Playing
                        };
                        
                        Console.Write(JsonSerializer.Serialize(result));
                        return;
                    }
                } catch { }
            }
        } catch { }
    }
}
