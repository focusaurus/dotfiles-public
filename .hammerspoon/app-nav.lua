local module= {}
local log = hs.logger.new("app-nav", "debug")
local hbin = os.getenv("HOME") .. "/bin"

function useTabNav(appName)
  return appName == "Google Chrome" or appName == "Firefox"
end

function isTerminal(appName)
  return appName == "iTerm2" or appName == "kitty"
end

function module.left()
  log.d("app-nav left")
  local name = hs.application.frontmostApplication():name()
  if isTerminal(name) then
    os.execute(hbin .. "/nav-tmux left")
  elseif name == "Code" then
    -- vim style tab navigation
    hs.eventtap.keyStroke({}, "Escape")
    hs.eventtap.keyStroke({}, "g")
    hs.eventtap.keyStroke({"shift"}, "T")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control", "shift"}, "Tab")
  end
end

function module.down()
  log.d("app-nav down")
  local name = hs.application.frontmostApplication():name()
  if isTerminal(name) then
    os.execute(hbin .. "/nav-tmux down")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "PageDown")
  end
end

function module.up()
  log.d("app-nav up")
  local name = hs.application.frontmostApplication():name()
  if isTerminal(name) then
    os.execute(hbin .. "/nav-tmux up")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "Home")
  end
end

function module.right()
  log.d("app-nav right")
  local name = hs.application.frontmostApplication():name()
  if isTerminal(name) then
    os.execute(hbin .. "/nav-tmux right")
  elseif name == "Code" then
    -- vim style tab navigation
    hs.eventtap.keyStroke({}, "Escape")
    hs.eventtap.keyStroke({}, "g")
    hs.eventtap.keyStroke({}, "t")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control"}, "Tab")
  end
end

return module
