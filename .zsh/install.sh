#!/usr/bin/env bash
# install.sh — provision the CLI tools this dotfiles config depends on.
#
# Idempotent: re-running only installs what is missing.
# Target: Debian/Ubuntu (uses apt). Run `./install.sh --check` to see status
# without changing anything.
#
# Covers: the shell stack (zsh + plugins, fzf, fd, bat, eza, zoxide),
# the prompt (starship), the multiplexer (zellij), gh, and Claude Code.
# Deliberately NOT covered: the pipx/uv Python toolchain, Intel oneAPI,
# and npm agents (pi, gemini) — install those separately.
set -euo pipefail

CHECK_ONLY=0
[ "${1:-}" = "--check" ] && CHECK_ONLY=1

have() { command -v "$1" >/dev/null 2>&1; }
say()  { printf '  %s\n' "$*"; }
step() { printf '\n== %s ==\n' "$*"; }

ARCH="$(uname -m)"
BIN="$HOME/.local/bin"; mkdir -p "$BIN"

# ---- 1. apt packages (+ curl prereq) --------------------------------------
step "apt packages"
# pkg name -> binary to test for presence
declare -A APT_BIN=(
  [curl]=curl [zsh]=zsh [fzf]=fzf [fd-find]=fdfind
  [bat]=batcat [eza]=eza [zoxide]=zoxide
)
missing=()
for pkg in curl zsh fzf fd-find bat eza zoxide; do
  if have "${APT_BIN[$pkg]}"; then say "ok   $pkg"; else say "need $pkg"; missing+=("$pkg"); fi
done
# zsh plugins are sourced files, not on PATH
for pair in \
  "zsh-autosuggestions:/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "zsh-syntax-highlighting:/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  pkg="${pair%%:*}"; f="${pair#*:}"
  if [ -f "$f" ]; then say "ok   $pkg"; else say "need $pkg"; missing+=("$pkg"); fi
done
if [ "${#missing[@]}" -gt 0 ] && [ "$CHECK_ONLY" -eq 0 ]; then
  sudo apt-get update
  sudo apt-get install -y "${missing[@]}"
fi

# ---- 2. starship (prompt) -> /usr/local/bin via official installer --------
step "starship"
if have starship; then say "ok   starship"
elif [ "$CHECK_ONLY" -eq 0 ]; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
else say "need starship"; fi

# ---- 3. zellij (multiplexer) -> ~/.local/bin (not packaged in apt) --------
step "zellij"
if have zellij; then say "ok   zellij"
elif [ "$CHECK_ONLY" -eq 0 ]; then
  case "$ARCH" in
    x86_64)  asset="zellij-x86_64-unknown-linux-musl.tar.gz" ;;
    aarch64) asset="zellij-aarch64-unknown-linux-musl.tar.gz" ;;
    *) echo "unsupported arch '$ARCH' for zellij — install manually" >&2; asset="" ;;
  esac
  if [ -n "$asset" ]; then
    tmp="$(mktemp -d)"
    curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/$asset" -o "$tmp/z.tgz"
    tar -xzf "$tmp/z.tgz" -C "$tmp"
    install -m 755 "$tmp/zellij" "$BIN/zellij"
    rm -rf "$tmp"
  fi
else say "need zellij"; fi

# ---- 4. gh (GitHub CLI) -> official apt repo (newer than the distro pkg) --
step "gh (GitHub CLI)"
if have gh; then say "ok   gh"
elif [ "$CHECK_ONLY" -eq 0 ]; then
  (type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install gh -y
else say "need gh"; fi

# ---- 5. Claude Code -> ~/.local/bin via official installer ----------------
step "Claude Code"
if have claude; then say "ok   claude"
elif [ "$CHECK_ONLY" -eq 0 ]; then
  curl -fsSL https://claude.ai/install.sh | bash
else say "need claude"; fi

step "done"
say "Ensure \$HOME/.local/bin is on PATH (your .zshrc already adds it)."
say "Then restart your shell:  exec zsh"
