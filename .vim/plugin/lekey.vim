" File: lekey.vim for VIM 7.1
" Purpose: Basic Brief Like emulation for vim
" Author: Lechee.Lai
" Version: 1.1
"
" TODO:
"
"
" ---------- B r i e f E X  l i k e -----------------------------------
"-----------------------------------------------------------------------
if !exists("vim_mask")
     if $bmask == ""   
         let g:vim_mask = '*'
     else 
	     let g:vim_mask = $bmask
     endif
endif	


function! s:UnderOccurences()
	let s:skip = 0
	try     
		exec "normal [I"
	catch /^Vim(\a\+):E349:/
		echo v:exception
		let s:skip = 1   
	endtry
	if s:skip == 0
		let nr = input("Which one: ")
		if nr == ""
			return
		endif
		exec "normal " . nr . "[\t"
	endif
endfunction!

function! s:leOccur()
	let pat = expand("<cword>")
	let pattern = input("leOccur (" . pat . "): ")
	if pattern == ""
		let pattern = pat
		if pattern ==""
			echo "Cancelled.!"
			return
		endif  
	endif
	exec 'let @/ = "'.pattern.'"'
	exec 'vimgrep ' . pattern . ' ' . expand('%') | :copen |:cc
endfunction!


function! s:FindOccurences(method)
	if a:method == "auto"
		let pat = expand("<cword>")
		let pattern = input("Prompt Find (".pat."): ")
		if pattern == ""
			let pattern = pat
			if pattern ==""
				echo "Cancelled.!"
				return
			endif  
		endif
	else 
		let pattern = input("Prompt Find: ")
		if pattern == ""
			echo "Cancelled.!"
			return
		endif
	endif   
	let s:skip = 0
	try
	exec "ilist! /" . pattern
	catch /^Vim(\a\+):E389:/
		echo v:exception ." \"" . pattern ."\""
		let s:skip = 1
	endtry
	if s:skip == 0
		exec 'let @/ = "'.pattern.'"'
		let nr = input("Which one: ")
		if nr == ""
			return
		endif
		try
			exec "ijump! " . nr . "/".pattern."/" 
		catch /^Vim(\a\+):E387:/
			echo "BAD :-( ---%<---"
		endtry
	endif
endfunction

function! s:BriefSave()
	if expand("%") == ""
		if has("gui_running")
			browse write
		else
			let fname = input("Save file as: ")
			if fname == ""
				return
			endif
			execute "write " . fname
		endif
	else
		write!
	endif
endfunction

function! s:BriefSaveAs()
	if has("gui_running")
		browse saveas
	else
		let fname = input("Save file as: ")
		if fname == ""
			return
		endif
		execute "saveas " . fname
	endif
endfunction

function! s:leJumpMark()
	let mark = input("m(c-z) for BookMark, Jump to bookmark(c-z): ")
	if mark == ""
		return
	endif

	try     
		exec "normal `".mark
	catch /^Vim(\a\+):E20:/  
		echo "set BookMark m(c-z) first, empty for BookMark(".mark.")" 
	endtry 
endfunction



function! s:leGotoLine()
	let linenr = input("Line number to jump to: ")
	if linenr == ""
		return
	endif

	execute "normal " . linenr . "gg"
endfunction

"vim substitute/replace
function! s:leReplace()
	call inputsave()
	let pat = expand("<cword>")
	let s:lePAT = input("Replace: (".pat."): ")
	if s:lePAT == ""
		let s:lePAT = pat
		if s:lePAT == ""
			return
		endif  
	endif
	let s:leREP = input("Replace (" . s:lePAT . ") with: ")
	exec '%s/' . s:lePAT . '/' . s:leREP . '/gc'
	call inputrestore()
endfunction

" from http://www.vim.org/tips/tip.php?tip_id=79 and modified
function! s:ShowFunc(sort) 
	let gf_s = &grepformat 
	let gp_s = &grepprg 
	if ( &filetype == "c" || &filetype == "php" || &filetype == "python" ||
				\ &filetype == "sh" )
		let &grepformat='%*\k%*\sfunction%*\s%l%*\s%f %m'
		let &grepprg = 'ctags -x --'.&filetype.'-types=f --sort='.a:sort
	elseif ( &filetype == "perl" )
		let &grepformat='%*\k%*\ssubroutine%*\s%l%*\s%f %m'
		let &grepprg = 'ctags -x --perl-types=s --sort='.a:sort
	elseif ( &filetype == "vim" )
		let &grepformat='%*\k%*\sfunction%*\s%l%*\s%f %m'
		let &grepprg = 'ctags -x --vim-types=f --language-force=vim --sort='.a:sort
	endif 
	if (&readonly == 0) | update | endif 
	silent! grep % 
	cwindow 10 
	redraw   
	let &grepformat = gf_s
	let &grepprg = gp_s 
