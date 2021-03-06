
let s:UPPER = 'UPPER'
let s:SNAKE = 'SNAKE'
let s:CAMEL = 'CAMEL'
let s:PASCAL = 'PASCAL'
let s:KEBAB = 'KEBAB'
let s:OTHER = 'OTHER'

function! suball#input(before, after) abort
    return suball#command(a:before, a:after) .. "\<Left>\<Left>\<Left>\<Left>"
endfunction

function! suball#command(before, after) abort
    let patterns = map([s:UPPER, s:SNAKE, s:CAMEL, s:PASCAL, s:KEBAB], {key, type -> s:convert(type, a:before)})
    let is_one_word = patterns[1] ==# patterns[4] ? '1' : '0'
    let pattern = join(patterns, '|')
    return printf("s/\\v(%s)/\\=suball#helper(%s, submatch(0), '%s')/g", pattern, is_one_word, a:after)
endfunction

function! suball#helper(is_one_word, match, word) abort
    let case_type = s:get_type(a:match)
    if a:is_one_word && (case_type ==? s:SNAKE || case_type ==? s:CAMEL || case_type ==? s:KEBAB)
        let case_type = s:get_type(a:word)
    endif
    return s:convert(case_type, a:word)
endfunction


function! s:convert(case_type, word) abort
    let mapper = {
        \ s:UPPER : {word -> s:to_upper(word)},
        \ s:SNAKE : {word -> s:to_snake(word)},
        \ s:CAMEL : {word -> s:to_camel(word)},
        \ s:PASCAL : {word -> s:to_pascal(word)},
        \ s:KEBAB : {word -> s:to_kebab(word)},
        \ s:OTHER : {word -> word},
    \ }
    return mapper[a:case_type](a:word)
endfunction

function! s:get_type(str) abort
    if s:is_upper(a:str)
        return s:UPPER
    elseif s:is_kebab(a:str)
        return s:KEBAB
    elseif s:is_snake(a:str)
        return s:SNAKE
    elseif s:is_camel(a:str)
        return s:CAMEL
    elseif s:is_pascal(a:str)
        return s:PASCAL
    endif
    return s:OTHER
endfunction


function! s:to_upper(str) abort
    return toupper(s:to_snake(a:str))
endfunction

function! s:is_upper(str) abort
    return a:str ==# toupper(a:str)
endfunction


function! s:to_snake(str) abort
    let case_type = s:get_type(a:str)
    if case_type ==? s:CAMEL
        return substitute(a:str, '\v(\u)', '_\l\1', 'g')
    elseif case_type ==? s:PASCAL
        let str = tolower(a:str[0]) . a:str[1:]
        return substitute(str, '\v(\u)', '_\l\1', 'g')
    elseif case_type ==? s:KEBAB
        return substitute(a:str, '-', '_', 'g')
    endif
    return tolower(a:str)
endfunction

function! s:is_snake(str) abort
    return a:str ==# tolower(a:str)
endfunction


function! s:to_camel(str) abort
    let case_type = s:get_type(a:str)
    let str = a:str
    if case_type ==? s:PASCAL
        return tolower(str[0]) .. str[1:]
    elseif case_type ==? s:CAMEL
        return str
    elseif case_type ==? s:KEBAB
        let str = s:to_snake(str)
    endif
    return substitute(tolower(str), '\v_(.)', '\u\1', 'g')
endfunction

function! s:is_camel(str) abort
    return a:str =~# '\v^\l+(\u\l+)+'
endfunction


function! s:to_pascal(str) abort
    let str = s:to_camel(a:str)
    return toupper(str[0]) .. str[1:]
endfunction

function! s:is_pascal(str) abort
    return a:str =~# '\v^(\u\l+)+'
endfunction


function! s:to_kebab(str) abort
    let str = s:to_snake(a:str)
    return substitute(str, '_', '-', 'g')
endfunction

function! s:is_kebab(str) abort
    return a:str =~# '\v^(\l+-\l+)+'
endfunction
