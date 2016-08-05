" vim: fdm=marker:
" Options {{{
let g:home=expand('<sfile>:p:h')."/"
fun! s:createIfNotExists(dir)
    if !isdirectory(a:dir)
        call mkdir(a:dir, "p")
    endif
endfunction
set showmode
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set history=50      " keep 50 lines of command line history
set ruler       " show the cursor position all the time
set noshowcmd
set nocursorline
set nocursorcolumn     " display incomplete commands
set incsearch       " do incremental searching
set encoding=utf-8
set hidden
map <space> <leader>
set re=2    " use the new NFA engine
set wildchar=<Tab> wildmenu
set wildmode=longest,list
set pastetoggle=<F11>
set ignorecase smartcase
set guioptions-=T
set guioptions-=r
set guioptions+=R
set timeout timeoutlen=1000 ttimeoutlen=100
set undofile
call s:createIfNotExists(g:home.".vimbackups/.undo")
exec("set undodir=".g:home.".vimbackups/.undo")
set undolevels=1000
" required for yankstack
set winaltkeys=no
" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
    set mouse=a
endif
" Backup Options {{{
set backup        " keep a backup file
call s:createIfNotExists(g:home.".vimbackups/.backup")
exec("set backupdir=".g:home.".vimbackups/.backup")
call s:createIfNotExists(g:home.".vimbackups/.swap")
exec("set directory=".g:home.".vimbackups/.swap")
"}}}
set switchbuf=usetab
set matchpairs+=<:>
set showmatch
set nowrap
set copyindent
set smarttab
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
set wildignore+=*.swp,*.bak,*.class,.git/*,.svn/*,.git\*,.svn\*
set visualbell
set noerrorbells
set list
set listchars=tab:».,trail:░,extends:→,nbsp:.

" ConEmu
if !empty($CONEMUBUILD)
    set term=pcansi
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
endif

" tmux and otherwise
set t_Co=256
if &term =~ '256color'
    " disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    " see also http://snk.tuxfamily.org/log/vim-256color-bce.html
    set t_ut=
endif

set path=.,,**,$HOME

" Only do this part when compiled with support for autocommands.
if has("autocmd")

    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
        au!

        " For all text files set 'textwidth' to 120 characters.
        autocmd FileType text setlocal textwidth=120

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        " Also don't do it when the mark is in the first line, that is the default
        " position when opening a file.
        autocmd BufReadPost *
                    \ if line("'\"") > 1 && line("'\"") <= line("$") |
                    \   exe "normal! g`\"" |
                    \ endif

    augroup END

else

    set autoindent        " always set autoindenting on

endif " has("autocmd")

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

syntax sync minlines=256
set synmaxcol=300
set foldmethod=indent
set foldopen=block,hor,mark,percent,quickfix,search,tag,undo,jump
set foldnestmax=5
set foldminlines=2
set relativenumber
set nu
" replace all instances in a line.
set gdefault
set colorcolumn=120

" Session management
set sessionoptions&
set sessionoptions-=options
set sessionoptions+=resize,unix,slash,winpos
set guioptions-=t

set clipboard=unnamed
if has('unnamedplus')
    set clipboard=unnamedplus
endif

" colors
if has("gui_running")
    set background=light
else
    set background=dark
endif

if has('renderoptions')
    set renderoptions=type:directx,gamma:1.0,contrast:0.2,level:1.0,geom:1,renmode:5,taamode:1
endif

if has('win32') || has('win64')
    let g:fonts='Fantasque_Sans_Mono:h14:cANSI,Ubuntu_Mono_derivative_Powerlin:h13,Source_Code_Pro_Light:h11,Powerline_Consolas:h11,DejaVu Sans Mono For Powerline:h11,PragmataPro_Mono:h11'
    set guifont=Fantasque_Sans_Mono:h14:cANSI
else
    let g:fonts="Meslo\ LG\ S\ for\ Powerline\ 12,Monaco\ for\ Powerline\ 12,Pragmata\ Pro\ 13,Source\ Code\ Pro\ for\ Powerline\ 12,DejaVu\ Sans\ Mono\ for\ Powerline\ 12,Monospace\ 10,Ubuntu\ Mono\ 11"
    set guifont=Fantasque\ Sans\ Mono\ 14
    let g:GPGExecutable="gpg2"
    let g:GPGUseAgent = 1
endif

if has('nvim')
    GuiFont Fantasque Sans Mono:h14
endif

"}}}

" Plugin Bundles and config {{{
filetype off
exec("set rtp^=".g:home)
if !isdirectory(g:home."plugins/repos/github.com/Shougo/dein.vim")
    silent exec "!git clone https://github.com/shougo/dein.vim"." ".g:home."plugins/repos/github.com/Shougo/dein.vim"
endif
exec("set rtp^=".g:home."plugins/repos/github.com/Shougo/dein.vim")
call dein#begin(expand('~/.cache/dein'), [expand('<sfile>')])

call dein#add(g:home."plugins/repos/github.com/Shougo/dein.vim")

call dein#add('kshenoy/vim-signature')
nnoremap <S-F2>  :<C-U>call signature#mark#Goto("prev", "spot", "pos") <CR> \| zz
nnoremap <F2>  :<C-U>call signature#mark#Goto("next", "spot", "pos") <CR> \| zz

call dein#add("jamessan/vim-gnupg", {
            \ "lazy" : 1,
            \ "on_path": ['\.gpg$', '\.asc$']
            \ })
"If you have git, make sure that path does NOT point to git bash tools
" Path for git win should point to the libexec/git-core folder
" The default GPG should point to cygwin git
" To check: :sh, which gpg
let g:GPGDefaultRecipients=['Raghu Rajagopalan']

call dein#add('raghur/vim-helpnav', {
            \ "lazy" : 1,
            \ "on_ft" : ['help']
            \ })

call dein#add( 'vim-scripts/L9')
call dein#add( 'Shougo/neomru.vim')

function! s:on_unite_source()
    echom 'on_unite_source called'
    call unite#filters#matcher_default#use(['matcher_fuzzy'])
    call unite#filters#sorter_default#use(['sorter_rank'])
    call unite#custom#profile('default', 'context', {
                \ 'start_insert': 1,
                \ 'prompt': " ",
                \ 'prompt-visible': 1
                \ })
endfunction

call dein#add( 'shougo/unite.vim', {
    \ 'lazy' : 1,
    \ 'on_cmd': 'Unite',
    \ 'hook_post_source': function('s:on_unite_source')
    \ })
let g:unite_data_directory = g:home.".vimbackups/unite"
let g:unite_source_history_yank_enable=1
let g:unite_source_rec_max_cache_files=5000
let s:unite_ignores = [
            \ '\.git', 'deploy', 'dist',
            \ 'undo', 'tmp', 'backups',
            \ 'generated', 'build', 'images', 'node_modules']

if executable('ag')
    let g:unite_source_grep_command='ag'
    let g:unite_source_grep_default_opts='--nocolor --line-numbers --nogroup -S -C4'
    let g:unite_source_grep_recursive_opt=''
    " Using ag as recursive command.
    let g:unite_source_rec_async_command = ['ag', '--follow', '--nocolor', '--nogroup',
                \  '--hidden', '-g', '']
endif

if executable('sift')
    let g:unite_source_grep_command='sift'
    let g:unite_source_grep_default_opts='--no-color --line-number --no-group -s '
    let g:unite_source_grep_recursive_opt=''
    let g:unite_source_rec_async_command = ['sift', '--follow', '--no-color', '--no-group',
                \ '--git', '--targets']
endif
function! s:unite_settings()
    nmap <buffer> Q <plug>(unite_exit)
    nmap <buffer> <esc> <plug>(unite_exit)
    imap <buffer> <esc> <plug>(unite_exit)
    nmap <buffer> <F5> <plug>(unite_redraw)
    imap <buffer> <F5> <plug>(unite_redraw)
    inoremap <silent><buffer><expr> <C-s>     unite#do_action('split')
    inoremap <silent><buffer><expr> <C-v>     unite#do_action('right')
endfunction
augroup unite
    autocmd!
    autocmd FileType unite call s:unite_settings()
augroup END
nnoremap <silent> <leader><space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async:! neomru/file  buffer <cr><c-u>
nnoremap <silent> <leader>f :<C-u>Unite -toggle -auto-resize -buffer-name=file file_rec/async:! <cr><c-u>
nnoremap <silent> <leader>r :<C-u>Unite -buffer-name=recent file_mru<cr>
nnoremap <silent> <leader>y :<C-u>Unite -buffer-name=yanks history/yank<cr>
nnoremap <silent> <leader>j :<C-u>Unite -buffer-name=jumps jump change<cr>
nnoremap <silent> <leader>l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
nnoremap <silent> <leader>b :<C-u>Unite -auto-resize -buffer-name=buffers buffer file_mru<cr>
"nnoremap <silent> <leader>/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
nnoremap <silent> <leader>m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
nnoremap <silent> <leader>s :<C-u>Unite -quick-match buffer<cr>

nnoremap <leader>bd :bd<cr>
nnoremap <leader>d :bd!<cr>
nnoremap <leader>q :wq<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>o :on<cr>
nnoremap <leader>. @:
nnoremap <leader>a :b#<cr>
nnoremap <leader>n :call NextErrorOrLocation("next")<cr>
nnoremap <leader>p :call NextErrorOrLocation("prev")<cr>
"}}}

call dein#add( 'vim-pandoc/vim-pandoc', {
            \ 'on_ft': ['markdown', 'pandoc']
            \ })
call dein#add( 'vim-pandoc/vim-pandoc-syntax', {
            \ 'on_ft': ['markdown', 'pandoc']
            \ })
let g:pandoc#syntax#codeblocks#embeds#langs = ["ruby","python","bash=sh",
            \ "css", "erb=eruby", "javascript",
            \ "js=javascript", "json=javascript", "ruby",
            \ "sass", "xml", "html"]

"call dein#add( 'tpope/vim-fugitive')
call dein#add( 'tpope/vim-repeat')
let g:AutoPairsShortcutToggle = '\\'
call dein#add( 'jiangmiao/auto-pairs')
"call dein#add( 'nathanaelkane/vim-indent-guides')
let g:indent_guides_guide_size = 1
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree']
if has("gui_running")
    let g:indent_guides_enable_on_vim_startup = 1
endif

call dein#add( 'mbbill/undotree', {
            \ 'lazy': 1,
            \ 'on_cmd': ["UndotreeToggle"]
            \ })
call dein#add( 'gregsexton/MatchTag')
call dein#add( 'tpope/vim-commentary')
call dein#add( 'tyru/open-browser.vim')
"Plugin 'Valloric/YouCompleteMe'
"let g:ycm_autoclose_preview_window_after_completion = 1
"let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_auto_stop_csharp_server = 1
"nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<cr>

"NeoBundle 'kristijanhusak/vim-multiple-cursors'
" Called once right before you start selecting multiple cursors
"function! Multiple_cursors_before()
"if exists(':NeoCompleteLock')==2
"exe 'NeoCompleteLock'
"endif
"endfunction

" Called once only when the multiple selection is canceled (default <Esc>)
"function! Multiple_cursors_after()
"if exists(':NeoCompleteUnlock')==2
"exe 'NeoCompleteUnlock'
"endif
"endfunction

"NeoBundle 'marijnh/tern_for_vim', {
"\            'lazy':1,
"\            'autoload': {
"\              'filetypes' : ['javascript']
"\           }
"\}

if has('python') || has('python3')
    call dein#add( 'SirVer/ultisnips')
    call dein#add( 'honza/vim-snippets')
    "let g:UltiSnipsUsePythonVersion=2
    let g:UltiSnipsSnippetsDir=g:home."UltiSnips"
    let g:UltiSnipsExpandTrigger="<c-cr>"
    if !has('gui_running')
        let g:UltiSnipsExpandTrigger="<c-space>"
    endif
    let g:UltiSnipsListSnippets="<c-tab>"
endif

call dein#add( 'scrooloose/syntastic', {
            \ 'lazy' : 1,
            \ 'on_cmd': "SyntasticCheck",
            \ 'on_func': 'SyntasticStatuslineFlag'
            \ })
let g:syntastic_python_checkers = ['pylama']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_auto_loc_list = 1
nnoremap <F4> :w\|SyntasticCheck<cr>
let g:syntastic_mode_map = { 'mode': 'passive',
            \ 'active_filetypes': ['python', 'json', 'javascript'],
            \ 'passive_filetypes': [] }

call dein#add( 'kchmck/vim-coffee-script', {
            \ 'lazy': 1,
            \ 'on_ft': 'coffeescript'
            \ })
call dein#add( 'raghur/vim-colorschemes')
call dein#add( 'vim-scripts/Colour-Sampler-Pack')
call dein#add( 'sickill/vim-monokai')
call dein#add( 'jaromero/vim-monokai-refined')
call dein#add( 'altercation/vim-colors-solarized')
call dein#add( 'chriskempson/base16-vim')
let base16colorspace=256
let g:solarized_termcolors=256

call dein#add( 'pangloss/vim-javascript', {
            \ 'lazy': 1,
            \ 'on_ft': ['javascript']
            \ })
call dein#add( 'elzr/vim-json', {
            \ 'lazy': 1,
            \ 'on_ft': ['json']
            \ })
let g:vim_json_syntax_conceal = 0


call dein#add( 'jwhitley/vim-matchit.git')
call dein#add( 'tpope/vim-ragtag')

call dein#add( 'wellle/targets.vim')
call dein#add( 'kana/vim-textobj-user')
"call dein#add( 'sgur/vim-textobj-parameter')
call dein#add( 'kana/vim-textobj-function')
call dein#add( 'thinca/vim-textobj-function-javascript', {
    \ 'lazy': 1,
    \ 'on_ft': 'javascript'
    \ })
"call dein#add( 'kana/vim-textobj-indent')
"call dein#add( 'thinca/vim-textobj-between')
"call dein#add( 'terryma/vim-expand-region')
call dein#add( 'rstacruz/sparkup', { 'rtp': 'vim' })

" vim-airline and fonts
set lazyredraw
set laststatus=2

call dein#add( 'vim-airline/vim-airline')
let g:airline_enable_branch=1
let g:airline_enable_syntastic=1
let g:airline_powerline_fonts=1
let g:airline_detect_modified=1


call dein#add( 'tpope/vim-dispatch')
call dein#add( 'tpope/vim-markdown', {
            \ 'lazy' : 1,
            \ 'on_ft' : 'markdown'
            \ })

call dein#add( 'airblade/vim-rooter')
let g:rooter_silent_chdir = 1

"neocomplete
" run: nmake -f Make_msvc.mak nodebug=1
call dein#add( 'Shougo/vimproc.vim')
if has('lua')
    let g:neocomplete#use_vimproc = 1
    let g:neocomplete#enable_at_startup = 1
    call dein#add( 'Shougo/neocomplete', {
                \        'lazy': 1,
                \ 'on_i': 1,
                \ 'hook_post_source': 'exec("so ".g:home."neocomplete-custom.vim")'
                \ })
endif
let g:yankstack_yank_keys = ['c', 'C', 'd', 'D', 'x', 'X', 'y', 'Y']
call dein#add( 'maxbrunsfeld/vim-yankstack')

" make sure this is after vim-yankstack
call dein#add( 'tpope/vim-surround')

" vim sneak; replace f/F with sneak
call dein#add( 'justinmk/vim-sneak', {
    \ 'lazy' : 1,
    \ 'on_map': '<Plug>Sneak'
    \ })
"replace 'f' with 1-char Sneak
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F
let g:sneak#s_next = 0

let g:stopFirstAndNotifyTimeoutLen = 0
let g:EnhancedJumps_CaptureJumpMessages = 0
call dein#add('vim-scripts/ingo-library')
call dein#add( 'vim-scripts/EnhancedJumps')

nmap <backspace> <Plug>EnhancedJumpsOlder
nmap <C-backspace> <Plug>EnhancedJumpsRemoteOlder
nmap <C-tab> <Plug>EnhancedJumpsRemoteNewer
nnoremap <backspace>    g;
nnoremap <tab>    g,

call dein#add( 'PProvost/vim-ps1', {
            \ 'lazy': 1,
            \ 'on_ft': ['ps1', 'powershell']
            \})
call dein#add( 'nvie/vim-flake8', {
            \ 'lazy': 1,
            \ 'on_ft': 'python'
            \})
"call dein#add( 'nvie/vim-pyunit')
call dein#add( 'klen/python-mode', {
            \ 'lazy': 1,
            \ 'on_ft': 'python'
            \})
call dein#add( 'python-rope/ropevim', {
            \ 'lazy': 1,
            \ 'on_ft': 'python'
            \})
let g:pymode_run_bind = '<leader>pr'
let g:pymode_rope = 1

if &term =~ '^screen'
    " Page keys http://sourceforge.net/p/tmux/tmux-code/ci/master/tree/FAQ
    set t_kP=\e[5;*~
    set t_kN=\e[6;*~

    " Arrow keys http://unix.stackexchange.com/a/34723
    set <xUp>=\e[1;*A
    set <xDown>=\e[1;*B
    set <xRight>=\e[1;*C
    set <xLeft>=\e[1;*D
endif

call dein#add( 'xolox/vim-misc')
call dein#add( 'xolox/vim-session')
if (has('win32unix'))
    let g:session_directory=g:home.".vimbackups/.cygsessions"
else
    let g:session_directory=g:home.".vimbackups/.sessions"
endif
let g:session_command_aliases = 1
let g:session_autosave='yes'
let g:session_autoload='yes'
let g:session_default_to_last=1

call dein#add( 'kana/vim-submode')
" A message will appear in the message line when you're in a submode
" and stay there until the mode has existed.
let g:submode_always_show_submode = 1
let g:submode_timeout = 0

" We're taking over the default <C-w> setting. Don't worry we'll do
" our best to put back the default functionality.
call submode#enter_with('window', 'n', '', '<leader><C-w>')

" Note: <C-c> will also get you out to the mode without this mapping.
" Note: <C-[> also behaves as <ESC>
call submode#leave_with('window', 'n', '', '<ESC>')

" Go through every letter
for key in ['a','b','c','d','e','f','g','h','i','j','k','l','m',
            \           'n','o','p','q','r','s','t','u','v','w','x','y','z']
    " maps lowercase, uppercase and <C-key>
    call submode#map('window', 'n', '', key, '<C-w>' . key)
    call submode#map('window', 'n', '', toupper(key), '<C-w>' . toupper(key))
    call submode#map('window', 'n', '', '<C-' . key . '>', '<C-w>' . '<C-'.key . '>')
endfor
" Go through symbols. Sadly, '|', not supported in submode plugin.
for key in ['=','_','+','-','<','>']
    call submode#map('window', 'n', '', key, '<C-w>' . key)
endfor

call dein#add( 'Chiel92/vim-autoformat', {
            \ 'lazy': 1,
            \ 'on_cmd': 'AutoFormat'
            \ })
nnoremap <F7> :Autoformat<cr>

set rtp+=$GOROOT/misc/vim
call dein#end()
filetype plugin indent on
colors Monokai-Refined
"}}}

"Non Plugin specific keybindings {{{
" disable arrow keys
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>
nnoremap   <c-space> :bd<cr>
"inoremap <esc> <c-o>:echoe "use jk"<cr>
inoremap jk <esc>

map [[ ?{<CR>w99[{
map ][ /}<CR>b99]}
map ]] j0[[%/{<CR>
map [] k$][%?}<CR>

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

let maplocalleader='\'
" Search customizations
nnoremap / /\v
cnoremap %s/ %s/\v
nnoremap <leader>h  :noh<cr><c-l>
nnoremap <leader>w  :w<cr>
nnoremap <leader>fc :lcl <cr>
nnoremap <leader>pw :ed ~/.gnupg/passwords.txt.asc <cr>
vnoremap > >gv
vnoremap < <gv
vnoremap <silent> * y:let @/=@"<cr>:set hlsearch<cr>n
nnoremap 0 ^
nnoremap ^ 0
noremap <C-s> :w<cr>
nnoremap <leader>sv :ed $MYVIMRC<cr>
nnoremap <F5> :UndotreeToggle<CR>
vnoremap <leader>v "0p
" copy a block and comment it and move to insert mode
vmap <leader>ce  <S-v>ygv<Leader>cc`>pi
vnoremap % <space>%


"Move lines
nnoremap <A-j> :m+<CR>==
nnoremap <A-k> :m-2<CR>==
inoremap <A-j> <Esc>:m+<CR>==gi
inoremap <A-k> <Esc>:m-2<CR>==gi
vnoremap <A-j> :m'>+<CR>gv=gv
vnoremap <A-k> :m-2<CR>gv=gv

"Move by screen lines
nnoremap j gj
nnoremap k gk
"}}}

" Autocommands {{{

augroup Markdown
    au!
    autocmd FileType markdown setl wrap
                \ linebreak
    "\ spell spelllang=en_us
augroup END
augroup Html
    au!
    au BufNewFile,BufRead *.aspx setl filetype=html
    au BufNewFile,BufRead *.cshtml set filetype=html
    au BufNewFile,BufRead *.ascx set filetype=html
    au FileType html setl foldmethod=indent
augroup END

augroup Moin
    au!
    au BufNewFile,BufRead *.moin setf moin
    au BufNewFile,BufRead *.wiki setf moin
augroup END

augroup coffeescript
    au!
    au BufNewFile,BufReadPost *.coffee setl foldmethod=indent nofoldenable
                \ shiftwidth=2 expandtab
augroup END

augroup filecleanup
    au!
    autocmd BufWritePre *.pl,*.js,*.ps1,*.cs,*.md,*.html :%s/\s\+$//e
augroup END
"}}}

" Custom code/Utils {{{
let s:ackopts='\ -a\ --no-group\ -Hi '
let s:grepopts='\ --exclude-dir=packages'
            \ . '\ --exclude-dir=.git'
            \ . '\ --exclude-dir=.svn'
            \ . '\ --exclude-dir=tmp'
            \ . '\ --exclude=*.intellisense.js'
            \ . '\ --exclude=*-vsdoc.js'
            \ . '\ --exclude=*.tmp'
            \ . '\ --exclude=*.js.map'
            \ . '\ --exclude=*.min.js'
            \ . '\ -PHIirn\ $*'
"File search {{{
if executable('grep')
    let s:grep="grep"
endif
" The Silver Searcher
if executable('ag')
    " Use ag over grep
    let s:grep='ag'
    let s:grepopts='\ --nogroup\ --nocolor'

    " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --hidden
                \ --ignore .git
                \ --ignore .svn
                \ --ignore .hg
                \ --ignore .DS_Store
                \ --ignore "**/*.pyc"
                \ -g ""'
