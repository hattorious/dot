
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd BufWrite *.vim :call DeleteTrailingWS()
au FileType vim setl shiftwidth=2
au FileType vim setl tabstop=2


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Bash section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:syntastic_sh_checkers=['shellcheck']


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Python section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:syntastic_python_checkers=['flake8']
let g:syntastic_python_flake8_args='--max-line-length=88'
let python_highlight_all = 1
au FileType python syn keyword pythonDecorator True None False self

au FileType python map <buffer> F :set foldmethod=indent<cr>

au FileType python inoremap <buffer> $r return
au FileType python inoremap <buffer> $i import
au FileType python inoremap <buffer> $p print
au FileType python inoremap <buffer> $f #--- PH ----------------------------------------------<esc>FP2xi
au FileType python map <buffer> <leader>1 /class
au FileType python map <buffer> <leader>2 /def
au FileType python map <buffer> <leader>C ?class
au FileType python map <buffer> <leader>D ?def
autocmd BufWritePre *.py execute ':Black'
autocmd BufWrite *.py :call DeleteTrailingWS()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => JavaScript section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:syntastic_javascript_checkers = ['standard']
au FileType javascript call JavaScriptFold()
au FileType javascript setl fen
au FileType javascript setl nocindent
au FileType javascript setl shiftwidth=2
au FileType javascript setl tabstop=2

au FileType javascript imap <c-t> AJS.log();<esc>hi
au FileType javascript imap <c-a> alert();<esc>hi

au FileType javascript inoremap <buffer> $r return
au FileType javascript inoremap <buffer> $f //--- PH ----------------------------------------------<esc>FP2xi

function! JavaScriptFold()
    setl foldmethod=syntax
    setl foldlevelstart=1
    syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

    function! FoldText()
        return substitute(getline(v:foldstart), '{.*', '{...}', '')
    endfunction
    setl foldtext=FoldText()
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Git section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au FileType gitcommit set tw=72
au FileType gitcommit setlocal spell


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Chef, Vagrant, etc section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufRead,BufNewFile {Vagrantfile,Berksfile} set ft=ruby
au FileType ruby setl shiftwidth=2
au FileType ruby setl tabstop=2


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => HTML section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au FileType html setl shiftwidth=2
au FileType html setl tabstop=2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => YAML section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:syntastic_yaml_checkers = ['yamllint']
au BufRead,BufNewFile *.{yaml,yml} set ft=yaml
au FileType yaml setl shiftwidth=2
au FileType yaml setl tabstop=2
au FileType yaml setl softtabstop=2
au FileType yaml setl expandtab
au FileType yaml setl foldmethod=indent


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => HCL section
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"au BufRead,BufNewFile *.hcl set ft=hcl
au FileType hcl set tw=80


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete trailing white space on save
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc


