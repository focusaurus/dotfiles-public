function rg-count() {
  rg --count-matches "$1" | awk -F: '{s+=$NF} END{print s+0}'
}
