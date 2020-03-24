#!/usr/bin/env bash
alias cabu='clear; cargo build'
# alias cate='clear; cargo test'
alias cate='clear;
  cargo test --quiet 2>&1 >/dev/null |
    egrep "^test result" |
    grep -v "0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out"'
alias cafm='cargo +nightly fmt'
alias caneb='cargo new --bin'

caru() {
  clear
  cargo run -q -- "$@"
}

exercism-done() {
  exercism submit src/lib.rs
  exercism fetch
  cd "../$(ls -tr .. | tail -1)"
  git init .
  git add .
  git commit -m "initial exercise"
  dos2unix src/*.rs
  atom .
}
