local module = {}

require('awful.autofocus')

local awful = require('awful')
local gears = require('gears')
local log = require('log')
local modifiers = require('modifiers')
local work_mode = ''

local home_bin = os.getenv('HOME') .. '/bin'
local function noop() end

local function run(args) awful.spawn.easy_async(args, noop) end

local function focus_client(client)
  -- client:emit_signal('request::activate', 'mouse_click', {raise = true})
  client:jump_to(true)
  client.first_tag:view_only()
end

local function name_prefix_fn(prefix)
  return function(c)
    local found = gears.string.startswith(c.name, prefix)
    log('checked', c.name, 'for prefix', prefix, found)
    return found
  end
end

local function rules_fn(rules)
  return function(c)
    local matched = awful.rules.match(c, rules)
    log('checked rules', matched, c.name)
    return matched
  end
end

-- awful.keygrabber:connect_signal('awful.keygrabber.started', function() log("keygrabber started") end)
local function by_functions(...)
  local selected_tag = awful.screen.focused().selected_tag.name

  local fns = {...} ---@class table

  local function with_tag(c)
    for _, fn in pairs(fns) do
      local matched = fn(c)
      -- log('with_tags checked fn match', c.name, matched)
      if matched == false then return false end
    end
    for _, tag in pairs(c:tags()) do
      if selected_tag == tag.name then
        -- log('tag match', selected_tag, tag.name)
        return true
      else
        -- log('tag mismatch', selected_tag, tag.name)
      end
    end
    -- log('with_tag returning false', c.name)
    return false
  end

  local function just_fns(c)
    for _, fn in pairs(fns) do
      -- log('just_fns testing', c.name)
      if fn(c) == false then
        -- log('just_fns was false', c.name)
        return false
      end
    end
    -- log('just_fns returning true', c.name)
    return true
  end

  -- prefer a matching client on the selected tag
  for c in awful.client.iterate(with_tag) do
    -- log('matched', c.name, 'on selected tag')
    focus_client(c)
    return true
  end

  -- fallback to matching clients on any tag
  for c in awful.client.iterate(just_fns) do
    -- log('matched with just_fns', c.name)
    focus_client(c)
    return true
  end
  -- log('by_functions: no match')
  return false
end

local function by_rules(rules)
  local selected_tag = awful.screen.focused().selected_tag.name
  local function tag_and_rules(c)
    log('tag_and_rules testing client', c.name, selected_tag)
    for _, tag in pairs(c:tags()) do
      local tag_matches = selected_tag == tag.name
      local rule_matches = awful.rules.match(c, rules)
      log('client', c.name, 'has tag', tag.name, 'tag_matches', tag_matches,
          'rule_matches', rule_matches)
      if tag_matches and rule_matches then
        -- log('client', c.name, 'matched tag and rules', tag)
        return true
      end
    end
    return false
  end

  -- prefer a matching client on the selected tag
  for c in awful.client.iterate(tag_and_rules) do
    focus_client(c)
    return true
  end

  local match_rules = function(c) return awful.rules.match(c, rules) end

  -- fallback to matching clients on any tag
  for c in awful.client.iterate(match_rules) do
    log('matched client by rules on different tag', c.name)
    focus_client(c)
    c.first_tag:view_only()
    -- work around awesomewm bug where if you change tags,
    -- keyboard focus is totally disconnected and the keyboard
    -- doesn't work until you click with the mouse for some reason
    log('hacking keyboard focus', c.first_tag.activated, c.first_tag.selected)
    -- awful.screen.focus()
    -- c:raise()

    -- awful.tag.viewidx(1)
    -- awful.tag.viewidx(-1)
    -- run(home_bin .. '/awesomewm-click-workaround')
    -- focus_client(c)
    -- module.previous()
    -- module.next()
    return true
  end
  return false
end

function module.work_mode(value)
  log('work_mode called. Current value: ', work_mode)
  work_mode = value
end

local function browser_tab(number)
  -- alt for firefox, control for chrome
  gears.timer.start_new(0.2, function()
    awful.key.execute({modifiers.alt}, number)
  end)
end

local function by_class(class_name) return by_rules({class = class_name}) end

function module.previous_window() awful.client.focus.byidx(-1) end

function module.next_window() awful.client.focus.byidx(1) end

function module.rofi() if not by_class('Rofi') then run(home_bin .. '/blezz') end end

function module.nofi() if not by_class('nofi') then run(home_bin .. '/nofi') end end
function module.gofi() if not by_class('org.wezfurlong.wezterm') then run(home_bin .. '/gofi-wezterm') end end

function module.executables()
  run({'rofi', '-show', 'run', '-normal-window', '-no-steal-focus'})
end

function module.fuzz_script() run(home_bin .. '/fuzz-script-choose') end

function module.fuzz_snippet() run(home_bin .. '/fuzz-snippet') end

function module.previous()
  awful.client.focus.history.previous()
  if client.focus then client.focus:raise() end
end

function module.highest()
  local s = awful.screen.focused()
  local c = awful.client.focus.history.get(s, 0)
  if c == nil then return end
  awful.client.focus.byidx(0, c)
