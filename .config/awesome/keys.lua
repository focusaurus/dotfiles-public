local awful = require("awful")
local gears = require("gears")
local menubar = require("menubar")
local naughty = require("naughty")

local cyclefocus = require("cyclefocus")

local placement = require("placement")
local focus = require("focus")
local wibar = require("wibar")

local alt = "Mod1"
local control = "Control"
local super = "Mod4"
local shift = "Shift"
local home_bin = os.getenv("HOME") .. "/bin"
-- Note I have kmonad mod-taps for hyper_pl on home row pinkies also
local hyper_pl = {"Control", "Mod4"}
local function noop() end
local function runner(cmd_map)
  return function()
    awful.spawn.easy_async(cmd_map, noop)
  end
end
local fkeys_path = home_bin .. "/fkeys"
local function fkeys(modifers, keysym, arg)
  if arg == nil then
    arg = string.lower(keysym)
  end
  -- the above goes to ~/.xsession-errors
  return awful.key(
    modifers,
    keysym,
    function()
      require("gears.debug").print_warning("@BUGBUG 3" .. arg)
      awful.spawn.easy_async({fkeys_path, arg}, noop)
    end,
    {description="fkeys", group="fkeys"})
end

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
      {description = "focus previous (right) by index", group = "client" }),
    awful.key(hyper_pl, "F1", wibar.set_volume,
      {description = "dev", group = "dev" }),
    fkeys({}, "F1"),
    fkeys({control}, "F1", "control+f1"),
    fkeys({}, "F2"),
    fkeys({}, "F3"),
    fkeys({}, "F4"),
    fkeys({},"F5"),
    fkeys({}, "F6"),
    fkeys({shift}, "F6", "shift+f6"),
    fkeys({control}, "F6", "control+f6"),
    fkeys({}, "F7"),
    fkeys({}, "F8"),
    fkeys({}, "F9"),
    fkeys({shift}, "F9", "shift+f9"),
    awful.key({super}, "space", runner({home_bin .. "/fuzz-script-choose"})),
    awful.key({super}, "2", runner({home_bin .. "/fuzz-snippet"})),
    awful.key({super, shift}, "space", runner({"rofi", "-show", "run"})),
    awful.key({super}, "4", runner({"rofi", "-show", "window"})),
    awful.key({super, control}, "o", runner({home_bin .. "/app-nav", "left"})),
    awful.key({super, control}, "e", runner({home_bin .. "/app-nav", "up"})),
    awful.key({super, control}, "u", runner({home_bin .. "/app-nav", "right"})),
    awful.key({super, control}, "Left", runner({home_bin .. "/app-nav", "left"})),
    awful.key({super, control}, "Down", runner({home_bin .. "/app-nav", "down"})),
    awful.key({super, control}, "Up", runner({home_bin .. "/app-nav", "up"})),
    awful.key({super, control}, "Right", runner({home_bin .. "/app-nav", "right"})),
    awful.key({}, "XF86MonBrightnessDown", runner({"sudo", "brightnessctl", "set", "20%-"})),
    awful.key({}, "XF86MonBrightnessUp", runner({"sudo", "brightnessctl", "set", "20%+"}))
  )
)
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
  cyclefocus.key({super}, "Tab",
    {cycle_filters = {cyclefocus.filters.same_screen, cyclefocus.filters.common_tag}}),
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
