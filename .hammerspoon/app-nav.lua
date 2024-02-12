local module = {}
local log = hs.logger.new("app-nav", "debug")
local hbin = os.getenv("HOME") .. "/bin"

local function useTabNav(appName)
  return appName == "Google Chrome" or appName == "Firefox" or appName == "Obsidian"
end

local function isTerminal(appName)
  return appName == "iTerm2" or appName == "kitty" or appName == "Terminal"
end

function module.left()
  log.d("app-nav left")
  local name = hs.application.frontmostApplication():name()
  log.d("app name: " .. name)
  if name == "kitty" then
    hs.eventtap.keyStroke({ "shift" }, "space")
    hs.eventtap.keyStroke({}, "p")
  elseif name == "Code" then
    hs.eventtap.keyStroke({ "command", "shift" }, "[")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({ "control", "shift" }, "Tab")
  end
end

function module.down()
  log.d("app-nav down")
  local name = hs.application.frontmostApplication():name()
  if name == "kitty" then
    hs.eventtap.keyStroke({ "shift", "control" }, "]")
  elseif name == "Firefox" then
    hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, true):post()
    hs.eventtap.event.newKeyEvent("Tab", true):post()
    hs.timer.doAfter(0.3, function()
      hs.eventtap.event.newKeyEvent("Tab", false):post()
      hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, false):post()
    end)
    -- hs.eventtap.keyStroke({ "control" }, "Tab")
  elseif isTerminal(name) then
    os.execute(hbin .. "/nav-tmux down")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "PageDown")
  end
end

function module.up()
  log.d("app-nav up")
  local name = hs.application.frontmostApplication():name()
  if name == "kitty" then
    hs.eventtap.keyStroke({ "shift", "control" }, "[")
  elseif name == "Firefox" then
    -- focus previous window
    hs.eventtap.keyStroke({ "command" }, "`")
    -- elseif isTerminal(name) then
    -- os.execute(hbin .. "/nav-tmux up")
    -- elseif useTabNav(name) then
    -- hs.eventtap.keyStroke({}, "Home")
  end
end

function module.right()
  log.d("app-nav right")
  local name = hs.application.frontmostApplication():name()
  if name == "kitty" then
    hs.eventtap.keyStroke({ "shift" }, "space")
    hs.eventtap.keyStroke({}, "n")
  elseif name == "Code" then
    hs.eventtap.keyStroke({ "command", "shift" }, "]")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({ "control" }, "Tab")
  end
end

return module
