--- global client
local module = {}

require('awful.autofocus')

local awful = require('awful')
local gears = require('gears')
local log = require('log')
local work_mode = ''

local home_bin = os.getenv('HOME') .. '/bin'
local function noop() end

local function focus_client(client)
  -- client:emit_signal('request::activate', 'mouse_click', {raise = true})
  client:jump_to(true)
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
    -- awful.spawn.easy_async(home_bin .. '/awesomewm-click-workaround', noop)
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
  gears.timer.start_new(0.2,
                        function() awful.key.execute({'Control'}, number) end)
end

local function by_class(class_name)
  return by_rules({class = class_name})
  -- local found = false
  -- local selected_tag = awful.screen.focused().selected_tag
  -- local match_class_and_tag = function(client)
  --   log("mcat: ", client.name, " client tag: ", client.first_tag.name
  --  , " selected tag: ", selected_tag.name,
  --   "matches:", client.first_tag == selected_tag)
  --   return client.first_tag == selected_tag and awful.rules.match(client, {class = class_name})
  -- end
  --
  -- local match_class = function (client)
  --   return awful.rules.match(client, {class = class_name})
  -- end
  --
  -- for client in awful.client.iterate(match_class_and_tag) do
  --   log("found by class and tag: ", client.name)
  --   found = true
  --   focus_client(client)
  --   return found
  -- end
  --
  -- for client in awful.client.iterate(match_class) do
  --   log("found by class only: ", client.name)
  --   found = true
  --   focus_client(client)
  --   if client.first_tag ~= selected_tag then
  --     client.first_tag:view_only()
  --   end
  -- end
  -- return found
end

function module.previous_window() awful.client.focus.byidx(-1) end

function module.next_window() awful.client.focus.byidx(1) end

function module.rofi()
  if not by_class('Rofi') then
    awful.spawn.easy_async(home_bin .. '/blezz', noop)
  end
end

function module.nofi()
  if not by_rules({class = 'nofi'}) then
    awful.spawn.easy_async(home_bin .. '/nofi', noop)
  end
end

function module.executables()
  awful.spawn.easy_async({
    'rofi', '-show', 'run', '-normal-window', '-no-steal-focus'
  }, noop)
end

function module.fuzz_script()
  log('focus.fuzz_script() called')
  awful.spawn.easy_async(home_bin .. '/fuzz-script-choose', noop)
end

function module.fuzz_snippet()
  log('focus.fuzz_snippet() called')
  awful.spawn.easy_async(home_bin .. '/fuzz-snippet', noop)
end

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
  log('focus.browser() called')
  if work_mode == 'frc' then
    module.frc()
    return
  end
  if work_mode == 'nuon' then
    module.nuon()
    return
  end
  -- try named chrome window specifically first
  local found = by_rules({class = 'Google-chrome', name = 'main'})
  if found then return end
  -- fall back to any chrome window
  found = by_rules({class = 'Google-chrome'})
  if found then return end
  -- if none, launch one
  if not found then
    awful.spawn.easy_async({'google-chrome-stable', '--restore-session'}, noop)
  end
end

function module.email()
  log('focus.email() called')
  module.browser()
  browser_tab('1')
end

function module.vscode()
  log('focus.vscode() called')
  local found = by_class('code-oss')
  if not found then awful.spawn.easy_async({'code'}, noop) end
end

function module.frc()
  log('focus.frc() called')
  local found = by_rules({class = 'Google-chrome', name = 'FRC: main'})
  if not found then awful.spawn.easy_async({'google-chrome-stable'}, noop) end
end

function module.nuon()
  log('focus.nuon() called')
  local found = by_rules({class = 'Google-chrome', name = 'nuon'})
  if not found then awful.spawn.easy_async({'google-chrome-stable'}, noop) end
end

function module.onepassword()
  log('focus.onepassword() called')
  local found = by_class('1Password')
  if not found then awful.spawn.easy_async({'1password'}, noop) end
end

function module.obsidian()
  log('focus.obsidian() called')
  local found = by_class('obsidian')
  if not found then awful.spawn.easy_async({'obsidian'}, noop) end
end

function module.calendar_chrome()
  log('focus.calendar_chrome() called')
  local found = by_rules({class = 'Google-chrome', name = 'calendar'})
  if not found then
    awful.spawn.easy_async({
      'google-chrome-stable', '--new-window',
      'https://calendar.google.com/calendar/r'
    }, noop)
  end
end

function module.calendar()
  log('focus.calendar() called')
  if not by_functions(rules_fn({class = 'firefox'}),
                      name_prefix_fn('[calendar]')) then
    awful.spawn.easy_async('firefox', noop)
  end
end

function module.todoist()
  log('focus.todoist() called')
  local found = by_rules({class = 'Google-chrome', name = 'todoist'})
  if not found then
    awful.spawn.easy_async({
      'google-chrome-stable', '--new-window', 'https://todoist.com/app/'
    }, noop)
  end
end

function module.music()
  log('focus.music() called')
  local found = by_rules({class = 'Google-chrome', name = 'music'})
  if not found then
    awful.spawn.easy_async({
      'google-chrome-stable', '--new-window', 'https://music.youtube.com'
    }, noop)
  end
end

function module.discord()
  log('focus.discord() called')
  local found = by_rules({class = 'Google-chrome', name = 'discord'})
  if not found then
    awful.spawn.easy_async({
      'google-chrome-stable', '--new-window', 'https://discord.com'
    }, noop)
  end
