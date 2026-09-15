# Ubuntu's /etc/zsh/zshrc runs compinit before ~/.zshrc does. The two runs see different
# $fpath, so each invalidates the other's ~/.zcompdump and it is rebuilt every launch.
skip_global_compinit=1
