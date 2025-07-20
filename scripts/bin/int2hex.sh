#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

###
# Constants
###
PROGRAM="$(basename "${0:-int2hex}")"
readonly PROGRAM

###
# Prints usage
###
function usage() {
    echo "Usage: ${PROGRAM} [-s] VALUE"
}

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

###
# Validates arguments
###
function validate_input() {
    local input_value="${1:-}"

    [[ -z "${input_value}" ]] \
        && fail "Missing input value"

    [[ "${input_value}" != @([0-9]|[1-9]+([0-9])) ]] \
        && fail "'${input_value}' is not a positive decimal integer"

    return 0
}

###
# Converts to hex
###
function convert_to_hex() {
    printf '0x%08x\n' "${1:-}"
}

###
# Main function
###
function main() {
    local skip_clipboard=
    while getopts "s" flag; do
        case ${flag} in
            s) skip_clipboard=1 ;;
            *) usage && exit 2 ;;
        esac
    done
    shift $((OPTIND-1))

    validate_input "${1:-}"

    local result
    result="$(convert_to_hex "${1:-}")"
    echo "${result}"

    if [[ -z "${skip_clipboard}" ]]; then
        echo "${result}" | tr -d '\n' | pbcopy
    fi
}

main "$@"
