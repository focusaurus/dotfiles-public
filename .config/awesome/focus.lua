local module = {}

local awful = require("awful")
local gears = require("gears")
local log = require("log")
local work_mode = false

local home_bin = os.getenv("HOME") .. "/bin"
function noop() end

function module.work_mode(value)
  log.log("work_mode_on called. Current value: " .. tostring(work_mode))
  work_mode = value
end

function focus_client(client)
  client:emit_signal("request::activate", "tasklist", {raise = true})
end

function browser_tab(number)
  gears.timer.start_new (0.2, function() 
    awful.key.execute({"Control"}, number)
  end)
end

function by_class(class_name)
  local found = false
  local match_class = function (client)
    return awful.rules.match(client, {class = class_name})
  end

  for client in awful.client.iterate(match_class) do
    found = true
    focus_client(client)
  end
  return found
end

function by_rules(rules)
  local found = false
  local match_rules = function (client)
    return awful.rules.match(client, rules)
  end

  for client in awful.client.iterate(match_rules) do
    found = true
    focus_client(client)
  end
  return found
end

function module.left()
  awful.client.focus.byidx(-1)
end

function module.right()
  awful.client.focus.byidx(1)
end

function module.leader()
  if not by_class("Rofi") then
    awful.spawn.easy_async(home_bin .. "/blezz", noop)
  end
end

function module.fuzz_script()
  log.log("focus.fuzz_script() called")
  awful.spawn.easy_async(home_bin .. "/fuzz-script-choose", noop)
end

function module.fuzz_snippet()
  log.log("focus.fuzz_snippet() called")
  awful.spawn.easy_async(home_bin .. "/fuzz-snippet", noop)
end

function module.previous()
  awful.client.focus.history.previous()
  if client.focus then
    client.focus:raise()
  end
end

function module.highest()
  local s = awful.screen.focused()
  local c = awful.client.focus.history.get(s, 0)
  if c == nil then return end
  awful.client.focus.byidx(0, c)
end

function module.browser()
  log.log("focus.browser() called")
  if work_mode then
    module.frc()
    return
  end
  local found = by_rules({class = "Google-chrome", name = "main"})
  if not found then
    awful.spawn.easy_async({"google-chrome-stable", "--restore-session"} , noop)
  end
end

function module.email()
  log.log("focus.email() called")
  module.browser()
  browser_tab("1")
end

function module.frc()
  log.log("focus.frc() called")
  local found = by_rules({class = "Google-chrome", name = "FRC"})
  if not found then
    awful.spawn.easy_async({"google-chrome-stable"}, noop)
  end
end

function module.calendar()
  log.log("focus.calendar() called")
  local found = by_rules({class = "Google-chrome", name = "calendar"})
  if not found then
    awful.spawn.easy_async({"google-chrome-stable", "--new-window",  "https://calendar.google.com/calendar/r"}, noop)
  end
end

function module.music()
  log.log("focus.music() called")
  local found = by_rules({class = "Google-chrome", name = "music"})
  if not found then
    awful.spawn.easy_async({"google-chrome-stable", "--new-window", "https://music.youtube.com"}, noop)
  end
end

function module.workflowy()
  log.log("focus.workflowy() called")
  local found = by_rules({class = "Google-chrome", name = "workflowy"})
  if not found then
    awful.spawn.easy_async({"google-chrome-stable", "--new-window", "https://workflowy.com"}, noop)
  end
end

function module.xournalpp()
  log.log("focus.xournalpp() called")
  if not by_class("Xournalpp") then
    awful.spawn.easy_async({"xournalpp"}, noop)
  end
end

function module.terminal()
  log.log("focus.terminal() called")
  if not by_class("kitty") then
    awful.spawn.easy_async({"kitty", "--single-instance", "--title", "terminal-kitty"}, noop)
  end
end

function module.slack()
  log.log("focus.slack() called")
  if not by_class("slack") then
    awful.spawn.easy_async("slack", noop)
  end
end

function module.gedit()
  log.log("focus.gedit() called")
  if not by_class("gedit") then
    awful.spawn.easy_async("gedit", noop)
  end
end

function module.zeal()
  log.log("focus.zeal() called")
  if not by_class("zeal") then
    awful.spawn.easy_async("zeal", noop)
  end
end

function module.zoom()
  log.log("focus.zoom() called")
  found = false
  for i, name in pairs({"Zoom Meeting", "Zoom Webinar", "Zoom - Free Account"}) do
    log.log("finding by name " .. name)
    if by_rules({name = name}) then

      log.log("zoom window found with name" .. name)
      break
    end
  end
  awful.spawn.easy_async("zoom", noop)
  -- if not by_class("zoom") then
  --   awful.spawn.easy_async("zoom", noop)
  -- end
end

function module.zulip()
  log.log("focus.zulip() called")
  if not by_class("Zulip") then
    awful.spawn.easy_async("zulip", noop)
  end
end

function module.code()
  log.log("focus.code() called")
  if not by_class("Visual Studio Code") then
    awful.spawn.easy_async("code", noop)
  end
end

function module.firefox()
  log.log("focus.firefox() called")
  if not by_class("firefox") then
    awful.spawn.easy_async("firefox", noop)
  end
end

function module.cura()
  log.log("focus.cura() called")
  if not by_class("cura") then
    awful.spawn.easy_async("cura", noop)
  end
end

function module.emacs()
  log.log("focus.emacs() called")
  if not by_class("Emacs") then
    awful.spawn.easy_async("emacs", noop)
  end
end

function module.prusa()
  log.log("focus.prusa() called")
  if not by_class("PrusaSlicer") then
    awful.spawn.easy_async("/bin/prusa-slicer", noop)
  end
end

function module.calculator()
  log.log("focus.calculator() called")
  if not by_class("Calculator") then
    awful.spawn.easy_async("mate-calc", noop)
  end
end

function module.freecad()
  log.log("focus.freecad() called")
  if not by_class("FreeCAD") then
    awful.spawn.easy_async("freecad", noop)
  end
end

function module.trello()
  log.log("focus.trello() called")
  module.frc()
  browser_tab("3")
end

function module.fastmail()
  log.log("focus.fastmail() called")
  module.frc()
  browser_tab("1")
end

function module.fastmail_calendar()
  log.log("focus.fastmail_calendar() called")
  module.frc()
  browser_tab("2")
end



-- function module.highest()
--   local s = awful.screen.focused()
--   local c = awful.client.focus.history.get(s, 0)
--   if c == nil then return end
--   -- c:raise()
--   awful.client.focus.byidx(0, c)
--   -- awful.client.focus.previous()
--   -- log.log(c.name)
--   -- c.focus = true
--   -- c:focus()
--   -- for _, c in ipairs(s.clients) do
--   --   log.log(c.name)
--   --   if c.minimized == false then
--   --     c:raise()
--   --   end
--   -- end
-- end

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:activate { context = "mouse_enter", raise = false }
-- end)

-- awesome.connect_signal("unmanage", module.highest)
-- awful.screen.focused():connect_signal("request::autoactivate", module.highest)
return module
