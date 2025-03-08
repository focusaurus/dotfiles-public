local module = {}
local log = hs.logger.new("mpd", "debug")

local function mpc(action)
  hs.execute("mpc --host=tool.home.peterlyons.org " .. action, true)
end

function module.toggle()
  log.d("toggle")
  mpc("toggle")
end

function module.play()
  log.d("play")
  mpc("play")
end

function module.pause()
  log.d("pause")
  mpc("pause")
end

return module
