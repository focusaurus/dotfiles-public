-- Stolen from: https://github.com/rosshadden/dotfiles/blob/master/src/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'

local scheme = wezterm.get_builtin_color_schemes()['Vaughn']

function tablfy(value)
  result = {}
  for match in (value .. ' '):gmatch('(.-)' .. ' ') do
    table.insert(result, match)
  end
  return result
end

local config = {
  audible_bell = 'Disabled',
  key_tables = {},

  -- startup
  -- default_prog = { "/media/media/src/forks/nushell/target/debug/nu" },
  default_gui_startup_args = {'connect', 'unix'},
  term = 'wezterm',

  -- fonts
  font = wezterm.font_with_fallback({
    'Hack Nerd Font', 'JetBrains Mono', 'Fira Code', 'Noto Color Emoji'
  }),
  font_size = 16,

  -- ui
  color_scheme = 'Paraiso Dark',
  color_schemes = {['Paraiso Dark'] = scheme},
  -- window_background_opacity = 0.85,

  -- cursor
  force_reverse_video_cursor = true,

  -- more native keys
  enable_csi_u_key_encoding = true,

  -- quick select keys
  quick_select_alphabet = 'aoeuqjkxpyhtnsgcrlmwvzfidb'
}

-- mappings

config.leader = {mods = 'CTRL', key = 'Space'}

