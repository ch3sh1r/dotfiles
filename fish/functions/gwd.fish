function gwd --description "Remove the current git worktree (created by gwa) and its branch"
    set -l cwd $PWD
    set -l worktree (basename $cwd)

    # gwa names worktrees <repo>--<branch>; refuse anything else so a plain
    # checkout is never removed by accident.
    if not string match -q '*--*' -- $worktree
        echo "gwd: $worktree is not a gwa worktree (<repo>--<branch>)"
        return 1
    end

    # Split on the first "--", as gwa joined them.
    set -l parts (string split -m1 -- '--' $worktree)
    set -l root $parts[1]
    set -l branch $parts[2]

    read -l -P "Remove worktree $worktree and branch $branch? [y/N] " answer
    string match -qi y -- $answer; or return 0

    cd "../$root"; or return 1
    git worktree remove $cwd --force; or return 1
    git branch -D $branch
end
