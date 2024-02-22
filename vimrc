" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Aleksei Bedniakov, <x@rxtx.wtf>

set nocompatible
set ruler
set showcmd
set number
set relativenumber
set nowrap
set linebreak
set scrolljump=2
set scrolloff=2
set backspace=indent,eol,start

call plug#begin('~/.vim/plugged')
    Plug 'dracula/vim',  { 'as': 'dracula' }
    Plug 'dyng/ctrlsf.vim'
    Plug 'scrooloose/nerdcommenter'
call plug#end()

" Tabs
    set smarttab
    set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

" Mouse support
    set mouse=a                  " Использовать мышь, если терминал позволяет
    set mousemodel=popup         " Выдавать меню по правому клику
    set mousehide                " Скрывать указатель мыши во время печати

" Search
    set ignorecase               " Поиск не чувствительный к регистру
    set smartcase                "  сообразительный
    set incsearch                "  по набору текста
    set hlsearch                 "  с подсветкой

" Colors
    colorscheme dracula

" Russian layout mapping
    set termencoding=utf-8
    set fileencodings=utf-8,latin1,cp1251
    set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

" Change controlling key
    let mapleader = ' '

" Shourtcut to remove trash highlight from previous search
    nmap <leader><space> :noh<cr>

" Show unprinted symbols
    set listchars=eol:¶,tab:→\ ,trail:~,extends:›,precedes:‹,space:·,nbsp:‡
    function! ToggleList()
        if &list
            set nolist
            let &colorcolumn=""
        else
            set list
            let &colorcolumn=join(range(121,121),",")
        endif
    endfunction
    nmap <leader>l :call ToggleList()<cr>

" Search by highlighted
    vmap // y/\c<c-r>"<cr>
    vmap /? y?\c<c-r>"<cr>

" Change file encoding
    nmap <leader>ek :e ++enc=koi8-r<cr>
    nmap <leader>ew :e ++enc=cp1251<cr>
    nmap <leader>ec :e ++enc=cp866<cr>
    nmap <leader>eu :e ++enc=utf8<cr>
    nmap <leader>er ggg?G <cr>

" Move by buffers
    map <leader>a :bprev!<return>
    map <leader>s :bnext!<return>
    map <leader>d :bd<return>

" File search
    nmap     <C-F>f <Plug>CtrlSFPrompt
    vmap     <C-F>f <Plug>CtrlSFVwordPath
    vmap     <C-F>F <Plug>CtrlSFVwordExec
    nmap     <C-F>n <Plug>CtrlSFCwordPath
    nmap     <C-F>p <Plug>CtrlSFPwordPath
    nnoremap <C-F>o :CtrlSFOpen<CR>
    nnoremap <C-F>t :CtrlSFToggle<CR>
    inoremap <C-F>t <Esc>:CtrlSFToggle<CR>

