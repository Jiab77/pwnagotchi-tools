#!/usr/bin/env bash

# Pwnagotchi AI fix for Rpi 3b+
# Made by Jiab77
#
# Based om the following issue:
# - https://github.com/evilsocket/pwnagotchi/issues/683
#
# Should solve the following issues:
# - https://github.com/evilsocket/pwnagotchi/issues/1101
# - https://github.com/evilsocket/pwnagotchi/issues/925
#
# Version 0.0.0

# Options
set -o xtrace

# Config
DEBUG_MODE=true
BROKEN_FILES=(epoch.py reward.py)
BROKEN_LINE="wifi.NumChannels"
BROKEN_LINE_FIX="wifi.NumChannelsExt"
BROKEN_FIX_CHECK="/root/.ai-patched"

# Functions
function die() {
  echo -e "\nError: $*\n" >&2
  exit 255
}
function apply_patch() {
  for F in "${BROKEN_FILES[@]}"; do
    find / -type f -name "$F" -exec cp -v {} {}.bak \; 2>/dev/null
    find / -type f -name "$F" -exec sed -e 's/'"$BROKEN_LINE"'/'"$BROKEN_LINE_FIX"'/g' -i {} \; 2>/dev/null
  done
  touch "$BROKEN_FIX_CHECK"
}
function restore_files() {
  for F in "${BROKEN_FILES[@]}"; do
    find / -type f -name "$F.bak" -ls 2>/dev/null
    if [[ $DEBUG_MODE == true ]]; then
      for R in $(find / -type f -name "$F.bak"); do echo "mv -v '$R' '$(dirname "$R")/$F'" ; done
    else
      for R in $(find / -type f -name "$F.bak"); do mv -v "$R" "$(dirname "$R")/$F" ; done
    fi
  done
  if [[ $DEBUG_MODE == true ]]; then
    stat "$BROKEN_FIX_CHECK"
  else
    rm -fv "$BROKEN_FIX_CHECK"
  fi
}
function print_usage() {
  echo -e "\nUsage: $(basename "$0") [-r|--restore] - Fix pownagotchi issue with 5Ghz wireless devices\n"
  exit 1
}

# Checks
[[ $1 == "-h" || $1 == "--help" ]] && print_usage
[[ $(id -u) -ne 0 ]] && die "You must run this script as root or with 'sudo'."
[[ -r "$BROKEN_FIX_CHECK" ]] && die "This pwnagotchi device has been already patched. Remove the file '$BROKEN_FIX_CHECK' to patch it again."

# Main
if [[ $1 == "-r" || $1 == "--restore" ]]; then
  restore_files
else
  apply_patch
fi
