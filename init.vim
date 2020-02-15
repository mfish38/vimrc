" The following are required before installation:
" - git
" - python 3
" - npm
" - Proggy Vector https://github.com/bluescan/proggyfonts
"
" Install locations:
"   Windows:
"       %LOCALAPPDATA%\nvim\init.vim
"
"   Linux:
"       ~/.config/nvim/init.vim

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
    \ 'GuiPopupmenu 0',
    \ 'GuiFont! ProggyVector:h10'
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
    if empty(glob(expand('$LOCALAPPDATA/nvim/autoload/plug.vim')))
        execute '!curl -fLo ' . $LOCALAPPDATA . '/nvim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
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

    let g:pip = 'pip'
elseif has('unix')
    let g:pip = 'pip3'
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

" vim-rooter -------------------------------------------------------------------
Plug 'airblade/vim-rooter'

let g:rooter_patterns = [
    \ '.git/',
    \ 'tests/',
    \ 'src/',
    \ 'repos/',
    \ 'setup.py',
    \ 'web.config',
    \ 'package.json',
    \ 'vim.root'
\]

let g:rooter_silent_chdir = 1

" coverage-highlight -----------------------------------------------------------
Plug 'mgedmin/coverage-highlight.vim'

let g:coverage_script = 'python -m coverage'

" ale --------------------------------------------------------------------------
function! AlePostInstall(info)
    execute '!' . g:pip . ' install --user --upgrade mypy'
    execute 'UpdateRemotePlugins'
endfunction

Plug 'dense-analysis/ale', {'do': function('AlePostInstall')}

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
    execute '!' . g:pip . ' install --user --upgrade pynvim'
    execute 'UpdateRemotePlugins'
endfunction

if has('nvim')
  Plug 'Shougo/deoplete.nvim', {'do': function('DeopletePostInstall')}
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc':
endif

let g:deoplete#enable_at_startup = 1

" Python
Plug 'deoplete-plugins/deoplete-jedi', {
    \ 'do': ':!' . g:pip . ' install --user --upgrade jedi'
\ }

" Javascript
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }

" CtrlP ------------------------------------------------------------------------
Plug 'ctrlpvim/ctrlp.vim'

let g:ctrlp_by_filename = 1

if executable('rg')
    set grepprg=rg\ --color=never\ --auto-hybrid-regex
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    " let g:ctrlp_use_caching = 0
endif

call plug#end()

" ==============================================================================
" Git

command! -bar Ga execute "!git add " . shellescape(expand('%'))
command! -bar -nargs=1 Gc execute "!git commit -m " . shellescape(<f-args>)
command! -bar -nargs=1 Gac execute "Ga | Gc " . <q-args>
command! Gs execute "!git status"
command! Gr execute "!git reset HEAD"
command! Gp execute "!git pull && git push"
command! Gd execute "!git diff"

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
" Bindings

" Make ctrl + backspace delete previous word.
inoremap <C-BS> <C-W>

" Easier escape than <Esc> or <C-[>.
inoremap <C-;> <Esc>
noremap <C-;> <Esc>
cnoremap <C-;> <Esc>

" OS copy paste shortcuts
vnoremap <C-c> "+y
inoremap <C-v> <C-r>+

" Faster and less stressfull command mode
nnoremap <Space> :
vnoremap <Space> :

let g:ctrlp_prompt_mappings = {
    \ 'PrtExit()':            ['<esc>', '<c-c>', '<c-g>', '<c-;>'],
\ }
    " \ 'PrtBS()':              ['<bs>', '<c-]>'],
    " \ 'PrtDelete()':          ['<del>'],
    " \ 'PrtDeleteWord()':      ['<c-w>'],
    " \ 'PrtClear()':           ['<c-u>'],
    " \ 'PrtSelectMove("j")':   ['<c-j>', '<down>'],
    " \ 'PrtSelectMove("k")':   ['<c-k>', '<up>'],
    " \ 'PrtSelectMove("t")':   ['<Home>', '<kHome>'],
    " \ 'PrtSelectMove("b")':   ['<End>', '<kEnd>'],
    " \ 'PrtSelectMove("u")':   ['<PageUp>', '<kPageUp>'],
    " \ 'PrtSelectMove("d")':   ['<PageDown>', '<kPageDown>'],
    " \ 'PrtHistory(-1)':       ['<c-n>'],
    " \ 'PrtHistory(1)':        ['<c-p>'],
    " \ 'AcceptSelection("e")': ['<cr>', '<2-LeftMouse>'],
    " \ 'AcceptSelection("h")': ['<c-x>', '<c-cr>', '<c-s>'],
    " \ 'AcceptSelection("t")': ['<c-t>'],
    " \ 'AcceptSelection("v")': ['<c-v>', '<RightMouse>'],
    " \ 'ToggleFocus()':        ['<s-tab>'],
    " \ 'ToggleRegex()':        ['<c-r>'],
    " \ 'ToggleByFname()':      ['<c-d>'],
    " \ 'ToggleType(1)':        ['<c-f>', '<c-up>'],
    " \ 'ToggleType(-1)':       ['<c-b>', '<c-down>'],
    " \ 'PrtExpandDir()':       ['<tab>'],
    " \ 'PrtInsert("c")':       ['<MiddleMouse>', '<insert>'],
    " \ 'PrtInsert()':          ['<c-\>'],
    " \ 'PrtCurStart()':        ['<c-a>'],
    " \ 'PrtCurEnd()':          ['<c-e>'],
    " \ 'PrtCurLeft()':         ['<c-h>', '<left>', '<c-^>'],
    " \ 'PrtCurRight()':        ['<c-l>', '<right>'],
    " \ 'PrtClearCache()':      ['<F5>'],
    " \ 'PrtDeleteEnt()':       ['<F7>'],
    " \ 'CreateNewFile()':      ['<c-y>'],
    " \ 'MarkToOpen()':         ['<c-z>'],
    " \ 'OpenMulti()':          ['<c-o>'],

" ==============================================================================
" Editor

" Turn of swapfile as it causes a bunch of existing swapfile notifications,
" and saving and commiting often lessens the need for it.
set noswapfile

" Ensure there is always at least 10 lines around the cursor.
set scrolloff=10

" Highlight the cursor line
set cursorline

" Make delete previous word always work.
set backspace=indent,eol,start

" Make command mode tab completion and search to be case insensitive.
" Search can be made case sensitive by prefixing with \C
" set ignorecase

" Setup width rulers
set colorcolumn=81

" Highlight everything that goes beyond 80 characters
call matchadd('ColorColumn', '\%>81v.\+', 100)

" Setup line numbers to show absolute number for current line, and relative
" for everything else.
set number relativenumber

" ==============================================================================
" Theme

" TODO: move all color theme settings together, and use variables to define
" pallete.
colorscheme onedark
