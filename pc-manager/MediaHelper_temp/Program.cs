using System;
using System.Diagnostics;
using System.Text.Json;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Net.Http;

class Program
{
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetWindowText(IntPtr hWnd, System.Text.StringBuilder text, int count);

    static async Task Main()
    {
        try
        {
            // Tenta método 1: API Spotify local
            var spotifyResult = await TrySpotifyLocalAPI();
            if (spotifyResult != null)
            {
                Console.Write(spotifyResult);
                return;
            }

            // Tenta método 2: Lê o título da janela do Spotify/YouTube
            var windowResult = TryGetWindowTitle();
            if (windowResult != null)
            {
                Console.Write(windowResult);
                return;
            }
        }
        catch { }
    }

    static async Task<string> TrySpotifyLocalAPI()
    {
        try
        {
            using (var client = new HttpClient())
            {
                var response = await client.GetAsync("http://127.0.0.1:4371/remote/status.json?client=OAuthLoginClient&redirect_uri=http://localhost:4371/blank.html&requestID=QQFGRjIe6&key=0524d91a321cb6d3d5160e83948cbe63");
                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync();
                    using (JsonDocument doc = JsonDocument.Parse(content))
                    {
                        var root = doc.RootElement;
                        if (root.TryGetProperty("track", out var track) &&
                            track.TryGetProperty("track_resource", out var trackRes) &&
                            trackRes.TryGetProperty("name", out var name))
                        {
                            var title = name.GetString();
                            var artist = "";
                            if (track.TryGetProperty("artist_resource", out var artistRes) &&
                                artistRes.TryGetProperty("name", out var artistName))
                            {
                                artist = artistName.GetString();
                            }

                            var isPlaying = false;
                            if (root.TryGetProperty("playing", out var playing))
                            {
                                isPlaying = playing.GetBoolean();
                            }

                            var result = new
                            {
                                title = title ?? "",
                                artist = artist ?? "",
                                album = "",
                                cover = "",
                                playing = isPlaying
                            };

                            return JsonSerializer.Serialize(result);
                        }
                    }
                }
            }
        }
        catch { }
        return null;
    }

    static string TryGetWindowTitle()
    {
        try
        {
            var spotifyProcess = Process.GetProcessesByName("Spotify");
            if (spotifyProcess.Length > 0)
            {
                var mainWindowHandle = spotifyProcess[0].MainWindowHandle;
                var sb = new System.Text.StringBuilder(1024);
                GetWindowText(mainWindowHandle, sb, 1024);
                var title = sb.ToString();

                // Spotify window title formato: "Artist - Track"
                if (!string.IsNullOrEmpty(title) && title.Contains(" - "))
                {
                    var parts = title.Split(new[] { " - " }, StringSplitOptions.None);
                    if (parts.Length >= 2)
                    {
                        var result = new
                        {
                            title = parts[parts.Length - 1],
                            artist = parts[0],
                            album = "",
                            cover = "",
                            playing = true
                        };
                        return JsonSerializer.Serialize(result);
                    }
                }
            }

            // Tenta YouTube/Chrome
            string[] chromeNames = { "chrome", "msedge", "firefox" };
            foreach (var browserName in chromeNames)
            {
                var browserProcess = Process.GetProcessesByName(browserName);
                if (browserProcess.Length > 0)
                {
                    var mainWindowHandle = browserProcess[0].MainWindowHandle;
                    var sb = new System.Text.StringBuilder(1024);
                    GetWindowText(mainWindowHandle, sb, 1024);
                    var title = sb.ToString();

                    // Remove apenas o sufixo do navegador no final
                    title = title.Replace("- Google Chrome", "").Replace("- Microsoft Edge", "").Replace("- Firefox", "").Replace("- YouTube", "").Replace("- Brave", "").Replace("- Opera", "");
                    title = title.TrimEnd();
                    
                    title = title.Trim();

                    if (!string.IsNullOrEmpty(title) && title.Length > 3)
                    {
                        var result = new
                        {
                            title = title,
                            artist = "",
                            album = "",
                            cover = "",
                            playing = true
                        };
                        return JsonSerializer.Serialize(result);
                    }
                }
            }
        }
        catch { }
        return null;
    }
}