endif

execute "set grepprg=" . s:grep ."\\ ".s:grepopts

fun! Get_grep_include_opt(prefix)
    let l:cmd = ""
    if (expand("%:e") != "")
        "let l:cmd =  " --include=*.". expand("%:e") . " "
        let l:cmd = a:prefix . expand("%:e") . " "
    endif
    return l:cmd
endfun

fun! Grep_with_args(patt, path)
    let l:cmd=":silent grep! "
    let l:post="\"" . a:patt . "\""
    let l:pipe =  "\| copen"
    "let l:cmd = l:cmd .  Get_grep_include_opt(" --include=*.")
    let l:cmd = l:cmd . " " . l:post
    if a:path != ""
        let l:cmd = l:cmd . " " . a:path
        "else
        "let l:cmd = l:cmd . "  *"
    endif
    let l:cmd = l:cmd . " " . l:pipe
    return l:cmd
endfun

fun! s:get_visual_selection()
    let l=getline("'<")
    let [line1,col1] = getpos("'<")[1:2]
    let [line2,col2] = getpos("'>")[1:2]
    return l[col1 - 1: col2 - 1]
endfun

" lvimgrep - internal - slow
nnoremap <expr> <leader>* ":silent vimgrep /" . expand("<cword>") . "/j " .  Get_grep_include_opt("**/*.") . " \|copen"
vnoremap <script> <leader>* <Esc>:vimgrep /<C-R><C-R>=<SID>get_visual_selection()<CR>/j <C-R><C-R>=Get_grep_include_opt("**/*.")<CR>\|copen

