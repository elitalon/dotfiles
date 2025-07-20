#!/usr/bin/env bash

# Enable shell behaviours if script is not being sourced
# Via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    set -o nounset  # Treat unset variables and parameters as an error
    set -o errexit  # Exit if a pipeline returns a non-zero status
    set -o pipefail # Use last non-zero exit code in a pipeline
fi

###
# Constants
###
SCRIPT_DIRECTORY=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROGRAM_NAME="$(basename "${0:-int2hex}")"
readonly SCRIPT_DIRECTORY PROGRAM_NAME

###
# Log functions
###
function fail() {
    local message=${1:-"Error"}
    local code=${2:-1}

    if [[ $code -eq 0 ]]; then
        code=1
    fi

    warn "${message} (${code})"
    exit "$code"
}

function warn() {
    local message=${1:-}
    echo -e "\033[91m${message}\e[0m"
}

function notice() {
    local message=${1:-}
    echo -e "\033[93m${message}\e[0m"
}

function info() {
    local message=${1:-}
    echo -e "${message}"
}

###
# Whether a program exists in the search path
###
function program_exists() {
    if [[ $# -lt 1 ]]; then
        fail "Missing binary name argument in program_exists" 2
    else
        command -v "$1" 1>/dev/null 2>&1
    fi
}

###
# Write your functions here
###
function hello_world() {
    info "Hello, world!"
}

###
# Main function
###
function main() {
    # Invoke your functions here
    hello_world
}

# Invoke main with args if script is not being sourced
# Via: https://stackoverflow.com/a/28776166/8787985
if ! (return 0 2> /dev/null); then
    main "$@"
fi
