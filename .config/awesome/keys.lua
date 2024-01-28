local awful = require('awful')
local gears = require('gears')

local cyclefocus = require('cyclefocus')

local placement = require('placement')
local focus = require('focus')
local leader_rofi = require('leader-rofi')
local leader_nofi = require('leader-nofi')
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

local function noop() end

local function runner(args)
  return function() awful.spawn.easy_async(args, noop) end
end

-- This table will collect all keybindings for awesomewm global scope
-- (not associated with any particular client window)
local root_keys = {}
local function bind_root(group, description, mods, keysym, action)
  root_keys = gears.table.join(root_keys, awful.key(mods, keysym, action, {
    description = description,
    group = group
  }))
end
-- Set up a little function call DSL for concise keybinds.
-- These are more friendly to autoformatting then gigantic
-- inline table literals full of complex function definitions

bind_root('window manager', 'restart window manager', shift_super, 'r',
          awesome.restart)
bind_root('window manager', 'quit window manager', shift_super, 'q',
          awesome.quit)

-- window manager virtual desktops (tags)
bind_root('tags', 'view previous (left) tag', shift_super, 'Left',
          awful.tag.viewprev)
bind_root('tags', 'view next (right) tag', shift_super, 'Right',
          awful.tag.viewnext)
bind_root('tags', 'view next (right) tag', {modifiers.super}, 'q',
          awful.tag.viewprev)
bind_root('tags', 'view next (right) tag', {modifiers.super}, 'k',
          awful.tag.viewnext)

bind_root('screen', 'brightness down', {}, 'XF86MonBrightnessDown',
          runner({'sudo', 'brightnessctl', 'set', '20%-'}))
bind_root('screen', 'brightness up', {}, 'XF86MonBrightnessUp',
          runner({'sudo', 'brightnessctl', 'set', '20%+'}))

bind_root('sound', 'volume up', {}, 'XF86AudioRaiseVolume',
          runner({home_bin .. '/volume', '+10%'}))
bind_root('sound', 'volume down', {}, 'XF86AudioLowerVolume',
          runner({home_bin .. '/volume', '-10%'}))
bind_root('sound', 'toggle volume mute', {}, 'XF86AudioMute',
          runner({home_bin .. '/volume-toggle-mute'}))
bind_root('sound', 'toggle mic mute', {}, 'XF86AudioMicMute',
          runner({home_bin .. '/microphone-toggle'}))

bind_root('nofi', 'run gofi', {modifiers.super}, '7', leader_gofi.tag_in)
bind_root('rofi', 'run rofi', {modifiers.super}, '8', leader_nofi.tag_in)
bind_root('nofi', 'run nofi', {modifiers.super}, '9', leader_rofi.tag_in)
bind_root('rofi', 'leader', {modifiers.super}, '1', leader_gofi.tag_in)
bind_root('rofi', 'leader', {}, 'F10', leader_gofi.tag_in)
-- bind_root('rofi', 'leader', {}, 'F10', leader_nofi.tag_in)
-- bind_root('rofi', 'leader', {}, 'F10', focus.rofi)
bind_root('rofi', 'fuzz script', {modifiers.super}, '2', focus.fuzz_script)
bind_root('rofi', 'fuzz script', {modifiers.super}, 'space',
          runner({home_bin .. '/fuzz-script-choose'}))
bind_root('rofi', 'fuzz script', {}, 'F11', focus.fuzz_script)
bind_root('rofi', 'fuzz snippet', {modifiers.super}, '3', focus.fuzz_snippet)
bind_root('rofi', 'fuzz snippet', {modifiers.super}, 's', focus.fuzz_snippet)
bind_root('rofi', 'fuzz snippet', {}, 'F12', focus.fuzz_snippet)
bind_root('rofi', 'run', shift_super, 'space', runner({'rofi', '-show', 'run'}))
bind_root('rofi', 'windows', shift_super, 'w',
          runner({'rofi', '-show', 'window', '-theme', 'gruvbox-light-soft'}))
bind_root('rofi', 'windows', {modifiers.super}, '4',
          runner({'rofi', '-show', 'window'}))

bind_root('dev', 'dev 1', shift_super, '1', dev.dev1)
bind_root('dev', 'dev 2', shift_super, '2', dev.dev2)

-- bind function keys to selecting the corresponding tag
for _, n in pairs({'1', '2', '3', '4'}) do
  bind_root('tags', 'select tag ' .. n, shift_super, 'F' .. n,
            function() tags.select(n) end)
  bind_root('tags', 'move to tag ' .. n, shift_super, n,
            function() placement.move_to_tag(n) end)
end

-- register the key bindings with awesomewm
root.keys(root_keys)

local client_keys = {}

local function bind_client(g, d, mods, keysym, action)
  local key = awful.key(mods, keysym, action, {description = d, group = g})
  client_keys = gears.table.join(client_keys, key)
end

-- app nav arrow keys (also rownav keyd layer)
bind_client('app nav', 'left', {modifiers.super}, 'Left',
            runner({app_nav, 'left'}))
bind_client('app nav', 'down', {modifiers.super}, 'Down',
            runner({app_nav, 'down'}))
bind_client('app nav', 'up', {modifiers.super}, 'Up', runner({app_nav, 'down'}))
bind_client('app nav', 'right', {modifiers.super}, 'Right',
            runner({app_nav, 'right'}))
-- app nav left pinky mod-tap
bind_client('app nav', 'left', {modifiers.super}, 'o', runner({app_nav, 'left'}))
bind_client('app nav', 'down', {modifiers.super}, 'j', runner({app_nav, 'down'}))
bind_client('app nav', 'right', {modifiers.super}, 'u',
            runner({app_nav, 'right'}))

bind_client('windows', 'cycle window placement', {modifiers.super}, '.',
            placement.cycle)
bind_client('windows', 'close', {modifiers.super}, 'x', function(c) c:kill() end)
bind_client('windows', 'focus previous', {modifiers.super}, 'p', focus.previous)
-- bind_client('windows', 'focus previous', {modifiers.super}, 'e', focus.previous)
bind_client('windows', 'focus previous (up) window', shift_super, 'Up',
            focus.previous)
bind_client('windows', 'focus next (down) window', shift_super, 'Down',
            focus.next_window)

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
