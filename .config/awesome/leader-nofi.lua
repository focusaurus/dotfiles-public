local module = {}

local awful = require('awful')
local focus = require('focus')
local log = require('log')

local leader_rules = {class = 'Mate-calc'}
leader_rules = {class = 'nofi'}

local tag4 = awful.tag.find_by_name(awful.screen.focused(), '4')

function module.tag_out()
  local match_class = function(c) return awful.rules.match(c, leader_rules) end

  for c in awful.client.iterate(match_class) do
    log('leader-nofi.tag_out: c.class: ', c.class, ' c.hidden: ', c.hidden,
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
    log('tagging in', c.name)
    c:tags({focused_tag})
    c:emit_signal('request::activate', 'tasklist', {raise = true})
  end
  if not found then focus.nofi() end
end

return module
