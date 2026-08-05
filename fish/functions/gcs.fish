function gcs --description "Commit current status and push"
    git status

    set -l changes (git status --porcelain)
    if test (count $changes) -eq 0
        echo "No edits to commit."
        return 0
    end

    git add --all; or return 1
    git commit --verbose --message "status update: "(date +"%Y-%m-%dT%H:%M"); or return 1
    git pull; or return 1
    git push
end
