local module = {}
local log = hs.logger.new("sound", "debug")

function module.toggleMute()
  log.d("toggleMute")
  local device = hs.audiodevice.defaultOutputDevice()
  device:setMuted(not device:muted())
end

function module.volumeDown()
  log.d("volumeDown")
  local device = hs.audiodevice.defaultOutputDevice()
  local level = math.floor(device:volume() - 10)
  if level < 0 then level = 0 end
  log.df("volume %s", level)
  hs.alert("volume " .. level)
  device:setVolume(level)
end

function module.volumeUp()
  log.d("volumeUp")
  local device = hs.audiodevice.defaultOutputDevice()
  local level = math.floor(device:volume() + 10)
  if level > 100 then level = 100 end
  log.df("volume %s", level)
  hs.alert("volume " .. level)
  device:setVolume(level)
end

function module.setVolume(value)
  hs.audiodevice.current().device:setVolume(value)
end

return module
