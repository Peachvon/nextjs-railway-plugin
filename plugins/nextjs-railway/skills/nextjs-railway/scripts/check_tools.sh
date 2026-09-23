#!/usr/bin/env bash
# Report which tools a Next.js + Railway project needs are present, and how to fix what's missing.
# Read-only: installs nothing, changes nothing. Prints one line per check: OK / MISSING / ACTION.

ok()      { printf 'OK       %-14s %s\n' "$1" "$2"; }
missing() { printf 'MISSING  %-14s %s\n' "$1" "$2"; }
action()  { printf 'ACTION   %-14s %s\n' "$1" "$2"; }

if command -v brew >/dev/null 2>&1; then
  ok homebrew "$(brew --version 2>/dev/null | head -1)"
  have_brew=1
else
  missing homebrew "user must install it themselves (needs their Mac password): https://brew.sh"
  have_brew=0
fi

if command -v node >/dev/null 2>&1; then
  v=$(node -v | sed 's/^v//')
  major=${v%%.*}; rest=${v#*.}; minor=${rest%%.*}
  if [ "$major" -gt 20 ] || { [ "$major" -eq 20 ] && [ "$minor" -ge 9 ]; }; then
    ok node "v$v"
  else
    missing node "v$v is too old for Next.js 16 (needs >= 20.9) — fix: brew upgrade node"
  fi
else
  if [ "$have_brew" = 1 ]; then missing node "fix: brew install node"; else missing node "install Homebrew first, or the LTS installer from https://nodejs.org"; fi
fi

if command -v git >/dev/null 2>&1; then
  ok git "$(git --version)"
  if [ -z "$(git config --global user.name)" ] || [ -z "$(git config --global user.email)" ]; then
    action git-identity "git has no name/email — ask the user for them, then: git config --global user.name '...' && git config --global user.email '...'"
  fi
else
  missing git "fix: xcode-select --install (user clicks Install in the dialog) or brew install git"
fi

if command -v railway >/dev/null 2>&1; then
  ok railway "$(railway --version 2>/dev/null)"
  who=$(railway whoami 2>&1 | grep -i 'logged in' | head -1)
  if [ -n "$who" ]; then
    ok railway-login "$who"
  else
    action railway-login "user must run: ! railway login   (opens the browser; free to sign up)"
  fi
else
  if [ "$have_brew" = 1 ]; then missing railway "fix: brew install railway"; else missing railway "fix: npm i -g @railway/cli"; fi
fi
