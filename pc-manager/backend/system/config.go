package config

import (
	"encoding/json"
	"os"
)

type Config struct {
	Shortcuts []Shortcut `json:"shortcuts"`
}

type Shortcut struct {
	ID      int    `json:"id"`
	Name    string `json:"name"`
	Icon    string `json:"icon"`
	Command string `json:"command"`
}

func Load() (*Config, error) {
	data, err := os.ReadFile("config/config.json")
	if err != nil {
		return nil, err
	}

	var config Config

	err = json.Unmarshal(data, &config)
	if err != nil {
		return nil, err
	}

	return &config, nil
}