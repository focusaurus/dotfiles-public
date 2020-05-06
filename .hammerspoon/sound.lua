local log = hs.logger.new("sound", "debug")

-- sound: toggle mute output
hs.hotkey.bind({}, "f10", function()
  log.d("fkeys f9")
  local device = hs.audiodevice.defaultOutputDevice()
  device:setMuted(not device:muted())
end)

-- decrease volume
hs.hotkey.bind({}, "f11", function()
  log.d("fkeys f11")
  local device = hs.audiodevice.defaultOutputDevice()
  local level = device:volume() - 10
  if level < 0 then level = 0 end
  device:setVolume(level)
end)

-- increase volume
hs.hotkey.bind({}, "f12", function()
  log.d("fkeys f12")
  local device = hs.audiodevice.defaultOutputDevice()
  local level = device:volume() + 10
  log.f("increase volume %s", level)
  if level > 100 then level = 100 end
  device:setVolume(level)
end)
