#!/usr/bin/env bash
# Claude Code devcontainer feature: native installer, Debian/Ubuntu only.
set -euo pipefail

VERSION="${VERSION:-latest}"
USERNAME="${_REMOTE_USER:-root}"
STATE_DIR="/claude-state"

if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: this feature must run as root." >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "ERROR: only Debian-based images (apt) are supported." >&2
  exit 1
fi

if ! [[ "$VERSION" =~ ^(latest|stable|[0-9]+\.[0-9]+\.[0-9]+([-.+][0-9A-Za-z.]+)?)$ ]]; then
  echo "ERROR: invalid 'version' option '$VERSION' (use latest, stable, or X.Y.Z)." >&2
  exit 1
fi

# Prerequisites (idempotent; no Node.js)
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates git
rm -rf /var/lib/apt/lists/*

# Install with a throwaway HOME so nothing lands in the real user's home,
# then copy the binary system-wide.
tmp_home="$(mktemp -d)"
trap 'rm -rf "$tmp_home"' EXIT

args=()
if [ "$VERSION" != "latest" ]; then
  args=("$VERSION")
fi

echo "Installing Claude Code (${VERSION})..."
HOME="$tmp_home" bash -c 'curl -fsSL https://claude.ai/install.sh | bash -s -- "$@"' _ ${args[@]+"${args[@]}"}

src="$(readlink -f "$tmp_home/.local/bin/claude")"
if [ ! -x "$src" ]; then
  echo "ERROR: installer did not produce an executable at $tmp_home/.local/bin/claude" >&2
  exit 1
fi
install -m 0755 "$src" /usr/local/bin/claude

# Private state dir. A fresh named volume inherits this ownership/mode from the image.
# World-writable + sticky: the remote user's UID can be remapped at container start
# (updateRemoteUserUID), so ownership set at build time can't be relied on.
mkdir -p "$STATE_DIR"
chmod 1777 "$STATE_DIR"

# Smoke test
claude --version
echo "Claude Code installed at /usr/local/bin/claude; state dir: $STATE_DIR"
