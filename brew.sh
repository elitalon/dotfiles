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

    # Improved shell experience
    install coreutils findutils tree
    install bash bash-completion2

    # Git
    install git

    # Ruby environment
    install rbenv ruby-build

    # Python environment
    install pyenv

    # iOS dependency managers
    # install carthage

    # Code quality
    # install cloc
    # install tokei
    # install swiftlint

    # Programming languages and runtimes
    install go
    install node npm

    # Networking utilities
    install masscan nmap

    # Data processing
    # install kafkacat

    # Other useful binaries
    install unrar
    # install p7zip

    clean_up
}

main
