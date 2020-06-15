local log = hs.logger.new("app-nav", "debug")
local hbin = os.getenv("HOME") .. "/bin"

function useTabNav(appName)
  return appName == "Google Chrome" or appName == "Firefox" or appName == "Code"
end

----- application navigation -----
-- left
hs.hotkey.bind({"option"}, "a", function ()
  log.d("app-nav left")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux left")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control", "shift"}, "Tab")
  end
end)

-- down
hs.hotkey.bind({"option"}, "o", function ()
  log.d("app-nav down")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux down")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "PageDown")
  end
end)

-- up
hs.hotkey.bind({"option"}, "e", function ()
  log.d("app-nav up")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux up")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "Home")
  end
end)

-- right
hs.hotkey.bind({"option"}, "u", function ()
  log.d("app-nav right")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux right")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control"}, "Tab")
  end
end)
