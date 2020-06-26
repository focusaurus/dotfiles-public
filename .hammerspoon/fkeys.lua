local log = hs.logger.new("fkeys", "debug")
local sound = require("sound")

local function iterm2() 
  log.d("fkeys f3")
  hs.application.launchOrFocus("iTerm")
end
hs.hotkey.bind({}, "f3", iterm2)

----- fkeys -----
hs.hotkey.bind({}, "f1", function()
  log.d("fkeys f1")
  hs.application.launchOrFocus("Google Chrome")
end)

hs.hotkey.bind({"shift"}, "f1", function()
  log.d("fkeys shift+f1")
  hs.application.launchOrFocus("Google Chrome")
  hs.eventtap.keyStroke({"command"}, "1")
end)

-- hs.hotkey.bind({}, "f2", function()
--   log.d("fkeys f2")
--   hs.application.launchOrFocus("Postman")
-- end)


hs.hotkey.bind({}, "f4", function()
  log.d("fkeys f4")
  hs.application.launchOrFocus("WorkFlowy")
end)

hs.hotkey.bind({}, "f5", function()
  log.d("fkeys f5")
  hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, true):post()
  hs.eventtap.event.newKeyEvent("Tab", true):post()
  -- hs.timer.doAfter(0.2, function()
    hs.eventtap.event.newKeyEvent("Tab", false):post()
    hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, false):post()
  -- end)
end)

hs.hotkey.bind({}, "f6", function()
  log.d("fkeys f6")
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
end)

hs.hotkey.bind({}, "f7", function()
  log.d("fkeys f7")
  hs.application.launchOrFocus("Google Chrome")
  hs.eventtap.keyStroke({"command"}, "2")
end)

hs.hotkey.bind({}, "f8", function()
  log.d("fkeys f8")
  hs.application.launchOrFocus("Google Chrome")
  -- command-3 is my normal way to activate a pinned tab with 
  -- google play music, but temporarily doing 4
  -- since I'm fascinated with mynoise.net at the moment
  hs.eventtap.keyStroke({"command"}, "4")
end)

hs.hotkey.bind({}, "f10", function()
  log.d("fkeys f10")
  sound.toggleMute()
end)

hs.hotkey.bind({}, "f11", function()
  log.d("fkeys f11")
  sound.volumeDown()
end)

hs.hotkey.bind({}, "f12", function()
  log.d("fkeys f12")
  sound.volumeUp()
end)
