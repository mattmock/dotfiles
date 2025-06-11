# Dotfiles Setup Guide

This guide covers different scenarios for setting up and maintaining your dotfiles configuration.

## Quick Start

### New Computer Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/Projects/dotfiles
   cd ~/Projects/dotfiles
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

This will:
- Set up all necessary symlinks
- Configure Git with your global excludes
- Install required dependencies
- Set up your shell configuration
- Configure your editors

### Updating Existing Dotfiles

If you already have the dotfiles repository but need to update:

1. Navigate to your dotfiles directory:
   ```bash
   cd ~/Projects/dotfiles
   ```

2. Pull the latest changes:
   ```bash
   git pull
   ```

3. Run the installation script:
   ```bash
   ./install.sh
   ```

## Editor Workspace Setup

### New VS Code/Cursor Projects

When creating a new project, you need to set up the workspace settings. You have two options:

1. **Quick Setup (Recommended)**
   ```bash
   # From your dotfiles directory
   ./editors/setup-workspace-settings.sh /path/to/new/project
   # Or from within the project directory
   /Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh
   ```

2. **Manual Setup**
   - Create `.vscode/settings.json` in your project
   - Copy settings from `editors/workspace-settings.md`

### Existing VS Code/Cursor Projects

For existing projects that need the workspace settings:

1. Run the setup script:
   ```bash
   /Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh
   ```

2. Restart your editor
3. Open a new terminal to verify the environment variables are set

## Common Use Cases

### Setting Up a New Python Project

1. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # or `venv\Scripts\activate` on Windows
   ```

2. Set up workspace settings:
   ```bash
   /Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh
   ```

3. Open in VS Code/Cursor:
   ```bash
   code .  # or `cursor .`
   ```

### Setting Up a New Git Repository

1. Initialize the repository:
   ```bash
   git init
   ```

2. Set up workspace settings:
   ```bash
   /Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh
   ```

3. Make your first commit:
   ```bash
   git add .
   git commit -m "Initial commit"
   ```

### Working with Multiple Projects

1. Each project needs its own workspace settings:
   ```bash
   # In project A
   cd /path/to/project-a
   /Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh

   # In project B
   cd /path/to/project-b
   /Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh
   ```

2. Each project will have its own:
   - Terminal history in `.config/editor-history`
   - Workspace settings in `.vscode/settings.json`

## Troubleshooting

### Common Issues

1. **Git Global Excludes Not Working**
   ```bash
   # Check if excludes file is set
   git config --get core.excludesfile
   
   # If not set, run the setup script
   ./git/setup-git-excludes.sh
   ```

2. **Editor History Not Working**
   - Verify the workspace settings are in place
   - Check if `.config/editor-history` directory exists
   - Restart your editor and open a new terminal

3. **Shell Configuration Not Loading**
   - Check if `DOTFILES_DIR` is set:
     ```bash
     echo $DOTFILES_DIR
     ```
   - Verify symlinks are correct:
     ```bash
     ls -la ~/.zshrc
     ls -la ~/.zsh_aliases
     ls -la ~/.zsh_functions
     ```

### Environment Variables

To verify your environment is set up correctly:

```bash
# Check workspace variables
echo $WORKSPACE_FOLDER
echo $VSCODE_WORKSPACE
echo $CURSOR_WORKSPACE

# Check dotfiles directory
echo $DOTFILES_DIR

# Check history file
echo $HISTFILE
```

## Maintenance

### Regular Updates

1. Pull the latest changes:
   ```bash
   cd ~/Projects/dotfiles
   git pull
   ./install.sh
   ```

2. Check for new dependencies:
   ```bash
   # Update Oh My Zsh
   omz update

   # Update Git global excludes
   ./git/setup-git-excludes.sh
   ```

### Adding New Projects

1. Create your new project directory
2. Run the workspace settings setup:
   ```bash
   /Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh
   ```
3. Open in your preferred editor

## Notes

- The installation script is idempotent - it's safe to run multiple times
- Workspace settings are project-specific and need to be set up for each new project
- Git global excludes are managed through your dotfiles and apply to all repositories
- Editor history is stored in `.config/editor-history` in each project directory 