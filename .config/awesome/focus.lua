local awful = require("awful")
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
-- {{{ Key bindings
local bindg = awful.keyboard.append_global_keybinding


bindg(awful.key({modkey}, "a", wm_nav_left, wm_nav_left_config))
bindg(awful.key({modkey}, "u", wm_nav_right, wm_nav_right_config))
bindg(awful.key({modkey}, "h", wm_nav_left, wm_nav_left_config))
bindg(awful.key({modkey}, "s", wm_nav_right, wm_nav_right_config))

