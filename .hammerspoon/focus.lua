local module = {}
local log = hs.logger.new("focus", "debug")
local focusMode = false
local hbin = os.getenv("HOME") .. "/bin"
local browserName = "Google Chrome"

-- function findWindow(appName, filter)
--   log.d('findWindow')
--   for _, window in pairs(filter:getWindows()) do
--     log.d("findWindow: title: " .. window:title())
--     if window:application():name() == appName then
--       return window
--     end
--   end
-- end
--
-- -- Sigh. Hammerspoon window filters are unusably slow.
-- We have to cache the results or hammerspoon locks up
-- local filterBrowserMain = hs.window.filter.new():setAppFilter(
--   browserName,{rejectTitles={"YouTube Music", "- Calendar -"}})
local windowBrowserMain

-- function module.findBrowserMain()
--   log.d('findBrowserMain')
--   windowBrowserMain = findWindow(browserName, filterBrowserMain)
-- end
--

-- function module.browserByName()
--   log.d("browserByName")
--   hs.application.launchOrFocus(browserName)
-- end
--

-- function module.browserWindowFilter()
--   log.d("browserWindowFilter")
--   for _, window in pairs(filterBrowserMain:getWindows()) do
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
--   if windowBrowserMain == nil then
--     module.scanWindows()
--   end
--   if windowBrowserMain ~= nil then
--     windowBrowserMain:focus()
--   end
-- end
--

-- function module.browserByFilterCache()
--   if windowBrowserMain == nil then
--     windowBrowserMain = findWindow(browserName, filterBrowserMain)
--   end
--   if windowBrowserMain == nil then
--     -- if we get here, we didn't find any windows, launch the app
--     hs.application.launchOrFocus(browserName)
--   else
--     windowBrowserMain:focus()
--   end
-- end

function module.cycleByHotkey()
  hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, true):post()
  hs.eventtap.event.newKeyEvent("`", true):post()
  hs.timer.doAfter(0.2, function()
    hs.eventtap.event.newKeyEvent("`", false):post()
    hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, false):post()
  end)
end

