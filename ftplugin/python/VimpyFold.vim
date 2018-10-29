if exists('b:loaded_VimpyFold')
    finish
endif
let b:loaded_VimpyFold = 1

call VimpyFold#RebuildCache()
setlocal foldmethod=expr foldexpr=VimpyFold#FoldPython(v:lnum)

augroup VimpyFold
    autocmd TextChanged, InsertLeave <buffer> call VimpyFold#RebuildCache()
augroup END
