local log = hs.logger.new("app-nav", "debug")
local hbin = os.getenv("HOME") .. "/bin"

function useTabNav(appName)
  return appName == "Google Chrome" or appName == "Firefox" or appName == "Code"
end

local function left()
  log.d("app-nav left")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux left")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control", "shift"}, "Tab")
  end
end

local function down()
  log.d("app-nav down")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux down")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "PageDown")
  end
end

local function up()
  log.d("app-nav up")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux up")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({}, "Home")
  end
end

local function right()
  log.d("app-nav right")
  local name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute(hbin .. "/nav-tmux right")
  elseif useTabNav(name) then
    hs.eventtap.keyStroke({"control"}, "Tab")
  end
end

return {
  down = down,
  left = left,
  right = right,
  up = up,
}
