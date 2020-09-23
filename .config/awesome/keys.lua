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

-- {{{ Mouse bindings
root.buttons(gears.table.join(awful.button({}, 3,
                                           function() mymainmenu:toggle() end),
                              awful.button({}, 4, awful.tag.viewnext),
                              awful.button({}, 5, awful.tag.viewprev)))
-- }}}


-- global keys
root.keys(gears.table.join(
  awful.key({super, alt}, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
  awful.key({super, alt}, "q", awesome.quit,
      {description = "quit awesome", group = "awesome"}),

-- awful.key({super}, "r",
--                 function() awful.screen.focused().mypromptbox:run() end,
--                 {description = "run prompt", group = "launcher"}),
-- awful.key({super}, "x", function()
--   awful.prompt.run {
--     prompt = "Run Lua code: ",
--     textbox = awful.screen.focused().mypromptbox.widget,
--     exe_callback = awful.util.eval,
--     history_path = awful.util.get_cache_dir() .. "/history_eval"
--   }
-- end, {description = "lua execute prompt", group = "awesome"}),
  awful.key({super}, "a", focus.left,
    {description = "focus previous (left) by index", group = "client" }),
  awful.key({super}, "u", focus.right, {
    description = "focus previous (right) by index", group = "client" }),
  awful.key({super}, "p", function() menubar.show() end,
    {description = "show the menubar", group = "launcher"})))

cyclefocus.key({super}, "Tab", {
  cycle_filters = {
    cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
  },
  keys = {"Tab", "ISO_Left_Tab", "n"}
})

local clientkeys = gears.table.join(
  awful.key({super}, "f", placement.fullscreen_toggle,
    {description = "toggle fullscreen", group = "client"}),
  awful.key({super, alt}, "w", function(c) c:kill() end,
    {description = "close", group = "client"}),
  awful.key({super}, "h", placement.left_half,
    {description = "snap window to left half of the screen", group = "placement" }),
  awful.key({super}, "n", placement.maximize_toggle,
    {description = "(un)maximize", group = "client"}),
  awful.key({super}, "s", placement.right_half,
    {description = "snap window to right half of the screen", group = "placement" }),
  awful.key({super}, "e", placement.cycle,
    {description = "cycle window placement", group = "client"}))

local clientbuttons = gears.table.join(awful.button({}, 1, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
end), awful.button({super}, 1, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
  awful.mouse.client.move(c)
end), awful.button({super}, 3, function(c)
  c:emit_signal("request::activate", "mouse_click", {raise = true})
  awful.mouse.client.resize(c)
end))

return {
  clientkeys = clientkeys,
  clientbuttons = clientbuttons
}
