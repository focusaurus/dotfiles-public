local log = hs.logger.new("fuzzball", "debug")
local hbin = os.getenv("HOME") .. "/bin"

local function chooseScript()
  log.d("fuzzball script")
  os.execute(hbin .. "/fuzz-script-choose")
end


return {
  chooseScript = chooseScript,
}
