##### Ruby Ecosystem #####
bundle-config() {
  mkdir .bundle
  cat <<EOF >.bundle/config
---
BUNDLE_DISABLE_SHARED_GEMS: "1"
BUNDLE_PATH: vendor/bundle
EOF
}
alias be='bundle exec'
alias irb='irb --simple-prompt'
alias nogems="gem list|awk '{print $1}'|xargs -n 1 -I X gem uninstall X -a -I"

# export RUBYOPT=rubygems
# if [[ -d ~/.rbenv ]]; then
#   eval "$(rbenv init -)"
# fi
