#!/bin/bash

# Get the directory of this script (works in both bash and zsh)
if [ -n "$BASH_VERSION" ]; then
  location=$(dirname "${BASH_SOURCE[0]}")
elif [ -n "$ZSH_VERSION" ]; then
  location=$(dirname "${(%):-%x}")
else
  location=$(dirname "$0")
fi

# CLI Colours
export RED='\033[0;31m'
export PURPLE='\033[0;35m'
export GREEN='\033[0;32m'
export NC='\033[0m' # No Colorhelp

# Alias
source $location/src/alias.sh

# Help
source $location/src/help.sh

# Helper
source $location/src/helper.sh

# Functions
source $location/src/functions.sh

# Completion - load the appropriate completion file based on shell
if [ -n "$ZSH_VERSION" ]; then
  # Zsh
  source $location/src/completion.zsh
elif [ -n "$BASH_VERSION" ]; then
  # Bash
  source $location/src/completion.bash
fi
