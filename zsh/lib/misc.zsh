# Не пиликать.
setopt NO_BEEP
# Перемещасться в директорию без cd.
setopt AUTO_CD
# Править все, при любой возможности.
setopt CORRECT_ALL
# zsh будет обращаться с пробелами так же, как и bash
setopt SH_WORD_SPLIT 
# Не считать Control+C за выход из оболочки
setopt  IGNORE_EOF

bindkey "\e[A" up-line-or-search # Верхняя стелка := вверх по истории
bindkey "\e[B" down-line-or-search # Нижняя стелка := вниз по истории

