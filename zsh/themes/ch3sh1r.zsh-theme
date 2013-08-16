PROMPT="%(#.%{$bg[red]%}.%{$fg[magenta]%})%n%{$reset_color%}%{$fg[lightgrey]%}@%m %~ %{$reset_color%}
%(?.%{$fg[lightgrey]%}.%{$bg[red]%})$(git_prompt_info)>>%{$reset_color%} "

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[white]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="*"
ZSH_THEME_GIT_PROMPT_CLEAN=""
