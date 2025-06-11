# VS Code/Cursor Workspace Settings Template

This document contains the template for workspace settings that ensure proper environment variable configuration in VS Code and Cursor terminals.

## Why These Settings?

These settings ensure that the following environment variables are properly set in your terminal:
- `WORKSPACE_FOLDER`: The root directory of your current project
- `VSCODE_WORKSPACE`: The root directory of your current project (for VS Code)
- `CURSOR_WORKSPACE`: The root directory of your current project (for Cursor)

These variables are used by:
1. Project-specific terminal history in `.config/editor-history`
2. Smart project root detection
3. Editor-specific configurations
4. Workspace-aware shell customization

## Template

Create a `.vscode/settings.json` file in your project root with the following content:

```json
{
    "terminal.integrated.env.osx": {
        "WORKSPACE_FOLDER": "${workspaceFolder}",
        "VSCODE_WORKSPACE": "${workspaceFolder}",
        "CURSOR_WORKSPACE": "${workspaceFolder}"
    },
    "terminal.integrated.env.linux": {
        "WORKSPACE_FOLDER": "${workspaceFolder}",
        "VSCODE_WORKSPACE": "${workspaceFolder}",
        "CURSOR_WORKSPACE": "${workspaceFolder}"
    },
    "terminal.integrated.env.windows": {
        "WORKSPACE_FOLDER": "${workspaceFolder}",
        "VSCODE_WORKSPACE": "${workspaceFolder}",
        "CURSOR_WORKSPACE": "${workspaceFolder}"
    },
    "terminal.integrated.inheritEnv": false
}
```

## Usage

1. Create a `.vscode` directory in your project root if it doesn't exist:
   ```bash
   mkdir -p .vscode
   ```

2. Create or edit the `settings.json` file:
   ```bash
   touch .vscode/settings.json
   ```

3. Copy the template above into the file

4. Restart VS Code/Cursor and open a new terminal to verify the environment variables are set:
   ```bash
   echo $WORKSPACE_FOLDER
   echo $VSCODE_WORKSPACE
   echo $CURSOR_WORKSPACE
   ```

## Troubleshooting

If the environment variables are not set after following these steps:

1. Make sure you've restarted VS Code/Cursor completely
2. Open a new terminal (the settings won't apply to existing terminals)
3. Verify that `terminal.integrated.inheritEnv` is set to `false`
4. Check that the `${workspaceFolder}` variable is resolving correctly

### Common Issues

1. **Variables Not Set**
   - Check if the settings file exists: `ls -la .vscode/settings.json`
   - Verify the JSON is valid
   - Make sure you're using the correct editor (VS Code or Cursor)

2. **History Not Working**
   - Verify the variables are set correctly
   - Check if `.config/editor-history` directory exists
   - Look for any error messages in the terminal startup

3. **Editor-Specific Issues**
   - VS Code: Check if the workspace is trusted
   - Cursor: Verify the workspace is properly initialized

## Note

These settings are project-specific and need to be added to each new project. There is currently no way to automatically apply these settings to all new projects, as VS Code and Cursor don't support project templates in this way.

For convenience, you can use the setup script:
```bash
/Users/mmock/Projects/dotfiles/editors/setup-workspace-settings.sh
``` 