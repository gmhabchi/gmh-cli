#!/bin/bash

location=$(dirname "$0")

# CLI Colours
export RED='\033[0;31m'
export PURPLE='\033[0;35m'
export GREEN='\033[0;32m'
export NC='\033[0m' # No Colorhelp

# Alias
source $location/alias.sh

# Help
source $location/help.sh

# Helper
source $location/helper.sh

# Main
source $location/functions.sh
