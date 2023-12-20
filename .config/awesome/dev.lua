local log = require('log')
local awful = require('awful')
local module = {}

log('dev loaded')
local toggle = true
local test_class = 'Rofi'
function module.dev2()
  for k, v in pairs(_G) do
    log("GLOBAL", k, v)
  end
end

function module.dev1()
  log("dev1 called", screen)
  for s in screen do
    log("screen", s, s.geometry, s.index, s.outputs)
  end
end

return module
