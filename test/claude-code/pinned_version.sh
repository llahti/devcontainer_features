#!/bin/bash
set -e
source dev-container-features-test-lib

# Keep in sync with the version in scenarios.json
check "claude runs"                  claude --version
check "pinned version is installed"  bash -c 'claude --version | grep -q "2.1.293"'

reportResults
