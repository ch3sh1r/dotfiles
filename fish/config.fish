if status is-interactive
    # Run ssh agent plugin
    fish_ssh_agent
    thefuck --alias | source

    # Set up session logging
    #if test -z "$SCRIPTED"
    #set -gx SCRIPTED nested
    #set script_share "$HOME/.local/share/fish/scripts"
    #mkdir -p $script_share
    #script -q $script_share/(date +%s)
    #echo WARNING: session is no longer being captured
    #end
end

# Abbreviations
abbr -a p 'ps -auxw'
abbr -a h history

# Git abbreviations
abbr -a g git
abbr -a ga 'git add'
abbr -a gc 'git commit --verbose'
abbr -a gcl 'git clone --recursive'
abbr -a gco 'git checkout'
abbr -a gd 'git diff'
abbr -a glg 'git log --stat'
abbr -a gp 'git push'
abbr -a grhh 'git reset --hard'
abbr -a gss 'git status'
abbr -a gsta 'git stash push'
abbr -a gstp 'git stash pop'
abbr -a gsu 'git submodule update --remote --recursive'
abbr -a gup 'git pull'

# Global abbreviations
abbr -a C --position anywhere --set-cursor '%| wl-copy'
abbr -a G --position anywhere --set-cursor '%| grep -i'
abbr -a H --position anywhere --set-cursor '%| head'
abbr -a J --position anywhere --set-cursor '%| jq'
abbr -a L --position anywhere --set-cursor '%| less -R'
abbr -a T --position anywhere --set-cursor '%| tail'
