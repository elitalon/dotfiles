#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

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

function install_for_all_users() {
    local path=${1:-}
    [[ -z "${path}" ]] && fail "Missing path for script"
    [[ -d "${path}" ]] && fail "${path} is a directory"
    if [[ ! -f "${path}" && ! -x "${path}" ]]; then
        fail "${path} is not a regular nor executable file"
    fi

    info "Removing extension from ${path}"
    local filename
    filename="$(basename "${path}")"
    local program_name
    program_name="${filename%.*}"

    local destination="/usr/local/bin/${program_name}"
    info "Installing ${path} to ${destination}"
    cp -f "${path}" "${destination}"

    info "Making ${destination} executable"
    chmod 0755 "${destination}"

    local user=elitalon
    local group=staff
    info "Setting user and group to ${user}:${group}"
    chown "${user}:${group}" "${destination}"

    info "Done!"
}

function main() {
    install_for_all_users "${1:-}"
}

main "$@"