endfunction  

function! s:BufferNext()
	exec "bnext!"
endfunction

function! s:BufferPrev()
	exec "bprevious!"
endfunction

function! s:leQuit()
	exec "confirm qa"
endfunction

function! s:leClose()
	exec "bdelete"
endfunction

function! s:leCMD()
	exec ":"
endfunction

function! s:leBuffer()
	"    exec "buffers"
	exec "BufExplorer"
endfunction

function! s:leDelLine()
	exec "norm dd"
endfunction

function! s:leDired()
	exec "e! ."
endfunction

function! s:leFile()
	exec "file"
endfunction

function! s:leComplete()
	exec "norm <C-P>"
endfunction

function! s:leFinfo()
	let finfo = expand("%:p")
	let ww = expand("<cword>")
	echo '"' . finfo . '"'
endfunction

function! s:leFind()
	call inputsave()
	let g:pat = expand("<cword>")
        let @" = g:pat
	call inputrestore()
	exec 'let @a ="' . g:pat .'"'       
	exec 'let @/ ="' . g:pat .'"'
	echo "<".g:pat."> Marked!! n/N for repeat search CTRL-V for yank"
endfunction

function! s:leTAB(direction)
	let col = col('.') - 1        
	if !col || getline('.')[col -1] !~ '\k'
		return "\<tab>"
	elseif "forward" == a:direction    
		return "\<c-p>"
	endif 
endfunction!

function! TabCompletion()
	if mapcheck("\<tab>", "i") != ""
		:iunmap <tab>
		echo "TAB completion off"
	else 
		:imap <tab> <c-p>
		echo "TAB completion on"
	endif
	"map <Leader>tc :call TabCompletion()<CR>
endfunction

function! s:leSave()
	if expand("%") == ""
		if has("gui_running")
			browse write
		else
			let fname = input("Save file as: ")
			if fname == ""
				return
			endif
			execute "write " . fname
		endif  
	else
		write!
	endif
endfunction

function! s:levimgrep()
    " No argument supplied. Get the identifier and file list from user
    let pattern = input("vimGrep for pattern: ", expand("<cword>"))
    if pattern == ""
	echo "Cancelled."    
        return
    endif

    if g:vim_mask == "*"
        let ff = expand("%:e")
        if ff != ""
            let g:vim_mask = "*.".ff
        endif
    endif

    let filenames = input("vimGrep in files: ", g:vim_mask)
    if filenames == ""
        echo "Cancelled."    
        return
    endif
    if filenames == "*"
        let ff =expand("%:e")
        if ff != ""
            let filenames = "*.".ff
        endif
    endif
 
    exec "vimgrep /" . pattern . "/ **/" . filenames 

endfunction

