# Oh My Zsh git plugin aliases, as a standalone file.
# Source: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git

# ---- Helper functions (required by some aliases) ----

function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

function current_branch() { git_current_branch }

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,stable,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo main
}

function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return
    fi
  done
  echo develop
}

# ---- Aliases ----

alias g='git'

# add
alias ga='git add'
alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'

# apply / am
alias gap='git apply'
alias gapt='git apply --3way'
alias gam='git am'
alias gamc='git am --continue'
alias gams='git am --skip'
alias gama='git am --abort'
alias gamscp='git am --show-current-patch'

# branch
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'

# delete merged branches
function gbda() {
  git branch --no-color --merged \
    | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" \
    | command xargs git branch -d 2>/dev/null
}

# bisect
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

# commit
alias gc='git commit -v'
alias 'gc!'='git commit -v --amend'
alias 'gcn!'='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias 'gca!'='git commit -v -a --amend'
alias 'gcan!'='git commit -v -a --no-edit --amend'
alias 'gcans!'='git commit -v -a -s --no-edit --amend'
alias gcam='git commit -a -m'
alias gcas='git commit -a -s'
alias gcasm='git commit -a -s -m'
alias gcsm='git commit -s -m'
alias gcmsg='git commit -m'
alias gcs='git commit -S'

# checkout / switch / clone
alias gcb='git checkout -b'
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gcm='git checkout $(git_main_branch)'
alias gcd='git checkout $(git_develop_branch)'
alias gsw='git switch'
alias gswc='git switch -c'
alias gswm='git switch $(git_main_branch)'
alias gswd='git switch $(git_develop_branch)'
alias gcl='git clone --recurse-submodules'
function gccd() {
  git clone --recurse-submodules "$@" && cd "$(basename "$_" .git)"
}

# config / clean
alias gcf='git config --list'
alias gclean='git clean -id'
alias gpristine='git reset --hard && git clean -dffx'

# cherry-pick
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# shortlog
alias gcount='git shortlog -sn'

# diff
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdup='git diff @{upstream}'
alias gdw='git diff --word-diff'
function gdv() { git diff -w "$@" | view -; }
function gdnolock() {
  git diff "$@" ":(exclude)package-lock.json" ":(exclude)*.lock"
}

# fetch
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfg='git ls-files | grep'
alias gfo='git fetch origin'

# gui
alias gg='git gui citool'
alias gga='git gui citool --amend'

# push/pull shortcuts (current branch)
alias ggf='git push --force origin $(current_branch)'
alias ggfl='git push --force-with-lease origin $(current_branch)'
alias ggl='git pull origin $(current_branch)'
alias ggp='git push origin $(current_branch)'
alias ggpnp='ggl && ggp'
alias ggpull='git pull origin "$(git_current_branch)"'
alias ggpur='ggu'
alias ggpush='git push origin "$(git_current_branch)"'
alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias ggu='git pull --rebase origin $(current_branch)'
alias gpsup='git push --set-upstream origin $(git_current_branch)'

# help
alias ghh='git help'

# ignore / ignored files
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias gunignore='git update-index --no-assume-unchanged'

# svn
alias git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias gsd='git svn dcommit'
alias gsr='git svn rebase'

# gitk
alias gk='gitk --all --branches &!'
alias gke='gitk --all $(git log -g --pretty=%h) &!'

# pull
alias gl='git pull'
alias glum='git pull upstream $(git_main_branch)'
alias gluc='git pull upstream $(git_current_branch)'
alias gpr='git pull --rebase'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash -v'
alias gupom='git pull --rebase origin $(git_main_branch)'
alias gupomi='git pull --rebase=interactive origin $(git_main_branch)'

# log
alias glg='git log --stat'
alias glgp='git log --stat -p'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glo='git log --oneline --decorate'
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'"
alias glols="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat"
alias glod="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias glods="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
function glp() { git log --pretty="$1"; }

# merge
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/$(git_main_branch)'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge upstream/$(git_main_branch)'

# push
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias 'gpf!'='git push --force'
alias gpoat='git push origin --all && git push origin --tags'
alias gpu='git push upstream'
alias gpv='git push -v'

# remote
alias gr='git remote'
alias gra='git remote add'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grup='git remote update'
alias grv='git remote -v'

# rebase
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbd='git rebase $(git_develop_branch)'
alias grbi='git rebase -i'
alias grbm='git rebase $(git_main_branch)'
alias grbom='git rebase origin/$(git_main_branch)'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'

# revert / reset / restore / rm
alias grev='git revert'
alias grh='git reset'
alias grhh='git reset --hard'
alias groh='git reset origin/$(git_current_branch) --hard'
alias grm='git rm'
alias grmc='git rm --cached'
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'
alias gru='git reset --'

# repo root
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'

# status
alias gsb='git status -sb'
alias gss='git status -s'
alias gst='git status'

# show
alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'

# submodule
alias gsi='git submodule init'
alias gsu='git submodule update'

# stash
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstu='git stash --include-untracked'
alias gstall='git stash --all'

# tag
alias gts='git tag -s'
alias gtv='git tag | sort -V'
function gtl() { git tag --sort=-v:refname -n -l "${1}*" }

# whatchanged / wip
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
