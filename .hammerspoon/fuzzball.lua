local module = {}
local log = hs.logger.new("fuzzball", "debug")
local hbin = os.getenv("HOME") .. "/bin"

 function module.chooseScript()
  log.d("fuzzball script")
  os.execute(hbin .. "/fuzz-script-choose")
end

return module
