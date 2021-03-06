local module = {}
local log = hs.logger.new("snippets", "debug")
local hbin = os.getenv("HOME") .. "/bin"

function module.chooseByUIAndType()
  log.d("snippets")
  ok, result = hs.applescript("do shell script \"" .. hbin .. "/fuzz-snippet\"")
  if ok then
    hs.pasteboard.setContents(result)
    hs.eventtap.keyStroke({"command"}, "v")
  else
    log.d("snippet cancelled" .. result)
  end
end

return module
