local log = require("log")
local module = {}

-- log.log("dev loaded")
screen.connect_signal("list", function()
  log.log("screen list. Screen count: " .. screen:count())
end)
screen.connect_signal("added", function()
  log.log("screen added. Screen count: " .. screen:count())
end)
screen.connect_signal("removed", function()
  log.log("screen removed. Screen count: " .. screen:count())
end)
screen.connect_signal("primary_changed", function()
  log.log("screen primary_changed. Screen count: " .. screen:count())
end)
awesome.connect_signal("screen::change", function()
  log.log("screen::change. Screen count: " .. screen:count())
end)

function module.dev()
  log.log("dev.dev called. Screen count: " .. screen:count())
end

return module
