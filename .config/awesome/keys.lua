local awful = require("awful")
local gears = require("gears")
-- local menubar = require("menubar")
-- local naughty = require("naughty")

local cyclefocus = require("cyclefocus")

local placement = require("placement")
local focus = require("focus")
-- local wibar = require("wibar")
local leader = require("leader")
local tags = require("tags")
local dev = require("dev")

local alt = "Mod1"
local control = "Control"
local super = "Mod4"
local shift = "Shift"
local home_bin = os.getenv("HOME") .. "/bin"
local app_nav = home_bin .. "/app-nav"
-- Note I have kmonad mod-taps for hyper_pl on home row pinkies also
local hyper_pl = {alt, super}
local function noop() end
-- local function runner(cmd_map)
--   return function()
--     awful.spawn.easy_async(cmd_map, noop)
--   end
-- end

local function runner(args)
  return function() awful.spawn.easy_async(args, noop) end
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
    awful.key({super, shift}, "r", awesome.restart,
      {description="reload awesome", group="awesome"}),
    awful.key(hyper_pl, "q", awesome.quit,
      {description="quit awesome", group="awesome"}),
    -- awful.key(hyper_pl, "m", function() menubar.show() end,
    --   {description="show the menubar", group="launcher"}),
    awful.key({super}, "q", awful.tag.viewprev,
      {description="view previous (left) tag", group="tags" }),
    awful.key({super}, "k", awful.tag.viewnext,
      {description="view next (right) tag", group="tags" }),
    awful.key({super}, ",", focus.left,
      {description="focus previous (left) by index", group="windows" }),
    awful.key(hyper_pl, "p", focus.right,
      {description="focus next (right) by index", group="windows" }),
    awful.key({super}, "p", focus.right,
      {description="focus next (right) by index", group="windows" }),
    awful.key(hyper_pl, "9", dev.dev1, {description="dev1", group="dev" }),
    awful.key(hyper_pl, "1", function() placement.move_to_tag("1") end, {description="move to tag 1", group="tags" }),
    awful.key(hyper_pl, "2", function() placement.move_to_tag("2") end, {description="move to tag 2", group="tags" }),
    awful.key(hyper_pl, "F1", function() tags.select("1") end, {description="select tag 1", group="tags" }),
    awful.key(hyper_pl, "F2", function() tags.select("2") end, {description="select tag 2", group="tags" }),
    awful.key(hyper_pl, "F3", function() tags.select("3") end, {description="select tag 3", group="tags" }),
    awful.key(hyper_pl, "F4", function() tags.select("4") end, {description="select tag 4", group="tags" }),
    awful.key(hyper_pl, "k", runner({home_bin .. "/copy-link"}),
      {description="copy-link", group="dev" }),
    awful.key({super}, "space", runner({home_bin .. "/fuzz-script-choose"}),
      {description="fuzz script", group="rofi"}),
    awful.key({super}, "1", focus.leader,
      {description="leader", group="rofi" }),
    awful.key({}, "F10", leader.tag_in,
      {description="leader", group="rofi" }),
    awful.key({super}, "2", focus.fuzz_script,
      {description="fuzz script", group="rofi" }),
    awful.key({}, "F11", focus.fuzz_script,
      {description = "fuzz script", group = "rofi" }),
    awful.key({super}, "3", focus.fuzz_snippet,
      {description = "fuzz snippet", group = "rofi" }),
    awful.key({super}, "s", focus.fuzz_snippet,
      {description = "fuzz snippet", group = "rofi" }),
    awful.key({}, "F12", focus.fuzz_snippet,
      {description = "fuzz snippet", group = "rofi" }),
    awful.key({super, shift}, "space", runner({"rofi", "-show", "run"}),
      {description = "run", group="rofi"}),
    awful.key(hyper_pl, "w", runner({"rofi", "-show", "window", "-theme", "gruvbox-light-soft"}),
      {description="windows", group="rofi"}),
    awful.key({super}, "4", runner({"rofi", "-show", "window"}),
      {description="windows", group="rofi"}),
    awful.key(hyper_pl, "o", runner({app_nav, "left"}),
      {description="left", group="app nav"}),
    awful.key({super}, "o", runner({app_nav, "left"}),
      {description="left", group="app nav"}),
    -- awful.key(hyper_pl, "t", runner({app_nav, "up"}),
    --   {}),
    awful.key(hyper_pl, "u", runner({app_nav, "right"}),
      {description="right", group="app nav"}),
    awful.key({super}, "u", runner({app_nav, "right"}),
      {description="right", group="app nav"}),
    awful.key(hyper_pl, "j", runner({app_nav, "down"}),
      {description="down", group="app nav"}),
    awful.key({super}, "j", runner({app_nav, "down"}),
      {description="down", group="app nav"}),
    awful.key(hyper_pl, "Left", runner({app_nav, "left"}),
      {description="left", group="app nav"}),
    awful.key(hyper_pl, "Up", runner({app_nav, "up"}),
      {description="up", group="app nav"}),
    awful.key(hyper_pl, "Right", runner({app_nav, "right"}),
      {description="right", group="app nav"}),
    awful.key(hyper_pl, "Down", runner({app_nav, "down"}),
      {description="down", group="app nav"}),
    awful.key({}, "XF86MonBrightnessDown", runner({"sudo", "brightnessctl", "set", "20%-"}),
      {description="brightness down", group="screen"}),
    awful.key({}, "XF86MonBrightnessUp", runner({"sudo", "brightnessctl", "set", "20%+"}),
      {description="brightness up", group="screen"}),
    awful.key({}, "XF86AudioRaiseVolume", runner({home_bin .. "/volume", "+10%"}),
      {description="volume up", group="sound"}),
    awful.key({}, "XF86AudioLowerVolume", runner({home_bin .. "/volume", "-10%"}),
      {description="volume down", group="sound"}),
    awful.key({}, "XF86AudioMute", runner({home_bin .. "/volume-toggle-mute"}),
      {description="toggle volume mute", group="sound"}),
    awful.key({}, "XF86AudioMicMute", runner({home_bin .. "/microphone-toggle"}),
      {description="toggle mic mute", group="sound"})
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
  awful.key({super}, ".", placement.cycle,
    {description = "cycle window placement", group = "windows"}),
  awful.key(hyper_pl, "x", function(c) c:kill() end,
    {description = "close", group = "windows"}),
  awful.key({super}, "x", function(c) c:kill() end,
    {description = "close", group = "windows"}),
  awful.key({super, shift}, "w", function(c) c:kill() end,
    {description = "close", group = "windows"}),
  awful.key(hyper_pl, "e", focus.previous,
   {description="focus previous", group="windows"}),
  awful.key({super}, "e", focus.previous,
   {description="focus previous", group="windows"}),
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
