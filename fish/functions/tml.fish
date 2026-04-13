function tml --description "Create a Tmux Mullvad Layout: watch, ping, and shell panes"
    if test -z "$TMUX"
        echo "You must start tmux to use tml."
        return 1
    end

    set -l current_dir $PWD
    set -l watch_pane $TMUX_PANE
    tmux rename-window -t $watch_pane mullvad

    set -l shell_pane (tmux split-window -v -p 10 -t $watch_pane -P -F '#{pane_id}')
    set -l ping_pane (tmux split-window -h -t $watch_pane -P -F '#{pane_id}')

    tmux send-keys -t $watch_pane "watch -c 'mullvad status --json | jq -C'" C-m
    tmux send-keys -t $ping_pane "ping 1.1" C-m
    tmux send-keys -t $shell_pane "mullvad reconnect"
    tmux select-pane -t $shell_pane
end
