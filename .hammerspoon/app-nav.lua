local log = hs.logger.new("app-nav", "debug")

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
