package main

import (
	"context"

	"pc-carplay/backend/media"
	"pc-carplay/backend/shortcuts"
	pcwindows "pc-carplay/backend/windows"
)

type App struct {
	ctx context.Context
}

func NewApp() *App {
	return &App{}
}

func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// MEDIA

func (a *App) GetMedia() media.MediaInfo {
	return media.GetCurrentMedia()
}

func (a *App) PlayPause() {
	media.PlayPause()
}

func (a *App) Next() {
	media.Next()
}

func (a *App) Previous() {
	media.Previous()
}

func (a *App) VolumeUp() { pcwindows.VolumeUp() }

func (a *App) VolumeDown() { pcwindows.VolumeDown() }

func (a *App) ToggleMute() { pcwindows.ToggleMute() }

func (a *App) OpenNotifications() error { return pcwindows.OpenNotifications() }

func (a *App) OpenFocusSettings() error { return pcwindows.OpenFocusSettings() }

// SHORTCUTS

func (a *App) GetShortcuts() []shortcuts.Shortcut {
	return shortcuts.GetAll()
}

func (a *App) OpenShortcut(id int) error {
	return shortcuts.Open(id)
}
