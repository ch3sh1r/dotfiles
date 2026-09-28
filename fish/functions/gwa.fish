function gwa --description "Create a git worktree and branch next to the repo (../<repo>--<branch>)"
    if test -z "$argv[1]"
        echo "Usage: gwa <branch name>"
        return 1
    end

    set -l branch $argv[1]
    set -l base (basename $PWD)
    set -l wt_path "../$base--$branch"

    git worktree add -b $branch $wt_path; or return 1
    cd $wt_path
end
