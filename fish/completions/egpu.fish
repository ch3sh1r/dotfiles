# Fish shell completion for egpu command
complete -c egpu -f
complete -c egpu -n __fish_use_subcommand -a enable -d "Enable eGPU and external monitors"
complete -c egpu -n __fish_use_subcommand -a disable -d "Disable eGPU and external monitors"
complete -c egpu -n __fish_use_subcommand -a status -d "Show current eGPU and monitor status"
complete -c egpu -n __fish_use_subcommand -a help -d "Show help message"
