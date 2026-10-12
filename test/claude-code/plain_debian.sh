#!/bin/bash
# debian:12 ships without curl/git; the feature must pull in what it needs.
set -e
source dev-container-features-test-lib

check "claude runs"                  claude --version
check "git was installed"            command -v git
check "runs as root, state is root"  bash -c '[ "$(stat -c %U /claude-state)" = "$(id -un)" ]'

reportResults
