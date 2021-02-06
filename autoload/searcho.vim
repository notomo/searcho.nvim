function! searcho#do(...) abort
    return luaeval('require("searcho/command").main(unpack(_A))', a:000)
endfunction

" mapping util

function! searcho#with_left(key) abort
    return a:key .. repeat("\<Left>", strchars(a:key))
endfunction

doautocmd User SearchoSourceLoad