" vimgrep - fast but external
" project root
nnoremap <expr><leader>/ Grep_with_args("\\b".expand("<cword>")."\\b", "")
vnoremap <script><leader>/ <Esc>:silent grep
            \ "<C-R><C-R>=<SID>get_visual_selection()<CR>"
            \ * \|copen
"\ <C-R><C-R>=Get_grep_include_opt(" --include=*.")<CR>
"" down current folder
"nnoremap <expr><leader>fd Grep_with_args("\\b".expand("<cword>")."\\b", expand("%:p:h"))
"vnoremap <script><leader>fd <Esc>:silent grep
"\ "<C-R><C-R>=<SID>get_visual_selection()<CR>"
"\ <C-R><C-R>=expand("%:p:h")<CR>\* \|copen
""\ <C-R><C-R>=Get_grep_include_opt(" --include=*.")<CR>
"}}}

"{{{ Create folders on write
function! s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction

augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END
"}}}

" Cycle colors
fun! CycleArray(arr, value, dir)
    let c = index(a:arr, a:value) + a:dir
    if (a:dir > 0)
        if (c >= len(a:arr))
            let c = 0
        endif
    else
        if (c < 0)
            let c = len(a:arr) - 1
        endif
    endif
    return c
endfunction

let g:colorschemes="smyck"
            \ . ":base16-default"
            \ . ":base16-eighties"
            \ . ":Monokai-Refined"
            \ . ":monokai"
            \ . ":molokai"
            \ . ":github"
            \ . ":mayansmoke"
            \ . ":newspaper"
            \ . ":greyhouse"

