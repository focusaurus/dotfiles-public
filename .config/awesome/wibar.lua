local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")

local menubar = require("menubar")
local placement = require("placement")
local titles = require("titles")
local leader = require("leader")
local dev = require("dev")
local focus = require("focus")

local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local module = {}
--- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
beautiful.hotkeys_font = "Hack 14"
beautiful.hotkeys_description_font = "Hack 12"
beautiful.menu_font = "Hack 14"
beautiful.menu_height = 28
beautiful.menu_width = 400
beautiful.tasklist_plain_task_name = true

mymainmenu = awful.menu({
  items = {
    {"open terminal", terminal},
    {"awesome: gather clients", placement.move_all_clients_to_screen},
    {"awesome: hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    {"awesome: restart", awesome.restart},
    {"awesome: unminimize", placement.unminimize},
    {"awesome: titles", titles.dev},
    {"awesome: dev1", dev.dev1},
    {"awesome: dev2", dev.dev2},
    {"awesome: quit", function() awesome.quit() end},
    {"leader", focus.leader}
  }
})

mylauncher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu
})

menubar.utils.terminal = terminal
alt = "Mod1"
super = "Mod4" -- super
control = "Control"
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                            awful.button({}, 1, function(t) t:view_only() end),
                            awful.button({control}, 1, function(t)
      if client.focus then client.focus:move_to_tag(t) end
    end), awful.button({}, 3, awful.tag.viewtoggle),
                            awful.button({control}, 3, function(t)
      if client.focus then client.focus:toggle_tag(t) end
    end)
    -- awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
-- awful.button({}, 5, function(t)
--   awful.tag.viewprev(t.screen)
-- end)
)

local tasklist_buttons = gears.table.join(
                             awful.button({}, 1, function(c)
      if c == client.focus then
        c.minimized = true
      else
        c:emit_signal("request::activate", "tasklist", {raise = true})
      end
    end) -- awful.button({}, 3, function()
--   awful.menu.client_list({theme = {width = 250}})
-- end),
-- awful.button({}, 4, function() awful.client.focus.byidx(1) end),
-- awful.button({}, 5, function()
--   awful.client.focus.byidx(-1)
-- end)
)

client.connect_signal("manage", function (c)
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then
    awful.client.setslave(c)
  end
end)

local clock_widget = wibox.widget.textclock()
local microphone_script_widget = awful.widget.watch(
                                     os.getenv("HOME") ..
                                         "/bin/widgets/microphone", 2)
local battery_script_widget = awful.widget.watch(
                                  os.getenv("HOME") .. "/bin/widgets/battery",
                                  30)
local screen_brightness_script_widget = awful.widget.watch(
                                            os.getenv("HOME") ..
                                                "/bin/widgets/screen-brightness",
                                            4)
local volume_widget = wibox.widget.textbox("")

awful.screen.connect_for_each_screen(function(s)

  -- Each screen has its own tag table.
  awful.tag({"1", "2", "3", "4"}, s, awful.layout.layouts[1])
  -- awful.tag({"1"}, s, awful.layout.layouts[1])

  -- Create a promptbox for each screen
  s.mypromptbox = awful.widget.prompt()
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
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
  -- Create the top wibar
  s.topwibar = awful.wibar({position = "top", screen = s, height = 30})

  -- Add widgets to the top wibar
  s.topwibar:setup{
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist,
      s.mypromptbox
    },
    {layout=wibox.layout.fixed.horizontal}, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      volume_widget,
      battery_script_widget,
      microphone_script_widget,
      screen_brightness_script_widget,
      wibox.widget.systray(),
      s.mylayoutbox,
      clock_widget
    }
  }
  -- Create the left wibar
  s.leftwibar = awful.wibar({position = "left", screen = s, width = 175})
  -- Add widgets to the left wibar
  s.leftwibar:setup{
    layout = wibox.layout.align.vertical,
    { -- Left widgets
      layout = wibox.layout.fixed.vertical,
    },
    { -- Left widgets
      layout = wibox.layout.fixed.vertical,
      s.mytasklist, -- Middle widget
    },
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
    }
  }
end)

-- https://github.com/elenapan/dotfiles/blob/master/config/awesome/evil/volume.lua
local volume_script_path = os.getenv("HOME") .. "/bin/widgets/volume"

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
awful.spawn.easy_async({"pkill", "--full", "--uid", os.getenv("USER"), "^pactl subscribe"}, function ()
  awful.spawn.with_line_callback(volume_script, { stdout = module.set_volume })
end)

return module
