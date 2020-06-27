function! s:do(args) abort
    let args = map(copy(a:args), { _, v -> printf('"%s"', v) })
    let cmd = printf('require("searcho/command").main(%s)', join(args, ', '))
    return luaeval(cmd)
endfunction

if get(g:, 'searcho_debug', v:false)
    function! searcho#do(...) abort
        lua require("searcho/cleanup")("searcho")
        doautocmd User SearchoSourceLoad
        return s:do(a:000)
    endfunction
else
    function! searcho#do(...) abort
        return s:do(a:000)
    endfunction
endif

doautocmd User SearchoSourceLoad
