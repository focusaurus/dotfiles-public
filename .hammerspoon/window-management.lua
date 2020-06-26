local log = hs.logger.new("window-management", "debug")
local Module = {}

----- window management -----
local function winScreenFrame() 
  local win = hs.window.focusedWindow()
  return win, win:screen():frame(), win:frame()
end

function maximize() 
  log.d("maximize")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x
  f.y = screenFrame.y 
  f.w = screenFrame.w
  f.h = screenFrame.h
  win:setFrame(f)
end
-- hs.hotkey.bind({"command", "shift"}, "m", maximize)
--right hand home row "up"
hs.hotkey.bind({"option"}, "n", maximize)
--left hand bottom row "up"
-- hs.hotkey.bind({"option"}, "j", maximize)

function left()
  log.d("left")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end

-- hs.hotkey.bind({"command", "shift"}, "l", left)
--right hand home row "left"
hs.hotkey.bind({"option"}, "h", left)
--left hand bottom row "left"
-- hs.hotkey.bind({"option"}, ";", left)

function right()
  log.d("right")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.w / 2 
  f.y = screenFrame.y 
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end
-- hs.hotkey.bind({"command", "shift"}, "r", right)
--right hand home row "right"
hs.hotkey.bind({"option"}, "s", right)
--left hand bottom row "right"
-- hs.hotkey.bind({"option"}, "k", right)

function Module.bottomRight()
  log.d("bottomRight")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.w / 2
  f.w = f.x
  f.y = (screenFrame.h / 2) + (screenFrame.y / 2)
  f.h = f.y
  -- hs.alert.show("x=" .. screenFrame.x .. "y=" ..screenFrame.y .. "w=" .. screenFrame.w .. "h=" .. screenFrame.h)
  win:setFrame(f)
end
hs.hotkey.bind({"command", "shift"}, "b", Module.bottomRight)

return Module
