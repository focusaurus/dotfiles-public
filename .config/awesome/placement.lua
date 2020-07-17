local awful = require("awful")
local honor = {honor_workarea = true}

function left_half(client)
  awful.placement.scale(client.focus, {to_percent = 0.5, direction = "left", honor_workarea=true})
  awful.placement.scale(client.focus, {to_percent = 1, direction = "up", honor_workarea=true})
  awful.placement.top(client.focus, honor)
  awful.placement.left(client.focus, honor)
  client:raise()
end

function right_half(client)
  awful.placement.scale(client.focus, {to_percent = 0.5, direction = "right", honor_workarea=true})
  awful.placement.scale(client.focus, {to_percent = 1, direction = "up", honor_workarea=true})
  awful.placement.top(client.focus, honor)
  awful.placement.right(client.focus, honor)
  client:raise()
end

function maximize_toggle(client)
  client.maximized = not client.maximized
  client:raise()
end

return {
  right_half = right_half,
  left_half = left_half,
  maximize_toggle = maximize_toggle
}
