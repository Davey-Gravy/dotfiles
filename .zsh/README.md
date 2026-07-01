# Dotfiles

Shell config tracked in a **bare git repo** at `~/.dotfiles`. Files live in place in
`$HOME` (no symlinks). A `dotfiles` alias (defined in `.zshrc`) is just `git` pointed at
that repo with the work-tree set to `$HOME`.

## Everyday use

```sh
dotfiles status
dotfiles add ~/.zshrc            # stage a change (must add explicitly; untracked files are hidden)
dotfiles commit -m "tweak fzf"
dotfiles push
```

## Tracked files
- `.zshrc`, `.zsh/aliases-git.zsh`, `.zsh/completions/`, `.zsh/README.md`
- `.gitconfig`

## NOT tracked (machine-local / secret)
- `.zshrc.local`  — API keys and per-host overrides. `.zshrc` sources it if present.
- `.zsh_history`, `.zshrc.bak`

## Set up on a NEW machine

1. Install the tools the config depends on:
   ```sh
   sudo apt install zsh fzf fd-find bat eza zsh-autosuggestions zsh-syntax-highlighting
   # zoxide + starship: use their install scripts if apt is too old
   ```
2. Clone and check out:
   ```sh
   git clone --bare <REMOTE_URL> $HOME/.dotfiles
   alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   dotfiles checkout            # if this errors on existing files, back them up first:
                                #   mkdir ~/.dotfiles-backup && dotfiles checkout 2>&1 | \
                                #   grep -E "^\s" | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/
   dotfiles checkout            # retry
   dotfiles config status.showUntrackedFiles no
   ```
3. Recreate `~/.zshrc.local` with your secrets (it is intentionally not in the repo).
