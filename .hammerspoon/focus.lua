local module = {}
local log = hs.logger.new("focus", "debug")
local focusMode = require("focus-mode")
local wf = hs.window.filter.new()

local hbin = os.getenv("HOME") .. "/bin"
local browserName = "Google Chrome"

function module.terminal()
  log.d("terminal")
  hs.application.launchOrFocus("kitty")
end

function module.terminalQuick()
  log.d("terminalQuick")
  hs.execute(hbin .. "/terminal-quick", true)
end

function module.browser1()
  log.d("browser1")
  hs.application.launchOrFocus(browserName)
end

generalBrowser = hs.window.filter.new():setAppFilter(browserName,{rejectTitles={"YouTube Music", "- Calendar -"}})
function module.browser()
  log.d("browser")
  for _, window in pairs(generalBrowser:getWindows()) do
    if window:application():name() == browserName then
      log.d(window:title())
      window:focus()
      break
    end
  end
  -- if we get here, we didn't find any windows, launch the app
  hs.application.launchOrFocus(browserName)
end

function module.email()
  log.d("email")
  if focusMode then return end
  module.browser()
  hs.eventtap.keyStroke({"command"}, "1")
end

function module.emacs()
  log.d("emacs")
  hs.application.launchOrFocus("Emacs")
end

function module.code()
  log.d("code")
  hs.application.launchOrFocus("Visual Studio Code")
end


function module.workflowy()
  log.d("workflowy")
  hs.application.launchOrFocus("WorkFlowy")
end

function module.previous()
  log.d("previous")
  lastWindow = wf:getWindows(wf.sortByFocusedLast)[2]
  if lastWindow == nil then return end
  log.d("Previous: " .. lastWindow:title())
  lastWindow:focus()

  -- hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, true):post()
  -- hs.eventtap.event.newKeyEvent("Tab", true):post()
  -- hs.timer.doAfter(0.2, function()
  --   hs.eventtap.event.newKeyEvent("Tab", false):post()
  --   hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, false):post()
  -- end)
end

function module.slack()
  log.d("slack")
  if focusMode then return end
  hs.application.launchOrFocus("Slack")
end

-- function module.slackOrZoom()
--   log.d("slackOrZoom")
--   if focusMode then return end
--   local zoomIsFront = hs.window.frontmostWindow():application():name() == "zoom.us"
--   local zoomIsRunning = false
--   -- window count > 1 used as a proxy for "has active meeting window"
--   local zoomWindowCount = 0
--   local apps = hs.application.runningApplications()
--   for i = 1, #apps do
--     -- log.df(apps[i]:name())
--     if apps[i]:name() == "zoom.us" then
--       zoomIsRunning = true
--       zoomWindowCount = #apps[i]:visibleWindows()
--     end
--   end
--   log.df("zoomIsRunning %s zoomWindowCount %s", zoomIsRunning, zoomWindowCount)
--   if zoomIsRunning and zoomWindowCount > 0 and not zoomIsFront then
--     hs.application.launchOrFocus("zoom.us")
--   else
--     hs.application.launchOrFocus("Slack")
--   end
-- end

function module.calendar1()
  log.d("calendar1")
  hs.application.launchOrFocus("Google Calendar")
  -- hs.eventtap.keyStroke({"command"}, "2")
end

musicFilter = hs.window.filter.new():setAppFilter(browserName,{allowTitles="YouTube Music"})
function module.music()
  log.d("music")
  for _, window in pairs(musicFilter:getWindows()) do
    if window:application():name() == browserName then
      log.d(window:title())
      window:focus()
      break
    end
  end
  -- if we get here, we didn't find any windows, launch the app
  hs.application.launchOrFocus(browserName)
end

function module.music1()
  log.d("music1")
  hs.application.launchOrFocus("YouTube Music")
  -- hs.application.launchOrFocus("Google Chrome")
  -- hs.eventtap.keyStroke({"command"}, "3")
end

calendarFilter = hs.window.filter.new():setAppFilter(browserName,{allowTitles="- Calendar -"})
function module.calendar()
  log.d("calendar")
  for _, window in pairs(calendarFilter:getWindows()) do
    if window:application():name() == browserName then
      log.d(window:title())
      window:focus()
      break
    end
  end
  -- if we get here, we didn't find any windows, launch the app
  hs.application.launchOrFocus(browserName)
end

return module
