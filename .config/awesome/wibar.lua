local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local menubar = require("menubar")

local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
--- This is used later as the default terminal and editor to run.
terminal = "termite"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
myawesomemenu = {
  {
    "hotkeys",
    function() hotkeys_popup.show_help(nil, awful.screen.focused()) end
  }, {"manual", terminal .. " -e man awesome"},
  {"edit config", editor_cmd .. " " .. awesome.conffile},
  {"restart", awesome.restart}, {"quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({
  items = {
    {"awesome", myawesomemenu, beautiful.awesome_icon},
    {"open terminal", terminal}
  }
})

mylauncher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu
})

menubar.utils.terminal = terminal

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                            awful.button({}, 1, function(t) t:view_only() end),
                            awful.button({modkey}, 1, function(t)
      if client.focus then client.focus:move_to_tag(t) end
    end), awful.button({}, 3, awful.tag.viewtoggle),
                            awful.button({modkey}, 3, function(t)
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

local clock_widget = wibox.widget.textclock()
local microphone_script_widget = awful.widget.watch(
                                     os.getenv("HOME") ..
                                         "/bin/widgets/microphone", 2)
local volume_script_widget = awful.widget.watch(
                                 os.getenv("HOME") .. "/bin/widgets/volume", 2)
local battery_script_widget = awful.widget.watch(
                                  os.getenv("HOME") .. "/bin/widgets/battery",
                                  10)
local screen_brightness_script_widget = awful.widget.watch(
                                            os.getenv("HOME") ..
                                                "/bin/widgets/screen-brightness",
                                            4)

awful.screen.connect_for_each_screen(function(s)

  -- Each screen has its own tag table.
  awful.tag({"1", "2", "3", "4"}, s, awful.layout.layouts[1])

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
  s.mytasklist = awful.widget.tasklist {
    screen = s,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
    style = {shape = gears.shape.rounded_bar}
  }

  -- Create the wibar
  s.mywibar = awful.wibar({position = "top", screen = s, height = 30})

  -- Add widgets to the wibar
  s.mywibar:setup{
    layout = wibox.layout.align.horizontal,
    { -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      mylauncher,
      s.mytaglist,
      s.mypromptbox
    },
    s.mytasklist, -- Middle widget
    { -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      volume_script_widget,
      battery_script_widget,
      microphone_script_widget,
      screen_brightness_script_widget,
      wibox.widget.systray(),
      s.mylayoutbox,
      clock_widget
    }
  }
end)
