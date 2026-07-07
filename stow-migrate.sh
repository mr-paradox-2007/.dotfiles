#!/usr/bin/env bash
#
# stow-migrate.sh
# One-time cleanup: removes dead/empty leftover folders in ~/.dotfiles,
# reorganizes everything into proper GNU Stow packages, and re-links
# your whole system with `stow`.
#
# Run this from anywhere. It cd's into ~/.dotfiles itself.

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$DOTFILES" ]; then
    echo "Can't find $DOTFILES. Aborting."
    exit 1
fi

echo "This will restructure $DOTFILES into Stow packages and re-link"
echo "i3, micro, gtk, alacritty, zsh, git, x11, omz configs."
echo "A full backup will be made first at:"
echo "  $BACKUP"
read -rp "Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted, nothing changed."
    exit 0
fi

echo "==> Checking for GNU Stow"
if ! command -v stow &> /dev/null; then
    echo "    Not found, installing..."
    sudo pacman -S --noconfirm stow
fi

echo "==> Backing up current .dotfiles to $BACKUP"
cp -r "$DOTFILES" "$BACKUP"

echo "==> Removing dead empty leftover folders (i3/micro/gtk/alacritty top-level)"
rm -rf "$DOTFILES/i3" "$DOTFILES/micro" "$DOTFILES/gtk" "$DOTFILES/alacritty"

echo "==> Building proper Stow package skeletons"
mkdir -p "$DOTFILES/i3/.config"
mkdir -p "$DOTFILES/micro/.config"
mkdir -p "$DOTFILES/gtk/.config"
mkdir -p "$DOTFILES/alacritty/.config"

echo "==> Moving real configs out of home/.config into their own packages"
[ -d "$DOTFILES/home/.config/i3" ]        && mv "$DOTFILES/home/.config/i3" "$DOTFILES/i3/.config/i3"
[ -d "$DOTFILES/home/.config/micro" ]     && mv "$DOTFILES/home/.config/micro" "$DOTFILES/micro/.config/micro"
[ -d "$DOTFILES/home/.config/gtk-3.0" ]   && mv "$DOTFILES/home/.config/gtk-3.0" "$DOTFILES/gtk/.config/gtk-3.0"
[ -d "$DOTFILES/home/.config/alacritty" ] && mv "$DOTFILES/home/.config/alacritty" "$DOTFILES/alacritty/.config/alacritty"

echo "==> Removing now-empty home/ wrapper folder"
rmdir "$DOTFILES/home/.config" 2>/dev/null || true
rmdir "$DOTFILES/home" 2>/dev/null || true

echo "==> Unlinking old symlinks so Stow can take over cleanly"
for link in \
    "$HOME/.config/i3" \
    "$HOME/.config/micro" \
    "$HOME/.config/gtk-3.0" \
    "$HOME/.config/alacritty" \
    "$HOME/.zshrc" \
    "$HOME/.gitconfig" \
    "$HOME/.Xresources" \
    "$HOME/.oh-my-zsh/custom"
do
    if [ -L "$link" ]; then
        unlink "$link"
        echo "    unlinked $link"
    fi
done

echo "==> Stowing all packages"
cd "$DOTFILES"
stow -v -t "$HOME" i3 micro gtk alacritty zsh git x11 omz

echo ""
echo "==> Verifying links"
all_ok=true
for link in \
    "$HOME/.config/i3" \
    "$HOME/.config/micro" \
    "$HOME/.config/gtk-3.0" \
    "$HOME/.config/alacritty" \
    "$HOME/.zshrc" \
    "$HOME/.gitconfig" \
    "$HOME/.Xresources" \
    "$HOME/.oh-my-zsh/custom"
do
    if [ -L "$link" ]; then
        echo "    OK      $link -> $(readlink -f "$link")"
    else
        echo "    MISSING $link"
        all_ok=false
    fi
done

echo ""
if $all_ok; then
    echo "All packages linked successfully."
else
    echo "Some links are missing - check the output above."
fi
echo "Old structure backed up at: $BACKUP"
echo ""
echo "Next: cd ~/.dotfiles && git add -A && git commit -m 'restructure into stow packages'"
