# Replays the environment /opt/intel/oneapi/setvars.sh produces, from a cache.
# Sourcing setvars.sh directly costs ~4.4s per zsh launch; this costs a few ms.
# Rebuilt when setvars.sh or a top-level oneAPI component dir changes (installing or
# removing a version touches the component dir). Force a rebuild: rm the cache file.
() {
  [[ $SETVARS_COMPLETED == 1 ]] && return   # same guard setvars.sh itself applies

  local root=/opt/intel/oneapi
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/oneapi-env.zsh
  local f k line stale=1

  if [[ -s $cache ]]; then
    stale=0
    for f in $root $root/setvars.sh $root/*(N/); do
      [[ $f -nt $cache ]] && { stale=1; break }
    done
  fi
  # Line 1 of the cache names the vars that were empty when it was built, line 2 those
  # that were set. setvars.sh merges into pre-existing values with per-var special cases
  # (overwrites some, skips components whose *_ROOT is set), so replay is only exact if
  # the same vars are empty now. Otherwise rebuild for this environment.
  if (( ! stale )); then
    { read -r line; for k in ${=line#\# empty:}; [[ -n ${(P)k} ]] && stale=1
      read -r line; for k in ${=line#\# set:};   [[ -z ${(P)k} ]] && stale=1 } < $cache
  fi

  if (( stale )); then
    mkdir -p ${cache:h}
    # Vars empty beforehand are written literally; vars already set (PATH) are written as
    # prefix"$VAR"suffix so they compose with whatever value a future shell inherits.
    zsh -f -c '
      typeset -A before; local -a empty set body
      for k in ${(k)parameters[(R)*export*]}; before[$k]=${(P)k}
      source /opt/intel/oneapi/setvars.sh >/dev/null 2>&1
      [[ $SETVARS_COMPLETED == 1 ]] || exit 1
      for k in ${(ok)parameters[(R)*export*]}; do
        [[ $k == _ ]] && continue
        v=${(P)k}; o=${before[$k]-}
        (( ${+before[$k]} )) && [[ $v == $o ]] && continue
        if [[ -z $o ]]; then
          empty+=($k); body+=("export $k=${(qq)v}")
        elif [[ $v == *${(b)o}* ]]; then
          set+=($k); body+=("export $k=${(qq)${v%%${(b)o}*}}\"\$$k\"${(qq)${v#*${(b)o}}}")
        else
          exit 1   # setvars rewrote a pre-existing value; cannot replay it
        fi
      done
      print -r -- "# empty: $empty"; print -r -- "# set: $set"; print -rl -- $body
    ' > $cache.tmp.$$ && mv $cache.tmp.$$ $cache || { rm -f $cache.tmp.$$; source $root/setvars.sh >/dev/null 2>&1; return }
  fi
  source $cache
}
