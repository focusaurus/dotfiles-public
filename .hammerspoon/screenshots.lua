local log = hs.logger.new("screenshots", "debug")

----- hammerspoon config reloading -----
function renameScreenshot(files, opts)
  log.df("renameScreenshot %s", files)
  for index, path in pairs(files) do
    if path:find("Screen Shot ", 1, true) and opts[index]["itemCreated"] then
      hs.alert("Screenshot created at " .. path)
      -- os.execute(hbin .. "/screenshot-rename '" .. path .. "'")
      local button, text = hs.dialog.textPrompt("screenshot suffix", "")
      hs.alert(text)
    end
  end
end
-- myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Desktop/", renameScreenshot):start()
