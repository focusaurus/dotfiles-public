local module = {}

local awful = require('awful')
local focus = require('focus')
local log2 = require('log2')

local leader_path = 'mate-calc'
local leader_rules = {class = 'Mate-calc'}
leader_path = os.getenv('HOME') .. '/bin/nofi'
leader_rules = {class = 'nofi'}

-- local prespawned_client = nil
-- local tag1 = awful.tag.find_by_name(awful.screen.focused(), "1")
local tag4 = awful.tag.find_by_name(awful.screen.focused(), '4')

local function noop() end

function module.log_clients()
  for c in awful.client.iterate(function() return true end) do
    log2('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
             ' c.modal: ' .. tostring(c.modal))
    -- c.hidden = not c.hidden
  end
end

function module.tag_out()
  local match_class = function(c) return awful.rules.match(c, leader_rules) end

  for c in awful.client.iterate(match_class) do
    log2('leader-nofi.tag_out: c.class: ', c.class, ' c.hidden: ', c.hidden,
         ' c.modal: ', c.modal)
    c:tags({tag4})
  end
end

function module.tag_in()
  local focused_tag = awful.screen.focused().selected_tag
  local match_class = function(c) return awful.rules.match(c, leader_rules) end

  local found = false
  for c in awful.client.iterate(match_class) do
    found = true
    log2('tagging in')
    c:tags({focused_tag})
    c:emit_signal('request::activate', 'tasklist', {raise = true})
  end
  if not found then focus.nofi() end
end

function module.tag_on_by_class(class_name)
  local match_class = function(c)
    -- return true
    return awful.rules.match(c, {class = class_name})
  end

  for c in awful.client.iterate(match_class) do
    log2('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
             ' c.modal: ' .. tostring(c.modal))
    local focused_tag = awful.screen.focused().selected_tag
    c:tag({focused_tag})
  end
end

function module.hide_by_class(class_name)
  local match_class = function(c)
    -- return true
    return awful.rules.match(c, {class = class_name})
  end

  for c in awful.client.iterate(match_class) do
    log2('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
             ' c.modal: ' .. tostring(c.modal))
    c.hidden = not c.hidden
  end
end

function module.dev2()
  if prespawned_client ~= nil then
    log2('dev2 found prespawn. Showing.')
    prespawned_client.hidden = false
    prespawned_client.below = false
    prespawned_client.focusable = true
    prespawned_client:emit_signal('request::activate', 'tasklist',
                                  {raise = true})
    return
  end

  log2('dev2: not found. Spawning visible.')
  awful.spawn.easy_async(leader_path, noop)
end

function module.dev()
  -- Unhide a prespawned leader window, or show one if not already spawned
  local found = false
  local match_class = function(c) return awful.rules.match(c, leader_rules) end

  for c in awful.client.iterate(match_class) do
    log2('dev: found. activating c.class: ' .. c.class .. ' c.hidden: ' ..
             tostring(c.hidden) .. ' c.modal: ' .. tostring(c.modal))
    found = true
    -- c.hidden = false
    c.below = false
    c.focusable = true
    c:emit_signal('request::activate', 'tasklist', {raise = true})
  end

  if found then return end
  log2('Did not find a prespawn. Spawning above')
  awful.spawn.easy_async(leader_path, noop)
end

function module.unmanage(c)
  log2('leader-nofi.unmanage called ')

  if awful.rules.match(c, leader_rules) then
    log2('leader-nofi.unmanage: class matches. spawn fresh below')
    awful.spawn.easy_async(leader_path, noop)
  end
end

function module.manage(c)
  log2('leader-nofi.manage called ' .. c.name)
  if awful.rules.match(c, leader_rules) then
    log2('marking', c.name, 'as not urgent')
    tag4.urgent = false
    c.urgent = false
    -- awful.urgent.delete(c)
    log2('done marking urgent')
    -- prespawned_client = c
  end
end

-- client.connect_signal('unmanage', module.unmanage)
-- client.connect_signal('manage', module.manage)

return module