" Return last visually selected text or '\<cword\>'.
" what = 1 (selection), or 2 (cword), or 0 (guess if 1 or 2 is wanted).
function! s:Pattern(what)
	if a:what == 2 || (a:what == 0 && histget(':', -1) =~# '^H')
		let result = expand("<cword>")
		if !empty(result)
			let result = '\<'.result.'\>'
		endif
	else
		let old_reg = getreg('"')
		let old_regtype = getregtype('"')
		normal! gvy
		let result = substitute(escape(@@, '\.*$^~['), '\_s\+', '\\_s\\+', 'g')
		normal! gV
		call setreg('"', old_reg, old_regtype)
	endif
	return result
endfunction



" you can use "CTRL-V" for mapping real key in Quote
if has("gui_running")
	let Occur_Key    = '<M-o>'
	let lequit_Key   = '<M-q>'
	let legoto_Key   = '<M-g>'
	let lesave_Key   = '<M-w>'
	let leclose_Key  = '<M-x>'
	let lefind_Key   = '<M-s>'
	let leedit_Key   = '<M-e>'
	let lewmark_Key  = '<M-y>'
	let ledelln_Key  = '<M-d>'
	let bn_Key       = '<M-.>'
	let bp_Key       = '<M-,>'
	let lecomp_Key   = "<M-/>"
	let lebuff_Key   = "<M-b>"
	let leinfo_Key   = "<M-f>"
	let leRepl_Key   = "<M-t>"
	let leMarkLn     = "<M-l>"
else	
	let Occur_Key    = "o" 
	let lequit_Key   = "q" 
	let legoto_Key   = "g"
	let lesave_Key   = "w"
	let leclose_Key  = "x"
	let lefind_Key   = "s"
        let lefile_Key   = "f"
	let leedit_Key   = "e"
	let lewmark_Key  = "y"
	let ledelln_Key  = "d"
	let bn_Key       = "." 
	let bp_Key       = ","
	let lecomp_Key   = "/"
	let lebuff_Key   = "b"
	let leinfo_Key   = "f"
	let leRepl_Key   = "t"
	let leMarkLn     = "l"
endif

noremap <F4> :qa!<CR>
noremap <silent> <F6> <C-W>w
noremap <silent> <C-W>k <C-W>c
noremap <silent> <C-W>0 <C-W>c
noremap <silent> <C-X>k :bd<CR>
noremap <silent> <C-X>0 <C-W>c
noremap <silent> <C-X>1 :only<CR>
noremap <silent> <C-X>2 <C-W>i
noremap <silent> <C-X>3 <C-W>v
noremap <silent> <C-V> "ap
noremap <silent> <C-B> :pop<CR>
inoremap <silent> <C-B> <C-O>:pop<CR>
noremap <F8> :TlistToggle<CR>
noremap <F7> %
inoremap <F7> <C-O>%
noremap <TAB> ==j
inoremap <silent> <ESC>/ <C-P>
nmap <F2> :Rgrep<CR>
inoremap <F2> <C-O>:Rgrep<CR>
nmap <F3> :exec "vimgrep /" . expand("<cword>") . "/j **/*." . expand("%:e") <Bar>  cw<CR>
nmap . :cn<CR>
nmap , :cp<CR>
" hint for no-map usage 
"
" replace %s/foo/xxx/gc    <A-t>
"

exec "nnoremap <unique> <silent> " . bn_Key .    " :call <SID>BufferNext()<CR>"
exec "inoremap <unique> <silent> " . bn_Key .    " <C-O>:call <SID>BufferNext()<CR>"

exec "nnoremap <unique> <silent> " . bp_Key .    " :call <SID>BufferPrev()<CR>"
exec "inoremap <unique> <silent> " . bp_Key .    " <C-O>:call <SID>BufferPrev()<CR>"

exec "nnoremap <unique> <silent> " . lequit_Key . " :call <SID>leQuit()<CR>"
exec "inoremap <unique> <silent> " . lequit_Key . " <C-O>:call <SID>leQuit()<CR>"

exec "nnoremap <unique> <silent> " . lesave_Key . " :call <SID>leSave()<CR>"
exec "inoremap <unique> <silent> " . lesave_Key . " <C-O>:call <SID>leSave()<CR>"

exec "nnoremap <unique> <silent> " . leedit_Key . " :call <SID>leDired()<CR>"
exec "inoremap <unique> <silent> " . leedit_Key . " <C-O>:call <SID>leDired()<CR>"

exec "nnoremap <unique> <silent> " . ledelln_Key . " :call <SID>leDelLine()<CR>"
exec "inoremap <unique> <silent> " . ledelln_Key . " <C-O>:call <SID>leDelLine()<CR>"

exec "nnoremap <unique> <silent> " . lebuff_Key . " :call <SID>leBuffer()<CR>"
exec "inoremap <unique> <silent> " . lebuff_Key . " <C-O>:call <SID>leBuffer()<CR>"

exec "nnoremap <unique> <silent> " . leclose_Key . " :call <SID>leClose()<CR>"
exec "inoremap <unique> <silent> " . leclose_Key . " <C-O>:call <SID>leClose()<CR>"

exec "nnoremap <unique> <silent> " . lewmark_Key . " :call <SID>leFind()<CR>"
exec "inoremap <unique> <silent> " . lewmark_Key . " <C-O>:call <SID>leFind()<CR>"

exec "nnoremap <unique> <silent> " . lefile_Key . " :call <SID>leFinfo()<CR>"
exec "inoremap <unique> <silent> " . lefile_Key . " <C-O>:call <SID>leFinfo()<CR>"

exec "nnoremap <unique> <silent> " . lefind_Key . " :call <SID>levimgrep()<CR>"
exec "inoremap <unique> <silent> " . lefind_Key . " <C-O>:call <SID>levimgrep()<CR>"

exec "nnoremap <unique> <silent> " . Occur_Key . " :call <SID>leOccur()<CR>"
exec "inoremap <unique> <silent> " . Occur_Key. " <C-O>:call <SID>leOccur()<CR>"

exec "nnoremap <unique> <silent> " . legoto_Key . " :call <SID>leGotoLine()<CR>"
exec "inoremap <unique> <silent> " . legoto_Key . " <C-O>:call <SID>leGotoLine()<CR>"

" vim:sw=4:tabstop=4

