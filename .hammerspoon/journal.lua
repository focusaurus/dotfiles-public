local log = hs.logger.new("journal", "debug")
local fuzzball = os.getenv("HOME") .. "/git.peterlyons.com/dotfiles/fuzzball"

----- journal -----
local function journalVim() 
  log.d("journalVim")
  hs.application.launchOrFocus("iTerm")
  hs.timer.doAfter(0.2, function()
    hs.eventtap.keyStroke({"command", "control"}, "j")
  end)
end
hs.hotkey.bind({"command"}, "j", journalVim)

local function journalDialog() 
  log.d("journalDialog")
  os.execute(fuzzball .. "/journal-mailchimp")
end
hs.hotkey.bind({}, "f9", journalDialog)

local function journalStandupDialog() 
  log.d("journalStandupDialog")
  os.execute(fuzzball .. "/journal-mailchimp-standup")
end
hs.hotkey.bind({"shift"}, "f9", journalStandupDialog)
