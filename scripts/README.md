# Scripts

This directory contains utility and diagnostic scripts for troubleshooting and maintenance.

## Available Scripts

### `diagnose-history.sh`

Diagnostic tool to check if project-specific history is configured correctly. Displays:
- Environment variables
- History file location
- Configuration status

Run with:
```bash
./scripts/diagnose-history.sh
```

### `inspect-history.sh`

Interactive diagnostic tool to inspect history behavior in your current terminal. Shows:
- Current HISTFILE setting
- History file contents
- Duplicate detection
- History options
- Environment variables

Run with:
```bash
./scripts/inspect-history.sh
```

Useful for debugging history issues in your actual terminal session.

