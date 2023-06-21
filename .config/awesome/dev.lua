local log2 = require('log2')
local focus = require('focus')
local naughty = require('naughty')
local awful = require('awful')
local module = {}

log2('dev loaded')
-- screen.connect_signal("list", function()
--   log2("screen list. Screen count: " .. screen:count())
-- end)
-- screen.connect_signal("added", function()
--   log2("screen added. Screen count: " .. screen:count())
-- end)
-- screen.connect_signal("removed", function()
--   log2("screen removed. Screen count: " .. screen:count())
-- end)
-- screen.connect_signal("primary_changed", function()
--   log2("screen primary_changed. Screen count: " .. screen:count())
-- end)
-- awesome.connect_signal("screen::change", function()
--   log2("screen::change. Screen count: " .. screen:count())
-- end)

local toggle = true
local test_class = 'Rofi'
function module.dev2()
  log2('dev.dev2() called: toggle is: ', toggle)
  -- local c = client.focus
  -- if not c then return end
  local tag1 = awful.tag.find_by_name(awful.screen.focused(), '1')
  local tag2 = awful.tag.find_by_name(awful.screen.focused(), '2')
  local match_class = function(c)
    return awful.rules.match(c, {class = test_class})
  end

  local found = false
  for c in awful.client.iterate(match_class) do
    found = true
    -- if toggle then
    log2('tagging 1')
    c:tags({tag1})
    c:emit_signal('request::activate', 'tasklist', {raise = true})
    -- else
    -- log2("tagging 2")
    -- c:tags({tag2})
    -- end
  end
  log2('dev2 found: ', found)
  toggle = not toggle
  -- c:tags({t})
  -- t:view_only()
  -- print("1: " .. awful.screen.focused().selected_tags[1])
end

function module.dev1()
  for c in awful.client.iterate(function() return true end) do
    log2('client name:', c.name, ' urgent:', c.urgent)
    c.urgent = false
  end
end

return module
