"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Scratch buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Quickly open a buffer scratch
map <leader>q :e ~/.vim_runtime/tmp/buffer/temp<cr>

" Quickly open a markdown buffer scratch
map <leader>x :e ~/.vim_runtime/tmp/buffer/temp.md<cr>


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

