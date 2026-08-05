-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- Appearance
config.color_scheme = "Catppuccin Mocha"
config.window_frame = {
	font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
	font_size = 12.0,
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

config.colors = {
	tab_bar = {
		background = "none",
	},
}
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
config.window_background_opacity = 0.8

config.use_fancy_tab_bar = true
config.macos_window_background_blur = 20

config.window_decorations = "RESIZE"

config.show_new_tab_button_in_tab_bar = false

local catppuccinTheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]

config.window_background_gradient = {
	colors = { catppuccinTheme.background },
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = catppuccinTheme.tab_bar.inactive_tab.bg_color
	local foreground = catppuccinTheme.tab_bar.inactive_tab.fg_color

	if tab.is_active then
		background = catppuccinTheme.tab_bar.active_tab.bg_color
		foreground = catppuccinTheme.tab_bar.active_tab.fg_color
	end

	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

-- Finally, return the configuration to wezterm:
return config
