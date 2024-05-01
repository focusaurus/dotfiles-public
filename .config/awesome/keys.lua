local awful = require('awful')
local gears = require('gears')

local cyclefocus = require('cyclefocus')

local placement = require('placement')
local focus = require('focus')
local leader_rofi = require('leader-rofi')
local leader_gofi = require('leader-gofi')
local tags = require('tags')
local modifiers = require('modifiers')
local dev = require('dev')

local home_bin = os.getenv('HOME') .. '/bin'
local app_nav = home_bin .. '/app-nav'
-- local hyper_pl = {alt, modifiers.super}
-- Would prefer alt+super for this but not easy in vial
-- and don't want to get back to custom QMK fork code
local shift_super = {modifiers.shift, modifiers.super}
local control_super = {modifiers.control, modifiers.super}

local function noop() end

local function runner(args)
  return function() awful.spawn.easy_async(args, noop) end
end

-- This table will collect all keybindings for awesomewm global scope
-- (not associated with any particular client window)
local root_keys = {}

-- Set up a little function call DSL for concise keybinds.
-- These are more friendly to autoformatting then gigantic
-- inline table literals full of complex function definitions
local function bind_root(group, description, mods, keysym, action)
  root_keys = gears.table.join(root_keys, awful.key(mods, keysym, action, {
    description = description,
    group = group
  }))
end

bind_root('window manager', 'restart window manager',
  control_super, 'r', awesome.restart)
bind_root('window manager', 'quit window manager',
  control_super, 'q', awesome.quit)

-- window manager virtual desktops (tags)
bind_root('tags', 'view previous (left) tag',
  control_super, 'Left', awful.tag.viewprev)
bind_root('tags', 'view next (right) tag',
  control_super, 'Right', awful.tag.viewnext)
bind_root('tags', 'view next (right) tag',
  {modifiers.super}, 'q', awful.tag.viewprev)
bind_root('tags', 'view next (right) tag',
  {modifiers.super}, 'k', awful.tag.viewnext)

-- row nav bottom row window manager
bind_root('windows', 'focus previous',
  control_super, 'Up', focus.previous)

bind_root('screen', 'brightness down',
  {}, 'XF86MonBrightnessDown', runner({'sudo', 'brightnessctl', 'set', '20%-'}))
bind_root('screen', 'brightness up',
  {}, 'XF86MonBrightnessUp', runner({'sudo', 'brightnessctl', 'set', '20%+'}))

bind_root('sound', 'volume up',
  {}, 'XF86AudioRaiseVolume', runner({home_bin .. '/volume', '+10%'}))
bind_root('sound', 'volume down',
  {}, 'XF86AudioLowerVolume', runner({home_bin .. '/volume', '-10%'}))
bind_root('sound', 'toggle volume mute',
  {}, 'XF86AudioMute', runner({home_bin .. '/volume-toggle-mute'}))
bind_root('sound', 'toggle mic mute',
  {}, 'XF86AudioMicMute', runner({home_bin .. '/microphone-toggle'}))

bind_root('leader', 'gofi', {modifiers.super}, '7', leader_gofi.tag_in)
bind_root('leader', 'rofi', {modifiers.super}, '9', leader_rofi.tag_in)
bind_root('leader', 'gofi', {modifiers.super}, '1', leader_gofi.tag_in)
bind_root('leader', 'gofi', {}, 'F10', leader_gofi.tag_in)
bind_root('fuzzball', 'fuzz script', {modifiers.super}, '2', focus.fuzz_script)
bind_root('fuzzball', 'fuzz script', {modifiers.super}, 'space',
 runner({home_bin .. '/fuzz-script-choose'}))
bind_root('fuzzball', 'fuzz script', {}, 'F11', focus.fuzz_script)
bind_root('fuzzball', 'fuzz snippet', {modifiers.super}, '3', focus.fuzz_snippet)
bind_root('fuzzball', 'fuzz snippet', {modifiers.super}, 's', focus.fuzz_snippet)
bind_root('fuzzball', 'fuzz snippet', {}, 'F12', focus.fuzz_snippet)
bind_root('rofi', 'run', control_super, 'space', runner({'rofi', '-show', 'run'}))
bind_root('rofi', 'windows', control_super, 'w',
  runner({'rofi', '-show', 'window', '-theme', 'gruvbox-light-soft'}))
bind_root('rofi', 'windows', {modifiers.super}, '4',
  runner({'rofi', '-show', 'window'}))

bind_root('dev', 'dev 1', control_super, '1', dev.dev1)
bind_root('dev', 'dev 2', control_super, '2', dev.dev2)

-- bind function keys to selecting the corresponding tag
for _, n in pairs({'1', '2', '3', '4'}) do
  bind_root('tags', 'select tag ' .. n, control_super, 'F' .. n,
            function() tags.select(n) end)
  bind_root('tags', 'move to tag ' .. n, control_super, n,
            function() placement.move_to_tag(n) end)
end

-- register the key bindings with awesomewm
root.keys(root_keys)

local client_keys = {}

local function bind_client(g, d, mods, keysym, action)
  local key = awful.key(mods, keysym, action, {description = d, group = g})
  client_keys = gears.table.join(client_keys, key)
end

bind_client('windows', 'close',
  {modifiers.super}, 'x', function(c) c:kill() end)
bind_client('windows', 'focus previous',
  {modifiers.super}, 'p', focus.previous)
bind_client('windows', 'cycle window placement',
    control_super, 'Down', placement.cycle)
-- app nav arrow keys (also rownav keyd layer)
bind_client('app nav', 'left',
  shift_super, 'Left', runner({app_nav, 'left'}))
bind_client('app nav', 'down',
  shift_super, 'Down', runner({app_nav, 'down'}))
bind_client('app nav', 'up',
  shift_super, 'Up', runner({app_nav, 'up'}))
bind_client('app nav', 'right',
  shift_super, 'Right', runner({app_nav, 'right'}))
-- app nav left pinky mod-tap
bind_client('app nav', 'left',
  shift_super, 'o', runner({app_nav, 'left'}))
bind_client('app nav', 'down',
  shift_super, 'j', runner({app_nav, 'down'}))
bind_client('app nav', 'right',
  shift_super, 'u', runner({app_nav, 'right'}))


bind_client('browser', 'copy-link', {modifiers.super}, 'i',
            runner({home_bin .. '/copy-link'}))

-- add binding for cyclefocus manually since it does not follow
-- the above pattern
cyclefocus.default_preset.base_font_size = 14
client_keys = gears.table.join(client_keys,
                               cyclefocus.key({modifiers.super}, 'e', {
  cycle_filters = {
    cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
  }
}, {group = 'windows', description = 'cycle focus'}))
client_keys = gears.table.join(client_keys,
                               cyclefocus.key({modifiers.super}, 'Tab', {
  cycle_filters = {
    cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
  }
}, {group = 'windows', description = 'cycle focus'}))

local clientbuttons = gears.table.join(awful.button({}, 1, function(c)
  c:emit_signal('request::activate', 'mouse_click', {raise = true})
end), awful.button({modifiers.super}, 1, function(c)
  c:emit_signal('request::activate', 'mouse_click', {raise = true})
  awful.mouse.client.move(c)
end), awful.button({modifiers.super}, 3, function(c)
  c:emit_signal('request::activate', 'mouse_click', {raise = true})
  awful.mouse.client.resize(c)
end))

return {clientkeys = client_keys, clientbuttons = clientbuttons}
