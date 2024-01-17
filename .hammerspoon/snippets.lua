local module = {}
local log = hs.logger.new("snippets", "debug")
local hbin = os.getenv("HOME") .. "/bin"

function module.chooseByUIAndType()
  log.d("snippets")
  local function callback(exitCode, stdout, stderr) 
    log.d("snippet task callback")
  if exitCode == 0 then
    hs.pasteboard.setContents(stdout)
    hs.eventtap.keyStroke({"command"}, "v")
  else
    log.d("snippet failed" .. stderr)
  end
  end
  local task = hs.task.new(hbin .. "/fuzz-snippet", callback)
  task:start()
  log.d("task launched" .. task:pid())
  -- local ok, result = hs.osascript.applescript("do shell script \"" .. hbin .. "/fuzz-snippet\"")
end

return module
