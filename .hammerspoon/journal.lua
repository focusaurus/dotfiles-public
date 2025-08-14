local module = {}
local log = hs.logger.new("journal", "debug")
-- local windowManagement = require("window-management")
local fuzzball = os.getenv("HOME") .. "/git.peterlyons.com/dotfiles/fuzzball"

-- local function journalVim()
--   log.d("journalVim")
--   hs.application.launchOrFocus("iTerm")
--   local windows = hs.application.frontmostApplication():allWindows()
--   for _, window in pairs(windows) do
--     if window:title() == "journal mailchimp" then
--       log.d("focusing existing journal window")
--       window:focus()
--       return
--     end
--   end
--   hs.timer.doAfter(0.2, function()
--     hs.eventtap.keyStroke({"command", "control"}, "j")
--     hs.timer.doAfter(0.5, function()
--       log.d("about to bottomRight")
--       windowManagement.bottomRight()
--     end)
--   end)
-- end

function module.appendPrompt()
	log.d("appendByDialog")
	os.execute(fuzzball .. "/fh-journal-prompt &")
end

function module.appendPromptCheckIn()
	log.d("appendPromptCheckIn")
	os.execute(fuzzball .. "/fh-journal-standup &")
end

function module.appendPromptTask()
	log.d("appendPromptTask")
	os.execute(fuzzball .. "/fh-journal-task &")
end

function module.appendVim()
	log.d("appendVim")
	local ok, _, _ = os.execute(fuzzball .. "/fh-journal-vim &")
	log.d("appendVim ok: " .. ok)
end

return module
