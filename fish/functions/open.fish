function open --description "Open files or URLs with the default app, detached from the terminal"
    xdg-open $argv >/dev/null 2>&1 &
    disown
end
