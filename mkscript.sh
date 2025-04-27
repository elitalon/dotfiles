#!/usr/bin/env bash

# -u, treat unset variables and parameters as an error
set -o nounset

# -e, exit immediately if a pipeline returns a non-zero status
set -o errexit

# The return value of a pipeline is the value of the last (rightmost) command
# to exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully
set -o pipefail

function fail() {
    local message=${1:-"Error"}
    local code=${2:-1}

    if [[ $code -eq 0 ]]; then
        code=1
    fi

    echo -e "\033[91m${message} (${code})\e[0m"
    exit "$code"
}

function log() {
    local message=${1:-}
    echo -e "\033[93m${message}\e[0m"
}

function make_template() {
    local filename=${1:-}
    [[ -z "${filename}" ]] && fail "missing filename" 2
    [[ -e "${filename}" ]] && fail "${filename} already exists" 3

    log "Creating ${filename}"
    touch "${filename}"

    cat << 'END_OF_TEMPLATE' > "${filename}"
#!/usr/bin/env bash

# -u, treat unset variables and parameters as an error"
set -o nounset

# -e, exit immediately if a pipeline returns a non-zero status
set -o errexit

# The return value of a pipeline is the value of the last (rightmost) command
# to exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully
set -o pipefail


script_directory=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly script_directory

function fail() {
    local message=${1:-"Error"}
    local code=${2:-1}

    if [[ $code -eq 0 ]]; then
        code=1
    fi

    echo -e "\033[91m${message} (${code})\e[0m"
    exit "$code"
}

function log() {
    local message=${1:-}
    echo -e "\033[93m${message}\e[0m"
}

#############################
# Write your functions here #
#############################
function hello_world() {
    echo "Hello, world!"
}

function main() {
    ##############################
    # Invoke your functions here #
    ##############################
    hello_world
}

main "$@"
END_OF_TEMPLATE

    log "Making ${filename} executable"
    chmod 0755 "${filename}"

    log "Executing ${filename}"
    # shellcheck source=/dev/null
    . "${filename}"

    log "Done!"
}

function main() {
    make_template "${1:-}"
}

main "$@"
