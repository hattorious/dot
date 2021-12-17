"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Maintainer:
"       Ross Hattori
"
" Version:
"       0.0.1 - 13/09/15 13:58:09
"
" Sections:
"    -> General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Load plugins
call plug#begin('~/.vim_runtime/plugins/plugged')


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'altercation/vim-colors-solarized' " solarized color scheme
Plug 'itchyny/lightline.vim' " A light and configurable statusline/tabline plugin for Vim
Plug 'bagrat/vim-buffet' " IDE-like Vim tabline
Plug 'junegunn/goyo.vim' | Plug 'amix/vim-zenroom2' " distraction-free writing
Plug 'editorconfig/editorconfig-vim' " EditorConfig plugin for Vim
Plug 'airblade/vim-gitgutter' " A Vim plugin which shows a git diff in the gutter (sign column) and stages/undoes hunks.
Plug 'Yggdroot/indentLine' " A vim plugin to display the indention levels with thin vertical lines

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Navigation
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'scrooloose/nerdtree' "| Plug 'Xuyuanp/nerdtree-git-plugin'  file browser
Plug 'jlanzarotta/bufexplorer' " quick switching between buffers
Plug 'christoomey/vim-tmux-navigator' " better tmux and vim navigation
Plug 'majutsushi/tagbar', {'for': 'go'} " Vim plugin that displays tags in a window, ordered by scope
Plug 'yegappan/mru' " Most Recently Used (MRU) Vim Plugin
Plug 'takac/vim-hardtime' " Plugin to help you stop repeating the basic movement keys
Plug 'unblevable/quick-scope' " Lightning fast left-right movement in Vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Languages and syntax
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'scrooloose/syntastic' " external syntax checking
Plug 'sheerun/vim-polyglot' " A solid language pack for Vim.
Plug 'scrooloose/nerdcommenter' " Vim plugin for intensely orgasmic commenting
Plug 'fatih/vim-go', {'for': 'go'} " Go development plugin for Vim
Plug 'psf/black', { 'branch': 'stable' } " The uncompromising Python code formatter
Plug 'fatih/vim-hclfmt', {'for': 'hcl'} " Vim plugin for hclfmt

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => External tools
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-fugitive' " git integration
Plug 'tpope/vim-rhubarb' " GitHub extension for fugitive.vim
Plug 'whiteinge/diffconflicts' " A better Vimdiff Git mergetool
Plug 'hashivim/vim-terraform', {'for': 'terraform' } " terraform integration
Plug 'alx741/vinfo' " Vim info documentation reader, allows to read info pages when inside a Vim session or from the shell prompt (instead of Info)
Plug 'mhinz/vim-grepper' " 👾 Helps you win at grep.


" This devicons is always last
Plug 'ryanoasis/vim-devicons'

" Add plugins to &runtimepath
call plug#end()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-plug
" :hibiscus: Minimalist Vim Plugin Manager
" https://github.com/junegunn/vim-plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:plug_window = 'new'


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Solarized
" precision colorscheme for the vim text editor
" http://ethanschoonover.com/solarized
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    colorscheme solarized
catch
endtry
hi! link txtBold Identifier
hi! link MatchParen DiffText

hi! link CTagsModule Type
hi! link CTagsClass Type
hi! link CTagsMethod Identifier
hi! link CTagsSingleton Identifier

hi! link javascriptFuncName Type
hi! link jsFuncCall jsFuncName
hi! link javascriptFunction Statement
hi! link javascriptThis Statement
hi! link javascriptParens Normal
hi! link jOperators javascriptStringD
hi! link jId Title
hi! link jClass Title

" Javascript language support
hi! link javascriptJGlobalMethod Statement

" Make the braces and other noisy things slightly less noisy
hi! jsParens guifg=#005F78 cterm=NONE term=NONE ctermfg=NONE ctermbg=NONE
hi! link jsFuncParens jsParens
hi! link jsFuncBraces jsParens
hi! link jsBraces jsParens
hi! link jsParens jsParens
hi! link jsNoise jsParens

hi! link NERDTreeFile Constant
hi! link NERDTreeDir Identifier

hi! link sassMixinName Function
hi! link sassDefinition Function
hi! link sassProperty Type
hi! link htmlTagName Type

hi! PreProc gui=bold

" Solarized separators are a little too distracting.
" This moves separators, comments, and normal
" text into the same color family as the background.
" Using the http://drpeterjones.com/colorcalc/,
" they are now just differently saturated and
" valued riffs on the background color, making
" everything play together just a little more nicely.
hi! VertSplit guifg=#003745 cterm=NONE term=NONE ctermfg=NONE ctermbg=NONE
hi! LineNR guifg=#004C60 gui=bold guibg=#002B36 ctermfg=146
hi! link NonText VertSplit
hi! Normal guifg=#77A5B1
hi! Constant guifg=#00BCE0
hi! Comment guifg=#52737B
hi! link htmlLink Include
hi! CursorLine cterm=NONE gui=NONE
hi! Visual ctermbg=233
hi! Type gui=bold
hi! EasyMotionTarget ctermfg=100 guifg=#4CE660 gui=bold


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Lightline
" A light and configurable statusline/tabline for Vim
" https://github.com/itchyny/lightline.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
      \ 'colorscheme': 'solarized',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'readonly': 'MyReadonly',
      \   'filename': 'MyFilename',
      \   'filetype': 'MyFiletype',
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }


let g:lightline.enable = {
      \ 'tabline': 0
      \ }

" Display a lock symbol if the current buffer is read-only
function! MyReadonly()
  if &filetype == "help"
    return ""
  elseif &readonly
    return " " " \uf456
  else
    return ""
  endif
endfunction

