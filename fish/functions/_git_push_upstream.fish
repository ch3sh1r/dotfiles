function _git_push_upstream --description 'Expansion for the gpu abbr: push current branch and set upstream'
    set -l branch (git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if test -z "$branch"
        # Not on a branch (detached HEAD or not a repo) — leave the branch
        # slot empty so it can be filled in by hand.
        echo "git push --set-upstream origin "
    else
        echo "git push --set-upstream origin $branch"
    end
end
