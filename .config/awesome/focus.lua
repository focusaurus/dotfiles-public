local module = {}

local awful = require("awful")

function module.left()
  awful.client.focus.byidx(-1)
end

function module.right()
  awful.client.focus.byidx(1)
end

function module.previous()
  awful.client.focus.history.previous()
  if client.focus then
    client.focus:raise()
  end
end

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:activate { context = "mouse_enter", raise = false }
-- end)
return module
