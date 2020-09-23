local awful = require("awful")
local gears = require("gears")
local menubar = require("menubar")
local naughty = require("naughty")

local cyclefocus = require("cyclefocus")

local placement = require("placement")
local focus = require("focus")

alt = "Mod1"
control = "Control"
super = "Mod4"
shift = "Shift"
hyper_pl = {"Control", "Mod4"}

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3,
                                           function() mymainmenu:toggle() end),
                              awful.button({}, 4, awful.tag.viewnext),
                              awful.button({}, 5, awful.tag.viewprev)))
-- }}}
local bindg = awful.keyboard.append_global_keybinding
local bindc = awful.keyboard.append_client_keybinding

-- bindg(awful.key({super}, "Left", awful.tag.viewprev,
--                 {description = "view previous", group = "tag"}))
-- bindg(awful.key({super}, "Right", awful.tag.viewnext,
--                 {description = "view next", group = "tag"}))
-- bindg(awful.key({super}, "Escape", awful.tag.history.restore,
--                 {description = "go back", group = "tag"}))

bindg(awful.key(hyper_pl, "r", awesome.restart,
                {description = "reload awesome", group = "awesome"}))
bindg(awful.key(hyper_pl, "q", awesome.quit,
                {description = "quit awesome", group = "awesome"}))

-- bindg(awful.key({super}, "r",
--                 function() awful.screen.focused().mypromptbox:run() end,
--                 {description = "run prompt", group = "launcher"}))
-- bindg(awful.key({super}, "x", function()
--   awful.prompt.run {
--     prompt = "Run Lua code: ",
--     textbox = awful.screen.focused().mypromptbox.widget,
--     exe_callback = awful.util.eval,
--     history_path = awful.util.get_cache_dir() .. "/history_eval"
--   }
-- end, {description = "lua execute prompt", group = "awesome"}))
bindg(awful.key(hyper_pl, "h", focus.left, {
  description = "focus previous (left) by index",
  group = "client"
}))
bindc(awful.key(hyper_pl, "t", placement.cycle,
                {description = "cycle window placement", group = "client"}))
bindg(awful.key(hyper_pl, "n", focus.right, {
  description = "focus previous (right) by index",
  group = "client"
}))

-- Menubar
bindg(awful.key({super}, "p", function() menubar.show() end,
                {description = "show the menubar", group = "launcher"}))

bindc(awful.key({super}, "f", placement.fullscreen_toggle,
                {description = "toggle fullscreen", group = "client"}))
bindc(awful.key({super, shift}, "w", function(c) c:kill() end,
                {description = "close", group = "client"}))
-- bindc(awful.key({super}, "h", placement.left_half, {
--   description = "snap window to left half of the screen",
--   group = "placement"
-- }))
-- bindc(awful.key({super}, "s", placement.right_half, {
--   description = "snap window to right half of the screen",
--   group = "placement"
-- }))
bindc(cyclefocus.key({super}, "Tab", {
  cycle_filters = {
    cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
  },
  keys = {"Tab", "ISO_Left_Tab", "n"}
}))
cyclefocus.default_preset.base_font_size = 14
-- bindg(cyclefocus.key({}, "f5", {
--   cycle_filters = {
--     cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
--   },
--   keys = {"Tab", "ISO_Left_Tab", "f5"}
-- }))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
-- for i = 1, 9 do
--   bindg(awful.key({super}, "#" .. i + 9, function()
--     local screen = awful.screen.focused()
--     local tag = screen.tags[i]
--     if tag then tag:view_only() end
--   end, {description = "view tag #" .. i, group = "tag"}))
--   -- Toggle tag display.
--   bindg(awful.key({super, alt}, "#" .. i + 9, function()
--     local screen = awful.screen.focused()
--     local tag = screen.tags[i]
--     if tag then awful.tag.viewtoggle(tag) end
--   end, {description = "toggle tag #" .. i, group = "tag"}))
--   -- Move client to tag.
--   bindg(awful.key({super, "Shift"}, "#" .. i + 9, function()
--     if client.focus then
--       local tag = client.focus.screen.tags[i]
--       if tag then client.focus:move_to_tag(tag) end
--     end
--   end, {description = "move focused client to tag #" .. i, group = "tag"}))
--   -- Toggle tag on focused client.
--   bindg(awful.key({super, alt, "Shift"}, "#" .. i + 9, function()
--     if client.focus then
--       local tag = client.focus.screen.tags[i]
--       if tag then client.focus:toggle_tag(tag) end
--     end
--   end, {description = "toggle focused client on tag #" .. i, group = "tag"}))
-- end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
end), awful.button({super}, 1, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
  awful.mouse.client.move(c)
end), awful.button({super}, 3, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
  awful.mouse.client.resize(c)
end))
