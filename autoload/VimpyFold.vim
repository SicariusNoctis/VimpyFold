function! VimpyFold#FoldPython(lnum) abort
    " Unholy hacks because vim sucks
    if a:lnum == 1
        call VimpyFold#RebuildCache()
    endif
    return b:VimpyFold_cache[a:lnum]
endfunction

function! VimpyFold#RebuildCache() abort
    let b:VimpyFold_cache = s:BuildCache()
endfunction

function! s:BuildCache() abort
    let lines = getline('1', '$')
    let num_lines = len(lines)
    let cache = map(range(num_lines + 1), '""')
    let indent_stack = map(range(21), '"-1"')
    let level = 0
    let is_import = 0

    function! PopStack() abort closure
        while indent <= indent_stack[level]
            let level -= 1
        endwhile
    endfunction

    function! PushStack() abort closure
        let level += 1
        let indent_stack[level] = indent
    endfunction

    function! Finalize() abort closure
        let cache[lnum] = prefix . level
    endfunction

    for lnum in range(1, num_lines)
        let line = lines[lnum - 1]
        let prefix = ''
        let indent = indent(lnum)

        if line =~? '\v^\s*$'
            call Finalize()
            continue
        endif

        if line =~? '\v^(import|from)\s'
            if !is_import
                let prefix = '>'
                let is_import = 1
                call PushStack()
            endif
            call Finalize()
            continue
        endif

        let is_import = 0
        call PopStack()

        if line =~? '\v^\s*(class|def)\s'
            let prefix = '>'
            if indent != indent_stack[level]
                call PushStack()
            endif
        endif

        if indent == indent_stack[level]
            let prefix = '>'
        endif

        call Finalize()
    endfor

    " echoerr string(cache)
    return cache
endfunction


" TODO docstring, decorator, header comment, multiline list/dict/string
" TODO wrapped text within a multiline or parenthesis (eww)
" TODO maybe < will help with weird refresh problems

" let lines = getbufline(bufnr('%'), 1, '$')
" let line = getline(lnum)
" let num_lines = line('$')

" 0
" >1  class:
" >2      def:
" 2           pass
" 2           pass
" 2
" >2      def:
" 2           pass
" >3          def:
" 3               pass
" >3          def:
" 3               pass
" 2           pass
" 2
" 0   if:
" 0       pass
" 0
" >1  def:
" 1       pass
" 1
" >1  def: pass
" >1  def: pass
