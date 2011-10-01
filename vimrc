" chesh1r's vimrc
" Maintained by Alexey Bednyakov, <cheshir.box@google.com>

" Загрузка pathogen'a (https://github.com/tpope/vim-pathogen)
filetype off
call pathogen#runtime_append_all_bundles()
filetype plugin indent on

set nocompatible            " Предпочтение натройкам Vim относительно Vi
set ruler                   " Показывать положение курсора всё время
set showcmd                 " Показывать незавершённые команды в статусбаре
set nu                      " Включаем нумерацию строк
set autoread                " Автоматическая перезагрузка при изменении
set foldmethod=indent       " Фолдинг по отсупам
set scrolljump=3            " Теперь нет необходимости передвигать курсор к 
set scrolloff=3             "   краю экрана, чтобы подняться/отпуститься
set shortmess+=I            " И больше не будет детей Уганды
set history=128             " Хранить больше истории команд
set undolevels=2048         "   и правок
set t_Co=256                " Ставим терминалу 256 цветов
colorscheme wombat256mod    " Цветовая тема
set guifont=Monospace\ Book\ 10

" Выключить звук на ошибки 
    set noerrorbells
    set novisualbell            
    set tm=500
    set t_vb=   

" Строка состояния 
    set ch=1                    " Сделать строку команд высотой в одну строку
    set laststatus=2            " У последнего окна всегда есть статус
    set statusline=\ %<%-15.25(%f%)%m%r%h\ %w\ \
    set statusline+=\ \ \ [%{&ff}/%Y]
    set statusline+=\ \ \ %<%20.30(%{hostname()}:%{CurDir()}%)\
    set statusline+=%=%-10.(%l,%c%V%)\ %p%%/%L

    function! CurDir()
        let curdir = substitute(getcwd(), $HOME, "~", "")
            return curdir
    endfunction

" Настройка отступов и tab 
    set autoindent
    set expandtab
    set shiftwidth=4
    set softtabstop=4
    set tabstop=4
    set smartindent
    set smarttab

" Поддержка мыши 
    set mouse=a             " Использовать мышь, если терминал позволяет
    set mousemodel=popup    " Выдавать меню по правому клику
    set mousehide           " Скрывать указатель мыши когда печатаем

" Поиск 
    set ignorecase  " Поиск не чувствительный к регистру 
    set incsearch   " ...с подсветкой
    set hlsearch    " ...по набору текста

" Подстветка синтаксиса 
    syntax on
    let python_highlight_all = 1

" Меню выбора кодировки текста 
    set wildmenu
    set wcm=<Tab> 
    menu Encoding.koi8-r :e ++enc=koi8-r<CR>
    menu Encoding.windows-1251 :e ++enc=cp1251<CR>
    menu Encoding.cp866 :e ++enc=cp866<CR>
    menu Encoding.utf-8 :e ++enc=utf8 <CR>

" Переключение на русскую/английскую раскладку по Ctrl-/ 
    set termencoding=utf-8
    set fileencodings=utf-8,latin1,cp1251
    set keymap=russian-jcukenwin   
    set iminsert=0 
    set imsearch=0 
    cmap  <C-^>
    map   <C-^>X<Esc>:call MyKeyMapHighlight()<CR>a<C-H>
    imap  <Esc>a<C-^><Esc>:call MyKeyMapHighlight()<CR>a
    nmap  a<C-^><Esc>:call MyKeyMapHighlight()<CR>
    vmap  <Esc>a<C-^><Esc>:call MyKeyMapHighlight()<CR>gv
    " Индикация выбранной в данный момент раскладки
    function MyKeyMapHighlight()
       if &iminsert == 0
           " TODO Определяь цвет относительно gui
           hi StatusLine ctermfg=Blue guifg=Blue
       else
           hi StatusLine ctermfg=Red guifg=Red
       endif
    endfunction
    call MyKeyMapHighlight()
    " При изменении активного окна будет выполняться обновление индикации текущей раскладки
    au WinEnter * :call MyKeyMapHighlight()

" Сохранение резервных копий в ~/.backup 
    set backup
    function! BackupDir()
        " определим каталог для сохранения резервной копии
        let l:backupdir=$HOME.'/.backup/'.
                \substitute(expand('%:p:h'), '^'.$HOME, '~', '')
        " если каталог не существует, создадим его рекурсивно
        if !isdirectory(l:backupdir)
            call mkdir(l:backupdir, 'p', 0700)
        endif
        " переопределим каталог для резервных копий
        let &backupdir=l:backupdir
        " переопределим расширение файла резервной копии
        let &backupext=strftime('~%Y-%m-%d~')
    endfunction
    " выполним перед записью буффера на диск
    autocmd! bufwritepre * call BackupDir()

" Автокомплит "из текущего"
    function InsertTabWrapper()
         let col = col('.') - 1
         if !col || getline('.')[col - 1] !~ '\k'
             return "\<tab>"
         else
             return "\<c-p>"
         endif
    endfunction
    " Будем завершать из текущего буфера, других открытых буферов, тегов
    set complete=".bt"

