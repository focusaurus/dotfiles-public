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
  -- Default to assuming only 1 screen.
  -- We still want to move all clients to it because
  -- awesomewm doesn't do this for us automatically

  local screen_from = screen[1]
  local screen_to = screen[1]
  for s in screen do
    log.log("dev8: s.index: " .. s.index .. " clients: " .. #s.all_clients)
    if #s.all_clients == 0 then
      log.log(s.index .. " is screen_to since has zero clients")
      screen_to = s
    else
      log.log(s.index .. " is screen_from since has some clients")
      screen_from = s
    end

    -- if #s.all_clients < #screen_to.all_clients then
    --   screen_to = s
    -- end
    -- if #s.all_clients >= #screen_from.all_clients then
    --   log.log(s.index .. " is screen_from since has most clients")
    --   screen_from = s
    -- end
    -- if screen_from == nil then
    --   log.log("screen_from default is " .. s.index)
    --   screen_from = s
    -- end
    -- if screen_to == nil then
    --   log.log("screen_to default is " .. s.index)
    --   screen_to = s
    -- end
    -- if #s.all_clients == 0 then
    --   log.log("Screen " .. s.index .. " has no clients, is screen_to")
    --   screen_to = s
    -- else
    --   log.log("Screen " .. s.index .. " has some clients, is screen_from")
    --   screen_from = s
    -- end
  end

  log.log("dev9 WTF " .. #screen_from.all_clients)
  for key, client in pairs(screen_from.all_clients) do
    log.log("dev10 WTF")
    log.log("dev7 moving " .. (client.name or "") .. " from " .. client.screen.index .. " to " .. screen_to.index)
    client:move_to_screen(screen_to.index)
    client.minimized = false
    client:raise()
  end
end

return module
