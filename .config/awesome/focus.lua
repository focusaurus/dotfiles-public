local focus = {}

local awful = require("awful")
function focus.left() awful.client.focus.byidx(-1) end
function focus.right() awful.client.focus.byidx(1) end
-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:activate { context = "mouse_enter", raise = false }
-- end)
return focus
