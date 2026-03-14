$DOTFILES_DIR = "$HOME\Projects\dotfiles"
if (-not (Test-Path $DOTFILES_DIR)) {
    $DOTFILES_DIR = "$HOME\dotfiles"
}
if (-not (Test-Path $DOTFILES_DIR)) {
    $DOTFILES_DIR = "$HOME\.dotfiles"
}

$ENV:STARSHIP_CONFIG = "$DOTFILES_DIR\starship\starship.toml"

if ((Get-Command starship -ErrorAction SilentlyContinue) -and $ENV:TERM -ne 'dumb') {
    Invoke-Expression (&starship init powershell)
}
