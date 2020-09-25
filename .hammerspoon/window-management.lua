local log = hs.logger.new("window-management", "debug")
local Module = {}

----- window management -----
local function winScreenFrame()
  local win = hs.window.focusedWindow()
  return win, win:screen():frame(), win:frame()
end

function Module.maximize()
  log.d("maximize")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x
  f.y = screenFrame.y
  f.w = screenFrame.w
  f.h = screenFrame.h
  win:setFrame(f)
end
-- hs.hotkey.bind({"command", "shift"}, "m", Module.maximize)
--left hand top row "up"
-- hs.hotkey.bind({"option"}, ".", Module.maximize)
--left hand bottom row "up"
-- hs.hotkey.bind({"option"}, "j", Module.maximize)

function Module.left()
  log.d("left")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x
  f.y = screenFrame.y
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end

-- hs.hotkey.bind({"command", "shift"}, "l", left)
--left hand top row "left"
hs.hotkey.bind({"option"}, "'", Module.left)
--left hand bottom row "left"
-- hs.hotkey.bind({"option"}, ";", Module.left)

function Module.right()
  log.d("right")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.w / 2
  f.y = screenFrame.y
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end
-- hs.hotkey.bind({"command", "shift"}, "r", Module.right)
--left hand top row "right"
hs.hotkey.bind({"option"}, "p", Module.right)
--left hand bottom row "right"
-- hs.hotkey.bind({"option"}, "k", Module.right)

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

function Module.cycle()
  log.d("cycle")
  win, screenFrame, f =  winScreenFrame()
  ratio = f.w / screenFrame.w
  -- hs.alert.show("cycle" .. ratio)
  if ratio > 0.95 then
    Module.left()
  else if ratio < 0.55 then
    if f.x < 100 then
      Module.right()
    else
      Module.maximize()
    end
  end
end
end
-- hs.hotkey.bind({"shift"}, "f1", Module.cycle)
hs.hotkey.bind({"option"}, "c", Module.cycle)

return Module
