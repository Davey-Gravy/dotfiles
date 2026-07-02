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
- `.zsh/install.sh` — provisions the CLI tools the config depends on
- `.gitconfig`

## NOT tracked (machine-local / secret)
- `.zshrc.local`  — API keys and per-host overrides. `.zshrc` sources it if present.
- `.zsh_history`, `.zshrc.bak`

## Set up on a NEW machine

1. Clone and check out the config (the installer lives inside the repo):
   ```sh
   git clone --bare https://github.com/Davey-Gravy/dotfiles.git $HOME/.dotfiles
   alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
   dotfiles checkout            # if this errors on existing files, back them up first:
                                #   mkdir ~/.dotfiles-backup && dotfiles checkout 2>&1 | \
                                #   grep -E "^\s" | awk '{print $1}' | xargs -I{} mv {} ~/.dotfiles-backup/
   dotfiles checkout            # retry
   dotfiles config status.showUntrackedFiles no
   ```
2. Install the tools the config depends on (Debian/Ubuntu):
   ```sh
   ~/.zsh/install.sh --check    # preview what's missing, changes nothing
   ~/.zsh/install.sh            # install the missing ones
   ```
3. Recreate `~/.zshrc.local` with your secrets (it is intentionally not in the repo).
4. `exec zsh`

## Auth note (this machine)

This box has multiple `gh` accounts logged in; the repo is owned by **Davey-Gravy** but the
active account is usually **CoolSimDavis**. So the dotfiles repo has a **repo-local** git
credential helper (`~/.dotfiles/config`, not tracked) that fetches Davey-Gravy's token on
demand: `push`/`pull` work without switching accounts, and no token is stored on disk.
On a single-account machine you don't need this — the default `gh` helper just works.
