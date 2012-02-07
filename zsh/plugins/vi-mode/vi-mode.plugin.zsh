# Интеграция с vim.
bindkey -v

function zle-line-init zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
    RPS2=$RPS1
    zle reset-prompt
}

# Создание режимов на основе существующих.
bindkey -N myviins viins
bindkey -N myvicmd vicmd

# Режим вставки по умолчанию.
bindkey -A myviins main

# Отображение действующего режима.
zle -N zle-line-init
zle -N zle-keymap-select

# Памятка с текущими привязками.
function list_mappings(){bindkey}; zle -N list_mappings
alias :map='list_mappings'

# Заплатки для непривычного поведения.
bindkey "\e[2~" yank
bindkey "\e[3~" delete-char
bindkey "\e[5~" up-line-or-history
bindkey "\e[6~" down-line-or-history
bindkey "\e[A" up-line-or-search # Верхняя стелка := вверх по истории
bindkey "\e[B" down-line-or-search # Нижняя стелка := вниз по истории

