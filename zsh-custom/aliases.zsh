alias genpasswd='openssl rand -base64 12'
alias iddqd='sudo -s'
alias l='ls'
alias p='ps auxw'
alias vi='vim'

alias -g D=' | colordiff | less'
alias -g C=' | column -t'
alias -g J=' | jq'

alias gitup='gitup open'
alias gp!='gp -f'
alias gpsup!='gpsup -f'
alias gpr='git-quick-stats -r'

alias brew_link_vim='ln -Fs `find /usr/local -name "MacVim.app"` /Applications/MacVim.app'
alias converge='cookstyle -a && foodcritic . && kitchen converge'

# Enter container on HW node
pve() {
    hw_node=$(prls-find-ve $1)
    if [ -z "${hw_node}" ]; then
       echo "VE $1 not found."
       return 1
    fi

    if [ "$#" -eq 1 ]; then
        echo "Connecting to $hw_node, entering $1 node."
        ssh ${hw_node} -t "sudo /usr/sbin/vzctl enter $1"
    else
        ssh ${hw_node} -o LogLevel=QUIET -t "sudo /usr/sbin/vzctl exec $1 '${@:2}'"
    fi
}

# Setup Jira hook for repo
ghj() {
    if [ ! -d .git/hooks ]; then
        echo "Error: Not a git repo."
        return 1
    fi
    hook_file=.git/hooks/commit-msg
    if [ -f ${hook_file} ]; then
        echo "Error: ${hook_file} exists."
        return 1
    fi
    cat <<EOF >${hook_file}
#!/bin/sh
commit_file=\$1
commit_msg=\$(cat \${commit_file})
current_branch=\$(git rev-parse --abbrev-ref HEAD)
jira_id=\$(echo "\${current_branch}" | grep -Eo "[A-Z0-9]{1,10}-?[A-Z0-9]+")
if [ ! -z "\${jira_id}" ]; then
    if [[ ! \$commit_msg == \${jira_id}* ]]; then
        echo "\${jira_id} \${commit_msg}" > \${commit_file}
        echo "Jira ID \${jira_id}, matched in current branch name, prepended to commit message."
    fi
fi
EOF
    chmod 755 ${hook_file}
    echo "Created ${hook_file} hook file."
}
