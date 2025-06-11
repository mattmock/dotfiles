# Editor-Specific Terminal History

This feature provides project-specific terminal history for VS Code and Cursor editors. It's designed to work with your existing dotfiles setup.

## Installation

1. The configuration files are located in the `editors/vscode` directory of this dotfiles repository
2. The installation script will automatically:
   - Create necessary directories
   - Set up symlinks
   - Add the required line to your `.zshrc`

## Configuration Files

### 1. `editors/vscode/settings.json`
```json
{
    "terminal.integrated.defaultProfile.osx": "zsh",
    "terminal.integrated.profiles.osx": {
        "zsh": {
            "path": "/bin/zsh",
            "args": ["-l"]
        }
    },
    "terminal.integrated.env.osx": {
        "WORKSPACE_FOLDER": "${workspaceFolder}",
        "VSCODE_WORKSPACE": "${workspaceFolder}",
        "CURSOR_WORKSPACE": "${workspaceFolder}"
    },
    "terminal.integrated.inheritEnv": false
}
```

### 2. `zsh/zsh-editor-config.zsh`
The configuration script handles:
- Project root detection (using `.git`, `package.json`, or `.project` markers)
- History file management in `.config/editor-history`
- Automatic backup of large history files
- Environment variable validation

## Integration with Existing Setup

This feature integrates with your existing dotfiles setup:

1. Works with your existing zsh configuration
2. Compatible with your Cursor editor setup
3. Maintains the same philosophy of keeping configurations organized and version controlled

## Usage

1. Open a project in VS Code or Cursor
2. Open a terminal
3. Your commands will be saved to the project's `.config/editor-history/.zsh_history` file
4. Each project maintains its own separate history

## Benefits

- Project-specific command history
- History stored with project (can be version controlled)
- Works with both VS Code and Cursor
- No interference between different projects' histories
- Automatic backup of large history files
- Smart project root detection

## Requirements

- macOS with zsh shell
- VS Code or Cursor editor
- This dotfiles repository installed

## Testing

To verify the setup is working:
1. Open a terminal in your project
2. Run some commands
3. Close and reopen the terminal
4. Press the up arrow to verify your commands are still in history
5. Open a different project and verify it has its own separate history

## Troubleshooting

If history isn't working as expected:

1. Check if the workspace variables are set:
   ```bash
   echo $WORKSPACE_FOLDER
   echo $VSCODE_WORKSPACE  # or $CURSOR_WORKSPACE
   ```

2. Verify the history file exists:
   ```bash
   ls -la .config/editor-history/.zsh_history
   ```

3. Check if the project root is detected:
   ```bash
   # Should show your project root
   echo $WORKSPACE_PATH
   ```

4. Look for any error messages in the terminal startup output 