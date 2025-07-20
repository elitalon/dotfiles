#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

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

function info() {
    local message=${1:-}
    echo -e "${message}"
}

###
# Creates a script out of the template
###
function make_template() {
    local template_script
    template_script=template.sh
    [[ -f "${template_script}" ]] \
        || fail "Template script ${template_script} does not exist" 2

    local filename=${1:-}
    [[ -z "${filename}" ]] && fail "Missing filename" 3
    [[ -e "${filename}" ]] && fail "Script ${filename} already exists" 3

    info "Creating ${filename}"
    cat "${template_script}" > "${filename}"

    info "Making ${filename} executable"
    chmod 0755 "${filename}"
}

###
# Main function
###
function main() {
    make_template "${1:-}"
}

main "$@"
