-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

config.leader = { key = ";", mods = "CTRL", timeout_milliseconds = 1000 }

-- Wezterm fails to start with Hyprland without this
config.enable_wayland = false

-- Appearance
config.color_scheme = "Catppuccin Mocha"
local catppuccinTheme = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
config.window_frame = {
	border_top_height = "0.5cell",
	border_top_color = catppuccinTheme.tab_bar.inactive_tab.bg_color,
}

config.window_padding = {
	top = "0.5cell",
}

config.colors = {
	tab_bar = {
		background = catppuccinTheme.tab_bar.inactive_tab.bg_color,
		active_tab = {
			-- No background highlight: match the tab bar background instead.
			bg_color = catppuccinTheme.tab_bar.inactive_tab.bg_color,
			-- Move the accent colour to the text so the active tab still stands out.
			fg_color = catppuccinTheme.tab_bar.active_tab.bg_color,
		},
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
	local index = tab.tab_index + 1
	--
	-- When the visible pane is zoomed, only a single pane of several is shown.
	-- Prefix an eye icon so it's clear we're focused on one pane.
	local zoom_prefix = ""
	local zoom_len_correction = 0
	if tab.active_pane.is_zoomed then
		local eye_icon = wezterm.nerdfonts.fa_eye
		zoom_prefix = eye_icon .. " "
		-- string.len counts UTF-8 bytes; the glyph is 1 display cell, so
		-- correct for the extra bytes when computing padding.
		zoom_len_correction = string.len(eye_icon) - 1
	end

	-- Every tab except the first gets a leading separator glyph so it's clear
	-- where one tab ends and the next begins. Reserve a cell for it in the
	-- width calculation so tab widths stay consistent.
	local has_separator = tab.tab_index > 0
	local target_width = math.floor(max_width)
	if has_separator then
		target_width = target_width - 1
	end

	-- Always keep at least this many spaces between the title and the tab
	-- edges/separator so long titles don't run right up to the divider.
	local min_padding = 2

	local prefix = string.format("%s %d: ", zoom_prefix, index)
	local prefix_len = string.len(prefix) - zoom_len_correction

	-- Reserve room for the prefix plus the minimum padding on both sides.
	local available_for_title = target_width - prefix_len - (min_padding * 2)
	if available_for_title < 0 then
		available_for_title = 0
	end

	local title = prefix .. wezterm.truncate_right(tab.active_pane.title, available_for_title)

	local padding_total = target_width - (string.len(title) - zoom_len_correction)
	if padding_total < min_padding * 2 then
		padding_total = min_padding * 2
	end

	local left_padding = math.floor(padding_total / 2)
	local right_padding = padding_total - left_padding

	local left_spaces = string.rep(" ", left_padding)
	local right_spaces = string.rep(" ", right_padding)

	title = left_spaces .. title .. right_spaces

	-- Colour the title explicitly per tab: accent for the active tab, the
	-- theme's default for inactive ones. Setting it here also stops the
	-- separator's colour from bleeding into the title text.
	local title_fg = tab.is_active and catppuccinTheme.tab_bar.active_tab.bg_color
		or catppuccinTheme.tab_bar.inactive_tab.fg_color

	local elements = {}
	if has_separator then
		table.insert(elements, { Foreground = { Color = catppuccinTheme.tab_bar.inactive_tab.fg_color } })
		table.insert(elements, { Text = wezterm.nerdfonts.pl_left_soft_divider })
	end
	table.insert(elements, { Foreground = { Color = title_fg } })
	table.insert(elements, { Text = title })

	return elements
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
		key = "H",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		key = "L",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({
			domain = "CurrentPaneDomain",
		}),
	},
	-- Split pane vertically
	{
		key = "J",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},
	{
		key = "K",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({
			domain = "CurrentPaneDomain",
		}),
	},
	-- Improved url opening
	{
		key = "u",
		mods = "LEADER",
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
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "f",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
	-- Create a new tab
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	-- Navigate to previous/next tab
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "]",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(1),
	},
}

-- Leader + number selects the corresponding tab (1-indexed for the user,
-- ActivateTab is 0-indexed internally)
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

config.inactive_pane_hsb = {
	saturation = 0.8,
	brightness = 0.7,
}

config.quick_select_alphabet = "arstdhneio"

config.hide_mouse_cursor_when_typing = true

-- Finally, return the configuration to wezterm:
return config
