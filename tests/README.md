# Tests

This directory contains test scripts for validating dotfiles functionality.

## Available Tests

### `test-history.sh`

Tests the project-specific terminal history feature. Verifies:
- History file creation in editor workspaces
- Environment variable detection
- History file location and permissions
- Separate history files for different projects
- Global history fallback in regular terminals

Run with:
```bash
./tests/test-history.sh
```

