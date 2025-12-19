cd ~/photos/2025/cnc-desktop-ii
name=$(~/bin/prompt-or-clipboard "symlink name")
if [[ -z "${name}" ]]; then
    exit
fi
bn=$(basename "${imv_current_file}")
ln -nsf "../${bn}" "${name}.jpg" 
