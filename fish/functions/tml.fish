function tml --description "Create a Tmux Mullvad Layout: status, logs, wg, relay, ping, and shell panes"
    if test -z "$TMUX"
        echo "You must start tmux to use tml."
        return 1
    end

    set -l watch_pane $TMUX_PANE
    tmux rename-window -t $watch_pane mullvad
    set -l shell_pane (tmux split-window -v -p 5 -t $watch_pane -P -F '#{pane_id}')
    set -l journal_pane (tmux split-window -h -p 60 -t $watch_pane -P -F '#{pane_id}')
    set -l ping_pane (tmux split-window -v -p 30 -t $journal_pane -P -F '#{pane_id}')

    tmux send-keys -t $watch_pane \
        "watch -c 'mullvad status --json | jq -C'" C-m

    tmux send-keys -t $journal_pane \
        "journalctl -u mullvad-daemon -f --no-hostname -o cat | grep --line-buffered -iE 'error|warn|connect|handshake|relay|timeout|block|disconn|obfusc'" C-m

    tmux send-keys -t $ping_pane \
        "ping 1.1.1.1" C-m

    tmux send-keys -t $shell_pane \
        "mullvad reconnect"

    tmux select-pane -t $shell_pane
end
