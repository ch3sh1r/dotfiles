# Based on: https://github.com/dideler/dotfiles/blob/master/functions/extract.fish

function extract --description "Expand or extract bundled & compressed files"
    if test (count $argv) -eq 0
        echo "usage: extract FILE..." >&2
        return 1
    end

    set --local status_code 0
    for file in $argv
        switch $file
            case '*.tar' '*.tar.gz' '*.tgz' '*.tar.xz' '*.txz' '*.tar.bz2' '*.tbz2' '*.tar.zst' '*.tzst'
                tar -xvaf $file
            case '*.gz'
                gunzip -k $file
            case '*.xz'
                unxz -k $file
            case '*.bz2'
                bunzip2 -k $file
            case '*.zst'
                unzstd $file
            case '*.rar'
                unrar x $file
            case '*.zip'
                unzip $file
            case '*.7z'
                7z x $file
            case '*'
                echo "extract: unknown extension: $file" >&2
                set status_code 1
                continue
        end
        or set status_code 1
    end
    return $status_code
end
