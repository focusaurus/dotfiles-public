local placement = {}

local awful = require("awful")
local honor = {honor_workarea = true}

function placement.left_half(client)
  client.maximized = false
  awful.placement.scale(client.focus, {
    to_percent = 0.5,
    direction = "left",
    honor_workarea = true
  })
  awful.placement.scale(client.focus, {
    to_percent = 1,
    direction = "up",
    honor_workarea = true
  })
  awful.placement.top(client.focus, honor)
  awful.placement.left(client.focus, honor)
  client:raise()
end

function placement.right_half(client)
  client.maximized = false
  awful.placement.scale(client.focus, {
    to_percent = 0.5,
    direction = "right",
    honor_workarea = true
  })
  awful.placement.scale(client.focus, {
    to_percent = 1,
    direction = "up",
    honor_workarea = true
  })
  awful.placement.top(client.focus, honor)
  awful.placement.right(client.focus, honor)
  client:raise()
end

function placement.maximize_toggle(client)
  client.maximized = not client.maximized
  client:raise()
end

function placement.fullscreen_toggle(client)
  client.fullscreen = not client.fullscreen
  client:raise()
end

function placement.cycle(client)
  ratio = client.width / client.screen.geometry.width
  if ratio > 0.75 then
    placement.left_half(client)
  else
    if client.x < 100 then
      placement.right_half(client)
    else
      placement.maximize_toggle(client)
    end
  end
end

return placement