config.keys = {
  -- unmap
  {mods = 'ALT', key = 'Enter', action = 'DisableDefaultAssignment'},
  {mods = 'CTRL', key = 'Slash', action = wezterm.action {SendString = ''}},

  -- normalize
  {mods = 'SHIFT', key = ' ', action = wezterm.action {SendString = ' '}}, {
    mods = 'SHIFT',
    key = 'Backspace',
    action = wezterm.action {SendKey = {key = 'Backspace'}}
  },
  {mods = 'CTRL', key = 'v', action = wezterm.action {PasteFrom = 'Clipboard'}},
  {mods = '', key = 'PageUp', action = wezterm.action {ScrollByPage = -1}},
  {mods = '', key = 'PageDown', action = wezterm.action {ScrollByPage = 1}},

  -- modes
  {
    mods = 'LEADER',
    key = 'a',
    action = wezterm.action {
      ActivateKeyTable = {
        name = 'app',
        one_shot = true,
        replace_current = false
      }
    }
  }, {
    mods = 'LEADER',
    key = 'p',
    action = wezterm.action {
      ActivateKeyTable = {
        name = 'panes',
        one_shot = true,
        replace_current = false
      }
    }
  }, {mods = 'LEADER', key = 'c', action = 'ActivateCopyMode'}, {
    mods = 'LEADER',
    key = 'r',
    action = wezterm.action {
      ActivateKeyTable = {
        name = 'resize',
        one_shot = false,
        replace_current = false
      }
    }
  }, {
    mods = 'LEADER',
    key = 's',
    action = wezterm.action {
      ActivateKeyTable = {
        name = 'session',
        one_shot = true,
        replace_current = false
      }
    }
  }, {
    mods = 'LEADER',
    key = 'w',
    action = wezterm.action {
      ActivateKeyTable = {
        name = 'windows',
        one_shot = true,
        replace_current = false
      }
    }
  }, {
    mods = 'LEADER',
    key = 't',
    action = wezterm.action {
      ActivateKeyTable = {
        name = 'tabs',
        one_shot = true,
        replace_current = false
      }
    }
  }, {
    mods = 'LEADER',
    key = 'l',
    action = wezterm.action {ClearScrollback = 'ScrollbackAndViewport'}
  }, -- navigation
  -- {mods = 'LEADER', key = 'Tab', action = 'ActivateLastTab'}, {
  --   mods = 'LEADER',
  --   key = 'p',
  --   action = wezterm.action {ActivateTabRelative = -1}
  -- },
  -- {
  --   mods = 'LEADER',
  --   key = 'n',
  --   action = wezterm.action {ActivateTabRelative = 1}
  -- }, {
  {
    mods = 'CTRL',
    key = 'j',
    action = wezterm.action {ActivatePaneDirection = 'Down'}
  }, {
    mods = 'CTRL',
    key = 'k',
    action = wezterm.action {ActivatePaneDirection = 'Up'}
  }, {
    mods = 'CTRL',
    key = 'h',
    action = wezterm.action {ActivatePaneDirection = 'Left'}
  }, {
    mods = 'CTRL',
    key = 'l',
    action = wezterm.action {ActivatePaneDirection = 'Right'}
  }, -- debug
  {
    mods = 'LEADER',
    key = 'Backspace',
    action = wezterm.action_callback(function(win, pane)
      os.execute('notify-send debug \'title: ' .. pane:get_title() ..
                     '\nprocess: ' .. pane:get_foreground_process_name() ..
                     '\ncwd: ' .. pane:get_current_working_dir() .. '\'')
    end)
  }, {
    mods = 'CTRL|SHIFT',
    key = 'DownArrow',
    action = wezterm.action.PaneSelect {mode = 'Activate'}
  }
}

local exitMappings = {
  {key = 'Escape', action = 'PopKeyTable'}, {key = 'q', action = 'PopKeyTable'}
}

config.key_tables.app = {
  {key = 'f', action = 'ToggleFullScreen'},
  {key = 'l', action = 'ShowLauncher'},
  {key = 'r', action = 'ReloadConfiguration'}
}

config.key_tables.session = {
  {key = 'd', action = wezterm.action {DetachDomain = 'CurrentPaneDomain'}}
}

config.key_tables.windows = {{key = 'n', action = 'SpawnWindow'}}

config.key_tables.tabs = {
  {key = 'Space', action = 'ShowTabNavigator'},
  {key = 'Tab', action = 'ActivateLastTab'},
  {key = '`', action = wezterm.action {ActivateTab = -1}},

  {key = 'n', action = wezterm.action {SpawnTab = 'CurrentPaneDomain'}},
  {key = 'c', action = wezterm.action {CloseCurrentTab = {confirm = true}}},
  {key = 'C', action = wezterm.action {CloseCurrentTab = {confirm = false}}},

  {key = 'h', action = wezterm.action {ActivateTabRelative = -1}},
  {key = 'l', action = wezterm.action {ActivateTabRelative = 1}},
  {key = 'H', action = wezterm.action {MoveTabRelative = -1}},
  {key = 'L', action = wezterm.action {MoveTabRelative = 1}}, {
    key = 't',
    action = wezterm.action_callback(function(win, pane)
      wezterm.log_info 'Hello from callback!'
      wezterm.log_info('WindowID:', win:window_id(), 'PaneID:', pane:pane_id())
      -- pane::
    end)
  }
}
for i = 1, 9 do
  table.insert(config.keys, {
    mods = 'LEADER',
    key = tostring(i),
    action = wezterm.action {ActivateTab = i - 1}
  })
  table.insert(config.key_tables.tabs, {
    key = tostring(i),
    action = wezterm.action {ActivateTab = i - 1}
  })
end

config.key_tables.panes = {
  {key = 'Space', action = wezterm.action {PaneSelect = {}}},
  {key = 's', action = wezterm.action {PaneSelect = {mode = 'Activate'}}},

  {key = 'c', action = wezterm.action {CloseCurrentPane = {confirm = true}}},
  {key = 'C', action = wezterm.action {CloseCurrentPane = {confirm = false}}},

  {key = 'j', action = wezterm.action {SplitPane = {direction = 'Down'}}},
  {key = 'k', action = wezterm.action {SplitPane = {direction = 'Up'}}},
  {key = 'h', action = wezterm.action {SplitPane = {direction = 'Left'}}},
  {key = 'l', action = wezterm.action {SplitPane = {direction = 'Right'}}}, {
    key = 'J',
    action = wezterm.action {SplitPane = {direction = 'Down', top_level = true}}
  }, {
    key = 'K',
    action = wezterm.action {SplitPane = {direction = 'Up', top_level = true}}
  }, {
    key = 'H',
    action = wezterm.action {SplitPane = {direction = 'Left', top_level = true}}
  }, {
    key = 'L',
    action = wezterm.action {
      SplitPane = {direction = 'Right', top_level = true}
    }
  }, {key = 'f', action = 'TogglePaneZoomState'},
  {key = 'z', action = 'TogglePaneZoomState'}
}

config.key_tables.resize = {
  {key = 'j', action = wezterm.action {AdjustPaneSize = {'Down', 1}}},
  {key = 'k', action = wezterm.action {AdjustPaneSize = {'Up', 1}}},
  {key = 'h', action = wezterm.action {AdjustPaneSize = {'Left', 1}}},
  {key = 'l', action = wezterm.action {AdjustPaneSize = {'Right', 1}}},
  table.unpack(exitMappings)
}

-- menu
config.launch_menu = {{args = {'btm'}}, {args = {'htop'}}}

-- workspaces
config.unix_domains = {{name = 'unix'}}

-- config.window_frame = {
-- font_size = 16.0,
-- 	active_titlebar_bg = "#2f1e2e",
-- 	inactive_titlebar_bg = "#333333",
-- }

config.colors = {
  compose_cursor = 'orange',
  cursor_border = 'white',
  -- foreground = "white",

  tab_bar = {
    -- background = "#ef6155",
    active_tab = {bg_color = '#815ba4', fg_color = '#ffffff'},
    inactive_tab = {bg_color = '#2f1e2e', fg_color = '#ffffff'}
  }
}

for key, value in pairs(config.colors) do scheme[key] = value end

-- wezterm.on("update-right-status", function(win, pane)
-- 	local process = pane:get_foreground_process_name()
-- 	local mode = win:active_key_table() or ""
-- 	local status = process
-- 	if mode ~= "" then status = "[" .. string.upper(mode) .. "] " .. status end
-- 	win:set_right_status(" " .. status .. " ")
-- end)

return config
-- local wezterm = require('wezterm')
-- return {
--   font = wezterm.font 'Hack Nerd Font',
--   leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 5000 },
--   keys = {
--     {
--       key = 's',
--       mods = 'LEADER',
--       action = wezterm.action.QuickSelect,
--     },
--     {
--       key = 'n',
--       mods = 'LEADER',
--       action = wezterm.action.ActivatePaneDirection('Right'),
--     },
--     {
--       key = 'p',
--       mods = 'LEADER',
--       action = wezterm.action.ActivatePaneDirection('Left'),
--     },
--     {
--       key = 'P',
--       mods = 'LEADER',
--       action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
--     },
--     {
--       key = '-',
--       mods = 'LEADER',
--       action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
--     },
--     {
--       key = 'v',
--       mods = 'CTRL',
--       action = wezterm.action.PasteFrom('Clipboard'),
--     },
--     -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
--     -- {
--     --   key = 'spc',
--     --   mods = 'LEADER|CTRL',
--     --   action = wezterm.action.SendString '\x01',
--     },
-- }
--
