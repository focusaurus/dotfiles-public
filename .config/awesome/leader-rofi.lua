local module = {}

local awful = require('awful')
local focus = require('focus')
local log = require('log')

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

function module.hide_by_class(class_name)
  local match_class = function(c)
    -- return true
    return awful.rules.match(c, {class = class_name})
  end

  for c in awful.client.iterate(match_class) do
    log('dev1: c.class: ' .. c.class .. ' c.hidden: ' .. tostring(c.hidden) ..
             ' c.modal: ' .. tostring(c.modal))
    c.hidden = not c.hidden
  end
end


function module.show() module.hide_by_class('Rofi') end

function module.unmanage(c)
  log('leader.unmanage called ')

  if awful.rules.match(c, {class = 'Rofi'}) then
    log('leader.unmanage: class matches . spawn fresh below')
    focus.rofi()
  end
end

function module.manage(c)
  log('leader.manage called ' .. c.name)
  if awful.rules.match(c, {class = 'Rofi'}) then
    log('grabbing prespawned hidden client')
  end
end

return module
