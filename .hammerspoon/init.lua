local hbin = "/Users/peterlyons/bin"
local function winScreenFrame() 
  local win = hs.window.focusedWindow()
  return win, win:screen():frame(), win:frame()
end
----- maximize -----
hs.hotkey.bind({"cmd", "shift"}, "m", function()
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x
  f.y = screenFrame.y 
  f.w = screenFrame.w
  f.h = screenFrame.h
  win:setFrame(f)
end)

----- left half -----
hs.hotkey.bind({"cmd", "shift"}, "l", function()
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end)

----- right half -----
hs.hotkey.bind({"cmd", "shift"}, "r", function()
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.w / 2 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end)

----- fkeys -----
hs.hotkey.bind({}, "f1", function()
  hs.application.launchOrFocus("Google Chrome")
end)
hs.hotkey.bind({"shift"}, "f1", function()
  hs.application.launchOrFocus("Google Chrome")
  hs.eventtap.keyStroke({"cmd"}, "1",50)
end)
hs.hotkey.bind({}, "f3", function()
  hs.application.launchOrFocus("iTerm")
end)
hs.hotkey.bind({}, "f4", function()
  hs.application.launchOrFocus("WorkFlowy")
end)
hs.hotkey.bind({}, "f6", function()
  hs.application.launchOrFocus("Slack")
end)
hs.hotkey.bind({}, "f7", function()
  hs.application.launchOrFocus("Google Chrome")
  hs.eventtap.keyStroke({"cmd"}, "2",50)
end)

----- snippets -----
hs.hotkey.bind({"control"}, ".", function()
  ok, result = hs.applescript("do shell script \"" .. hbin .. "/fuzz-snippet\"")
  -- TODO log error
  hs.pasteboard.setContents(result)
  hs.eventtap.keyStroke({"cmd"}, "v",50)
end)

----- fuzzball scripts -----
hs.hotkey.bind({"command"}, "Space", function()
  os.execute(hbin .. "/fuzz-script-choose")
end)

----- application navigation -----
-- left
hs.hotkey.bind({"option"}, "a", function ()
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux previous-window")
  elseif name == "Google Chrome" or name == "Code" then
    hs.eventtap.keyStroke({"control", "shift"}, "Tab", 25)
  end
end)

-- down
hs.hotkey.bind({"option"}, "o", function ()
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux switch-client -n")
  elseif name == "Google Chrome" then
    hs.eventtap.keyStroke({}, "PageDown", 25)
  end
end)

-- up
hs.hotkey.bind({"option"}, "e", function ()
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux select-pane -l")
  elseif name == "Google Chrome" then
    hs.eventtap.keyStroke({}, "Home", 25)
  end
end)

-- right
hs.hotkey.bind({"option"}, "u", function ()
  name = hs.application.frontmostApplication():name()
  if name == "iTerm2" then
    os.execute("/usr/local/bin/tmux next-window")
  elseif name == "Google Chrome" or name == "Code" then
    hs.eventtap.keyStroke({"control"}, "Tab", 25)
  end
end)
