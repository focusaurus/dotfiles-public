local module = {}
local log = hs.logger.new("placement", "debug")
local focus = require("focus")

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
  log.d("ratio" .. ratio)
  if ratio > 0.9 then
    -- Maximized already or nearly so, proceed to left
    module.left()
  else
    if f.x < 100 then
      -- pretty close to left edge, proceed to right
      module.right()
    else
      -- go to maximized in all other cases
      module.maximize()
    end
  end
end

function module.tidy()
  log.d("tidy")
  focus.emacs()
  module.right()
  focus.calendar()
  module.left()
  focus.browser()
  module.maximize()
  focus.terminal()
  module.maximize()
  focus.slack()
  module.maximize()
  focus.firefox()
  module.maximize()
end

return module
