alias g='git'
compdef _git g=git

alias ga='git add'
compdef _git gc=git-add
alias gc='git commit -v'
compdef _git gc=git-commit
alias gca='git commit -v -a'
compdef _git gca=git-commit

alias gl='git pull'
compdef _git gl=git-pull
alias gp='git push'
compdef _git gp=git-push

alias gco='git checkout'
compdef _git gco=git-checkout
alias gcm='git checkout master'
alias gb='git branch'
compdef _git gb=git-branch
alias gba='git branch -a'
compdef _git gba=git-branch
alias gm='git merge'
compdef _git gm=git-merge

alias gs='git status'
compdef _git gst=git-status
alias gss='git status -s'
compdef _git gss=git-status
alias gk="gitk --all&"
alias gcount='git shortlog -sn'
compdef _git gcount=git

alias gcp='git cherry-pick'
compdef _git gcp=git-cherry-pick

alias gd='git diff --word-diff'
compdef _git gd=git-diff

alias glg='git log --stat --max-count=5'
compdef _git glg=git-log
alias glgg='git log --graph --max-count=5'
compdef _git glgg=git-log
alias gh="git hist"
compdef _git gh=git-log
alias gt="git time"
compdef _git gh=git-log
gdv() { git diff -w "$@" | view - }
compdef _git gdv=git-diff

alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'

#
# Имя текущей ветки и текущего репозитория
# Использование: git pull origin $(current_branch)
#
function current_branch() {
 ref=$(git symbolic-ref HEAD 2> /dev/null) || return
 echo ${ref#refs/heads/}
}
function current_repository() {
 ref=$(git symbolic-ref HEAD 2> /dev/null) || return
 echo $(git remote -v | cut -d':' -f 2)
}
alias ggpull='git pull origin $(current_branch)'
compdef _git ggpull=git
alias ggpush='git push origin $(current_branch)'
compdef _git ggpush=git
alias ggpnp='git pull origin $(current_branch) && git push origin $(current_branch)'
compdef _git ggpnp=git
