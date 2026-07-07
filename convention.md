# .dotfiles Conventions

This repo (`~/.dotfiles`) is managed with **GNU Stow**. Read this before
adding, editing, or restructuring anything here — including if you're an
AI assistant being asked to "add X to my dotfiles."

## The one rule that matters

**Every top-level folder in `~/.dotfiles` is a Stow package, and its
internal structure is an exact mirror of where its files belong relative
to `$HOME`.**

Stow symlinks by literally overlaying a package folder onto `$HOME`. If
the internal path is wrong, the symlink lands in the wrong place. There
is no other indirection, no wrapper folder, no "shared" folder. One app
= one top-level folder = one package.

## Layout pattern

For an app whose config normally lives at `~/.config/<app>`:

```
~/.dotfiles/<app>/.config/<app>/...
```

Example — i3:

```
~/.dotfiles/i3/.config/i3/config
~/.dotfiles/i3/.config/i3/autostart
```

Running `stow i3` from inside `~/.dotfiles` creates:

```
~/.config/i3 -> ~/.dotfiles/i3/.config/i3
```

For a dotfile that lives directly in `$HOME` (not under `.config`):

```
~/.dotfiles/<name>/.<filename>
```

Example — zsh:

```
~/.dotfiles/zsh/.zshrc
```

`stow zsh` creates `~/.zshrc -> ~/.dotfiles/zsh/.zshrc`.

## Current packages

| Package     | Contains                          | Links to                         |
|-------------|------------------------------------|-----------------------------------|
| `i3`        | `.config/i3/`                     | `~/.config/i3`                   |
| `micro`     | `.config/micro/`                  | `~/.config/micro`                |
| `gtk`       | `.config/gtk-3.0/`                | `~/.config/gtk-3.0`              |
| `alacritty` | `.config/alacritty/`              | `~/.config/alacritty`            |
| `x11`       | `.Xresources`                     | `~/.Xresources`                  |
| `zsh`       | `.zshrc`                          | `~/.zshrc`                       |
| `git`       | `.gitconfig`                      | `~/.gitconfig`                   |
| `omz`       | `.oh-my-zsh/custom/`              | `~/.oh-my-zsh/custom`            |

Package name doesn't have to match the target folder name exactly (see
`gtk` -> `gtk-3.0`), but keep it obvious — don't get clever.

## Rules for adding something new

1. Pick a package name = the app name, lowercase (`nvim`, `kitty`, `dunst`, `polybar`...).
2. Create `~/.dotfiles/<name>/` and inside it, recreate the *exact* path
   the app expects relative to `$HOME` — check the app's docs for where
   its config actually lives before assuming `.config`.
3. Put the real config file(s) there — not a copy, not a placeholder.
4. `cd ~/.dotfiles && stow <name>`
5. Confirm with `readlink -f ~/.config/<name>` (or wherever it should land)
   — it must resolve into `~/.dotfiles/<name>/...`
6. `git add -A && git commit`

## Rules for editing an existing config

Just edit the file directly wherever `readlink -f` says it actually
lives (inside `~/.dotfiles/<package>/...`) — never edit through the
symlink path if you're unsure, always resolve it first. Then commit.

## What NOT to do

- Do **not** create a `home/` folder, a `config/` catch-all folder, a
  `misc/` folder, or any folder that isn't itself an app name mapping to
  a real package.
- Do **not** manually create symlinks with `ln -s`. Always use `stow`
  so the repo and the live system can't drift apart.
- Do **not** leave old/empty folders behind after restructuring — delete
  them (`rm -rf`) and commit the deletion. Dead folders next to real
  ones are exactly how this repo got messy the first time.
- Do **not** put more than one app's config inside a single package
  folder unless the apps are genuinely inseparable (rare).

## Removing a package

```
cd ~/.dotfiles
stow -D <name>      # removes the symlinks
rm -rf <name>        # deletes the package folder
git add -A && git commit
```
