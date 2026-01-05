#!/bin/sh

open_intellij() {
    path=${1:-}
    shift

    open -na "${path}" --args "$@" 2>/dev/null
}

main() {
    open_intellij "IntelliJ IDEA.app" "$@" || open_intellij "IntelliJ IDEA CE.app" "$@"
}

main "$@"
