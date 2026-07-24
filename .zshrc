# ---- PATH ----
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"   # npm -g binaries (pi coding agent, etc.)

# ---- History ----
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_VERIFY

# ---- Completion ----
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# ---- Plugins (sourced directly, no framework) ----
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- fzf: ctrl-R history, ctrl-T files, alt-C dirs, **<TAB> inline picker ----
# Backend = fd (fdfind on Debian): fast, respects .gitignore, includes hidden.
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border --info=inline'
# Previews, like Claude Code's @ : file contents via bat, dir trees via eza.
export FZF_CTRL_T_OPTS="--preview 'batcat --style=numbers --color=always --line-range=:300 {} 2>/dev/null || eza --tree --color=always --icons {} 2>/dev/null | head -300'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -300'"
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh
# Make the **<TAB> inline trigger use fd too (this is the closest thing to @).
_fzf_compgen_path() { fdfind --hidden --follow --exclude .git . "$1"; }
_fzf_compgen_dir()  { fdfind --type d --hidden --follow --exclude .git . "$1"; }

# ---- zoxide: smart cd ----
eval "$(zoxide init zsh)"

# ---- starship: prompt ----
eval "$(starship init zsh)"

# ---- git aliases (Oh My Zsh git plugin) ----
source ~/.zsh/aliases-git.zsh

# ---- dotfiles: bare git repo tracking $HOME (see ~/.zsh/README.md) ----
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# ---- Debian renames: expose standard names ----
command -v batcat >/dev/null && alias bat='batcat'
command -v fdfind >/dev/null && alias fd='fdfind'

# ---- Modern ls via eza ----
if command -v eza >/dev/null; then
  alias ls='eza --icons'
  alias ll='eza -l --git --icons'
  alias la='eza -la --git --icons'
  alias tree='eza --tree --icons'
fi

# ---- Secrets & machine-local overrides (NOT tracked in git) ----
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# >>> MFC Intel oneAPI (ifx) toolchain >>>
# Makes ./mfc.sh build/run use ifx + Intel MPI by default.
# Delete this block to revert MFC (and other builds) to gfortran/OpenMPI.
if [ -f /opt/intel/oneapi/setvars.sh ]; then
    source /opt/intel/oneapi/setvars.sh > /dev/null 2>&1
    export FC=ifx CC=icx CXX=icpx
    export MPIFC=mpiifx MPICC=mpiicx MPICXX=mpiicpx
fi
# <<< MFC Intel oneAPI (ifx) toolchain <<<

# GLM 5.2 via Z.ai (Anthropic-compatible endpoint) — `glm` launches Claude Code on GLM;
# plain `claude` stays on the Anthropic subscription. Key lives in ~/.config/zai/key (chmod 600).
glm() {
  ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic" \
  ANTHROPIC_AUTH_TOKEN="$(< ~/.config/zai/key)" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.2" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7" \
  API_TIMEOUT_MS="3000000" \
  claude --model glm-5.2 "$@"
}

# >>> Basilisk CFD >>>
# Built 2026-07-07 with gcc (CC=gcc) so qcc bakes in gcc, NOT the oneAPI icx
# from the block above — simulations compile/run without oneAPI sourced.
# GPU backends (gpu/cuda/hip/opencl) skipped: CPU-only host, unused by octree/quadtree AMR.
export BASILISK="$HOME/basilisk/src"
export PATH="$PATH:$BASILISK"
# <<< Basilisk CFD <<<
