" Install this file by doing the following:
"
"   1. Open Neovim
"   2. Run :e $MYVIMRC
"   3. Paste the contents of this file in
"   4. Save and restart

" ==============================================================================
" Environment Settings

if has('win32')
    " Ensure that $HOME points to $USERPROFILE
    let $HOME = $USERPROFILE

    " Set CMD as the windows shell.
    set shell=$COMSPEC
endif

" ==============================================================================
" GUI Settings

" This section holds GUI settings. After updating these settings
" WriteGUISettings must be called to apply the settings.

if has('win32')
    let s:ginit_path = expand('$LOCALAPPDATA/nvim/ginit.vim')
elseif has('unix')
    let s:ginit_path = expand('~/.config/nvim/ginit.vim')
endif

" Lines of GUI settings file.
let s:ginit = [
    \ 'GuiPopupmenu 0'
\ ]

function WriteGUISettings()
    call writefile(s:ginit, s:ginit_path, 'b')

    echo 'Gui restart required.'
endfunction

if empty(glob(s:ginit_path))
    call WriteGUISettings()
endif

" ==============================================================================
" Vim Plug Installation

if has('win32')
    " TODO: implement
elseif has('unix')
    if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
        silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endif

" ==============================================================================
" Python Provider

if has('win32')
    " Set the path to Python 3 command.
    " I use Anaconda, which on windows does not have a python3 symlink, so I
    " default this to call 'python', which will be python 3 on my machines.
    let g:python3_host_prog = expand('python')

    let pip = 'pip'
elseif has('unix')
    let pip = 'pip3'
endif

" Disable python 2 since it has been end of lifed.
let g:loaded_python_provider = 1

" ==============================================================================
" Plugins

if has('win32')
    call plug#begin('$LOCALAPPDATA/nvim/plugged')
elseif has('unix')
    call plug#begin('~/.local/share/nvim/plugged')
endif

Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-commentary'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'mechatroner/rainbow_csv'
Plug 'nestorsalceda/vim-strip-trailing-whitespaces'
Plug 'brooth/far.vim'
Plug 'airblade/vim-rooter'

" vim-indent-guides ------------------------------------------------------------
Plug 'nathanaelkane/vim-indent-guides'

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0

autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=#303039 ctermbg=3
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#353540 ctermbg=4

" lightline --------------------------------------------------------------------
Plug 'itchyny/lightline.vim'
let g:lightline = {
    \ 'colorscheme': 'onedark',
\ }

" vim-illuminate ----------------------------------------------------------------
Plug 'RRethy/vim-illuminate'
autocmd VimEnter * :hi illuminatedWord cterm=underline gui=underline

" deoplete ---------------------------------------------------------------------
function! DeopletePostInstall(info)
    execute '!' . pip . ' install --user --upgrade pynvim'
    execute 'UpdateRemotePlugins'
endfunction

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': function('DeopletePostInstall')}
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc':
endif

let g:deoplete#enable_at_startup = 1

Plug 'deoplete-plugins/deoplete-jedi', {
    \ 'do': ':!' . pip . ' install --user --upgrade jedi'
\ }

" CtrlP ------------------------------------------------------------------------
Plug 'ctrlpvim/ctrlp.vim'

if executable('rg')
    set grepprg=rg\ --color=never
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    let g:ctrlp_use_caching = 0
endif

call plug#end()

" ==============================================================================
" Indent

" Visual spaces per tab
set tabstop=4

" Spaces per tab while editing
set softtabstop=4

" Autoindent spaces
set shiftwidth=4

" Use spaces instead of tabs
set expandtab

" ==============================================================================
" Gutter

" Setup width rulers
set colorcolumn=81

" Highlight everything that goes beyond 80 characters
call matchadd('ColorColumn', '\%>81v.\+', 100)

" Setup line numbers to show absolute number for current line, and relative
" for everything else.
set number relativenumber

" ==============================================================================
" Bindings

" Make ctrl + backspace delete previous word.
inoremap <C-BS> <C-W>

" ==============================================================================
" Editor

" Ensure there is always at least 10 lines around the cursor.
set scrolloff=10

" Highlight the cursor line
set cursorline

" Make delete previous word always work.
set backspace=indent,eol,start

" Make command mode tab completion and search to be case insensitive.
" Search can be made case sensitive by prefixing with \C
" set ignorecase

" ==============================================================================
" Theme

colorscheme onedark