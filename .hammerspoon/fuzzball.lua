local log = hs.logger.new("fuzzball", "debug")
local hbin = "/Users/peterlyons/bin"

----- fuzzball scripts -----
hs.hotkey.bind({"command"}, "Space", function()
  log.d("fuzzball script")
  os.execute(hbin .. "/fuzz-script-choose")
end)
