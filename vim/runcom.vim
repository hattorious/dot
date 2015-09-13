set runtimepath+=~/.vim_runtime

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/plugins.vim
source ~/.vim_runtime/vimrcs/filetypes.vim

try
source ~/.vimrc.local.vim
catch
endtry
