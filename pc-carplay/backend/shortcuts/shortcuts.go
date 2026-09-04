package shortcuts

import (
	"os"
	"os/exec"
	"strings"
)

type Shortcut struct {
	ID      int    `json:"id"`
	Name    string `json:"name"`
	Icon    string `json:"icon"`
	Command string `json:"command"`
}

var shortcuts = []Shortcut{
	{
		ID:      1,
		Name:    "YouTube",
		Icon:    "discord",
		Command: "https://www.youtube.com/",
	},
	{
		ID:      2,
		Name:    "Chrome",
		Icon:    "chrome",
		Command: "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
	},
	{
		ID:      3,
		Name:    "GitHub",
		Icon:    "whatsapp",
		Command: "https://github.com/",
	},
	{
		ID:      4,
		Name:    "Portfólio",
		Icon:    "league-of-legends",
		Command: "https://portfolio-carlos-eduardo-andrade.netlify.app/",
	},
}

func GetAll() []Shortcut {
	return shortcuts
}

func Open(id int) error {
	for _, shortcut := range shortcuts {
		if shortcut.ID == id {
			if strings.HasPrefix(shortcut.Command, "http://") || strings.HasPrefix(shortcut.Command, "https://") {
				return exec.Command("rundll32", "url.dll,FileProtocolHandler", shortcut.Command).Start()
			}

			return exec.Command(os.ExpandEnv(shortcut.Command)).Start()
		}
	}

	return nil
}
