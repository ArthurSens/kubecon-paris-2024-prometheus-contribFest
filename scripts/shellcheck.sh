#!/usr/bin/env bash
# vim: ai:ts=8:sw=8:noet

set -eufo pipefail
export SHELLOPTS        # propagate set to children by default
IFS=$'\t\n'
umask 0077

find ./scripts -name '*.sh' -exec shellcheck {} \;

printf "INFO: All scripts have been linted\n"
