# Mac Migration Plan: Pure Prompt -> Starship

Plan for switching from Oh My Zsh + Pure prompt to Starship on Mac/Linux,
so all platforms share one prompt config.

## Why

- One `starship.toml` works on PowerShell, Zsh, Bash, Fish — any shell
- Already set up on Windows (see `WINDOWS_SETUP.md`)
- Eliminates the need to install/maintain Pure prompt separately
- Same look and feel everywhere

## What Changes

### Install Starship

```bash
# macOS
brew install starship

# Linux
curl -sS https://starship.rs/install.sh | sh
```

### Update `.zshrc`

Remove the Pure prompt lines:

```zsh
# REMOVE THESE:
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure
```

Add Starship init at the end of `.zshrc`:

```zsh
# ADD THIS:
export STARSHIP_CONFIG="$DOTFILES_DIR/starship/starship.toml"
eval "$(starship init zsh)"
```

### Update `install.sh`

- Remove the Pure prompt clone/setup section (lines ~92-98)
- Add Starship install step:
  ```bash
  if ! command -v starship &> /dev/null; then
      if command -v brew &> /dev/null; then
          brew install starship
      else
          curl -sS https://starship.rs/install.sh | sh
      fi
  fi
  ```
- Remove `$HOME/.zsh/pure` from cleanup/symlink logic

## What Stays the Same

- Oh My Zsh — can keep it for plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- All aliases, functions, env files — untouched
- Git config, editor config, Hyper config — untouched
- The `starship.toml` in this repo is already styled to match Pure's minimal look

## What You Can Optionally Drop

- Oh My Zsh entirely — your plugins can be sourced directly (they already are in `.zshrc`)
- The `$HOME/.zsh/pure` directory

## Steps

1. `brew install starship`
2. Edit `zsh/.zshrc`: remove Pure lines, add Starship init
3. Edit `install.sh`: swap Pure install for Starship install
4. Test in a new terminal
5. If happy, remove `~/.zsh/pure` directory
6. Merge `windows` branch into `main`

## Rollback

If something goes wrong, revert the `.zshrc` changes and Pure prompt
is back immediately — Starship doesn't modify anything permanently.
