local log = hs.logger.new("journal", "debug")
local hbin = "/Users/peterlyons/bin"

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
  -- os.execute(hbin .. "/fuzz-script-exec ~/projects/dotfiles/fuzzball journal-mailchimp")
  os.execute(os.getenv("HOME") .. "/git.peterlyons.com/dotfiles/fuzzball/journal-mailchimp")
end
hs.hotkey.bind({}, "f9", journalDialog)

local function journalStandupDialog() 
  log.d("journalStandupDialog")
  os.execute(os.getenv("HOME") .. "/git.peterlyons.com/dotfiles/fuzzball/journal-mailchimp-standup")
end
hs.hotkey.bind({"shift"}, "f9", journalStandupDialog)
