local module = {}
local log = hs.logger.new("mpd", "debug")
local hostArg = "--host=tool.home.peterlyons.org"

function module.toggle()
  log.d("toggle")
  hs.execute([["mpc" "--host=tool.home.peterlyons.org" "toggle"]], true)
end

function module.play()
  log.d("play")
  hs.execute([["mpc" "--host=home.peterlyons.org" "play"]], true)
end

function module.pause()
  log.d("pause")
  hs.execute([["mpc" "--host=tool.home.peterlyons.org" "pause"]], true)
end



return module
