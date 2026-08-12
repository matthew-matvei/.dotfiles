-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.leader = { key = ";", timeout_milliseconds = 1000 }

-- Wezterm fails to start with Hyprland without this
config.enable_wayland = false

-- Appearance
config.color_scheme = "Catppuccin Mocha"
local catppuccinTheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
config.window_frame = {
	font = wezterm.font({ family = "JetBrainsMono Nerd Font", weight = "Bold" }),
	font_size = 12.0,
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
	border_top_height = "0.5cell",
	border_top_color = catppuccinTheme.tab_bar.inactive_tab.bg_color,
}

config.window_padding = {
	top = "0.5cell",
}

config.colors = {
	tab_bar = {
		background = catppuccinTheme.tab_bar.inactive_tab.bg_color,
	},
}
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
config.window_background_opacity = 0.8

config.use_fancy_tab_bar = false
config.tab_max_width = 999
config.macos_window_background_blur = 20

config.window_decorations = "RESIZE"

config.show_new_tab_button_in_tab_bar = false

config.window_background_gradient = {
	colors = { catppuccinTheme.background },
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = catppuccinTheme.tab_bar.inactive_tab.bg_color
	local foreground = catppuccinTheme.tab_bar.inactive_tab.fg_color
	local index = tab.tab_index + 1

	if tab.is_active then
		background = catppuccinTheme.tab_bar.active_tab.bg_color
		foreground = catppuccinTheme.tab_bar.active_tab.fg_color
	end

	local title = string.format(" %d: ", index) .. wezterm.truncate_right(tab.active_pane.title, max_width - 1)

	local target_width = math.floor(max_width)
	local padding_total = target_width - string.len(title)
	if padding_total < 0 then
		padding_total = 0
	end

	local left_padding = math.floor(padding_total / 2)
	local right_padding = padding_total - left_padding

	local left_spaces = string.rep(" ", left_padding)
	local right_spaces = string.rep(" ", right_padding)

	title = left_spaces .. title .. right_spaces

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

config.keys = {
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	-- Split pane horizontally
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	-- Split pane vertically
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},
	-- Improved url opening
	{
		key = "u",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuickSelectArgs({
			patterns = {
				"https?://\\S+",
			},
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				if url and url ~= "" then
					wezterm.log_info("Opening URL: " .. url)
					wezterm.open_with(url)
				end
			end),
		}),
	},
}

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

config.quick_select_alphabet = "arstdhneio"

-- Finally, return the configuration to wezterm:
return config
