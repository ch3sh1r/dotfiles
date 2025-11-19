# Fish shell completion for egpu command
# Installation: Place this file in ~/.config/fish/completions/egpu.fish
complete -c egpu -f -d "eGPU Manager - Manage external monitors and eGPU"
complete --command egpu --exclusive --condition __fish_use_subcommand --arguments enable --description "Enable eGPU and external monitors"
complete -c egpu -n __fish_use_subcommand -a disable -d "Disable eGPU and external monitors"
complete -c egpu -n __fish_use_subcommand -a status -d "Show current eGPU and monitor status"
complete -c egpu -n __fish_use_subcommand -a help -d "Show help message"
