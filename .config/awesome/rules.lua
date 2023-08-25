local module = {}
local awful = require('awful')
local beautiful = require('beautiful')
local log2 = require('log2')

local keys = require('keys')
local all_clients = {
  rule = {},
  -- Rename this table property to "callback" to enable logging
  -- for debugging and development purposes
  callbackOFF = function(client)
    log2('rule callback function called')
    log2('name:', client.name)
    log2('class:', client.class)
    log2('maximized:', client.maximized)
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
      'Event Tester', -- xev
      'Export File' -- shotcut
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
    -- tag = '4',
    placement = awful.placement.centered,
    maximized = false
    -- focus = false
  }
}

local nofi = {
  rule_any = {class = {'nofi'}},
  properties = {
    tag = '4',
    placement = awful.placement.centered,
    maximized = false,
    focus = false,
    urgent = false
  }
}

local all_regular_tags = {'1', '2', '3'}
local one_password = {
  rule_any = {class = {'1Password'}},
  properties = {tags = all_regular_tags, maximized = true}
}

local frc = {
  rule_any = {name = {'FRC: website'}},
  properties = {tags = {'2'}, maximized = true}
}

local slack = {
  rule_any = {class = {'Slack'}},
  properties = {tags = all_regular_tags, maximized = true}
}

local music = {
  rule_any = {name = {'music', 'YouTube Music'}},
  properties = {tags = all_regular_tags, maximized = true}
}

local freecad = {
  -- Force FreeCAD to maximize the main window properly
  rule_any = {class = {'FreeCAD'}},
  callback = function(client)
    -- log2('callback2 for FreeCAD:', client.name)
    -- This is very hacky, but the main FreeCAD window title
    -- includes the version number, so we check for a digit
    if string.match(client.name, '%d') then
      -- log2('callback3 for FreeCAD:', client.name)
      awful.rules.execute(client, {maximized = true})
    end
  end
}

local openshot_preview = {
  rule_any = {class = {'openshot'}, name = {'Preview'}},
  properties = {
    -- floating = true,
    titlebars_enabled = true
    -- ontop = false,
    -- sticky = false
  }
}

local openshot_tutorial = {
  rule_any = {class = {'openshot'}, name = {'Tutorial'}},
  properties = {
    floating = true,
    titlebars_enabled = false,
    ontop = false,
    sticky = false
  }
}

local obsidian = {
  rule_any = {class = {'obsidian'}},
  callback = function(client)
    local tags = {'1'}
    -- log2('callback2 for obsidian: ', client.name)
    for tag, name in pairs({'personal', 'focus-retreat-center', 'nuon'}) do
      if string.find(client.name, ' - ' .. name .. ' - ', 1, true) then
        -- log2('callback3 for obsidian: ', client.name)
        -- log2('callback4 for obsidian: ', name)
        tags = {tostring(tag)}
        break
      end
    end
    awful.rules.execute(client, {maximized = true, tags = tags})
  end
}

local xournalpp_export = {
  rule = {class = 'Xournalpp', name = 'Export'},
  properties = {floating = true, maximized = false}
}

local xournalpp_export_pdf = {
  rule = {class = 'Xournalpp', name = 'Export PDF'},
  properties = {floating = true, maximized = false}
}

awful.rules.rules = {
  all_clients, floating_clients, title_bars, sticky, one_password, frc, slack,
  music, freecad, openshot_preview, openshot_tutorial, obsidian,
  xournalpp_export, xournalpp_export_pdf, rofi, nofi
}

function module.reapply()
  for c in awful.client.iterate(function() return true end) do
    log2('re-applying rules to client: ', c.name)
    awful.rules.apply(c)
    c.urgent = false
  end
end
return module
