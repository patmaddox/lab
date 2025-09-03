local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.scrollback_lines = 0

config.enable_kitty_keyboard = true

-- disable ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.disable_default_key_bindings = true

config.keys = {
   { key = 'Space', mods = 'SHIFT', action = act.SendKey { key = 'Space' } },
   { key = 'c', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
   { key = 'v', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
   { key = 't', mods = 'SHIFT|CTRL', action = act.SpawnTab 'CurrentPaneDomain' },
   { key = 'w', mods = 'SHIFT|CTRL', action = act.CloseCurrentTab{ confirm = false } },
   { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-1) },
   { key = 'PageUp', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
   { key = 'PageUp', mods = 'SHIFT|CTRL', action = act.MoveTabRelative(-1) },
   { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
   { key = 'PageDown', mods = 'CTRL', action = act.ActivateTabRelative(1) },
   { key = 'PageDown', mods = 'SHIFT|CTRL', action = act.MoveTabRelative(1) },
   { key = 'PageDown', mods = 'ALT', action = act.DecreaseFontSize },
   { key = 'PageUp', mods = 'ALT', action = act.IncreaseFontSize },
   { key = 'k', mods = 'ALT', action = wezterm.action.SendString '\x0b' }, -- ctrl-k
}

return config
