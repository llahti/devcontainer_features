#!/bin/bash
set -e
source dev-container-features-test-lib

check "python toolchain untouched"   python3 --version
check "claude runs"                  claude --version
check "no node on PATH"              bash -c '! command -v node'

reportResults
