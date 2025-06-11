# Cursor Editor Configuration

This directory contains configuration files for the Cursor editor, including terminal integration and project-specific history.

## Features

- Project-specific terminal history
- Zsh shell integration
- UTF-8 support
- Editor-specific environment variables

## Configuration Files

### `settings.json`
```json
{
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.profiles.osx": {
        "zsh": {
            "path": "/bin/zsh",
            "args": ["-l"],
            "env": {
                "WORKSPACE_FOLDER": "${workspaceFolder}",
                "CURSOR_EDITOR": "true"
            }
        }
    },
    "terminal.integrated.inheritEnv": true,
    "terminal.integrated.shellIntegration.enabled": true,
    "terminal.integrated.env.osx": {
        "LANG": "en_US.UTF-8"
    }
}
```

## Integration with Terminal History

The Cursor configuration works in conjunction with the shared terminal history feature in `editors/vscode/zsh-editor-config.zsh`. This ensures:

1. Consistent terminal behavior across VS Code and Cursor
2. Project-specific history in both editors
3. Proper shell integration and environment variables

## Installation

The installation script will:
1. Create necessary directories
2. Set up symlinks for Cursor configuration
3. Ensure terminal history feature is properly configured

## Usage

1. Open a project in Cursor
2. Open a terminal
3. Your commands will be saved to the project's `.editor-terminal-history/.zsh_history` file
4. Each project maintains its own separate history

## Benefits

- Seamless integration with your dotfiles setup
- Consistent terminal experience across editors
- Project-specific command history
- UTF-8 support for international characters
- Shell integration for better terminal features 