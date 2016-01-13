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
Plug 'itchyny/lightline.vim' " status bar
Plug 'junegunn/goyo.vim' | Plug 'amix/vim-zenroom2' " distraction-free writing
Plug 'editorconfig/editorconfig-vim' " EditorConfig plugin for Vim


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Navigation
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'scrooloose/nerdtree' "| Plug 'Xuyuanp/nerdtree-git-plugin'  file browser
Plug 'jlanzarotta/bufexplorer' " quick switching between buffers
Plug 'christoomey/vim-tmux-navigator' " better tmux and vim navigation


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Languages and syntax
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'scrooloose/syntastic' " external syntax checking
Plug 'smerrill/vcl-vim-plugin' " varnish configuration highlighting
Plug 'scrooloose/nerdcommenter' " Vim plugin for intensely orgasmic commenting


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => External tools
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'tpope/vim-fugitive' " git integration
Plug 'markcornick/vim-terraform', {'for': 'terraform' } " terraform integration
Plug 'rking/ag.vim' " the_silver_searcher


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
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

" Display a lock symbol if the current buffer is read-only
function! MyReadonly()
  if &filetype == "help"
    return ""
  elseif &readonly
    return " "
  else
    return ""
  endif
endfunction

" Display the current branch if in a git repository
function! MyFugitive()
  if exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? ' '._ : ''
  endif
  return ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
       \ ('' != expand('%') ? expand('%') : '[NoName]')
endfunction


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
"let NERDTreeMinimalUI = 1
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
" => Syntastic
" Syntax checking hacks for vim
" https://github.com/scrooloose/syntastic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
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
" The tree buffer makes it easy to drill down through the directories of your
" git repository, but it’s not obvious how you could go up a level to the
" parent directory. Here’s a mapping of .. to the above command, but
" only for buffers containing a git blob or tree
autocmd User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif

" Every time you open a git object using fugitive it creates a new buffer.
" This means that your buffer listing can quickly become swamped with
" fugitive buffers. This prevents this from becomming an issue:
autocmd BufReadPost fugitive://* set bufhidden=delete

" For fugitive.vim, dp means :diffput. Define dg to mean :diffget
nnoremap <silent> ,dg :diffget<CR>
nnoremap <silent> ,dp :diffput<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => ag.vim
" Vim plugin for the_silver_searcher, 'ag', a replacement for the Perl
" module / CLI script 'ack'
" https://github.com/rking/ag.vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Open the Ag command and place the cursor into the quotes
nmap <leader>ag :Ag ""<left>
nmap <leader>af :AgFile ""<left>


""""""""""""""""""""""""""""""
" => MRU plugin
""""""""""""""""""""""""""""""
let MRU_Max_Entries = 400
map <leader>f :MRU<CR>


""""""""""""""""""""""""""""""
" => YankRing
""""""""""""""""""""""""""""""
if has("win16") || has("win32")
    " Don't do anything
else
    let g:yankring_history_dir = '~/.vim_runtime/tmp/yank/'
endif


""""""""""""""""""""""""""""""
" => CTRL-P
""""""""""""""""""""""""""""""
let g:ctrlp_working_path_mode = 0

let g:ctrlp_map = '<c-f>'
map <leader>j :CtrlP<cr>
map <c-b> :CtrlPBuffer<cr>

let g:ctrlp_max_height = 20
let g:ctrlp_custom_ignore = 'node_modules\|^\.DS_Store\|^\.git'


""""""""""""""""""""""""""""""
" => ZenCoding
""""""""""""""""""""""""""""""
" Enable all functions in all modes
let g:user_zen_mode='a'


""""""""""""""""""""""""""""""
" => snipMate (beside <TAB> support <CTRL-j>)
""""""""""""""""""""""""""""""
ino <c-j> <c-r>=snipMate#TriggerSnippet()<cr>
snor <c-j> <esc>i<right><c-r>=snipMate#TriggerSnippet()<cr>


""""""""""""""""""""""""""""""
" => Vim grep
""""""""""""""""""""""""""""""
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn generated'
set grepprg=/bin/grep\ -nH


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-multiple-cursors
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:multi_cursor_next_key="\<C-s>"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => surround.vim config
" Annotate strings with gettext http://amix.dk/blog/post/19678
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vmap Si S(i_<esc>f)
au FileType mako vmap Si S"i${ _(<esc>2f"a) }<esc>


