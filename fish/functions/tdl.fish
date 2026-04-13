function tdl --description "Create a Tmux Dev Layout with editor, ai, and terminal"
    # Usage: tdl <opencode|claude|codex|other_ai> [<second_ai>]
    if test -z "$argv[1]"
        echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"
        return 1
    end
    if test -z "$TMUX"
        echo "You must start tmux to use tdl."
        return 1
    end

    set -l current_dir $PWD
    set -l ai $argv[1]
    set -l ai2 $argv[2]
    set -l editor_pane $TMUX_PANE

    tmux rename-window -t $editor_pane (basename $current_dir)

    # Split vertically — top 90%, bottom 10%
    tmux split-window -v -p 10 -t $editor_pane -c $current_dir

    # Split editor pane horizontally — AI on right 30%
    set -l ai_pane (tmux split-window -h -p 30 -t $editor_pane -c $current_dir -P -F '#{pane_id}')

    # If second AI provided, split the AI pane vertically
    if test -n "$ai2"
        set -l ai2_pane (tmux split-window -v -t $ai_pane -c $current_dir -P -F '#{pane_id}')
        tmux send-keys -t $ai2_pane "$ai2" C-m
    end

    tmux send-keys -t $ai_pane "$ai" C-m
    tmux send-keys -t $editor_pane "vi ." C-m
    tmux select-pane -t $editor_pane
end
