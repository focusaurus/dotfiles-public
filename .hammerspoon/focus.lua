local module = {}
local log = hs.logger.new("focus", "debug")

function module.terminal()
  log.d("terminal")
  hs.application.launchOrFocus("iTerm")
end

function module.browser()
  log.d("browser")
  hs.application.launchOrFocus("Google Chrome")
end

function module.email()
  log.d("email")
  hs.application.launchOrFocus("Google Chrome")
  hs.eventtap.keyStroke({"command"}, "1")
end

function module.emacs()
  log.d("emacs")
  hs.application.launchOrFocus("Emacs")
end

function module.workflowy()
  log.d("workflowy")
  hs.application.launchOrFocus("WorkFlowy")
end

function module.previous()
  log.d("previous")
  hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, true):post()
  hs.eventtap.event.newKeyEvent("Tab", true):post()
  -- hs.timer.doAfter(0.2, function()
    hs.eventtap.event.newKeyEvent("Tab", false):post()
    hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, false):post()
  -- end)
end

function module.slackOrZoom()
  log.d("slackOrZoom")
  local zoomIsFront = hs.window.frontmostWindow():application():name() == "zoom.us"
  local zoomIsRunning = false
  -- window count > 1 used as a proxy for "has active meeting window"
  local zoomWindowCount = 0
  local apps = hs.application.runningApplications()
  for i = 1, #apps do
    -- log.df(apps[i]:name())
    if apps[i]:name() == "zoom.us" then
      zoomIsRunning = true
      zoomWindowCount = #apps[i]:visibleWindows()
    end
  end
  log.df("zoomIsRunning %s zoomWindowCount %s", zoomIsRunning, zoomWindowCount)
  if zoomIsRunning and zoomWindowCount > 0 and not zoomIsFront then
    hs.application.launchOrFocus("zoom.us")
  else
    hs.application.launchOrFocus("Slack")
  end
end

function module.calendar()
  log.d("calendar")
  hs.application.launchOrFocus("Google Chrome")
  hs.eventtap.keyStroke({"command"}, "2")
end

function module.music()
  log.d("music")
  hs.application.launchOrFocus("Google Chrome")
  -- command-3 is my normal way to activate a pinned tab with
  -- google play music, but temporarily doing 4
  -- since I'm fascinated with mynoise.net at the moment
  hs.eventtap.keyStroke({"command"}, "4")
end

return module
