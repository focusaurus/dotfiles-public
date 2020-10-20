local awful = require("awful")
local beautiful = require("beautiful")

local keys = require("keys")
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
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
  }, -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry"
      },
      class = {
        "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
        "Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui", "veromix", "xtightvncviewer", "Yad", "zenity"
      },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester" -- xev.
      },
      role = {
        "AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
      }
    },
    properties = {floating = true, maximized = false}
  }, -- Add titlebars to normal clients and dialogs
  {
    rule_any = {type = {"normal", "dialog"}},
    properties = {titlebars_enabled = true}
  }, {
    properties = {
      ontop = true,
      floating = true,
      sticky = true,
      placement = awful.placement.centered
    },
    rule_any = {class = {"Yad", "zenity"}, name = {"Chat"}}
  }

  -- Set Firefox to always map on the tag named "2" on screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" } },
}
