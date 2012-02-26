" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Alexey Bednyakov, <cheshir.box@google.com>

" pathogen (https://github.com/tpope/vim-pathogen)
filetype off
call pathogen#infect()
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()
filetype plugin indent on
syntax on

set nocompatible            " Предпочтение настройкам Vim относительно Vi
set ruler                   " Показывать положение курсора всё время
set showcmd                 " Показывать незавершённые команды в статусбаре
set nu                      " Включаем нумерацию строк
set autoread                " Автоматическая перезагрузка при изменении
set foldmethod=indent       " Фолдинг по отсупам
set modelines=0             " Во-первых не нужны, во-вторых - дырки (http://clck.ru/Lx2G)
set scrolljump=3            " Теперь нет необходимости передвигать курсор к 
set scrolloff=3             "   краю экрана, чтобы подняться/отпуститься
set shortmess+=I            " И больше не будет детей Уганды
set history=128             " Хранить больше истории команд
set undolevels=2048         "   и правок

"--------------------- СРЕДА -----------------------
    " Выключить звук на ошибки 
        set noerrorbells
        set novisualbell            
        set tm=500
        set t_vb=   

    " Строка состояния 
        set ch=1                " Сделать строку команд высотой в одну строку
        set laststatus=2        " У последнего окна всегда есть статус
        set statusline=\ %<%-15.25(%f%)%m%r%h\ %w\ \
        set statusline+=\ \ \ [%{&ff}/%Y]
        set statusline+=\ \ \ %<%20.30(%{hostname()}:%{CurDir()}%)\
        set statusline+=%=%-10.(%l,%c%V%)\ %p%%/%L
        function! CurDir()
            let curdir = substitute(getcwd(), $HOME, "~", "")
                return curdir
        endfunction

    " Настройка отступов и табов 
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
        set ignorecase          " Поиск не чувствительный к регистру 
        set smartcase           "   сообразительный 
        set incsearch           "   с подсветкой
        set hlsearch            "   по набору текста

    " Подстветка
        set t_Co=256
        let g:solarized_termcolors = 256
        let python_highlight_all = 1
        set background=dark
        colorscheme solarized
        autocmd BufRead *.conf :set filetype=sh

    " Меню выбора кодировки текста 
        set wildmenu
        set wcm=<Tab> 
        menu Encoding.koi8-r :e ++enc=koi8-r<cr>
        menu Encoding.windows-1251 :e ++enc=cp1251<cr>
        menu Encoding.cp866 :e ++enc=cp866<cr>
        menu Encoding.utf-8 :e ++enc=utf8<cr>

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
               hi StatusLine ctermfg=blue guifg=lightblue
           else
               hi StatusLine ctermfg=red guifg=lightred
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


"--------------------- ПЛАГИНЫ ---------------------
    " SessionMgr 
        let g:SessionMgr_DefaultName = "mysession"
        let g:SessionMgr_AutoManage = 0

    " py-mode (https://github.com/klen/python-mode)
        " Документация
            let g:pymode_doc = 1
            let g:pydoc = 'pydoc'
            let g:pymode_doc = 'K'
        " Запуск
            let g:pymode_run = 1
            let g:pymode_run_key = '<leader>r'
        " Проверка
            let g:pymode_lint = 1
            let g:pymode_lint_config = "$HOME/.pylintrc"
            let g:pymode_lint_checker = "pylint"            " pylint или pyflakes
            let g:pymode_lint_write = 0                     " Проверка при записи
            let g:pymode_lint_onfly = 0                     " Проверка в процессе
            let g:pymode_lint_cwindow = 0                   " Открывать cwindow при найденных
            let g:pymode_lint_message = 1                   " Сообшение о ошибке при наводе курсора
            let g:pymode_lint_jump = 0                      " Автоматический прыжок на найденную ошибку
            let g:pymode_lint_signs = 1                     " Отметки об ошибках в левой панели
            let g:pymode_lint_minheight = 3                 " Минимальная...
            let g:pymode_lint_maxheight = 6                 "  ...и максимальная высота окошка с ошибками
        " Рефакторинг
            let g:pymode_rope = 1
            let g:pymode_rope_auto_project = 1
            let g:pymode_rope_enable_autoimport = 1
            let g:pymode_rope_autoimport_generate = 1
            let g:pymode_rope_autoimport_underlineds = 0
            let g:pymode_rope_codeassist_maxfixes = 10
            let g:pymode_rope_sorted_completions = 1
            let g:pymode_rope_extended_complete = 1
            let g:pymode_rope_autoimport_modules = ["os","shutil","datetime"]
            let g:pymode_rope_confirm_saving = 1
            let g:pymode_rope_global_prefix = "<C-x>p"
            let g:pymode_rope_local_prefix = "<C-c>r"
            let g:pymode_rope_vim_completion = 1
            let g:pymode_rope_guess_project = 1
            let g:pymode_rope_goto_def_newwin = 0
            let g:pymode_rope_always_show_complete_menu = 0
        " Подсветка
            let g:pymode_syntax = 1                                         " Enable pymode's custom syntax highlighting
            let g:pymode_syntax_all = 1                                     " Enable all python highlightings
            let g:pymode_syntax_print_as_function = 0                       " Highlight 'print' as function
            let g:pymode_syntax_indent_errors = g:pymode_syntax_all         " Highlight indentation errors
            let g:pymode_syntax_space_errors = g:pymode_syntax_all          " Highlight trailing spaces
            let g:pymode_syntax_string_formatting = g:pymode_syntax_all     " Highlight string formatting
            let g:pymode_syntax_string_format = g:pymode_syntax_all         " Highlight str.format syntax
            let g:pymode_syntax_string_templates = g:pymode_syntax_all      " Highlight string.Template syntax
            let g:pymode_syntax_doctests = g:pymode_syntax_all              " Highlight doc-tests
            let g:pymode_syntax_builtin_objs = g:pymode_syntax_all          " Highlight builtin objects (__doc__, self, etc)
            let g:pymode_syntax_builtin_funcs = g:pymode_syntax_all         " Highlight builtin functions
            let g:pymode_syntax_highlight_exceptions = g:pymode_syntax_all  " Highlight exceptions
            let g:pymode_syntax_slow_sync = 0                               " For fast machines
        let g:pymode_motion = 1                     " Load python objects and motion
        let g:pymode_breakpoint = 1                 " Load breakpoints plugin
        let g:pymode_breakpoint_key = '<leader>b'   " Key for set/unset breakpoint
        let g:pymode_utils_whitespaces = 1          " Autoremove unused whitespaces
        let g:pymode_virtualenv = 1                 " Auto fix vim python paths if virtualenv enabled
        let g:pymode_options_indent = 1             " Set default pymode python indent options
        let g:pymode_options_fold = 1               " Set default pymode python fold options
        let g:pymode_options_other = 1              " Set default pymode python other options

    " Tlist (показвать только текущий файл в окне навигации по коду) 
        let g:Tlist_Show_One_File = 1
        set completeopt-=preview
        set completeopt+=longest
        set mps-=[:]
        map <leader>L :TlistToggle<cr>

    " OmniComletion 
        autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
        autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
        autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
        autocmd FileType java set omnifunc=javacomplete#Complete
        autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
        autocmd FileType css set omnifunc=csscomplete#CompleteCSS
        autocmd FileType c set omnifunc=ccomplete#Complete

    " SnipetsEmu
        let g:snippetsEmu_key = "<C-j>"

    " Tasklist 
        map <leader>T :TaskList<cr>

    " Самопальные шаблоны
        autocmd! BufNewFile * silent! 0r ~/.vim/templates/template.%:e


