local module = {}
local log = hs.logger.new("mpd", "debug")

local function mpc(action)
  -- need to use an IP instead of hostname here so this works even
  -- when work VPN is connected.
  -- Also had to directly add a route:
  -- sudo route -n add 10.9.8.121 10.9.8.1
  hs.execute("mpc --host=10.9.8.121 " .. action, true)
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
