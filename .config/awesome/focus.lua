local module = {}

local awful = require("awful")
local log = require("log")

local home_bin = os.getenv("HOME") .. "/bin"
function noop() end

function module.by_class(class_name)
  local found = false
  local match_class = function (c)
    return awful.rules.match(c, {class = class_name})
  end

  for c in awful.client.iterate(match_class) do
    found = true
    c:emit_signal("request::activate", "tasklist", {raise = true})
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
  if not module.by_class("Rofi") then
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