"--------------------- ХОТКЕИ ----------------------
    " Shift+Tab - автокомплит "из текущего"
        inoremap <silent><S-Tab> <C-r>=InsertTabWrapper()<cr> 

    " Поиск и замена слова под курсором
        nmap ; :%s/\<<c-r>=expand("<cword>")<cr>\>/           

    " Убрать мусор из прошлого поиска
        nnoremap <leader><space> :noh<cr>                     

    " Новый таб
        nmap tn :tabnew                                       

    " Беглые скачки
        nmap <Space> <PageDown>
        vmap <Space> <PageDown>
        nmap b <PageUp>
        vmap b <PageUp>

    " Поиск нормальными регулярками
        nnoremap / /\v
        vnoremap / /\v
        
    " leader-шорткаты
        " \r - запуск Python скриптов

        " \r - для C
        autocmd BufRead *.c nnoremap <leader>r :!tcc -run %<cr>

        " \r. - для LaTeX
        autocmd BufRead *.tex nnoremap <leader>rr :!latex %<cr>
        autocmd BufRead *.tex nnoremap <leader>rp :!pdflatex %<cr>

        " \br - поиск и замена слова под курсором во всех буферах (Tip #382)
            nmap <leader>br :call Replace()<cr>
            fun! Replace()
                let s:word = input("Replace " . expand('<cword>') . " with:")
                :exe 'bufdo! %s/\<' . expand('<cword>') . '\>/' . s:word . '/ge'
                :unlet! s:word
            endfun 

        " \e. - смена кодировок 
            " \ek - koi8.
            nmap <leader>ek :e ++enc=koi8-r<cr>
            vmap <leader>ek :e ++enc=koi8-r<cr>
            imap <leader>ek :e ++enc=koi8-r<cr>
            " \ew - cp1251 она же win.
            nmap <leader>ew :e ++enc=cp1251<cr>
            vmap <leader>ew :e ++enc=cp1251<cr>
            imap <leader>ew :e ++enc=cp1251<cr>
            " \ec - cp866.
            nmap <leader>ec :e ++enc=cp866<cr>
            vmap <leader>ec :e ++enc=cp866<cr>
            imap <leader>ec :e ++enc=cp866<cr>
            " \eu - utf8. Yarr!
            nmap <leader>eu :e ++enc=utf8<cr>
            vmap <leader>eu :e ++enc=utf8<cr>
            imap <leader>eu :e ++enc=utf8<cr>
            " \eu - rot13 до конца файла.
            nmap <leader>er g?G <cr>
            vmap <leader>er g?G <cr>
            imap <leader>er g?G <cr>
            
    " F<номер>-шорткаты
        " F1 - больше не поможет
            inoremap <F1> <ESC>
            nnoremap <F1> <ESC>
            vnoremap <F1> <ESC>

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

    " Работа с буерами
        " Быстрый сплит
        nnoremap <leader>w <C-w>v<C-w>l   
        " Быстрое перемещение
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l

