function! s:do(args) abort
    return luaeval('require("searcho/command").main(unpack(_A))', a:args)
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
