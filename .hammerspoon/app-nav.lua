local module = {}
local log = hs.logger.new("app-nav", "debug")
local hbin = os.getenv("HOME") .. "/bin"

local function useTabNav(appName)
  return appName == "Google Chrome" or appName == "Firefox" or appName == "Obsidian" or appName == "Alacritty"
end

local function isTerminal(appName)
  return appName == "iTerm2" or appName == "kitty" or appName == "Terminal"
end

function module.left()
  local name = hs.application.frontmostApplication():name()
  log.d("app nav left. app name: " .. name)
  if name == "Ghostty" then
    hs.eventtap.keyStroke({ "shift" }, "space")
    hs.eventtap.keyStroke({}, "p")
    log.d("ghostty app nav left keystroke")
  elseif name == "kitty"  or name == "Ghostty" then
    hs.eventtap.keyStroke({ "command" }, "t")
    hs.eventtap.keyStroke({}, "p")
    log.d("kitty app nav left keystroke")
  elseif name == "Code" then
    hs.eventtap.keyStroke({ "command", "shift" }, "[")
  elseif name == "TablePlus" then
    hs.eventtap.keyStroke({ "command" }, "[")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({ "control", "shift" }, "Tab")
  end
end

-- app nav "down" should switch window in the same application,
-- or something analogous that feels mentally similar
function module.down()
  -- This should switch windows in the same app, or something analogous
  local name = hs.application.frontmostApplication():name()
  log.d("app-nav down. app name: " .. name)
  if name == "kitty" then
    -- hs.eventtap.keyStroke({ "shift", "control" }, "]")
    hs.eventtap.keyStroke({ "command", "shift" }, "w")
  elseif name == "Firefox" or name == "Code" or name == "TablePlus" then
    -- focus previous window
    hs.eventtap.keyStroke({ "command" }, "`")
    -- hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, true):post()
    -- hs.eventtap.event.newKeyEvent("Tab", true):post()
    -- hs.timer.doAfter(0.3, function()
    --   hs.eventtap.event.newKeyEvent("Tab", false):post()
    --   hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, false):post()
    -- end)
    -- hs.eventtap.keyStroke({ "control" }, "Tab")
  elseif isTerminal(name) then
    os.execute(hbin .. "/nav-tmux down")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "PageDown")
  end
end

-- app nav "up" should cycle through splits or tabs within the same window
-- or something that feels mentally similar
function module.up()
  local name = hs.application.frontmostApplication():name()
  log.d("app-nav up. app name: " .. name)
  if name == "kitty" then
    -- focus.previousWindow()
    hs.eventtap.keyStroke({ "shift", "control" }, "[")
  elseif name == "Firefox" then
    -- focus previous tab
    hs.eventtap.keyStroke({ "control" }, "Tab")
    -- elseif isTerminal(name) then
    -- os.execute(hbin .. "/nav-tmux up")
    -- elseif useTabNav(name) then
    -- hs.eventtap.keyStroke({}, "Home")
  end
end

function module.right()
  local name = hs.application.frontmostApplication():name()
  log.d("app-nav right. app name: " .. name)
  if name == "Ghostty" then
    hs.eventtap.keyStroke({ "shift" }, "space")
    hs.eventtap.keyStroke({}, "n")
    log.d("ghostty app nav right keystroke")
  elseif name == "kitty" then
    hs.eventtap.keyStroke({ "command" }, "t")
    hs.eventtap.keyStroke({}, "n")
  elseif name == "Code" then
    hs.eventtap.keyStroke({ "command", "shift" }, "]")
  elseif name == "TablePlus" then
    hs.eventtap.keyStroke({ "command" }, "]")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({ "control" }, "Tab")
  end
end

return module
