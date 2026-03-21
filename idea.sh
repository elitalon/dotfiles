#!/usr/bin/env bash

set -o nounset

function activate_intellij() {
	local bundle_id=${1:-}
	osascript -e "tell application id \"${bundle_id}\" to activate"
}

function open_intellij() {
	local bundle_id=${1:-}
	shift

	open -b "${bundle_id}" --args "$@"
	# activate_intellij "${bundle_id}"
}

function find_bundle_id() {
	local app_names=("IntelliJ IDEA" "IntelliJ IDEA CE")

	local bundle_id
	for app_name in "${app_names[@]}"; do
		bundle_id=$(osascript -e "id of app \"${app_name}\"" 2>/dev/null)
		[[ -n "${bundle_id}" ]] && echo "${bundle_id}" && return
	done

	echo "No bundle ID found" >&2
	exit 1
}

function main() {
	open_intellij "$(find_bundle_id)" "$@"
}

main "$@"