fun! CycleColorScheme(dir)
    let arr = split(g:colorschemes, ":")
    let c = CycleArray(arr, g:colors_name, a:dir)
    let scheme = arr[c]
    exec "colors " scheme
    redraw | echom "Setting colorscheme to: ".scheme
endfun
command! ColorsNext call CycleColorScheme(1)
command! ColorsPrev call CycleColorScheme(-1)

fun! CycleFont(dir)
    let arr = split(g:fonts, ",")
    let c = CycleArray(arr, &guifont, a:dir)
    let font = substitute(arr[c], " ", '\\ ', "g")
    exec("set guifont=".font)
    redraw | echom "Setting font to: " &guifont
endfun
command! FontNext call CycleFont(1)
command! FontPrev call CycleFont(-1)
"}}}

" Commands {{{
if has("unix")
    command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif
fun! RemoveCtrlM()
    :update
    :e ++ff=dos
    :%s/\r$//e
endfun
command! RemoveCtrlM call RemoveCtrlM()
command! EditAsWin call RemoveCtrlM()

func! ReadExCommandOutput(newbuf, cmd)
    redir => l:message
    silent! execute a:cmd
    redir END
    if a:newbuf | wincmd n | endif
    silent put=l:message
endf
command! -nargs=+ -bang -complete=command R call ReadExCommandOutput(<bang>1, <q-args>)
inoremap <c-r>R <c-o>:<up><home>R! <cr>

