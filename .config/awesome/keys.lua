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
-- Note I have kmonad mod-taps for hyper_pl on home row pinkies also
hyper_pl = {"Control", "Mod4"}

-- mouse bindings
root.buttons(
  gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)))

-- global keys
root.keys(
  gears.table.join(
    awful.key(hyper_pl, "r", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
    awful.key(hyper_pl, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),
    awful.key(hyper_pl, "p", function() menubar.show() end,
      {description = "show the menubar", group = "launcher"}),
    awful.key(hyper_pl, "h", focus.left,
      {description = "focus previous (left) by index", group = "client" }),
    awful.key(hyper_pl, "n", focus.right,
      {description = "focus previous (right) by index", group = "client" })))
-- awful.key(hyper_pl, "r",
--   function() awful.screen.focused().mypromptbox:run() end,
--   {description = "run prompt", group = "launcher"}),
-- awful.key(hyper_pl, "x", function()
--   awful.prompt.run {
--     prompt = "Run Lua code: ",
--     textbox = awful.screen.focused().mypromptbox.widget,
--     exe_callback = awful.util.eval,
--     history_path = awful.util.get_cache_dir() .. "/history_eval"
--   }
-- end, {description = "lua execute prompt", group = "awesome"}),

cyclefocus.default_preset.base_font_size = 14

local function focus_previous()
  awful.client.focus.history.previous()
  if client.focus then
    client.focus:raise()
  end
end

local clientkeys = gears.table.join(
  awful.key(hyper_pl, "c", placement.cycle,
    {description = "cycle window placement", group = "client"}),
  awful.key({super, shift}, "w", function(c) c:kill() end,
    {description = "close", group = "client"}),
  awful.key(hyper_pl, "t", focus_previous,
   {description="focus previous", group="client"}),
  cyclefocus.key(hyper_pl, "Tab",
    {cycle_filters = {cyclefocus.filters.same_screen, cyclefocus.filters.common_tag}}))

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
