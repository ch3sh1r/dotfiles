# @ch3sh1r's dotfiles

## Установка с Git

Репозиторий клонируется куда угодно (у меня обычно получается 
`~/<long_way_to_code_directory>/dotfiles`) и из него кидаются 
симлинки в `~`:

    git clone https://github.com/ch3sh1r/dotfiles.git && cd dotfiles && ./push.sh -l

Иногда удобнее скопировать минимально необходимое и обойтись 
без зависимостей в виде симлинков. На этот случай `./push.sh -f`
скопирует все без настроек awesome и еще какой-то шелухи.

## Установка без Git

To get these dotfiles tarball without Git:
Можно скачать архив со свежайшими комитами:

    cd; wget https://github.com/ch3sh1r/dotfiles/tarball/master

Затем ручками распаковать (`tar xzf dotfiles`) и выполнить `./push.sh`.

