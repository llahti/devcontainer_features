#!/bin/bash
# Default test: runs against the base image given with `-i`, feature at default options.
set -e

# Provided by the devcontainer CLI test runner
source dev-container-features-test-lib

check "claude is on PATH"            command -v claude
check "claude runs"                  claude --version
check "installed system-wide"        test -x /usr/local/bin/claude
check "config dir env is set"        bash -c '[ "$CLAUDE_CONFIG_DIR" = "/claude-state" ]'
check "auto-update is disabled"      bash -c '[ "$DISABLE_AUTOUPDATER" = "1" ]'
check "state dir exists"             test -d /claude-state
check "state dir is owned by user"   bash -c '[ "$(stat -c %U /claude-state)" = "$(id -un)" ]'
check "state dir is private (700)"   bash -c '[ "$(stat -c %a /claude-state)" = "700" ]'
check "state dir is writable"        bash -c 'touch /claude-state/.probe && rm /claude-state/.probe'
check "no node on PATH"              bash -c '! command -v node'
check "no npm on PATH"               bash -c '! command -v npm'

reportResults