end

function module.workflowy()
  log('focus.workflowy() called')
  local found = by_rules({class = 'Google-chrome', name = 'workflowy'})
  if not found then
    awful.spawn.easy_async({
      'google-chrome-stable', '--new-window', 'https://workflowy.com'
    }, noop)
  end
end

function module.chrysalis()
  log('focus.chrysalis() called')
  if not by_class('chrysalis') then awful.spawn.easy_async({'chrysalis'}, noop) end
end

function module.xournalpp()
  log('focus.xournalpp() called')
  if not by_class('Xournalpp') then awful.spawn.easy_async({'xournalpp'}, noop) end
end

function module.wezterm()
  log('focus.wezterm() called')
  if not by_class('org.wezfurlong.wezterm') then
    awful.spawn.easy_async({'wezterm-gui'}, noop)
  end
end

function module.kitty()
  log('focus.kitty() called')
  if not by_class('kitty') then
    -- awful.spawn.easy_async({"kitty", "--single-instance", "--title", "terminal-kitty"}, noop)
    awful.spawn.easy_async({'kitty', '--title', 'terminal-kitty'}, noop)
  end
end

module.terminal = module.kitty -- alias for preferred terminal app

function module.slack()
  log('focus.slack() called')
  if not by_class('slack') then awful.spawn.easy_async('slack', noop) end
end

function module.gedit()
  log('focus.gedit() called')
  if not by_class('gedit') then awful.spawn.easy_async('gedit', noop) end
end

function module.zeal()
  log('focus.zeal() called')
  if not by_class('zeal') then awful.spawn.easy_async('zeal', noop) end
end

function module.zoom()
  log('focus.zoom() called')
  for _, name in pairs({'Zoom Meeting', 'Zoom Webinar', 'Zoom - Free Account'}) do
    log('finding by name', name)
    if by_rules({name = name}) then

      log('zoom window found with name', name)
      break
    end
  end
  awful.spawn.easy_async('zoom', noop)
  -- if not by_class("zoom") then
  --   awful.spawn.easy_async("zoom", noop)
  -- end
end

function module.zulip()
  log('focus.zulip() called')
  if not by_class('Zulip') then awful.spawn.easy_async('zulip', noop) end
end

function module.code()
  log('focus.code() called')
  if not by_class('Visual Studio Code') then
    awful.spawn.easy_async('code', noop)
  end
end

function module.firefox_old()
  log('focus.firefox_old() called')
  if not by_class('firefox') then awful.spawn.easy_async('firefox', noop) end
end

function module.firefox()
  log('focus.firefox() called')
  if not by_functions(rules_fn({class = 'firefox'}), name_prefix_fn('[main]')) then
    -- if not by_rules({name = awful.rules.match('[main]'), class='firefox'}) then
    awful.spawn.easy_async('firefox', noop)
  end
end

function module.insomnia()
  log('focus.insomnia() called')
  if not by_class('Insomnia') then
    awful.spawn.easy_async('/opt/insomnia/insomnia', noop)
  end
end

function module.cura()
  log('focus.cura() called')
  if not by_class('cura') then awful.spawn.easy_async('cura', noop) end
end

function module.emacs()
  log('focus.emacs() called')
  if not by_class('Emacs') then awful.spawn.easy_async('emacs', noop) end
end

function module.prusa()
  log('focus.prusa() called')
  if not by_class('PrusaSlicer') then
    awful.spawn.easy_async('/bin/prusa-slicer', noop)
  end
end

function module.calculator()
  log('focus.calculator() called')
  if not by_class('Mate-calc') then awful.spawn.easy_async('mate-calc', noop) end
end

function module.freecad()
  log('focus.freecad() called')
  if not by_class('FreeCAD') then awful.spawn.easy_async('freecad', noop) end
end

function module.vial()
  log('focus.vial() called')
  if not by_rules({name = 'Vial'}) then awful.spawn.easy_async('Vial', noop) end
end

function module.trello()
  log('focus.trello() called')
  local found = by_rules({class = 'Google-chrome', name = 'trello'})
  if not found then awful.spawn.easy_async({'google-chrome-stable'}, noop) end
  -- module.frc()
  -- browser_tab("3")
end

function module.fastmail()
  log('focus.fastmail() called')
  module.frc()
  browser_tab('1')
end

function module.fastmail_calendar()
  log('focus.fastmail_calendar() called')
  module.frc()
  browser_tab('2')
end

function module.qutebrowser()
  log('focus.qutebrowser() called')
  if not by_class('qutebrowser') then
    awful.spawn.easy_async('qutebrowser', noop)
  end
end

function module.kicad()
  log('focus.kicad() called')
  if not by_class('KiCAD') then awful.spawn.easy_async('kicad', noop) end
end

-- function module.highest()
--   local s = awful.screen.focused()
--   local c = awful.client.focus.history.get(s, 0)
--   if c == nil then return end
--   -- c:raise()
--   awful.client.focus.byidx(0, c)
--   -- awful.client.focus.previous()
--   -- log(c.name)
--   -- c.focus = true
--   -- c:focus()
--   -- for _, c in ipairs(s.clients) do
--   --   log(c.name)
--   --   if c.minimized == false then
--   --     c:raise()
--   --   end
--   -- end
-- end

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:activate { context = "mouse_enter", raise = false }
-- end)

-- awesome.connect_signal("unmanage", module.highest)
-- awful.screen.focused():connect_signal("request::autoactivate", module.highest)
return module
