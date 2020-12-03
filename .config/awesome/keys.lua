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
local app_nav = home_bin .. "/app-nav"
-- Note I have kmonad mod-taps for hyper_pl on home row pinkies also
local hyper_pl = {alt, super}
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
  return awful.key(
    modifers,
    keysym,
    function()
      require("gears.debug").print_warning("@BUGBUG 3" .. arg)
      awful.spawn.easy_async({fkeys_path, arg}, noop)
    end,
    {description="fkeys", group="fkeys"})
end

local function key_run(modifers, key, cmd)
  return awful.key(
    modifers,
    key,
    function() awful.spawn.easy_async(cmd, noop) end,
    {description="key_run", group="keys"})
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
    awful.key(hyper_pl, "o", focus.left,
      {description = "focus previous (left) by index", group = "client" }),
    awful.key(hyper_pl, "u", focus.right,
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
    key_run({super}, "space", {home_bin .. "/fuzz-script-choose"}),
    key_run({super}, "1", {home_bin .. "/blezz"}),
    key_run({}, "F10", {home_bin .. "/blezz"}),
    key_run({super}, "2", {home_bin .. "/fuzz-script-choose"}),
    key_run({}, "F11", {home_bin .. "/fuzz-script-choose"}),
    key_run({super}, "3", {home_bin .. "/fuzz-snippet"}),
    key_run({}, "F12", {home_bin .. "/fuzz-snippet"}),
    key_run({super, shift}, "space", {"rofi", "-show", "run"}),
    key_run(hyper_pl, "w", {"rofi", "-show", "window", "-theme", "gruvbox-light-soft"}),
    key_run({super}, "4", {"rofi", "-show", "window"}),
    key_run(hyper_pl, "h", {app_nav, "left"}),
    key_run(hyper_pl, "t", {app_nav, "up"}),
    key_run(hyper_pl, "n", {app_nav, "right"}),
    -- key_run(hyper_pl, "w", {app_nav, "down"}),
    key_run(hyper_pl, "Left", {app_nav, "left"}),
    key_run(hyper_pl, "Up", {app_nav, "up"}),
    key_run(hyper_pl, "Right", {app_nav, "right"}),
    key_run(hyper_pl, "Down", {app_nav, "down"}),
    key_run({}, "XF86MonBrightnessDown", {"sudo", "brightnessctl", "set", "20%-"}),
    key_run({}, "XF86MonBrightnessUp", {"sudo", "brightnessctl", "set", "20%+"}),
    key_run({}, "XF86AudioRaiseVolume", {home_bin .. "/volume", "+10%"}),
    key_run({}, "XF86AudioLowerVolume", {home_bin .. "/volume", "-10%"}),
    key_run({}, "XF86AudioMute", {home_bin .. "/volume-toggle-mute"}),
    key_run({}, "XF86AudioMicMute", {home_bin .. "/microphone-toggle"})
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

local clientkeys = gears.table.join(
  awful.key(hyper_pl, ".", placement.cycle,
    {description = "cycle window placement", group = "client"}),
  awful.key({super, shift}, "w", function(c) c:kill() end,
    {description = "close", group = "client"}),
  awful.key(hyper_pl, "e", focus.previous,
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