function module.cycleByFilter()
  app = hs.window.frontmostWindow():application()
  print("app name " .. app:name())
  windows = hs.window.filter.new({ app:name() }):getWindows(hs.window.filter.sortByFocusedLast)
  print("windows length: " .. #windows)
  windows[#windows]:focus()
end

module.cycleWindows = module.cycleByFilter

function module.browserMainByTitleCache()
  if windowBrowserMain == nil then
    windowBrowserMain = module.findWindowByTitle(browserName, "main")
  end
  if windowBrowserMain == nil then
    -- if we get here, we didn't find any windows, launch the app
    hs.application.launchOrFocus(browserName)
  else
    windowBrowserMain:focus()
  end
end

local windowBrowserIntuit
function module.browserIntuitByTitleCache()
  if windowBrowserIntuit == nil then
    windowBrowserIntuit = module.findWindowByTitle(browserName, "intuit")
  end
  if windowBrowserIntuit == nil then
    -- if we get here, we didn't find any windows, launch the app
    hs.application.launchOrFocus(browserName)
  else
    windowBrowserIntuit:focus()
  end
end

function module.firefox()
  log.d("firefox")
  hs.application.launchOrFocus("Firefox")
end

function module.obsidian()
  log.d("obsidian")
  hs.application.launchOrFocus("Obsidian")
end

local filterGofi = hs.window.filter.new(true) --:allowApp("gofi")
function module.gofiByTitle()
  log.d("gofiByTitle 2")
  for _, window in pairs(filterGofi:getWindows()) do
    log.d(window:application():name() .. ": " .. window:title())
    if window:application():name() == "kitty" then
      window:focus()
      -- break
    end
  end
  -- if we get here, we didn't find any windows, launch the app
  -- TODO
end

module.gofi = module.gofiByTitle
module.leader = module.gofi

-- I have had many implementations of this.
-- So I keep the function names in the module describing
-- the specific implementation approach, but in the module's
-- external API, alias it as just the intent.
module.browserIntuit = module.browserIntuitByTitleCache
module.browser = module.firefox

local windowCalendar
-- filterCalendar = hs.window.filter.new():setAppFilter(browserName, {allowTitles="- Calendar -"})

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

-- function module.calendarByFilterCache()
--   if windowCalendar == nil then
--     windowCalendar = findWindow(browserName, filterCalendar)
--   end
--   if windowCalendar == nil then
--     -- if we get here, we didn't find any windows, launch the app
--     hs.application.launchOrFocus(browserName)
--   else
--     windowCalendar:focus()
--   end
-- end

function module.calendarByTitleCache()
  if windowCalendar == nil then
    windowCalendar = module.findWindowByTitle(browserName, "calendar")
  end
  if windowCalendar == nil then
    -- if we get here, we didn't find any windows, launch the app
    hs.application.launchOrFocus(browserName)
  else
    windowCalendar:focus()
  end
end

-- I have had many implementations of this.
-- So I keep the function names in the module describing
-- the specific implementation approach, but in the module's
-- external API, alias it as just the intent.
module.calendar = module.calendarByTitleCache

-- filterMusic = hs.window.filter.new():setAppFilter(browserName,{allowTitles="YouTube Music"})
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

-- function module.musicByFilterCache()
--   if windowMusic == nil then
--     windowMusic = findWindow(browserName, filterMusic)
--   end
--   if windowMusic == nil then
--     -- if we get here, we didn't find any windows, launch the app
--     hs.application.launchOrFocus(browserName)
--   else
--     windowMusic:focus()
--   end
-- end
--

function module.musicByTitleCache()
  if windowMusic == nil then
    windowMusic = module.findWindowByTitle(browserName, "music")
  end
  if windowMusic == nil then
    -- if we get here, we didn't find any windows, launch the app
    hs.application.launchOrFocus(browserName)
  else
    windowMusic:focus()
  end
end

-- I have had many implementations of this.
-- So I keep the function names in the module describing
-- the specific implementation approach, but in the module's
-- external API, alias it as just the intent.
module.music = module.musicByTitleCache

function module.clearWindowCache()
  windowCalendar = nil
  windowMusic = nil
  windowBrowserMain = nil
  windowBrowserIntuit = nil
end

-- function onAppEvent(appName, eventType, app)
--   -- print("onAppEvent: " .. (appName or "nil") .. ", " .. eventType )
--   if appName == browserName and eventType == hs.application.watcher.terminated then
--     log.d(browserName .. " was quit. Clearing window cache.")
--     module.clearWindowCache()
--   end
-- end

-- function module.initAppWatcher()
--   hs.application.watcher.new(onAppEvent):start()
-- end

function module.enableFocusMode()
  print("enableFocusMode")
  focusMode = true
end

function module.disableFocusMode()
  print("disableFocusMode")
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
  if focusMode then
    return
  end
  local workWindow = module.byTitlePrefix("work-float")
  if workWindow ~= nil then
    workWindow.focus()
  else
    module.browser()
  end
  hs.eventtap.keyStroke({ "command" }, "1")
end

function module.calendarTab()
  log.d("calendarTab")
  if focusMode then
    return
  end
  module.browser()
  hs.eventtap.keyStroke({ "command" }, "2")
end

-- For Safari "Add to Dock" site specific browser macos 14 feature
function module.calendarDock()
  log.d("calendarDock")
  if focusMode then
    return
  end
  hs.application.launchOrFocus("Google Calendar")
end

module.calendar = module.calendarDock

function module.emacs()
  log.d("emacs")
  hs.application.launchOrFocus("Emacs")
end

function module.code()
  log.d("code")
  hs.application.launchOrFocus("Visual Studio Code")
end

local function startsWith(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

local function hasTitlePrefix(prefix)
  return function(window)
    -- log.d("window title prefix check " .. prefix .. ": " .. window:title())
    return startsWith(window:title(), prefix)
  end
end

function module.byTitlePrefix(prefix)
  local match = hs.window.filter.new(hasTitlePrefix(prefix)):getWindows(hs.window.filter.sortByFocusedLast)[1]
  if match ~= nil then
    match:focus()
  end
  return match
end

function module.previousWindowByFilter()
  log.d("previousWindowByFilter")
  local lastWindow = hs.window.filter.default:getWindows()[2]
  if lastWindow == nil then
    return
  end
  log.d("Previous: " .. lastWindow:title())
  lastWindow:focus()
end

module.previousWindow = module.previousWindowByFilter

function module.previousAppByFilter()
  log.d("previousAppByFilter")
  local currentAppName = ""
  local win = hs.window.focusedWindow()
  if win ~= nil then
    currentAppName = win:application():name()
  end
  for _, window in ipairs(hs.window.filter.default:getWindows()) do
    if window ~= nil and currentAppName ~= window:application():name() then
      log.d("previousAppByFilter: " .. window:title())
      window:focus()
      return
    end
  end
end

function module.previousAppByHotkey()
  -- hs.eventtap.event.newKeyEvent({ "cmd" }, "Tab", true):post()
  -- hs.eventtap.event.newKeyEvent({"shift", "alt"}, "a", false):post()
  -- Since I trigger this with home row mod on "a" (left pinky),
  -- the first thing I need to do is send a key up for "a" so
  -- the command+tab is interpretted correctly by macos
  -- hs.eventtap.event.newKeyEvent("e", false):post()
  if true then
    hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, true):post()
    hs.eventtap.event.newKeyEvent("Tab", true):post()
    hs.timer.doAfter(0.2, function()
      -- hs.eventtap.event.newKeyEvent({"cmd" }, "Tab", false):post()
      hs.eventtap.event.newKeyEvent("Tab", false):post()
      hs.eventtap.event.newKeyEvent(hs.keycodes.map.cmd, false):post()
    end)
  end
end

module.previousApp = module.previousAppByFilter

function module.slack()
  log.d("slack")
  print("slack focus mode ", focusMode)
  if focusMode then
    return
  end
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

-- Begin Window List Cache

-------------------------------
-- select window by title
windowsByFocus = hs.window.filter.new()
windowsByFocus:setDefaultFilter({})
windowsByFocus:setSortOrder(hs.window.filter.sortByFocusedLast)
local currentWindows = {}

function module.refreshWindowCache()
  currentWindows = {}
  for _, v in ipairs(windowsByFocus:getWindows()) do
    table.insert(currentWindows, v)
  end
end

module.refreshWindowCache()

function module.findWindowByTitle(appName, windowTitle)
  for _, window in ipairs(currentWindows) do
    print("findWindowByTitle: query: " .. windowTitle .. " window: " .. window:title())
    if string.find(window:application():name(), appName) and string.find(window:title(), windowTitle) then
      return window
    end
  end
  return nil
end

-- function module.focusByTitle(t)
--    w = module.findWindowByTitle(t)
--    if w then
--       w:focus()
--    end
--    return w
-- end

-- function module.focusByApp(appName)
--    print(' [' .. appName ..']')
--    for _,v in ipairs(currentWindows) do
--       print('           [' .. v:application():name() .. ']')
--       if string.find(v:application():name(), appName) then
--          print("Focusing window" .. v:title())
--          v:focus()
--          return v
--       end
--    end
--    return nil
-- end
--

local function callbackWindowCreated(w, appName, event)
  if event == "windowDestroyed" then
    --      print("deleting from windows-----------------", w)
    for i, v in ipairs(currentWindows) do
      if v == w then
        table.remove(currentWindows, i)
        return
      end
    end
    --      print("Not found .................. ", w)
    --      print("Not found ............ :()", w)
    return
  end
  if event == "windowCreated" then
    --      print("inserting into windows.........", w)
    table.insert(currentWindows, 1, w)
    return
  end
  if event == "windowFocused" then
    --otherwise is equivalent to delete and then create
    callbackWindowCreated(w, appName, "windowDestroyed")
    callbackWindowCreated(w, appName, "windowCreated")
  end
end
windowsByFocus:subscribe(hs.window.filter.windowCreated, callbackWindowCreated)
windowsByFocus:subscribe(hs.window.filter.windowDestroyed, callbackWindowCreated)
windowsByFocus:subscribe(hs.window.filter.windowFocused, callbackWindowCreated)

local function listWindowChoices()
  local windowChoices = {}
  --   for i,v in ipairs(windowsByFocus:getWindows()) do
  for i, w in ipairs(currentWindows) do
    if w ~= hs.window.focusedWindow() then
      table.insert(windowChoices, {
        text = w:title() .. "--" .. w:application():name(),
        subText = w:application():name(),
        uuid = i,
        image = hs.image.imageFromAppBundle(w:application():bundleID()),
        win = w,
      })
    end
  end
  return windowChoices
end

local windowChooser = hs.chooser.new(function(choice)
  if not choice then
    hs.alert.show("Nothing to focus")
    return
  end
  local v = choice["win"]
  if v then
    v:focus()
  else
    hs.alert.show("unable fo focus " .. name)
  end
end)

function module.showWindowChooser()
  local windowChoices = listWindowChoices()
  windowChooser:choices(windowChoices)
  --windowChooser:placeholderText('')
  windowChooser:rows(12)
  windowChooser:query(nil)
  windowChooser:show()
end

-- End Window List Cache

return module
