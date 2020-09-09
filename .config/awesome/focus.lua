local awful = require("awful")
require("awful.autofocus")
local function wm_nav_left() awful.client.focus.byidx(-1) end
local wm_nav_left_config = {
  description = "focus previous (left) by index",
  group = "client"
}
local function wm_nav_right() awful.client.focus.byidx(1) end
local wm_nav_right_config = {
  description = "focus next (right) by index",
  group = "client"
}
local bindg = awful.keyboard.append_global_keybinding

super = "Mod4"
bindg(awful.key({super}, "a", wm_nav_left, wm_nav_left_config))
bindg(awful.key({super}, "u", wm_nav_right, wm_nav_right_config))
-- bindg(awful.key({super}, "h", wm_nav_left, wm_nav_left_config))
-- bindg(awful.key({super}, "s", wm_nav_right, wm_nav_right_config))

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)
