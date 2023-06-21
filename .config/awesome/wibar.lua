local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local menubar = require('menubar')
local placement = require('placement')
local titles = require('titles')
local dev = require('dev')
local focus = require('focus')
local log2 = require('log2')

local hotkeys_popup = require('awful.hotkeys_popup')

local module = {}
--- This is used later as the default terminal and editor to run.
local terminal = 'kitty'
beautiful.hotkeys_font = 'Hack 14'
beautiful.hotkeys_description_font = 'Hack 12'
beautiful.menu_font = 'Hack 14'
beautiful.menu_height = 28
beautiful.menu_width = 400
beautiful.tasklist_plain_task_name = true

local function small(widget)
  widget.forced_height = 25
  return widget
end

local mymainmenu = awful.menu({
  items = {
    {'open terminal', terminal},
    {'awesome: gather clients', placement.move_all_clients_to_screen}, {
      'awesome: hotkeys',
      function() hotkeys_popup.show_help(nil, awful.screen.focused()) end
    }, {'awesome: restart', awesome.restart},
    {'awesome: unminimize', placement.unminimize},
    {'awesome: titles', titles.dev}, {'awesome: dev1', dev.dev1},
    {'awesome: dev2', dev.dev2},
    {'awesome: quit', function() awesome.quit() end}, {'leader', focus.leader}
  }
})

local mylauncher = awful.widget.launcher(
                       {image = beautiful.awesome_icon, menu = mymainmenu})
small(mylauncher)

menubar.utils.terminal = terminal
alt = 'Mod1'
super = 'Mod4' -- super
control = 'Control'
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                            awful.button({}, 1, function(t) t:view_only() end),
                            awful.button({control}, 1, function(t)
      if client.focus then client.focus:move_to_tag(t) end
    end), awful.button({}, 3, awful.tag.viewtoggle),
                            awful.button({control}, 3, function(t)
      if client.focus then client.focus:toggle_tag(t) end
    end))

local tasklist_buttons = gears.table.join(
                             awful.button({}, 1, function(c)
      if c == client.focus then
        c.minimized = true
      else
        c:emit_signal('request::activate', 'tasklist', {raise = true})
      end
    end))

client.connect_signal('manage', function(c)
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then awful.client.setslave(c) end
  log2('manage window', c.name, 'urgent:', c.urgent)
  c.urgent = false
  awful.spawn.easy_async({os.getenv('HOME') .. '/bin/set-icons'},
                         function() log2('ran set-icons.sh') end)
end)

local clock_widget = wibox.widget.textclock()
local microphone_script_widget = awful.widget.watch(
                                     os.getenv('HOME') ..
                                         '/bin/widgets/microphone', 2)
small(microphone_script_widget)
local sound_widget = awful.widget.watch(os.getenv('HOME') ..
                                            '/bin/widgets/sound', 2)
small(sound_widget)
local battery_script_widget = awful.widget.watch(
                                  os.getenv('HOME') .. '/bin/widgets/battery',
                                  30)
small(battery_script_widget)
local screen_brightness_script_widget = awful.widget.watch(
                                            os.getenv('HOME') ..
                                                '/bin/widgets/screen-brightness',
                                            4)
small(screen_brightness_script_widget)
local volume_widget = wibox.widget.textbox('')
small(volume_widget)

awful.screen.connect_for_each_screen(function(s)

  -- Each screen has its own tag table.
  awful.tag({'1', '2', '3', '4'}, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  small(s.mylayoutbox)
  s.mylayoutbox:buttons(gears.table.join(
                            awful.button({}, 1,
                                         function() awful.layout.inc(1) end),
                            awful.button({}, 3,
                                         function() awful.layout.inc(-1) end),
                            awful.button({}, 4,
                                         function() awful.layout.inc(1) end),
                            awful.button({}, 5,
                                         function() awful.layout.inc(-1) end)))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = taglist_buttons
  }

  -- Create a tasklist widget
  tasklistlayout = wibox.layout.flex.vertical()
  tasklistlayout.max_widget_size = 30
  s.mytasklist = awful.widget.tasklist {
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
    style = {shape = gears.shape.rectangle},
    layout = tasklistlayout
  }
  -- Create the left wibar
  s.leftwibar = awful.wibar({position = 'left', screen = s, width = 175})
  -- Add widgets to the left wibar
  s.leftwibar:setup{
    layout = wibox.layout.align.vertical,
    { -- top widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist,
      s.mylayoutbox
    },
    { -- middle widgets
      layout = wibox.layout.fixed.vertical,
      s.mytasklist
    },
    { -- bottom widgets
      layout = wibox.layout.fixed.vertical,
      small(wibox.widget.systray()),
      battery_script_widget,
      screen_brightness_script_widget,
      sound_widget,
      wibox.widget.textclock('🟨%F\n🟪%a %B %d\n⌚%H:%M')
    }
  }
end)

-- https://github.com/elenapan/dotfiles/blob/master/config/awesome/evil/volume.lua
local volume_script_path = os.getenv('HOME') .. '/bin/widgets/volume'

function module.set_volume()
  awful.spawn.easy_async_with_shell(volume_script_path, function(stdout)
    volume_widget.text = stdout
  end)
end

module.set_volume()
-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink #\"
    "]]
-- Kill old pactl subscribe processes
awful.spawn.easy_async({
  'pkill', '--full', '--uid', os.getenv('USER'), '^pactl subscribe'
}, function()
  awful.spawn.with_line_callback(volume_script, {stdout = module.set_volume})
end)

return module
