# Dotfiles

My personal dotfiles repository for managing configuration files across different machines.

## Prerequisites & What the Script Does

- **Git**: Must be installed (the script will check for it)
- **Zsh**: If not installed, the script will install it (supports apt and brew)
- **~/.local/bin in PATH**: The script will add this to your PATH and .bashrc if missing
- **Pure prompt**: The script will install and configure it automatically
- **Aliases & Functions**: The script ensures `.zsh_aliases` and `.zsh_functions` exist
- **Default shell**: The script will prompt to set Zsh as your default shell if it isn't already
- **Cursor Editor**: Optional, but recommended. See below for setup tips.

## Overview

This repository contains configuration files for various tools and applications, organized in a way that makes it easy to maintain and deploy across different machines.

## Repository Structure

```
dotfiles/
├── zsh/
│   ├── .zshrc              # Main zsh configuration
│   ├── .zsh_aliases        # Custom aliases
│   └── .zsh_functions      # Custom functions
├── git/
│   ├── .gitconfig          # Git configuration
│   └── scripts/            # Global Git command scripts
│       ├── save-wip.sh     # Save work in progress
│       ├── restore-wip.sh  # Restore last WIP state
│       ├── list-wip.sh     # List WIP branches
│       └── return-to-wip.sh # Return to WIP state
├── hyper/
│   └── .hyper.js           # Hyper terminal configuration
├── install.sh              # Installation script
└── README.md               # This file
```

## Features

### Shell Configuration
- Zsh with Oh My Zsh
- Pure prompt
- Syntax highlighting and autosuggestions
- Platform-agnostic configuration (works on both macOS and Linux)
- Smart editor selection (Cursor → VS Code → Vim)
- Enhanced history management (10,000 entries, deduplication)
- Improved tab completion with menu selection
- Smart directory navigation (auto-cd, case-insensitive globbing)
- Automatic loading of aliases and functions

### Terminal Configuration (Hyper)
- Cross-platform theme (hyper-snazzy)
- Enhanced search functionality
- Improved pane management
- Consistent keyboard shortcuts:
  - Pane navigation: `cmd+shift+d` (split right), `cmd+shift+e` (split down)
  - Tab navigation: `cmd+t` (new), `cmd+shift+right/left` (switch)
  - Window management: `cmd+n` (new), `cmd+shift+w` (close)
  - Search: `cmd+f`

### Git Configuration
#### Work In Progress (WIP) Management

A set of global Git commands for managing work-in-progress changes. These commands are installed in `~/.local/bin` and are available both as Git aliases and standalone commands.

##### Available Commands

1. `git save-wip` or `git-save-wip`
   - Creates a new branch named `wip/[current-branch-name]`
   - Saves both staged and unstaged changes separately
   - Staged changes are committed with message "WIP(staged): saving staged changes on [branch]"
   - Unstaged changes are committed with message "WIP(unstaged): saving unstaged changes on [branch]"
   - Usage: When you need to temporarily save your work without making a proper commit

2. `git restore-wip` or `git-restore-wip`
   - Restores the last saved WIP state
   - Resets the last two commits (staged and unstaged changes)
   - Unstages the files that were previously unstaged
   - Usage: When you want to return to your last saved WIP state

3. `git list-wip` or `git-list-wip`
   - Lists all branches that start with "wip/"
   - Usage: To see all your saved WIP states

4. `git return-to-wip` or `git-return-to-wip`
   - Returns to a specific WIP state
   - Restores both staged and unstaged files
   - Maintains the original staging state
   - Usage: When you want to return to a specific WIP state

##### Example Workflow

```bash
# Start working on a feature
git checkout -b feature/new-thing
# Make some changes and stage some files
git add file1.txt
# Need to switch tasks? Save your work
git save-wip
# Switch to another task
git checkout main
# ... work on other task ...
# Want to return to your WIP?
git checkout feature/new-thing
git return-to-wip
```

#### Other Git Features
- Git LFS enabled for large file handling
- Default editor set to Cursor (with fallbacks)
- Default branch name set to 'main'
- Rebase settings configured for cleaner history
- GPG signing disabled by default

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

The installation script will now:
- Install Zsh if missing
- Ensure `~/.local/bin` is in your PATH
- Install and configure the Pure prompt
- Create `.zsh_aliases` and `.zsh_functions` if missing
- Set Zsh as your default shell (with prompt)
- Check for required dependencies
- Create necessary directories
- Set up symlinks for all configuration files
- Install Git commands globally in `~/.local/bin`
- Install Oh My Zsh and required plugins

**After installation, restart your terminal or run:**
```bash
source ~/.zshrc
```

to apply all changes.

## Cursor Editor (Optional)
If you use the Cursor editor:
- Download the AppImage from the official site
- Move it to `~/Applications/`
- Make it executable: `chmod +x ~/Applications/cursor.AppImage`
- (Optional) Create a desktop entry for easy launching
- The installation script will automatically set up your Cursor settings with:
  - Zsh as the default terminal shell
  - Minimal configuration focused on essential terminal settings
  - Cross-platform support for Linux and macOS

## Troubleshooting

### Common Issues

1. **Git commands not found**
   - Ensure `~/.local/bin` is in your PATH
   - Run `echo $PATH` to verify
   - Add to your shell config if missing: `export PATH="$HOME/.local/bin:$PATH"`

2. **Oh My Zsh plugins not working**
   - Check if plugins are installed: `ls ~/.oh-my-zsh/custom/plugins`
   - Install missing plugins:
     ```bash
     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
     ```

3. **Pure prompt not working**
   - Ensure the Pure prompt is cloned to `~/.zsh/pure`
   - Ensure your `.zshrc` contains:
     ```zsh
     fpath+=$HOME/.zsh/pure
     autoload -U promptinit; promptinit
     prompt pure
     ```

4. **Hyper terminal issues**
   - Install required plugins:
     ```bash
     hyper i hyper-snazzy hyper-search hyper-pane
     ```
   - Restart Hyper after installation

5. **Symlinks not working**
   - Check if files exist in source directory
   - Ensure you have write permissions in home directory
   - Run `./install.sh` again to recreate symlinks

6. **Zsh not default shell after install**
   - Run `chsh -s $(which zsh)` and restart your terminal

## Platform Support

This configuration is designed to work on both macOS and Linux systems. The installation script and configurations automatically detect the operating system and apply the appropriate settings.

## Requirements

- Git
- Zsh
- Cursor (optional, falls back to VS Code or Vim)
- `~/.local/bin` in your PATH (for global Git commands)
- Hyper terminal (optional, for terminal configuration)

The installation script will:
- Check for required dependencies
- Create necessary directories
- Set up symlinks for all configuration files
- Install Git commands globally in `~/.local/bin`
- Install Oh My Zsh and required plugins

## Troubleshooting

### Common Issues

1. **Git commands not found**
   - Ensure `~/.local/bin` is in your PATH
   - Run `echo $PATH` to verify
   - Add to your shell config if missing: `export PATH="$HOME/.local/bin:$PATH"`

2. **Oh My Zsh plugins not working**
   - Check if plugins are installed: `ls ~/.oh-my-zsh/custom/plugins`
   - Install missing plugins:
     ```bash
     git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
     git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
     ```

3. **Hyper terminal issues**
   - Install required plugins:
     ```bash
     hyper i hyper-snazzy hyper-search hyper-pane
     ```
   - Restart Hyper after installation

4. **Symlinks not working**
   - Check if files exist in source directory
   - Ensure you have write permissions in home directory
   - Run `./install.sh` again to recreate symlinks 