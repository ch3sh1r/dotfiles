# Wrap ssh to clean up the terminal and reconnect when a connection drops.
#
# A remote tmux or editor arms terminal modes over the SSH pipe (mouse
# tracking, focus reporting, the alternate screen) that only it can disarm. If
# the link dies instead of exiting cleanly, those modes stay armed locally and
# every mouse move floods the prompt with escape junk.
function ssh --wraps ssh --description "ssh with terminal cleanup and reconnect on dropped links"
    set -l started (date +%s)
    command ssh $argv
    set -l rc $status

    isatty stdout; or return $rc
    __ssh_disarm

    # Reconnect only when an established interactive session drops: ssh exits
    # 255 for transport failures, but a fast 255 is a connect/auth failure, a
    # remote command's own 255 must not replay its side effects, and a piped
    # stdin would feed the rest of the input to a fresh remote shell.
    if test $rc -ne 255
        return $rc
    end
    isatty stdin; or return $rc
    __ssh_interactive $argv; or return $rc
    if test (math (date +%s) - $started) -lt 30
        return $rc
    end

    # Keep retrying fast failures too: a rebooting server refuses connections.
    while true
        echo "Connection lost. Reconnecting (Ctrl-C to stop)..."
        sleep 2
        command ssh $argv
        set rc $status
        __ssh_disarm
        if test $rc -ne 255
            return $rc
        end
    end
end

# Disarm mouse tracking (1000/1002/1003, 1006 encoding), focus reporting
# (1004) and the alternate screen (1049), and show the cursor again.
function __ssh_disarm
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h'
end

# True for an interactive session: a destination and no remote command. The
# letters are the ssh(1) options that take a value, so their arguments are not
# mistaken for the destination.
function __ssh_interactive
    set -l value_opts BbcDEeFIiJLlmOoPpQRSWw
    set -l dest ""
    set -l opts_done ""
    set -l args $argv

    while test (count $args) -gt 0
        set -l arg $args[1]
        set -e args[1]

        if test -z "$opts_done"; and test "$arg" = --
            set opts_done 1
        else if test -z "$opts_done"; and string match -qr '^-.+' -- $arg
            set -l letters (string sub -s 2 -- $arg)
            set -l n (string length -- $letters)
            for i in (seq $n)
                set -l letter (string sub -s $i -l 1 -- $letters)
                if string match -q "*$letter*" -- $value_opts
                    # The value is glued to the letter (-p2222) unless the
                    # letter ends the argument, then it consumes the next one.
                    if test $i -eq $n
                        set -e args[1]
                    end
                    break
                end
            end
        else if test -z "$dest"
            set dest $arg
        else
            return 1
        end
    end

    test -n "$dest"; or return 1

    # A RemoteCommand from ssh_config replays on reconnect like a positional
    # command. `ssh -G` resolves the effective config without connecting; fail
    # closed when it cannot, since an undetected RemoteCommand must not replay.
    set -l resolved (command ssh -G $argv 2>/dev/null); or return 1
    for line in $resolved
        if string match -qir '^remotecommand ' -- $line
            string match -qir '^remotecommand none$' -- $line; or return 1
        end
    end
    return 0
end
