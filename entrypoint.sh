#!/bin/sh
# Runs the node, and once it's up, connects it to its network: with
# NB_AUTH_KEY the first time, after that with what it keeps in its volume.
#
#   NB_AUTH_KEY     an auth key (nbk-…), to join a network the first time
#   NB_HOSTNAME     the device's name (default: the container's hostname)
#   NB_ACCEPT_DNS   point the container's DNS at Nardeboon (default: false)
#   NB_UP_ARGS      more for `nardeboon up`, e.g. --advertise-exit-node
#   NB_DAEMON_ARGS  more for nardeboond, e.g. --log-level debug
set -eu

connect() {
	# The node answers once it's up; `status` says how it stands in its exit
	# code too, so its answer is what tells.
	tries=0
	while :; do
		status=$(nardeboon status --json 2>/dev/null) || true
		case "$status" in *'"ok":true'*) break ;; esac
		tries=$((tries + 1))
		if [ "$tries" -gt 150 ]; then
			echo "nardeboon: the node didn't start" >&2
			return 1
		fi
		sleep 0.2
	done
	state=$(printf '%s' "$status" | grep -o '"state": *"[a-z_]*"' | head -n 1 | sed 's/.*"\([a-z_]*\)"$/\1/')
	set -- up --hostname "${NB_HOSTNAME:-$(hostname)}" --accept-dns="${NB_ACCEPT_DNS:-false}"
	if [ "$state" = needs_login ]; then
		if [ -z "${NB_AUTH_KEY:-}" ]; then
			echo "nardeboon: not on a network yet: start the container with NB_AUTH_KEY set to an auth key from your dashboard (Devices, Add device)" >&2
			return 0
		fi
		set -- "$@" --auth-key "$NB_AUTH_KEY"
	fi
	# shellcheck disable=SC2086 # NB_UP_ARGS is flags, split on purpose
	nardeboon "$@" ${NB_UP_ARGS:-}
}

connect &

# shellcheck disable=SC2086 # NB_DAEMON_ARGS is flags, split on purpose
exec nardeboond ${NB_DAEMON_ARGS:-} "$@"
