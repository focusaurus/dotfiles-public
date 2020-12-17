local module = {}

local awful = require("awful")
local honor = {honor_workarea = true}

local log = require("log")

function module.left_half(client)
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

function module.right_half(client)
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

function module.maximize_toggle(client)
  client.maximized = not client.maximized
  client:raise()
end

function module.fullscreen_toggle(client)
  client.fullscreen = not client.fullscreen
  client:raise()
end

function module.cycle(client)
  local ratio = client.width / client.screen.geometry.width
  local x_pos = client.x - client.screen.geometry.x
  -- local debug = require("gears.debug")
  -- debug.print_warning("client.x " .. client.x)
  -- debug.print_warning("screen.geometry.x " .. client.screen.geometry.x)
  if ratio > 0.9 then
    module.left_half(client)
  else
    if x_pos < 50 then
      module.right_half(client)
    else
      module.maximize_toggle(client)
    end
  end
end

function module.move_all_clients_to_screen()
  for s in screen do
    log.log("dev6: index: " .. s.index .. " clients: " .. #s.all_clients)
    if #s.all_clients == 0 then
      for k,v in pairs(s.all_clients) do
        log.log("dev7 " .. (v.name or "") .. "screen index: " .. v.screen.index)
        v:move_to_screen(s.index)
      end
    end
  end
end

return module
