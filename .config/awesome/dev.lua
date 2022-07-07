local log = require("log")
local focus = require("focus")
local naughty = require("naughty")
local awful = require("awful")
local module = {}

log.log("dev loaded")
-- screen.connect_signal("list", function()
--   log.log("screen list. Screen count: " .. screen:count())
-- end)
-- screen.connect_signal("added", function()
--   log.log("screen added. Screen count: " .. screen:count())
-- end)
-- screen.connect_signal("removed", function()
--   log.log("screen removed. Screen count: " .. screen:count())
-- end)
-- screen.connect_signal("primary_changed", function()
--   log.log("screen primary_changed. Screen count: " .. screen:count())
-- end)
-- awesome.connect_signal("screen::change", function()
--   log.log("screen::change. Screen count: " .. screen:count())
-- end)

local toggle = true
local test_class = 'Rofi'
function module.dev1()
  log.log("dev.dev1() called: toggle is: " .. tostring(toggle))
  -- local c = client.focus
  -- if not c then return end
  local tag1 = awful.tag.find_by_name(awful.screen.focused(), "1")
  local tag2 = awful.tag.find_by_name(awful.screen.focused(), "2")
  local match_class = function (c)
    return awful.rules.match(c, {class = test_class})
  end

  local found = false
  for c in awful.client.iterate(match_class) do
    found = true
    -- if toggle then
      log.log("tagging 1")
      c:tags({tag1})
      c:emit_signal("request::activate", "tasklist", {raise = true})
    -- else
      -- log.log("tagging 2")
      -- c:tags({tag2})
    -- end
  end
  log.log("dev1 found: " .. tostring(found))
  toggle = not toggle
  -- c:tags({t})
  -- t:view_only()
  -- print("1: " .. awful.screen.focused().selected_tags[1])
end

function module.dev2()
  log.log("dev.dev2() called")
  focus.work_mode_on()
end

return module