" Display the current branch if in a git repository
function! MyFugitive()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? " "._ : '' " \uf418
  endif
  return ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
       \ ('' != expand('%') ? expand('%') : '[NoName]')
endfunction

" Display the devicon before the fiyle type if available
function! MyFiletype()
  if winwidth(0) > 70
    let _ = (exists('*WebDevIconsGetFileTypeSymbol') ? WebDevIconsGetFileTypeSymbol() . ' ' : '')
    return (strlen(&filetype) ? _. &filetype : 'no ft')
  endif
  return ''
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Buffet
" IDE-like Vim tabline
" https://github.com/bagrat/vim-buffet
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" use powerline separators in between buffers and tabs in the tabline
let g:buffet_powerline_separators = 1

let g:buffet_modified_icon = " " " \uf44d

let g:buffet_new_buffer_name = "ﰟ" " \ufc1f

let g:buffet_tab_icon = "﬿" " \ufb3f
let g:buffet_left_trunc_icon = "" " \uf0a8
let g:buffet_right_trunc_icon = "" " \uf0a9

noremap <Tab> :bn<CR>
noremap <S-Tab> :bp<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Goyo
" :tulip: Distraction-free writing in Vim
" https://github.com/junegunn/goyo.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:goyo_width=100
let g:goyo_margin_top = 2
let g:goyo_margin_bottom = 2
nnoremap <silent> <leader>z :Goyo<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nerd Tree
" A tree explorer plugin for vim
" https://github.com/scrooloose/nerdtree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDTreeDirArrows = 1
let g:NERDTreeWinPos = "right"
let NERDTreeIgnore = ['\.pyc$']
let g:NERDTreeWinSize=30
let g:NERDTreeBookmarksFile=expand("$HOME/.vim_runtime/tmp/nerdtree/NERDTreeBookmarks")
" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<space>
map <leader>nf :NERDTreeFind<cr>

let NERDTreeHijackNetrw=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => bufExplorer
" BufExplorer Plugin for Vim
" https://github.com/jlanzarotta/bufexplorer
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp=0
let g:bufExplorerShowRelativePath=1
let g:bufExplorerFindActive=1
let g:bufExplorerSortBy='name'
map <leader>o :BufExplorer<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Hardtime
" Plugin to help you stop repeating the basic movement keys
" https://github.com/takac/vim-hardtime
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:hardtime_default_on = 1

" tweak the timeout allowed between keypresses in milliseconds
let g:hardtime_timeout = 1000

" enable the notification about HardTime being enabled set
let g:hardtime_showmsg = 1

" enable hardtime to ignore certain buffer patterns set
let g:hardtime_ignore_buffer_patterns = [ "NERD.*", ".*.git/index", "BufExplorer", "__MRU*" ]
let g:hardtime_ignore_quickfix = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => quick-scope
" Lightning fast left-right movement in Vim
" https://github.com/unblevable/quick-scope
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Syntastic
" Syntax checking hacks for vim
" https://github.com/scrooloose/syntastic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height=5
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_error_symbol = "✗"
let g:syntastic_warning_symbol = "⚠"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => fugitive.vim
" a Git wrapper so awesome, it should be illegal
" https://github.com/tpope/vim-fugitive
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Every time you open a git object using fugitive it creates a new buffer.
" This means that your buffer listing can quickly become swamped with
" fugitive buffers. This prevents this from becomming an issue:
autocmd BufReadPost fugitive://* set bufhidden=delete

" For fugitive.vim, dp means :diffput. Define dg to mean :diffget
nnoremap <silent> ,dg :diffget<CR>
nnoremap <silent> ,dp :diffput<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-terraform
" basic vim/terraform integration
" https://github.com/hashivim/vim-terraform
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Allow vim-terraform to override your .vimrc indentation syntax for matching file
let g:terraform_align=1

" Allow vim-terraform to automatically fold (hide until unfolded) sections of terraform code
let g:terraform_fold_sections=1

" Allow vim-terraform to re-map the spacebar to fold/unfold
let g:terraform_remap_spacebar=0

" Run `terraform fmt` against the current buffer on save
let g:terraform_fmt_on_save=1


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => black.vim
" Black is the uncompromising Python code formatter.
" https://github.com/psf/black
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Black will check that the reformatted code still produces a valid AST that is equivalent to the original
let g:black_fast=0

let g:black_linelength=88
let g:black_skip_string_normalization=0
let g:black_virtualenv="~/.vim_runtime/tmp/black_venv"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => indentLine
" A vim plugin to display the indention levels with thin vertical lines
" https://github.com/Yggdroot/indentLine
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:indentLine_char = '' " \ue621


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Grepper
" 👾 Helps you win at grep.
" https://github.com/mhinz/vim-grepper
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>g :Grepper<cr>
nnoremap <leader>gg :Grepper -tool git<cr>
nnoremap <leader>ga :Grepper -tool ag<cr>
nnoremap <leader>gs :Grepper -tool ag -side<cr>
nnoremap <leader>vg :Grepper -tool git -cword -noprompt<cr>
nnoremap <leader>va :Grepper -tool ag -cword -noprompt<cr>

let g:grepper = {}
let g:grepper.tools = ['git', 'ag', 'grep']
let g:grepper.open = 1
let g:grepper.switch = 1
let g:grepper.quickfix = 1

nmap gs  <plug>(GrepperOperator)
xmap gs  <plug>(GrepperOperator)


""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
let MRU_Max_Entries = 400
map <leader>f :MRU<space>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-hclfmt
" Vim plugin for hclfmt
" https://github.com/fatih/vim-hclfmt
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:hcl_fmt_autosave = 1
let g:nomad_fmt_autosave = 1
