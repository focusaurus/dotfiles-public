local log = hs.logger.new("screenshots", "debug")
local ssr = os.getenv("HOME") .. "/bin/screenshot-rename"

----- hammerspoon config reloading -----
local function renameScreenshot(files, opts)
	log.df("renameScreenshot %s files", #files)
	for index, path in pairs(files) do
		if path:find("Screen Shot ", 1, true) and opts[index]["itemCreated"] and opts[index]["itemIsFile"] then
			log.df("Screenshot created at %s", path)
			os.execute(ssr .. " '" .. path .. "'")
		end
	end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/Desktop/", renameScreenshot):start()
