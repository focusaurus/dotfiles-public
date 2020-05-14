local log = hs.logger.new("screenshots", "debug")
local hbin = os.getenv("HOME") .. "/bin"

----- hammerspoon config reloading -----
function renameScreenshot(files, opts)
  log.df("renameScreenshot %s files", #files)
  for index, path in pairs(files) do
    if path:find("Screen Shot ", 1, true) 
      and opts[index]['itemCreated']
      and opts[index]['itemIsFile'] then
        log.df("Screenshot created at %s", path)
        os.execute(hbin .. "/screenshot-rename '" .. path .. "'")
    end
  end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Desktop/", renameScreenshot):start()
