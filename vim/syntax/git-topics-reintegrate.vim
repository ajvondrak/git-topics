" Vim syntax file
" Language:   git topics reintegrate
" Maintainer: Alex Vondrak (https://github.com/ajvondrak)
" Repository: https://github.com/ajvondrak/git-topics
"
" Based on the git rebase --interactive highlighting by Tim Pope:
" https://github.com/vim/vim/blob/89bcfda/runtime/syntax/gitrebase.vim

if exists("b:current_syntax")
  finish
endif

syn case match

syn match reintegratePick    "\v^p%(ick)=>" nextgroup=reintegrateTopic skipwhite
syn match reintegrateDrop    "\v^d%(rop)=>" nextgroup=reintegrateTopic skipwhite
syn match reintegrateTopic   ".*"           contained
syn match reintegrateComment "^#.*"

hi def link reintegratePick    Statement
hi def link reintegrateDrop    Comment
hi def link reintegrateTopic   Identifier
hi def link reintegrateComment Comment

let b:current_syntax = "git-topics-reintegrate"
