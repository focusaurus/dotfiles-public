hs.hotkey.bind({"cmd", "shift"}, "m", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screenFrame = win:screen():frame()
  f.x = screenFrame.x
  f.y = screenFrame.y 
  f.w = screenFrame.w
  f.h = screenFrame.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "shift"}, "l", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screenFrame = win:screen():frame()
  f.x = screenFrame.x 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "shift"}, "r", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screenFrame = win:screen():frame()
  f.x = screenFrame.w / 2 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end)
