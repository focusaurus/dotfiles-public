local module = {}

local awful = require('awful')
local honor = {honor_workarea = true}

local log = require('log')

local all = function(_) return true end

function module.unminimize()
  for client in awful.client.iterate(all) do
    client.minimized = false
    client.maximized = true
  end
end

function module.left_half(client)
  client.maximized = false
  awful.placement.scale(client.focus, {
    to_percent = 0.5,
    direction = 'left',
    honor_workarea = true
  })
  awful.placement.scale(client.focus, {
    to_percent = 1,
    direction = 'up',
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
    direction = 'right',
    honor_workarea = true
  })
  awful.placement.scale(client.focus, {
    to_percent = 1,
    direction = 'up',
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
  -- log("client.x ", client.x)
  -- log("screen.geometry.x ", client.screen.geometry.x)
  if ratio > 0.9 then
    module.left_half(client)
  else
    if x_pos < 200 then
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
    log('dev8: s.index:', s.index, 'clients:', #s.all_clients)
    if #s.all_clients == 0 then
      log(s.index, 'is screen_to since has zero clients')
      screen_to = s
    else
      log(s.index, 'is screen_from since has some clients')
      screen_from = s
    end
  end

  log('dev9 WTF', #screen_from.all_clients)
  for _, client in pairs(screen_from.all_clients) do
    log('dev10 WTF')
    log('dev7 moving', (client.name or ''), 'from', client.screen.index,
         'to', screen_to.index)
    client:move_to_screen(screen_to.index)
    client.minimized = false
    client.maximized = true
    awful.placement.top(client, honor)
    awful.placement.left(client, honor)
    client:raise()
  end
end

function module.move_to_tag(tag_name)
  local c = client.focus
  log('placement.move_to_tag called ', tag_name, c == nil)
  if not c then return end
  local tag = awful.tag.find_by_name(awful.screen.focused(), tag_name)
  log('tag:', tag == nil)
  c:tags({tag})
end

return module
