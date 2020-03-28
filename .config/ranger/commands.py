# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command

import os
import subprocess

class fzf_select(Command):
    def execute(self):
        command = "fzf"
        fzf = self.fm.execute_command(command, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.decode("utf-8").rstrip("\n"))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


class fzf_cd(Command):
    def execute(self):
        fzfOpts = os.getenv("FZF_ALT_C_OPTS") or "--preview 'tree -C {} | head -200'"
        command = (
          "command find -L ."
          " \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\)"
          " -prune -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf"
        )
        command += " " + fzfOpts
        fzf = self.fm.execute_command(command, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.decode("utf-8").rstrip("\n"))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)
