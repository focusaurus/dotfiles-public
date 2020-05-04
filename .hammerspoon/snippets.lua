local log = hs.logger.new("snippets", "debug")
local hbin = "/Users/peterlyons/bin"

hs.hotkey.bind({"control"}, ",", function()
  log.d("snippets")
  ok, result = hs.applescript("do shell script \"" .. hbin .. "/fuzz-snippet\"")
  if ok then
    hs.pasteboard.setContents(result)
    hs.eventtap.keyStroke({"command"}, "v")
  else
    log.d("snippet cancelled" .. result)
  end
end)