end

function module.browser()
  if work_mode == 'frc' then
    module.frc()
    return
  end

  local firefox = true
  if firefox then
    -- try named firefox window specifically first
    if by_functions(rules_fn({class = 'firefox'}), name_prefix_fn('main: ')) then
      return
    end
    -- fall back to any firefox window
    if by_rules({class = 'firefox'}) then return end
    -- if none, launch one
    run('firefox')
  else
    -- try named chrome window specifically first
    if by_rules({class = 'Google-chrome', name = 'main'}) then return end
    -- fall back to any chrome window
    if by_rules({class = 'Google-chrome'}) then return end
    -- if none, launch one
    run({'google-chrome-stable', '--restore-session'})
  end
end

function module.email()
  module.browser()
  browser_tab('1')
end

function module.vscode() if not by_class('code-oss') then run({'code'}) end end

function module.frc_old()
  if not by_rules({class = 'Google-chrome', name = 'FRC: main'}) then
    run({'google-chrome-stable'})
  end
end

function module.frc()
  if not by_functions(rules_fn({class = 'firefox'}), name_prefix_fn('FRC: ')) then
    run('firefox')
  end
end

function module.onepassword()
  if not by_class('1Password') then run({'1password'}) end
end

function module.obsidian() if not by_class('obsidian') then run({'obsidian'}) end end

function module.calendar_chrome()
  if not by_rules({class = 'Google-chrome', name = 'calendar'}) then
    run({
      'google-chrome-stable', '--new-window',
      'https://calendar.google.com/calendar/r'
    })
  end
end

function module.calendar()
  if not by_functions(rules_fn({class = 'firefox'}),
                      name_prefix_fn('calendar: ')) then run('firefox') end
end

function module.todoist()
  if not by_functions(rules_fn({class = 'firefox'}), name_prefix_fn('todoist: ')) then
    run('firefox')
  end
end

function module.music()
  if not by_functions(rules_fn({class = 'firefox'}), name_prefix_fn('music: ')) then
    run('firefox')
  end
end

function module.discord()
  if not by_rules({class = 'Google-chrome', name = 'discord'}) then
    run({'google-chrome-stable', '--new-window', 'https://discord.com'})
  end
end

function module.workflowy()
  if not by_rules({class = 'Google-chrome', name = 'workflowy'}) then
    run({'google-chrome-stable', '--new-window', 'https://workflowy.com'})
  end
end

function module.chrysalis()
  if not by_class('chrysalis') then run({'chrysalis'}) end
end

function module.xournalpp()
  if not by_class('Xournalpp') then run({'xournalpp'}) end
end

function module.wezterm()
  if not by_class('org.wezfurlong.wezterm') then run({'wezterm-gui'}) end
end

function module.kitty()
  if not by_class('kitty') then run({'kitty', '--title', 'terminal-kitty'}) end
end

function module.alacritty()
  if not by_class('Alacritty') then run({'alacritty'}) end
end

module.terminal = module.kitty -- alias for preferred terminal app

function module.slack() if not by_class('Slack') then run('slack') end end

function module.gedit() if not by_class('gedit') then run('gedit') end end

function module.zeal() if not by_class('zeal') then run('zeal') end end

function module.zoom()
  for _, name in pairs({'Zoom Meeting', 'Zoom Webinar', 'Zoom - Free Account'}) do
    log('finding by name', name)
    if by_rules({name = name}) then
      log('zoom window found with name', name)
      break
    end
  end
  run('zoom')
end

function module.zulip() if not by_class('Zulip') then run('zulip') end end

function module.code() if not by_class('Visual Studio Code') then run('code') end end

function module.firefox_old() if not by_class('firefox') then run('firefox') end end

function module.firefox()
  if not by_functions(rules_fn({class = 'firefox'}), name_prefix_fn('main: ')) then
    run('firefox')
  end
end

function module.insomnia()
  if not by_class('Insomnia') then run('/opt/insomnia/insomnia') end
end

-- function module.cura() if not by_class('cura') then run('cura') end end

-- function module.emacs() if not by_class('Emacs') then run('emacs') end end

function module.prusa()
  if not by_class('PrusaSlicer') then run('/bin/prusa-slicer') end
end

function module.bambustudio()
  if not by_class('BambuStudio') then run('/bin/bambu-studio') end
end

function module.calculator()
  if not by_class('Mate-calc') then run('mate-calc') end
end

function module.freecad() if not by_class('FreeCAD') then run('freecad') end end

function module.vial() if not by_rules({name = 'Vial'}) then run('Vial') end end

function module.trello()
  if not by_functions(rules_fn({class = 'firefox'}), name_prefix_fn('trello: ')) then
    run('firefox')
  end
end

function module.fastmail()
  module.frc()
  browser_tab('1')
end

function module.fastmail_calendar()
  module.frc()
  browser_tab('2')
end

function module.qutebrowser()
  if not by_class('qutebrowser') then run('qutebrowser') end
end

function module.kicad() if not by_class('KiCAD') then run('kicad') end end

return module
