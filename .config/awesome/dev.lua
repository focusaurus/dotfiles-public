local log = require('log')
local awful = require('awful')
local module = {}

log('dev loaded')
local toggle = true
local test_class = 'Rofi'
function module.dev2()
  log('dev.dev2() called: toggle is: ', toggle)
  local tag1 = awful.tag.find_by_name(awful.screen.focused(), '1')
  local match_class = function(c)
    return awful.rules.match(c, {class = test_class})
  end

  local found = false
  for c in awful.client.iterate(match_class) do
    found = true
    log('tagging 1')
    c:tags({tag1})
    c:emit_signal('request::activate', 'tasklist', {raise = true})
  end
  log('dev2 found: ', found)
  toggle = not toggle
end

function module.dev1()
  local selected_tag = awful.screen.focused().selected_tag.name
  local rules = {name = 'music'}
  local function tag_and_rules(c)
    log('tag_and_rules testing client', c.name, selected_tag)
    for _, tag in pairs(c:tags()) do
      local tag_matches = selected_tag == tag.name
      local rule_matches = awful.rules.match(c, rules)
      log('client', c.name, 'has tag', tag.name, 'tag_matches', tag_matches,
          'rule_matches', rule_matches)
      if tag_matches and rule_matches then
        log('client', c.name, 'matched tag and rules', tag)
        return true
      end
    end
    return false
  end
  for c in awful.client.iterate(tag_and_rules) do log('blah', c.name) end
end

return module
