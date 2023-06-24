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
    install coreutils findutils
    install bash bash-completion2
    install the_silver_searcher
    install tree
    # install tmux

    # Git
    install git gh

    # Ruby environment
    install rbenv ruby-build

    # Python environment
    # install pyenv

    # iOS dependency managers
    # install carthage
    # install cocoapods
    # install swift-outdated

    # Code quality
    install swiftlint
    # install swiftformat
    # install tokei
    # install cloc
    # install danger/tap/danger-js
    # install shellcheck

    # Programming languages and runtimes
    # install go
    # install node npm
    # install jenv

    # Database utilities
    # install mongosh
    # install jq

    # Networking utilities
    # install masscan nmap

    # Other useful binaries
    # install unrar
    # install p7zip

    # CI/CD
    # install circleci

    # Containers and orchestration
    # install docker docker-completion docker-compose
    # install colima

    clean_up
}

main
