
----- hammerspoon debugging -----
hs.hotkey.bind({"control"}, "2", function()
  hs.alert(hs.application.frontmostApplication():selectMenuItem(".* - Google Play Music$", true))
end)

local log = hs.logger.new("main", "debug")
local hbin = "/Users/peterlyons/bin"

----- window management -----
local function winScreenFrame() 
  local win = hs.window.focusedWindow()
  return win, win:screen():frame(), win:frame()
end

local function maximize() 
  log.d("maximize")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x
  f.y = screenFrame.y 
  f.w = screenFrame.w
  f.h = screenFrame.h
  win:setFrame(f)
end
hs.hotkey.bind({"command", "shift"}, "m", maximize)
--right hand home row "up"
hs.hotkey.bind({"option"}, "n", maximize)
--left hand bottom row "up"
hs.hotkey.bind({"option"}, "j", maximize)

local function left()
  log.d("left")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end

hs.hotkey.bind({"command", "shift"}, "l", left)
--right hand home row "left"
hs.hotkey.bind({"option"}, "h", left)
--left hand bottom row "left"
hs.hotkey.bind({"option"}, ";", left)

local function right()
  log.d("right")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.w / 2 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end
hs.hotkey.bind({"command", "shift"}, "r", right)
--right hand home row "right"
hs.hotkey.bind({"option"}, "s", right)
--left hand bottom row "right"
hs.hotkey.bind({"option"}, "k", right)

local function iterm2() 
  log.d("fkeys f3")
  hs.application.launchOrFocus("iTerm")
end
hs.hotkey.bind({}, "f3", iterm2)

----- journal -----
local function journalVim() 
  log.d("journalVim")
  iterm2()
  hs.timer.doAfter(0.2, function()
    hs.eventtap.keyStroke({"command", "control"}, "j")
  end)
end
hs.hotkey.bind({"command"}, "j", journalVim)

local function journalDialog() 
  log.d("journalDialog")
  os.execute(hbin .. "/fuzz-script-exec ~/projects/dotfiles/fuzzball journal-mailchimp")
end


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
  local zoomIsRunning = false
  local apps = hs.application.runningApplications()
  for i = 1, #apps do
    -- log.df(apps[i]:name())
    if apps[i]:name() == "zoom.us" then
      zoomIsRunning = true
    end
  end
  -- log.df("zoomIsRunning %s", zoomIsRunning)
  if zoomIsRunning then
    if hs.window.frontmostWindow():application():name() == "zoom.us" then
      hs.application.launchOrFocus("Slack")
    else
      hs.application.launchOrFocus("zoom.us")
    end
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
  hs.eventtap.keyStroke({"command"}, "3")
end)

hs.hotkey.bind({}, "f9", journalDialog)

-- sound: toggle mute output
hs.hotkey.bind({}, "f10", function()
  log.d("fkeys f9")
  local device = hs.audiodevice.defaultOutputDevice()
  device:setMuted(not device:muted())
end)

-- decrease volume
hs.hotkey.bind({}, "f11", function()
  log.d("fkeys f11")
  local device = hs.audiodevice.defaultOutputDevice()
  local level = device:volume() - 10
  if level < 0 then level = 0 end
  device:setVolume(level)
end)

-- increase volume
hs.hotkey.bind({}, "f12", function()
  log.d("fkeys f12")
  local device = hs.audiodevice.defaultOutputDevice()
  local level = device:volume() + 10
  log.f("increase volume %s", level)
  if level > 100 then level = 100 end
  device:setVolume(level)
end)

----- snippets -----
hs.hotkey.bind({"control"}, ",", function()
  log.d("snippets")
  ok, result = hs.applescript("do shell script \"" .. hbin .. "/fuzz-snippet\"")
  if ok then
    hs.pasteboard.setContents(result)
    hs.eventtap.keyStroke({"command"}, "v")
  else
    log.d("snippet cancelled" .. result)
  end
end)

----- fuzzball scripts -----
hs.hotkey.bind({"command"}, "Space", function()
  log.d("fuzzball script")
  os.execute(hbin .. "/fuzz-script-choose")
end)

----- application navigation -----
-- left
hs.hotkey.bind({"option"}, "a", function ()
  log.d("app-nav left")
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux previous-window")
  elseif name == "Google Chrome" or name == "Code" then
    hs.eventtap.keyStroke({"control", "shift"}, "Tab")
  end
end)

-- down
hs.hotkey.bind({"option"}, "o", function ()
  log.d("app-nav down")
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux switch-client -n")
  elseif name == "Google Chrome" then
    hs.eventtap.keyStroke({}, "PageDown")
  end
end)

-- up
hs.hotkey.bind({"option"}, "e", function ()
  log.d("app-nav up")
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux select-pane -l")
  elseif name == "Google Chrome" then
    hs.eventtap.keyStroke({}, "Home")
  end
end)

-- right
hs.hotkey.bind({"option"}, "u", function ()
  log.d("app-nav right")
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux next-window")
  elseif name == "Google Chrome" or name == "Code" then
    hs.eventtap.keyStroke({"control"}, "Tab")
  end
end)


----- autotype sign in -----
hs.urlevent.bind("autotypeSignIn", function(eventName, params)
    hs.eventtap.keyStrokes(params.u)
    hs.eventtap.keyStroke({}, "Tab")
    hs.eventtap.keyStrokes(params.p)
end)

----- hammerspoon config reloading -----
function reloadConfig(files)
  log.d("reloadConfig")
    local doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config reloaded")
