local awful = require('awful')
local beautiful = require('beautiful')
local log = require('log')

local keys = require('keys')
local all_clients = {
  rule = {},
  -- Rename this table property to "callback" to enable logging
  -- for debugging and development purposes
  callbackOFF = function(client)
    log.log('rule callback function called')
    log.log('name:' .. client.name)
    log.log('class:' .. client.class)
    log.log('maximized:' .. tostring(client.maximized))
    return true
  end,
  properties = {
    border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    raise = true,
    maximized = true,
    buttons = keys.clientbuttons,
    keys = keys.clientkeys,
    screen = awful.screen.preferred,
    placement = awful.placement.no_overlap + awful.placement.no_offscreen
  }
}
local floating_clients = {
  rule_any = {
    instance = {
      'DTA', -- Firefox addon DownThemAll.
      'copyq', -- Includes session name in class.
      'pinentry'
    },
    class = {
      'Arandr', 'Blueman-manager', 'Gpick', 'Kruler', 'MessageWin', -- kalarm.
      'Sxiv', 'Tor Browser', -- Needs a fixed window size to avoid fingerprinting by screen size.
      'Wpa_gui', 'veromix', 'xtightvncviewer', 'Yad', 'zenity', 'FreeCAD',
      'zoom', 'Mate-calc', 'Prusa-slicer', 'Kicad'
    },

    -- Note that the name property shown in xprop might be set slightly after creation of the client
    -- and the name shown there might not match defined rules here.
    name = {
      'Event Tester' -- xev.
    },
    role = {
      'AlarmWindow', -- Thunderbird's calendar.
      'ConfigManager', -- Thunderbird's about:config.
      'pop-up', -- e.g. Google Chrome's (detached) Developer Tools.
      'Dialog' -- e.g. Firefox
    }
  },
  properties = {
    floating = true,
    maximized = false,
    sticky = false,
    ontop = false,
    placement = awful.placement.centered
  }
}
local title_bars = {
  rule_any = {type = {'normal', 'dialog'}},
  properties = {titlebars_enabled = true}
}
local sticky = {
  rule_any = {class = {'Yad', 'zenity'}, name = {'Chat'}, role = {'Dialog'}},
  properties = {
    ontop = true,
    floating = true,
    sticky = true,
    placement = awful.placement.centered
  }
}
local rofi = {
  -- rofi for leader key
  rule_any = {class = {'Rofi'}},
  properties = {
    tag = '4',
    placement = awful.placement.centered,
    maximized = false
  }
}
local all_regular_tags = {'1', '2', '3'}
local one_password = {
  -- Put 1Password on tags 1 & 2
  rule_any = {class = {'1Password'}},
  properties = {tags = all_regular_tags, maximized = true}
}
local frc = {
  -- Put FRC terminal on tags 1 & 2
  rule_any = {name = {'FRC: website'}},
  properties = {tags = {'2'}, maximized = true}
}
local slack = {
  -- Put slack on tags 1 & 2
  rule_any = {class = {'Slack'}},
  properties = {tags = all_regular_tags, maximized = true}
}
local music = {
  -- Put music on tags 1 & 2
  rule_any = {name = {'music'}},
  properties = {tags = all_regular_tags, maximized = true}
}
local freecad = {
  -- Force FreeCAD to maximize the main window properly
  rule_any = {class = {'FreeCAD'}},
  callback = function(client)
    -- log.log('callback2 for FreeCAD:' .. client.name)
    -- This is very hacky, but the main FreeCAD window title
    -- includes the version number, so we check for a digit
    if string.match(client.name, '%d') then
      -- log.log('callback3 for FreeCAD:' .. client.name)
      awful.rules.execute(client, {maximized = true})
    end
  end
}
awful.rules.rules = {
  all_clients, floating_clients, title_bars, sticky, rofi, one_password, frc,
  slack, music, freecad
}

