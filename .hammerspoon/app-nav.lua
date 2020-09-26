local log = hs.logger.new("app-nav", "debug")
local hbin = os.getenv("HOME") .. "/bin"

function useTabNav(appName)
  return appName == "Google Chrome" or appName == "Firefox" or appName == "Code"
end

local hyper_pl = {"command", "option"}
----- application navigation -----
-- left
hs.hotkey.bind(hyper_pl, "o", function ()
  log.d("app-nav left")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux left")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control", "shift"}, "Tab")
  end
end)

-- down
hs.hotkey.bind(hyper_pl, "j", function ()
  log.d("app-nav down")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux down")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "PageDown")
  end
end)

-- up
hs.hotkey.bind(hyper_pl, "e", function ()
  log.d("app-nav up")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux up")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "Home")
  end
end)

-- right
hs.hotkey.bind(hyper_pl, "u", function ()
  log.d("app-nav right")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux right")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control"}, "Tab")
  end
end)
