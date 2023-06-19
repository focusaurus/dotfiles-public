local awful = require('awful')
local gears = require('gears')

local cyclefocus = require('cyclefocus')

local placement = require('placement')
local focus = require('focus')
local leader = require('leader')
local tags = require('tags')
local dev = require('dev')

-- local alt = 'Mod1'
-- local control = 'Control'
local super = 'Mod4'
local shift = 'Shift'
local home_bin = os.getenv('HOME') .. '/bin'
local app_nav = home_bin .. '/app-nav'
-- local hyper_pl = {alt, super}
-- Would prefer alt+super for this but not easy in vial
-- and don't want to get back to custom QMK fork code
local shift_super = {shift, super}

local function noop() end

local function runner(args)
  return function() awful.spawn.easy_async(args, noop) end
end

-- This table will collect all keybindings for awesomewm global scope
-- (not associated with any particular client window)
local root_keys = {}
local function bind_root(group, description, modifiers, keysym, action)
  root_keys = gears.table.join(root_keys, awful.key(modifiers, keysym, action, {
    description = description,
    group = group
  }))
end
-- Set up a little function call DSL for concise keybinds.
-- These are more friendly to autoformatting then gigantic
-- inline table literals full of complex function definitions

bind_root('window manager', 'restart window manager', {super, shift}, 'r',
          awesome.restart)
bind_root('window manager', 'quit window manager', shift_super, 'q', awesome.quit)

-- window manager virtual desktops (tags)
bind_root('tags', 'view previous (left) tag', shift_super, 'Left',
          awful.tag.viewprev)
bind_root('tags', 'view next (right) tag', shift_super, 'Right', awful.tag.viewnext)
bind_root('tags', 'view next (right) tag', {super}, 'q', awful.tag.viewprev)
bind_root('tags', 'view next (right) tag', {super}, 'k', awful.tag.viewnext)

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

bind_root('rofi', 'leader', {super}, '1', leader.tag_in)
bind_root('rofi', 'leader', {}, 'F10', leader.tag_in)
bind_root('rofi', 'fuzz script', {super}, '2', focus.fuzz_script)
bind_root('rofi', 'fuzz script', {super}, 'space',
          runner({home_bin .. '/fuzz-script-choose'}))
bind_root('rofi', 'fuzz script', {}, 'F11', focus.fuzz_script)
bind_root('rofi', 'fuzz snippet', {super}, '3', focus.fuzz_snippet)
bind_root('rofi', 'fuzz snippet', {super}, 's', focus.fuzz_snippet)
bind_root('rofi', 'fuzz snippet', {}, 'F12', focus.fuzz_snippet)
bind_root('rofi', 'run', {super, shift}, 'space',
          runner({'rofi', '-show', 'run'}))
bind_root('rofi', 'windows', shift_super, 'w',
          runner({'rofi', '-show', 'window', '-theme', 'gruvbox-light-soft'}))
bind_root('rofi', 'windows', {super}, '4', runner({'rofi', '-show', 'window'}))

bind_root('dev', 'dev 1', shift_super, '9', dev.dev1)

-- bind function keys to selecting the corresponding tag
for _, n in pairs({'1', '2', '3', '4'}) do
  bind_root('tags', 'select tag ' .. n, shift_super, 'F' .. n,
            function() tags.select(n) end)
  bind_root('tags', 'move to tag ' .. n, shift_super, n,
            function() placement.move_to_tag(n) end)
end

-- register the key bindings with awesomewm
root.keys(root_keys)

-- awful.key(shift_super, "r",
--   function() awful.screen.focused().mypromptbox:run() end,
--   {description = "run prompt", group = "launcher"}),
-- awful.key(shift_super, "x", function()
--   awful.prompt.run {
--     prompt = "Run Lua code: ",
--     textbox = awful.screen.focused().mypromptbox.widget,
--     exe_callback = awful.util.eval,
--     history_path = awful.util.get_cache_dir() .. "/history_eval"
--   }
-- end, {description = "lua execute prompt", group = "awesome"}),


local client_keys = {}

local function bind_client(g, d, modifiers, keysym, action)
  local key = awful.key(modifiers, keysym, action, {description = d, group = g})
  client_keys = gears.table.join(client_keys, key)
end

-- app nav arrow keys
bind_client('app nav', 'left', {super}, 'Left', runner({app_nav, 'left'}))
bind_client('app nav', 'down', {super}, 'Down', runner({app_nav, 'down'}))
bind_client('app nav', 'up', {super}, 'Up', runner({app_nav, 'down'}))
bind_client('app nav', 'right', {super}, 'Right', runner({app_nav, 'right'}))
-- app nav left pinky mod-tap
bind_client('app nav', 'left', {super}, 'o', runner({app_nav, 'left'}))
bind_client('app nav', 'down', {super}, 'j', runner({app_nav, 'down'}))
bind_client('app nav', 'right', {super}, 'u', runner({app_nav, 'right'}))

bind_client('windows', 'cycle window placement', {super}, '.', placement.cycle)
bind_client('windows', 'close', {super}, 'x', function(c) c:kill() end)
bind_client('windows', 'focus previous', {super}, 'Up', focus.previous)
bind_client('windows', 'focus previous', {super}, 'e', focus.previous)
bind_client('windows', 'focus previous (up) window', shift_super, 'Up',
            focus.previous_window)
bind_client('windows', 'focus next (down) window', shift_super, 'Down',
            focus.next_window)

bind_client('browser', 'copy-link', {super}, 'i',
            runner({home_bin .. '/copy-link'}))

-- add binding for cyclefocus manually since it does not follow
-- the above pattern
cyclefocus.default_preset.base_font_size = 14
client_keys = gears.table.join(client_keys, cyclefocus.key({super}, 'Tab', {
  cycle_filters = {
    cyclefocus.filters.same_screen, cyclefocus.filters.common_tag
  }
}, {group = 'windows', description = 'cycle focus'}))

local clientbuttons = gears.table.join(awful.button({}, 1, function(c)
  c:emit_signal('request::activate', 'mouse_click', {raise = true})
end), awful.button({super}, 1, function(c)
  c:emit_signal('request::activate', 'mouse_click', {raise = true})
  awful.mouse.client.move(c)
end), awful.button({super}, 3, function(c)
  c:emit_signal('request::activate', 'mouse_click', {raise = true})
  awful.mouse.client.resize(c)
end))

return {clientkeys = client_keys, clientbuttons = clientbuttons}
