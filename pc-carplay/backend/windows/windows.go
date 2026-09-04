package windows

import (
	"os/exec"
	"syscall"
)

const (
	keyEventKeyUp = 0x0002
	volumeDown    = 0xAE
	volumeUp      = 0xAF
	mute          = 0xAD
)

var user32 = syscall.NewLazyDLL("user32.dll")
var keybdEvent = user32.NewProc("keybd_event")

func sendKey(key byte) {
	keybdEvent.Call(uintptr(key), 0, 0, 0)
	keybdEvent.Call(uintptr(key), 0, keyEventKeyUp, 0)
}

func VolumeUp()   { sendKey(volumeUp) }
func VolumeDown() { sendKey(volumeDown) }
func ToggleMute() { sendKey(mute) }

func OpenNotifications() error {
	return exec.Command("explorer.exe", "ms-settings:notifications").Start()
}

func OpenFocusSettings() error {
	return exec.Command("explorer.exe", "ms-settings:quiethours").Start()
}
