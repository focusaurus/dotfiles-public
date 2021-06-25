local module = {}
local log = hs.logger.new("focus", "debug")
local focusMode = false
local hbin = os.getenv("HOME") .. "/bin"
local browserName = "Google Chrome"

function findWindow(appName, filter)
  log.d('findWindow')
  for _, window in pairs(filter:getWindows()) do
    log.d("findWindow: title: " .. window:title())
    if window:application():name() == appName then
      return window
    end
  end
end

-- Sigh. Hammerspoon window filters are unusably slow.
-- We have to cache the results or hammerspoon locks up
local filterBrowserGeneral = hs.window.filter.new():setAppFilter(
  browserName,{rejectTitles={"YouTube Music", "- Calendar -"}})
local windowBrowserGeneral

-- function module.findBrowserGeneral()
--   log.d('findBrowserGeneral')
--   windowBrowserGeneral = findWindow(browserName, filterBrowserGeneral)
-- end
--

-- function module.browserByName()
--   log.d("browserByName")
--   hs.application.launchOrFocus(browserName)
-- end
--

-- function module.browserWindowFilter()
--   log.d("browserWindowFilter")
--   for _, window in pairs(filterBrowserGeneral:getWindows()) do
--     if window:application():name() == browserName then
--       log.d(window:title())
--       window:focus()
--       break
--     end
--   end
--   -- if we get here, we didn't find any windows, launch the app
--   hs.application.launchOrFocus(browserName)
-- end
--

-- function module.browserByScan()
--   if windowBrowserGeneral == nil then
--     module.scanWindows()
--   end
--   if windowBrowserGeneral ~= nil then
--     windowBrowserGeneral:focus()
--   end
-- end
--

function module.browserByFilterCache()
  if windowBrowserGeneral == nil then
    windowBrowserGeneral = findWindow(browserName, filterBrowserGeneral)
  end
  if windowBrowserGeneral == nil then
    -- if we get here, we didn't find any windows, launch the app
    hs.application.launchOrFocus(browserName)
  else
    windowBrowserGeneral:focus()
  end
end

module.browser = module.browserByFilterCache

local windowCalendar
filterCalendar = hs.window.filter.new():setAppFilter(browserName, {allowTitles="- Calendar -"})

-- function module.calendarByName()
--   log.d("calendaByName")
--   hs.application.launchOrFocus("Google Calendar")
-- end
--

-- function module.calendarByWindowMenu()
--   log.d("calendarWindowMenu")
--   hs.application.launchOrFocus(browserName)
--   result = hs.application.get(browserName):selectMenuItem(".*Science.*", true)
--   log.d("result" .. (result or ""))
-- end

-- function module.calendarByFilter()
--   log.d("calendarFilter")
--   for _, window in pairs(filterCalendar:getWindows()) do
--     if window:application():name() == browserName then
--       log.d(window:title())
--       window:focus()
--       break
--     end
--   end
--   -- if we get here, we didn't find any windows, launch the app
--   hs.application.launchOrFocus(browserName)
-- end

function module.calendarByFilterCache()
  if windowCalendar == nil then
    windowCalendar = findWindow(browserName, filterCalendar)
  end
  if windowCalendar == nil then
    -- if we get here, we didn't find any windows, launch the app
    hs.application.launchOrFocus(browserName)
  else
    windowCalendar:focus()
  end
end

module.calendar = module.calendarByFilterCache

filterMusic = hs.window.filter.new():setAppFilter(browserName,{allowTitles="YouTube Music"})
local windowMusic

-- function module.musicWindowFilter()
--   log.d("music")
--   for _, window in pairs(filterMusic:getWindows()) do
--     if window:application():name() == browserName then
--       log.d(window:title())
--       window:focus()
--       break
--     end
--   end
--   -- if we get here, we didn't find any windows, launch the app
--   hs.application.launchOrFocus(browserName)
-- end

-- function module.musicApp()
--   log.d("music1")
--   hs.application.launchOrFocus("YouTube Music")
--   -- hs.application.launchOrFocus("Google Chrome")
--   -- hs.eventtap.keyStroke({"command"}, "3")
-- end

-- function module.musicWindowMenu()
--   log.d("musicWindowMenu")
--   hs.application.launchOrFocus(browserName)
--   hs.application.get(browserName):selectMenuItem("^YouTube Music", true)
-- end

function module.musicByFilterCache()
  if windowMusic == nil then
    windowMusic = findWindow(browserName, filterMusic)
  end
  if windowMusic == nil then
    -- if we get here, we didn't find any windows, launch the app
    hs.application.launchOrFocus(browserName)
  else
    windowMusic:focus()
  end
end

module.music = module.musicByFilterCache

function module.clearWindowCache()
  windowCalendar = nil
  windowMusic = nil
  windowBrowserGeneral = nil
end

function module.enableFocusMode()
  focusMode = true
end

function module.disableFocusMode()
  focusMode = false
end

function module.terminal()
  log.d("terminal")
  hs.application.launchOrFocus("kitty")
end

function module.terminalQuick()
  log.d("terminalQuick")
  hs.execute(hbin .. "/terminal-quick", true)
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

function module.previousByWindowFilter()
  log.d("previous")
  lastWindow = hs.window.filter.default:getWindows()[2]
  if lastWindow == nil then return end
  log.d("Previous: " .. lastWindow:title())
  lastWindow:focus()
end

function module.previousByHotkey()
  -- hs.eventtap.event.newKeyEvent({"cmd" }, "Tab", true):post()
  -- hs.eventtap.event.newKeyEvent({"shift", "alt"}, "a", false):post()
  hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, true):post()
  hs.eventtap.event.newKeyEvent("Tab", true):post()
  hs.timer.doAfter(0.2, function()
    -- hs.eventtap.event.newKeyEvent({"cmd" }, "Tab", false):post()
    hs.eventtap.event.newKeyEvent("Tab", false):post()
    hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, false):post()
  end)
end

module.previous = module.previousByHotkey

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

return module
