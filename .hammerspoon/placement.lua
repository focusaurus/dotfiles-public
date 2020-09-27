local log = hs.logger.new("placement", "debug")
local module = {}

local function winScreenFrame()
  local win = hs.window.focusedWindow()
  return win, win:screen():frame(), win:frame()
end

function module.maximize()
  log.d("maximize")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x
  f.y = screenFrame.y
  f.w = screenFrame.w
  f.h = screenFrame.h
  win:setFrame(f)
end

function module.left()
  log.d("left")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.x
  f.y = screenFrame.y
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end

function module.right()
  log.d("right")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.w / 2
  f.y = screenFrame.y
  f.w = screenFrame.w / 2
  f.h = screenFrame.h
  win:setFrame(f)
end

function module.bottomRight()
  log.d("bottomRight")
  win, screenFrame, f = winScreenFrame()
  f.x = screenFrame.w / 2
  f.w = f.x
  f.y = (screenFrame.h / 2) + (screenFrame.y / 2)
  f.h = f.y
  win:setFrame(f)
end

function module.cycle()
  log.d("cycle")
  win, screenFrame, f =  winScreenFrame()
  ratio = f.w / screenFrame.w
  if ratio > 0.95 then
    module.left()
  else if ratio < 0.55 then
    if f.x < 100 then
      module.right()
    else
      module.maximize()
    end
  end
  end
end

return module