" Cпецифичные для maemo
    " Скроллинг пальцем
    " http://www.vim.org/scripts/script.php?script_id=3141
    "func! MScroll()
      "let l:done=0
      "let l:n = -1
      "let l:w0 = line("w0")
      "let l:last = line("$")
      "while done!=1
        "let l:g = getchar()
        "if l:g != "\<LeftDrag>"
          "let done = 1
        "else
          "if l:n == -1
            "let l:n = v:mouse_lnum
            "let l:fln = v:mouse_lnum
          "else
            "let l:new = l:w0 - v:mouse_lnum + l:n
            "if l:new<1
              "let l:new = 1
            "endif
            "let l:diff = -v:mouse_lnum + l:n
            "let l:nd = line("w$")
            "if l:nd+l:diff>l:last
              "let l:new = l:last - winheight(0) + 1
              "if l:new<1
                "let l:new = 1
              "endif
            "end
            "let l:wn = "normal ".string(l:new)."zt"
            "if (l:n != v:mouse_lnum)
              "exec(l:wn)
              "redraw
            "endif
            "let l:w0 = line("w0")
            "let l:n = v:mouse_lnum + l:diff
          "endif
        "endif
      "endwhile
      ":call cursor(v:mouse_lnum,v:mouse_col)
    "endfunc
    ":set mouse=a
    ":noremap <silent> <LeftMouse> :call MScroll()<CR>
    ":noremap <LeftRelease> <Nop>
    ":noremap <LeftDrag> <Nop>

    " Ctrl-Space (переключение консоли) ничего не ломает.
    "imap <Nul> <Nop>
    "map <Nul> <Nop>
    "vmap <Nul> <Nop>
    "cmap <Nul> <Nop>
    "nmap <Nul> <Nop>




"---------------------------------------------------
"--------------------- МОДУЛИ ----------------------
"---------------------------------------------------

" Настройки для PyDiction
    let g:pydiction_location = '/home/chesh1r/.vim/pydiction/complete-dict' 
    let g:pydiction_menu_height = 10

" Настройки для SessionMgr 
    let g:SessionMgr_AutoManage = 0
    let g:SessionMgr_DefaultName = "mysession"

" Настройки для Tlist (показвать только текущий файл в окне навигации по  коду) 
    let g:Tlist_Show_One_File = 1
    set completeopt-=preview
    set completeopt+=longest
    set mps-=[:]
    map \T :TlistToggle<cr>

" Настройки для OmniComletion 
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType java set omnifunc=javacomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
    autocmd FileType c set omnifunc=ccomplete#Complete

" Настройки для Tasklist 
    map T :TaskList<cr>
    map P :TlistToggle<cr>




"---------------------------------------------------
"--------------------- ХОТКЕИ ----------------------
"---------------------------------------------------
nmap <Space> <PageDown>

" Ctrl+j - сниппеты
let g:snippetsEmu_key = "<C-j>"

" Shift+Tab - автокомплит "из текущего"
inoremap <silent> <S-Tab> <C-r>=InsertTabWrapper()<cr>

" Поиск и замена слова под курсором
nmap ; :%s/\<<c-r>=expand("<cword>")<cr>\>/

" \br - поиск и замена слова под курсором во всех буферах (Tip #382)
nmap \br :call Replace()<cr>
fun! Replace()
    let s:word = input("Replace " . expand('<cword>') . " with:")
    :exe 'bufdo! %s/\<' . expand('<cword>') . '\>/' . s:word . '/ge'
    :unlet! s:word
endfun 

" \rr - запуск Python скриптов в стиле perl-support
autocmd BufRead *.py nmap      /rr :w !python %<cr>
autocmd BufRead *.py vmap <esc>/rr :w !python %<cr>
autocmd BufRead *.py imap <esc>/rr :w !python %<cr>

" \r. - для LaTeX
autocmd BufRead *.tex nmap      \rr :w !latex %<cr>
autocmd BufRead *.tex vmap <esc>\rr :w !latex %<cr>
autocmd BufRead *.tex imap <esc>\rr :w !latex %<cr>
autocmd BufRead *.tex nmap      \rp :w !pdflatex %<cr>
autocmd BufRead *.tex vmap <esc>\rp :w !pdflatex %<cr>
autocmd BufRead *.tex imap <esc>\rp :w !pdflatex %<cr>

" \rr - для C
autocmd BufRead *.c nmap      /rr :w !tcc -run %<cr>
autocmd BufRead *.c vmap <esc>/rr :w !tcc -run %<cr>
autocmd BufRead *.c imap <esc>/rr :w !tcc -run %<cr>

" \e. - смена кодировок 
    " \ek - koi8.
    nmap \ek :e ++enc=koi8-r<cr>
    vmap \ek :e ++enc=koi8-r<cr>
    imap \ek :e ++enc=koi8-r<cr>
    " \ew - cp1251 она же win.
    nmap \ew :e ++enc=cp1251<cr>
    vmap \ew :e ++enc=cp1251<cr>
    imap \ew :e ++enc=cp1251<cr>
    " \ec - cp866.
    nmap \ec :e ++enc=cp866<cr>
    vmap \ec :e ++enc=cp866<cr>
    imap \ec :e ++enc=cp866<cr>
    " \eu - utf8. Yarr!
    nmap \eu :e ++enc=utf8<cr>
    vmap \eu :e ++enc=utf8<cr>
    imap \eu :e ++enc=utf8<cr>
    " \eu - rot13 до конца файла.
    nmap \er g?G <cr>
    vmap \er g?G <cr>
    imap \er g?G <cr>

" Новый таб
nmap tn :tabnew 

" `+F2 - быстрое сохранение без вопросов
nmap `<F2> :w!<cr>
vmap `<F2> <esc>:w!<cr>
imap `<F2> <esc>:w!<cr>

" 1+F2 - быстрое sudo-сохранение
nmap 1<F2> :w !sudo tee %<cr>
vmap 1<F2> <esc>:w !sudo tee %<cr>
imap 1<F2> <esc>:w !sudo tee %<cr>

" F7 - проверка орфографии
imap <F7> <Esc>:setlocal spell spelllang=ru_yo,en_us<CR>a
nmap <F7> :setlocal spell spelllang=ru_yo,en_us<CR>

" Shift-F7 - отключить проверку орфографии
imap <S-F7> <Esc>:setlocal spell spelllang=<CR>a
nmap <S-F7> :setlocal spell spelllang=<CR>

