local module = {}

local awful = require('awful')
local focus = require('focus')
local log = require('log')

local leader_path = os.getenv('HOME') .. '/bin/blezz'
local prespawned_client = nil
local tag3 = awful.tag.find_by_name(awful.screen.focused(), '3')

function module.log_clients()
  for c in awful.client.iterate(function() return true end) do
    log('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
            ' c.modal: ' .. tostring(c.modal))
  end
end

function module.tag_off_by_class(class_name)
  local match_class = function(c)
    -- return true
    return awful.rules.match(c, {class = class_name})
  end

  for c in awful.client.iterate(match_class) do
    log('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
            ' c.modal: ' .. tostring(c.modal))
    c:tag({tag3})
  end
end

function module.tag_in()
  local focused_tag = awful.screen.focused().selected_tag
  local match_class =
      function(c) return awful.rules.match(c, {class = 'Rofi'}) end

  for c in awful.client.iterate(match_class) do
    log('tagging in')
    c:tags({focused_tag})
    c:emit_signal('request::activate', 'tasklist', {raise = true})
  end
end

function module.tag_on_by_class(class_name)
  local match_class = function(c)
    return awful.rules.match(c, {class = class_name})
  end

  for c in awful.client.iterate(match_class) do
    log('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
            ' c.modal: ' .. tostring(c.modal))
    local focused_tag = awful.screen.focused().selected_tag
    c:tag({focused_tag})
  end
end

function module.hide_by_class(class_name)
  local match_class = function(c)
    return awful.rules.match(c, {class = class_name})
  end

  for c in awful.client.iterate(match_class) do
    log('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
            ' c.modal: ' .. tostring(c.modal))
    c.hidden = not c.hidden
  end
end

function module.dev2()
  if prespawned_client ~= nil then
    log('dev5 found prespawn. Showing.')
    prespawned_client.hidden = false
    prespawned_client.below = false
    prespawned_client.focusable = true
    prespawned_client:emit_signal('request::activate', 'tasklist',
                                  {raise = true})
    return
  end

  log('dev5: not found. Spawning visible.')
  awful.spawn.easy_async(leader_path, function() end)
end

function module.dev()
  -- Unhide a prespawned leader window, or show one if not already spawned
  local found = false
  local match_class =
      function(c) return awful.rules.match(c, {class = 'Rofi'}) end

  for c in awful.client.iterate(match_class) do
    log('dev: found. activating c.class: ' .. c.class .. ' c.hidden: ' ..
            tostring(c.hidden) .. ' c.modal: ' .. tostring(c.modal))
    found = true
    -- c.hidden = false
    c.below = false
    c.focusable = true
    c:emit_signal('request::activate', 'tasklist', {raise = true})
  end

  if found then return end
  log('Did not find a prespawn. Spawning above')
  awful.spawn.easy_async(leader_path, function() end)
end

function module.show() module.hide_by_class('Rofi') end

function module.unmanage(c)
  log('leader.unmanage called ')

  if awful.rules.match(c, {class = 'Rofi'}) then
    log('leader.unmanage: class matches . spawn fresh below')
    focus.leader()
  end
end

function module.manage(c)
  log('leader.manage called ' .. c.name)
  if awful.rules.match(c, {class = 'Rofi'}) then
    log('grabbing prespawned hidden client')
    prespawned_client = c
  end
end

-- client.connect_signal("unmanage", module.unmanage)
-- client.connect_signal("manage", module.manage)

return module
