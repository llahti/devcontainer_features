# claude-code feature

Installs the Claude Code native binary (no Node.js) on Debian/Ubuntu images.

- Binary: `/usr/local/bin/claude`, auto-update disabled (pin via the `version` option)
- State: `CLAUDE_CONFIG_DIR=/claude-state`, a named volume `claude-state-${devcontainerId}`, so one private volume per project
- VS Code: adds the `anthropic.claude-code` extension

## Usage

Local copy: place this folder at `.devcontainer/features/claude-code/`.

```jsonc
{
  "image": "mcr.microsoft.com/devcontainers/python:3.12",
  "features": {
    "./features/claude-code": { "version": "latest" }
    // or: "ghcr.io/YOURUSER/features/claude-code:1": {}
  },
  "mounts": [
    // optional: shared read-only settings (create the host dir first)
    "source=${localEnv:HOME}/.claude-common,target=/etc/claude-code,type=bind,readonly"
  ],
  "runArgs": ["--cap-drop=ALL", "--security-opt=no-new-privileges"]
}
```

Publish: `devcontainer features publish -r ghcr.io -n YOURUSER/features .` (from the parent of `claude-code/`, with the folder under `src/`).

## Verify

```bash
which claude && claude --version
which node npm            # should print nothing on a non-Node image
echo $CLAUDE_CONFIG_DIR   # /claude-state
docker volume ls | grep claude-state   # one per project
```
