#!/usr/bin/env bash

set -o nounset
set -o errexit

readonly brew="$(command -v brew)"
[[ -z "${brew}" ]] && echo 'brew command is not installed' && exit -1


# Removes outdated versions and broken links
function clean_up() {
    ${brew} cleanup
}

# Updates Homebrew
function update() {
    ${brew} update
    ${brew} upgrade
}

# Installs a list of formulae
function install() {
    for formula; do
        ${brew} install "${formula}"
    done
}

function main() {
    ${brew} analytics off

    clean_up
    update

    # GNU core utilities
    install coreutils findutils

    # Latest Bash
    install bash bash-completion2

    # Git
    install git

    # Ruby environment
    install rbenv ruby-build

    # Python environment
    install pyenv

    # Package managers
    # install carthage

    # Code quality
    install cloc
    # install swiftlint

    # Other useful binaries
    install unrar p7zip

    clean_up
}

main
