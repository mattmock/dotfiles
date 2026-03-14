# Windows Setup

Everything done to set up dotfiles on Windows.

## Prerequisites Installed

- **Git** — installed via `winget install Git.Git`
- **Starship prompt** — installed via `winget install Starship.Starship`
- **Hyper terminal** — assumed already installed

## What Was Configured

### 1. Hyper Terminal

File: `%APPDATA%\Hyper\.hyper.js`

- Added plugins: `hyper-snazzy`, `hyper-search`, `hyper-pane`
- Added Windows-adapted keymaps (`ctrl` instead of `cmd`)
- Kept existing PowerShell shell config and args

The Hyper config is **not yet symlinked** — it was edited in place. See
"Still TODO" below for symlink plans.

### 2. Starship Prompt

Config file: `starship/starship.toml` (in this repo)

Styled to match the Pure prompt used on Mac/Linux:
- Two-line prompt: directory + git info on top, arrow on bottom
- Git branch (purple), dirty status (red), command duration (yellow)
- Language version indicators disabled (clean, minimal look)

### 3. PowerShell Profile

File: `powershell/Microsoft.PowerShell_profile.ps1` (in this repo)

Installed to: `~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

The profile:
- Auto-detects the dotfiles directory (`~/Projects/dotfiles`, `~/dotfiles`, or `~/.dotfiles`)
- Points `STARSHIP_CONFIG` to the repo's `starship.toml`
- Initializes Starship

### 4. Repo Structure (new files on `windows` branch)

```
starship/
  starship.toml          <- Starship prompt config (cross-platform)
powershell/
  Microsoft.PowerShell_profile.ps1  <- PowerShell profile
```

## Still TODO

- [ ] Create `install.ps1` (Windows equivalent of `install.sh`)
- [ ] Symlink Hyper config from repo to `%APPDATA%\Hyper\.hyper.js`
- [ ] Symlink PowerShell profile from repo instead of copying
- [ ] Symlink Cursor/VS Code settings to `%APPDATA%\Cursor\User\` and `%APPDATA%\Code\User\`
- [ ] Decide: single platform-aware `.hyper.js` using `process.platform`, or separate per-platform configs
- [ ] Merge Starship into `main` branch and adopt on Mac/Linux too (see `MAC_MIGRATION_PLAN.md`)

## Quick Reference

Restart Hyper after any config changes to pick up updates.

To manually reload the PowerShell profile without restarting:
```powershell
. $PROFILE
```