command! BlogSave exec ":! easyblogger file ". expand("%:p")

function! NeatFoldText() "{{{
    let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    let lines_count = v:foldend - v:foldstart + 1
    let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
    let foldchar = matchstr(&fillchars, 'fold:\zs.')
    let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(foldchar, 8)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
    return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
set foldtext=NeatFoldText()
" }}}

function! ToHtml()
    :w
    let file=expand("%:p")
    let outfile=fnamemodify(file, ":r") . ".html"
    let css=fnamemodify(file, ":h") . "pandoc.css"
    exec "silent !pandoc --toc  -c ". css .
                \ " -F mermaid-filter.cmd" .
                \ "  -fmarkdown_github" .
                \ "+footnotes" .
                \ "+implicit_header_references".
                \ "+auto_identifiers".
                \ "+superscript".
                \ "+subscript".
                \ "+fancy_lists".
                \ "+startnum".
                \ "+strikeout -i " . file . " -o " . outfile
    echom "wrote" . " " . outfile
    call openbrowser#open("file:///".substitute(outfile, "\\", "/", "g"))
endfunction
command! ToHtml call ToHtml()

function! NextErrorOrLocation(dir)
    let old_last_winnr = winnr('$')
    lclose
    let cmd=""
    if old_last_winnr != winnr('$')
        lopen
        let cmd=":l".a:dir
    endif

    cclose
    if old_last_winnr != winnr('$')
        copen
        let cmd=":c".a:dir
    endif
    if cmd != ""
        try
            exec cmd
        catch "E553"
            :exe old_last_winnr . "wincmd w"
            echom "No more items"
        endtry
    else
        echom "No location or error list"
    endif
endfunction

command! Gitex exec "silent !gitex browse " . expand("%:p:h")
command! Wex exec "silent !explorer " . expand("%:p:h")
nnoremap <F9> :Gitex<cr>
nnoremap <F10> :Wex<cr>
if dein#check_install()
    call dein#install()
    "call dein#recache_runtimepath()
endif
"}}}
