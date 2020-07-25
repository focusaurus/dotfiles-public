-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
require("errors")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- Notification library
local naughty = require("naughty")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local menubar = require("menubar")
local placement = require("placement")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.get().font = "Inconsolata 16"

-- This is used later as the default terminal and editor to run.
terminal = "termite"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.floating, awful.layout.suit.tile,
  -- awful.layout.suit.tile.left,
  -- awful.layout.suit.tile.bottom,
  -- awful.layout.suit.tile.top,
  awful.layout.suit.fair, -- awful.layout.suit.fair.horizontal,
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max, -- awful.layout.suit.max.fullscreen,
  -- awful.layout.suit.magnifier,
  awful.layout.suit.corner.nw
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3,
                                           function() mymainmenu:toggle() end),
                              awful.button({}, 4, awful.tag.viewnext),
                              awful.button({}, 5, awful.tag.viewprev)))
-- }}}
require("focus")
require("wibar")
-- {{{ Key bindings
local bindg = awful.keyboard.append_global_keybinding
local bindc = awful.keyboard.append_client_keybinding

-- local function bindg(key) awful.keyboard.append_global_keybinding(key) end
-- local function bindc(key) awful.keyboard.append_client_keybinding(key) end

bindg(awful.key({modkey}, "Left", awful.tag.viewprev,
                {description = "view previous", group = "tag"}))
bindg(awful.key({modkey}, "Right", awful.tag.viewnext,
                {description = "view next", group = "tag"}))
bindg(awful.key({modkey}, "Escape", awful.tag.history.restore,
                {description = "go back", group = "tag"}))

bindg(awful.key({modkey, "Control"}, "r", awesome.restart,
                {description = "reload awesome", group = "awesome"}))
bindg(awful.key({modkey, "Control"}, "q", awesome.quit,
                {description = "quit awesome", group = "awesome"}))
-- Prompt

bindg(awful.key({modkey}, "r",
                function() awful.screen.focused().mypromptbox:run() end,
                {description = "run prompt", group = "launcher"}))

bindg(awful.key({modkey}, "x", function()
  awful.prompt.run {
    prompt = "Run Lua code: ",
    textbox = awful.screen.focused().mypromptbox.widget,
    exe_callback = awful.util.eval,
    history_path = awful.util.get_cache_dir() .. "/history_eval"
  }
end, {description = "lua execute prompt", group = "awesome"}))
-- Menubar
bindg(awful.key({modkey}, "p", function() menubar.show() end,
                {description = "show the menubar", group = "launcher"}))

local cyclefocus = require("cyclefocus")
bindc(awful.key({modkey}, "f", function(c)
  c.fullscreen = not c.fullscreen
  c:raise()
end, {description = "toggle fullscreen", group = "client"}))
bindc(awful.key({modkey, "Shift"}, "w", function(c) c:kill() end,
                {description = "close", group = "client"}))
bindc(awful.key({modkey, "Control"}, "s", placement.right_half, {
  description = "snap window to right half of the screen",
  group = "placement"
}))
bindc(awful.key({modkey, "Control"}, "h", placement.left_half, {
  description = "snap window to left half of the screen",
  group = "placement"
}))
bindc(awful.key({modkey, "Control"}, "n", placement.maximize_toggle,
                {description = "(un)maximize", group = "client"}),
      cyclefocus.key({modkey}, "Tab", {
  cycle_filters = {
    cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
  },
  keys = {"Tab", "ISO_Left_Tab", "n"}
}))
bindc(cyclefocus.key({modkey}, "n", {
  -- TODO would like to also bindg this to Super+n but this doesn't work
  cycle_filters = {
    cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
  },
  keys = {"Tab", "ISO_Left_Tab", "n"}
}))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  bindg(awful.key({modkey}, "#" .. i + 9, function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then tag:view_only() end
  end, {description = "view tag #" .. i, group = "tag"}))
  -- Toggle tag display.
  bindg(awful.key({modkey, "Control"}, "#" .. i + 9, function()
    local screen = awful.screen.focused()
    local tag = screen.tags[i]
    if tag then awful.tag.viewtoggle(tag) end
  end, {description = "toggle tag #" .. i, group = "tag"}))
  -- Move client to tag.
  bindg(awful.key({modkey, "Shift"}, "#" .. i + 9, function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then client.focus:move_to_tag(tag) end
    end
  end, {description = "move focused client to tag #" .. i, group = "tag"}))
  -- Toggle tag on focused client.
  bindg(awful.key({modkey, "Control", "Shift"}, "#" .. i + 9, function()
    if client.focus then
      local tag = client.focus.screen.tags[i]
      if tag then client.focus:toggle_tag(tag) end
    end
  end, {description = "toggle focused client on tag #" .. i, group = "tag"}))
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
end), awful.button({modkey}, 1, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
  awful.mouse.client.move(c)
end), awful.button({modkey}, 3, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
  awful.mouse.client.resize(c)
end))

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      buttons = clientbuttons,
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
        "Wpa_gui", "veromix", "xtightvncviewer", "zenity"
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
    properties = {floating = true}
  }, -- Add titlebars to normal clients and dialogs
  {
    rule_any = {type = {"normal", "dialog"}},
    properties = {titlebars_enabled = true}
  }, {properties = {ontop = true}, rule_any = {class = {"zenity"}}}

  -- Set Firefox to always map on the tag named "2" on screen 1.
  -- { rule = { class = "Firefox" },
  --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- Set the windows at the slave,
  -- i.e. put it at the end of others instead of setting it master.
  -- if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup and not c.size_hints.user_position and
      not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(awful.button({}, 1, function()
    c:emit_signal("request::activate", "titlebar", {raise = true})
    awful.mouse.client.move(c)
  end), awful.button({}, 3, function()
    c:emit_signal("request::activate", "titlebar", {raise = true})
    awful.mouse.client.resize(c)
  end))

  awful.titlebar(c, {size = 30}):setup{
    { -- Left
      awful.titlebar.widget.iconwidget(c),
      buttons = buttons,
      layout = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
        align = "center",
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout = wibox.layout.flex.horizontal
    },
    { -- Right
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.horizontal()
    },
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus",
                      function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus",
                      function(c) c.border_color = beautiful.border_normal end)
-- }}}
