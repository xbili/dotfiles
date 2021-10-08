local tonumber = tonumber
local string_char = string.char
local utf8_char = utf8.char
local type = type
local table = table

local Errs
local State

local function pushError(err)
    if err.finish < err.start then
        err.finish = err.start
    end
    local last = Errs[#Errs]
    if last then
        if last.start <= err.start and last.finish >= err.finish then
            return
        end
    end
    err.level = err.level or 'error'
    Errs[#Errs+1] = err
    return err
end

-- goto 单独处理
local RESERVED = {
    ['and']      = true,
    ['break']    = true,
    ['do']       = true,
    ['else']     = true,
    ['elseif']   = true,
    ['end']      = true,
    ['false']    = true,
    ['for']      = true,
    ['function'] = true,
    ['if']       = true,
    ['in']       = true,
    ['local']    = true,
    ['nil']      = true,
    ['not']      = true,
    ['or']       = true,
    ['repeat']   = true,
    ['return']   = true,
    ['then']     = true,
    ['true']     = true,
    ['until']    = true,
    ['while']    = true,
}

local VersionOp = {
    ['&']  = {'Lua 5.3', 'Lua 5.4', 'Luau'},
    ['~']  = {'Lua 5.3', 'Lua 5.4'},
    ['|']  = {'Lua 5.3', 'Lua 5.4', 'Luau'},
    ['<<'] = {'Lua 5.3', 'Lua 5.4'},
    ['>>'] = {'Lua 5.3', 'Lua 5.4'},
    ['//'] = {'Lua 5.3', 'Lua 5.4'},
}

local function checkOpVersion(op, start)
    local versions = VersionOp[op]
    if not versions then
        return
    end
    for i = 1, #versions do
        if versions[i] == State.Version then
            return
        end
    end
    pushError {
        type = 'UNSUPPORT_SYMBOL',
        start = start,
        finish = start + #op - 1,
        version = versions,
        info = {
            version = State.Version,
        }
    }
end

local Exp

local function expSplit(list, start, finish, level)
    if start == finish then
        return list[start]
    end
    local info = Exp[level]
    if not info then
        return
    end
    local func = info[1]
    return func(list, start, finish, level)
end

local function binaryForward(list, start, finish, level)
    local info = Exp[level]
    for i = finish-1, start+2, -1 do
        local op = list[i]
        if info[op] then
            local e1 = expSplit(list, start, i-2, level)
            if not e1 then
                goto CONTINUE
            end
            local e2 = expSplit(list, i+1, finish, level+1)
            if not e2 then
                goto CONTINUE
            end
            checkOpVersion(op, list[i-1])
            return {
                type   = 'binary',
                op     = op,
                start  = e1.start,
                finish = e2.finish,
                [1]    = e1,
                [2]    = e2,
            }
        end
        ::CONTINUE::
    end
    return expSplit(list, start, finish, level+1)
end

local function binaryBackward(list, start, finish, level)
    local info = Exp[level]
    for i = start+2, finish-1 do
        local op = list[i]
        if info[op] then
            local e1 = expSplit(list, start, i-2, level+1)
            if not e1 then
                goto CONTINUE
            end
            local e2 = expSplit(list, i+1, finish, level)
            if not e2 then
                goto CONTINUE
            end
            checkOpVersion(op, list[i-1])
            return {
                type   = 'binary',
                op     = op,
                start  = e1.start,
                finish = e2.finish,
                [1]    = e1,
                [2]    = e2,
            }
        end
        ::CONTINUE::
    end
    return expSplit(list, start, finish, level+1)
end

local function unary(list, start, finish, level)
    local info = Exp[level]
    local op = list[start+1]
    if info[op] then
        local e1 = expSplit(list, start+2, finish, level)
        if e1 then
            checkOpVersion(op, list[start])
            return {
                type   = 'unary',
                op     = op,
                start  = list[start],
                finish = e1.finish,
                [1]    = e1,
            }
        end
    end
    return expSplit(list, start, finish, level+1)
end

local function checkMissEnd(start, source)
    if not State.MissEndErr then
        return
    end
    local err = State.MissEndErr
    State.MissEndErr = nil
    local _, finish = State.Lua:find('[%w_]+', start)
    if not finish then
        return
    end
    err.info.related = { start, finish }
    State.MissedEnd[#State.MissedEnd+1] = {source, start = start, finish = finish}
    pushError {
        type   = 'MISS_END',
        start  = start,
        finish = finish,
    }
end

Exp = {
    {
        ['or'] = true,
        binaryForward,
    },
    {
        ['and'] = true,
        binaryForward,
    },
    {
        ['<='] = true,
        ['>='] = true,
        ['<']  = true,
        ['>']  = true,
        ['~='] = true,
        ['=='] = true,
        binaryForward,
    },
    {
        ['|'] = true,
        binaryForward,
    },
    {
        ['~'] = true,
        binaryForward,
    },
    {
        ['&'] = true,
        binaryForward,
    },
    {
        ['<<'] = true,
        ['>>'] = true,
        binaryForward,
    },
    {
        ['..'] = true,
        binaryBackward,
    },
    {
        ['+'] = true,
        ['-'] = true,
        binaryForward,
    },
    {
        ['*']  = true,
        ['//'] = true,
        ['/']  = true,
        ['%']  = true,
        binaryForward,
    },
    {
        ['^'] = true,
        binaryBackward,
    },
    {
        ['not'] = true,
        ['#']   = true,
        ['~']   = true,
        ['-']   = true,
        unary,
    },
}

local function buildEmmy(obj, keys)
    local emmyName = "any"
    if obj.type == "varType" and keys.type == "name" then
        if obj.info.type == "nameType" then
            emmyName = obj.info[1]
        end
        return {
            type = "emmyType",
            start = keys.start,
            finish = keys.finish,
            syntax = true,
            varType = obj,
            [1] = {
                type = "emmyName",
                start = obj.info.start,
                finish = obj.info.finish,
                syntax = true,
                [1] = emmyName
            },
        }
    elseif obj.type == "paramType" and keys.type == "name" then
        if obj.info.type == "nameType" then
            emmyName = obj.info[1]
        end
        return {
            type = "emmyParam",
            start = keys.start,
            finish = keys.finish,
            syntax = true,
            [1] = {
                type = "emmyName",
                start = obj.info.start,
                finish = obj.info.finish,
                [1] = keys[1]
            },
            [2] = {
                type = "emmyType",
                start = keys.start,
                finish = keys.finish,
                paramType = obj,
                [1] = {
                    type = "emmyName",
                    start = obj.info.start,
                    finish = obj.info.finish,
                    syntax = true,
                    [1] = emmyName
                }
            },
        }
    elseif obj.type == "returnType" then
        if obj.info.type == "typeList" then 
            local types = table.deepCopy(obj.info.types)
            for i, v in pairs(types) do
                local name = "any"
                if v.type == "nameType" then
                    name = v[1]
                end
                types[i] = {
                    type = "emmyReturn",
                    start = v.start,
                    finish = v.finish,
                    syntax = true,
                    [1] = {
                        type = "emmyType",
                        start = v.start,
                        finish = v.finish,
                        returnType = obj,
                        [1] = {
                            type = "emmyName",
                            start = v.start,
                            finish = v.finish,
                            syntax = true,
                            [1] = name
                        }
                    },
                }
            end
            return types
        else
            if obj.info.type == "nameType" then
                emmyName = obj.info[1]
            end
            return {{
                type = "emmyReturn",
                start = obj.info.start,
                finish = obj.info.finish,
                syntax = true,
                [1] = {
                    type = "emmyType",
                    start = obj.info.start,
                    finish = obj.info.finish,
                    returnType = obj,
                    [1] = {
                        type = "emmyName",
                        start = obj.info.start,
                        finish = obj.info.finish,
                        syntax = true,
                        [1] = emmyName
                    }
                },
            }}
        end
    end
    return obj
end

local Defs = {
    Nil = function (pos)
        return {
            type   = 'nil',
            start  = pos,
            finish = pos + 2,
        }
    end,
    True = function (pos)
        return {
            type   = 'boolean',
            start  = pos,
            finish = pos + 3,
            [1]    = true,
        }
    end,
    False = function (pos)
        return {
            type   = 'boolean',
            start  = pos,
            finish = pos + 4,
            [1]    = false,
        }
    end,
    LongComment = function (beforeEq, afterEq, str, finish, missPos)
        State.Comments[#State.Comments+1] = {
            start  = beforeEq,
            finish = finish,
        }
        if missPos then
            local endSymbol = ']' .. ('='):rep(afterEq-beforeEq) .. ']'
            local s, _, w = str:find('(%][%=]*%])[%c%s]*$')
            if s then
                pushError {
                    type   = 'ERR_LCOMMENT_END',
                    start  = missPos - #str + s - 1,
                    finish = missPos - #str + s + #w - 2,
                    info   = {
                        symbol = endSymbol,
                    },
                    fix    = {
                        title = 'FIX_LCOMMENT_END',
                        {
                            start  = missPos - #str + s - 1,
                            finish = missPos - #str + s + #w - 2,
                            text   = endSymbol,
                        }
                    },
                }
            end
            pushError {
                type   = 'MISS_SYMBOL',
                start  = missPos,
                finish = missPos,
                info   = {
                    symbol = endSymbol,
                },
                fix    = {
                    title = 'ADD_LCOMMENT_END',
                    {
                        start  = missPos,
                        finish = missPos,
                        text   = endSymbol,
                    }
                },
            }
        end
    end,
    CLongComment = function (start1, finish1, start2, finish2)
        pushError {
            type   = 'ERR_C_LONG_COMMENT',
            start  = start1,
            finish = finish2 - 1,
            fix    = {
                title = 'FIX_C_LONG_COMMENT',
                {
                    start  = start1,
                    finish = finish1 - 1,
                    text   = '--[[',
                },
                {
                    start  = start2,
                    finish = finish2 - 1,
                    text   =  '--]]'
                },
            }
        }
    end,
    CCommentPrefix = function (start, finish)
        pushError {
            type   = 'ERR_COMMENT_PREFIX',
            start  = start,
            finish = finish - 1,
            fix    = {
                title = 'FIX_COMMENT_PREFIX',
                {
                    start  = start,
                    finish = finish - 1,
                    text   = '--',
                },
            }
        }
        return false
    end,
    String = function (start, quote, str, finish)
        return {
            type   = 'string',
            start  = start,
            finish = finish - 1,
            [1]    = str,
            [2]    = quote,
        }
    end,
    LongString = function (beforeEq, afterEq, str, missPos)
        if missPos then
            local endSymbol = ']' .. ('='):rep(afterEq-beforeEq) .. ']'
            local s, _, w = str:find('(%][%=]*%])[%c%s]*$')
            if s then
                pushError {
                    type   = 'ERR_LSTRING_END',
                    start  = missPos - #str + s - 1,
                    finish = missPos - #str + s + #w - 2,
                    info   = {
                        symbol = endSymbol,
                    },
                    fix    = {
                        title = 'FIX_LSTRING_END',
                        {
                            start  = missPos - #str + s - 1,
                            finish = missPos - #str + s + #w - 2,
                            text   = endSymbol,
                        }
                    },
                }
            end
            pushError {
                type   = 'MISS_SYMBOL',
                start  = missPos,
                finish = missPos,
                info   = {
                    symbol = endSymbol,
                },
                fix    = {
                    title = 'ADD_LSTRING_END',
                    {
                        start  = missPos,
                        finish = missPos,
                        text   = endSymbol,
                    }
                },
            }
        end
        return '[' .. ('='):rep(afterEq-beforeEq) .. '[', str
    end,
    Char10 = function (char)
        char = tonumber(char)
        if not char or char < 0 or char > 255 then
            return ''
        end
        return string_char(char)
    end,
    Char16 = function (pos, char)
        if State.Version == 'Lua 5.1' then
            pushError {
                type = 'ERR_ESC',
                start = pos-1,
                finish = pos,
                version = {'Lua 5.2', 'Lua 5.3', 'Lua 5.4', 'LuaJIT'},
                info = {
                    version = State.Version,
                }
            }
            return char
        end
        return string_char(tonumber(char, 16))
    end,
    CharUtf8 = function (pos, char)
        if  State.Version ~= 'Lua 5.3'
        and State.Version ~= 'Lua 5.4'
        and State.Version ~= 'LuaJIT'
        and State.Version ~= "Luau"
        then
            pushError {
                type = 'ERR_ESC',
                start = pos-3,
                finish = pos-2,
                version = {'Lua 5.3', 'Lua 5.4', 'LuaJIT'},
                info = {
                    version = State.Version,
                }
            }
            return char
        end
        if #char == 0 then
            pushError {
                type = 'UTF8_SMALL',
                start = pos-3,
                finish = pos,
            }
            return ''
        end
        local v = tonumber(char, 16)
        if not v then
            for i = 1, #char do
                if not tonumber(char:sub(i, i), 16) then
                    pushError {
                        type = 'MUST_X16',
                        start = pos + i - 1,
                        finish = pos + i - 1,
                    }
                end
            end
            return ''
        end
        if State.Version == 'Lua 5.4' then
            if v < 0 or v > 0x7FFFFFFF then
                pushError {
                    type = 'UTF8_MAX',
                    start = pos-3,
                    finish = pos+#char,
                    info = {
                        min = '00000000',
                        max = '7FFFFFFF',
                    }
                }
            end
        else
            if v < 0 or v > 0x10FFFF then
                pushError {
                    type = 'UTF8_MAX',
                    start = pos-3,
                    finish = pos+#char,
                    version = v <= 0x7FFFFFFF and 'Lua 5.4' or nil,
                    info = {
                        min = '000000',
                        max = '10FFFF',
                    }
                }
            end
        end
        if v >= 0 and v <= 0x10FFFF then
            return utf8_char(v)
        end
        return ''
    end,
    Number = function (start, number, finish)
        local n;
        if State.Version == 'Luau' then
            number = number:gsub("_", "")
            if number:sub(2, 2):lower() == "b" then
                -- Luau binary constant support
                n = tonumber(number:sub(3), 2)
            else
                n = tonumber(number)
            end
        else
            n = tonumber(number)
        end
        if n then
            State.LastNumber = {
                type   = 'number',
                start  = start,
                finish = finish - 1,
                [1]    = n,
                [2]    = number,
            }
            return State.LastNumber
        else
            pushError {
                type   = 'MALFORMED_NUMBER',
                start  = start,
                finish = finish - 1,
            }
            State.LastNumber = {
                type   = 'number',
                start  = start,
                finish = finish - 1,
                [1]    = 0,
            }
            return State.LastNumber
        end
    end,
    FFINumber = function (start, symbol)
        if math.type(State.LastNumber[1]) == 'float' then
            pushError {
                type = 'UNKNOWN_SYMBOL',
                start = start,
                finish = start + #symbol - 1,
                info = {
                    symbol = symbol,
                }
            }
            State.LastNumber[1] = 0
            return
        end
        if State.Version ~= 'LuaJIT' then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = start,
                finish = start + #symbol - 1,
                version = 'LuaJIT',
                info = {
                    version = State.Version,
                }
            }
            State.LastNumber[1] = 0
        end
    end,
    ImaginaryNumber = function (start, symbol)
        if State.Version ~= 'LuaJIT' then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = start,
                finish = start + #symbol - 1,
                version = 'LuaJIT',
                info = {
                    version = State.Version,
                }
            }
        end
        State.LastNumber[1] = 0
    end,
    Name = function (start, str, finish)
        local isKeyWord
        if RESERVED[str] then
            isKeyWord = true
        elseif str == 'goto' then
            if State.Version ~= 'Lua 5.1' and State.Version ~= 'LuaJIT' and State.Version ~= "Luau" then
                isKeyWord = true
            end
        end
        if isKeyWord then
            pushError {
                type = 'KEYWORD',
                start = start,
                finish = finish - 1,
            }
        end
        return {
            type   = 'name',
            start  = start,
            finish = finish - 1,
            [1]    = str,
        }
    end,
    Simple = function (first, ...)
        if ... then
            local obj = {
                type = 'simple',
                start = first.start,
                first, ...,
            }
            local last = obj[#obj]
            obj.finish = last.finish
            return obj
        elseif first == '' then
            return nil
        else
            return first
        end
    end,
    SimpleCall = function (simple)
        if not simple then
            return nil
        end
        if simple.type ~= 'simple' then
            pushError {
                type   = 'EXP_IN_ACTION',
                start  = simple.start,
                finish = simple.finish,
            }
            return simple
        end
        local last = simple[#simple]
        if last.type == 'call' then
            return simple
        end
        local colon = simple[#simple-1]
        if colon and colon.type == ':' then
            -- 型如 `obj:method`，将错误让给MISS_SYMBOL
            return simple
        end
        pushError {
            type   = 'EXP_IN_ACTION',
            start  = simple[1].start,
            finish = last.finish,
        }
        return simple
    end,
    Exp = function (first, ...)
        if not ... then
            return first
        end
        local list = {first, ...}
        return expSplit(list, 1, #list, 1)
    end,
    Prefix = function (start, exp, finish)
        exp.brackets = true
        return exp
    end,
    Index = function (start, exp, finish)
        return {
            type = 'index',
            start = start,
            finish = finish - 1,
            [1] = exp,
        }
    end,
    Call = function (start, arg, finish)
        if arg == nil then
            return {
                type = 'call',
                start = start,
                finish = finish - 1,
            }
        end
        if arg.type == 'list' then
            arg.type = 'call'
            arg.start = start
            arg.finish = finish - 1
            return arg
        end
        local obj = {
            type = 'call',
            start = start,
            finish = finish - 1,
            [1]  = arg,
        }
        return obj
    end,
    DOTS = function (start)
        return {
            type   = '...',
            start  = start,
            finish = start + 2,
        }
    end,
    DotsAsArg = function (obj)
        State.Dots[#State.Dots] = true
        return obj
    end,
    DotsAsExp = function (obj)
        if not State.Dots[#State.Dots] then
            pushError {
                type = 'UNEXPECT_DOTS',
                start = obj.start,
                finish = obj.finish,
            }
        end
        return obj
    end,
    COLON = function (start)
        return {
            type   = ':',
            start  = start,
            finish = start,
        }
    end,
    DOT = function (start)
        return {
            type   = '.',
            start  = start,
            finish = start,
        }
    end,
    Function = function (start, argStart, arg, argFinish, ...)
        local obj = {
            type      = 'function',
            start     = start,
            emmys      = arg and arg[2],
            arg       = arg and arg[1],
            argStart  = argStart - 1,
            argFinish = argFinish,
            ...
        }
        local max = #obj
        obj.finish = obj[max] - 1
        obj[max]   = nil
        if obj.argFinish > obj.finish then
            obj.argFinish = obj.finish
        end
        checkMissEnd(start, obj)
        if type(obj[1]) == "table" and obj[1].type == "returnType" then
            obj.emmys = obj.emmys or {}
            for _, tp in pairs(buildEmmy(table.pick(obj, 1))) do
                obj.emmys[#obj.emmys+1] = tp
            end
        end
        return obj
    end,
    NamedFunction = function (start, name, argStart, arg, argFinish, ...)
        local obj = {
            type      = 'function',
            start     = start,
            name      = name,
            arg       = arg and arg[1],
            argStart  = argStart - 1,
            argFinish = argFinish,
            ...
        }
        local max = #obj
        obj.finish = obj[max] - 1
        obj[max]   = nil
        if obj.argFinish > obj.finish then
            obj.argFinish = obj.finish
        end
        checkMissEnd(start, obj)
        local ret = (arg and arg[2] or {})
        if type(obj[1]) == "table" and obj[1].type == "returnType" then
            for _, tp in pairs(buildEmmy(table.pick(obj, 1))) do
                ret[#ret+1] = tp
            end
        end
        ret[#ret + 1] = obj
        return table.unpack(ret)
    end,
    LocalFunction = function (start, name, argStart, arg, argFinish, ...)
        local obj = {
            type       = 'localfunction',
            start      = start,
            name       = name,
            arg        = arg and arg[1],
            argStart   = argStart - 1,
            argFinish  = argFinish,
            ...
        }

        local max = #obj
        obj.finish = obj[max] - 1
        obj[max]   = nil
        if obj.argFinish > obj.finish then
            obj.argFinish = obj.finish
        end

        if name.type ~= 'name' then
            pushError {
                type = 'UNEXPECT_LFUNC_NAME',
                start = name.start,
                finish = name.finish,
            }
        end
        checkMissEnd(start, obj)
        local ret = (arg and arg[2] or {})
        if type(obj[1]) == "table" and obj[1].type == "returnType" then
            for _, tp in pairs(buildEmmy(table.pick(obj, 1))) do
                ret[#ret+1] = tp
            end
        end
        ret[#ret + 1] = obj
        return table.unpack(ret)
    end,
    Table = function (start, ...)
        local args = {...}
        local max = #args
        local finish = args[max] - 1
        local table = {
            type   = 'table',
            start  = start,
            finish = finish
        }
        start = start + 1
        local wantField = true
        for i = 1, max-1 do
            local arg = args[i]
            local isField = type(arg) == 'table'
            local isEmmy = isField and arg.type:sub(1, 4) == 'emmy'
            if wantField and not isField then
                pushError {
                    type = 'MISS_EXP',
                    start = start,
                    finish = arg - 1,
                }
            elseif not wantField and isField and not isEmmy then
                pushError {
                    type = 'MISS_SEP_IN_TABLE',
                    start = start,
                    finish = arg.start-1,
                }
            end
            if isField then
                table[#table+1] = arg
                if not isEmmy then
                    wantField = false
                    start = arg.finish + 1
                end
            else
                wantField = true
                start = arg
            end
        end
        return table
    end,
    NewField = function (key, value)
        return {
            type = 'pair',
            start = key.start,
            finish = value.finish,
            key, value,
        }
    end,
    NewIndex = function (key, value)
        return {
            type = 'pair',
            start = key.start,
            finish = value.finish,
            key, value,
        }
    end,
    List = function (first, second, ...)
        if second then
            local list = {
                type = 'list',
                start = first.start,
                first, second, ...
            }
            local last = list[#list]
            list.finish = last.finish
            return list
        elseif type(first) == 'table' then
            return first
        else
            return nil
        end
    end,
    ArgList = function (...)
        if ... == '' then
            return nil
        end
        local args = table.pack(...)
        local list = {}
        local max = args.n
        args.n = nil
        local wantName = true
        local paramTypes = nil
        for i = 1, max do
            local obj = args[i]
            if type(obj) == 'number' then
                if wantName then
                    pushError {
                        type = 'MISS_NAME',
                        start = obj,
                        finish = obj,
                    }
                end
                wantName = true
            elseif obj.type == "paramType" then
                paramTypes = paramTypes or {}
                paramTypes[#paramTypes+1] = buildEmmy(obj, args[i - 1])
                args[i] = nil
            else
                if not wantName then
                    pushError {
                        type = 'MISS_SYMBOL',
                        start = obj.start-1,
                        finish = obj.start-1,
                        info = {
                            symbol = ',',
                        }
                    }
                end
                wantName = false
                list[#list+1] = obj
                if obj.type == '...' then
                    if i < max then
                        local a = args[max - 1]
                        local b = args[max]
                        if type(b) ~= "number" and b.type == "paramType" then
                            break
                        end
                        pushError {
                            type = 'ARGS_AFTER_DOTS',
                            start = type(a) == 'number' and a or a.start,
                            finish = type(b) == 'number' and b or b.finish,
                        }
                    end
                    break
                end
            end
        end
        if wantName then
            local last = args[max]
            pushError {
                type = 'MISS_NAME',
                start = last+1,
                finish = last+1,
            }
        end
        if #list == 0 then
            return {nil, nil}
        elseif #list == 1 then
            return {list[1], paramTypes}
        else
            list.type = 'list'
            list.start = list[1].start
            list.finish = list[#list].finish
            return {list, paramTypes}
        end
    end,
    CallArgList = function (start, ...)
        local args = {...}
        local max = #args
        local finish = args[max] - 1
        local exps = {
            type = 'list',
            start = start,
            finish = finish,
        }
        local wantExp = true
        for i = 1, max-1 do
            local arg = args[i]
            local isExp = type(arg) == 'table'
            if wantExp and not isExp then
                pushError {
                    type = 'MISS_EXP',
                    start = start,
                    finish = arg - 1,
                }
            elseif not wantExp and isExp then
                pushError {
                    type = 'MISS_SYMBOL',
                    start = start,
                    finish = arg.start-1,
                    info = {
                        symbol = ',',
                    }
                }
            end
            if isExp then
                exps[#exps+1] = arg
                wantExp = false
                start = arg.finish + 1
            else
                wantExp = true
                start = arg
            end
        end
        if wantExp then
            pushError {
                type = 'MISS_EXP',
                start = start,
                finish = finish,
            }
        end
        if #exps == 0 then
            return nil
        elseif #exps == 1 then
            return exps[1]
        else
            return exps
        end
    end,
    Nothing = function ()
        return nil
    end,
    None = function()
        return
    end,
    Skip = function ()
        return false
    end,
    CompSet = function (keys, opstart, op, opfinish, values)
        if State.Version == "Luau" then
            pcall(function()
                values = {
                    [1] = keys,
                    [2] = values,
                    type = 'binary',
                    start = values.start,
                    finish = values.finish,
                    test = true,
                    op = op:sub(1, #op - 1)
                }
            end)
        else
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = opstart,
                finish = opfinish - 1,
                version = 'Luau',
                info = {
                    version = State.Version,
                }
            }
        end
        return {
            type = 'set',
            keys, values,
        }
    end,
    Set = function (keys, values)
        return {
            type = 'set',
            keys, values,
        }
    end,
    LocalTag = function (...)
        if not ... or ... == '' then
            return nil
        end
        local tags = {...}
        for i, tag in ipairs(tags) do
            if State.Version ~= 'Lua 5.4' then
                pushError {
                    type = 'UNSUPPORT_SYMBOL',
                    start = tag.start,
                    finish = tag.finish,
                    version = 'Lua 5.4',
                    info = {
                        version = State.Version,
                    }
                }
            elseif tag[1] ~= 'const' and tag[1] ~= 'close' then
                pushError {
                    type = 'UNKNOWN_TAG',
                    start = tag.start,
                    finish = tag.finish,
                    info = {
                        tag = tag[1],
                    }
                }
            elseif i > 1 then
                pushError {
                    type = 'MULTI_TAG',
                    start = tag.start,
                    finish = tag.finish,
                    info = {
                        tag = tag[1],
                    }
                }
            end
        end
        return tags
    end,
    LocalName = function (name, tags)
        name.tags = tags
        return name
    end,
    Local = function (keys, values)
        local ret = {}
        for i, v in ipairs(keys) do
            if v.type == "varType" then
                ret[#ret+1] = buildEmmy(v, keys[i - 1])
                table.remove(keys, i)
            end
        end
        ret[#ret+1] = {
            type = 'local',
            keys, values
        }
        return table.unpack(ret)
    end,
    NameType = function (start, str, finish, generics)
        return {
            type   = 'nameType',
            start  = start,
            finish = finish - 1,
            generics = generics,
            [1]    = str,
        }
    end,
    ModuleType = function (start, str, _, nameType, finish, generics)
        return {
            type   = 'moduleType',
            start  = start,
            finish = finish - 1,
            generics = generics,
            [1]    = str,
            [2]    = nameType
        }
    end,
    FuncType = function (start, args, returns, finish)
        local obj = {
            type = "funcType",
            start = start,
            finish = finish,
            args = args,
            returns = returns
        }
        return obj
    end,
    TableType = function (start, fields, finish)
        local obj = {
            type = "tableType",
            start = start,
            fields = fields,
            finish = finish
        }
        return obj
    end,
    FieldType1 = function (start, key, _, value, finish)
        return {
            type = "fieldType1",
            start = start,
            finish = finish,
            key = key,
            value = value
        }
    end,
    FieldType2 = function (start, key, _, _, value, finish)
        return {
            type = "fieldType2",
            start = start,
            finish = finish,
            key = key,
            value = value
        }
    end,
    FieldType3 = function (start, value, finish)
        return {
            type = "fieldType3",
            start = start,
            finish = finish,
            key = nil,
            value = value
        }
    end,
    VariadicType = function (start, dots, type, finish)
        return {
            type = "variadicType",
            start = start,
            finish = finish,
            dots = dots,
            value = type
        }
    end,
    FieldTypeList = function (...)
        local list = {...}
        local hasIndexer = false
        local wantField = true
        for i, field in pairs(list) do
            if type(field) == "number" then
                if wantField then
                    pushError {
                        type = 'MISS_FIELD',
                        start = field - 1,
                        finish = field - 1,
                    }
                end
                wantField = true
                list[i] = nil
            else
                if not wantField then
                    pushError {
                        type = 'MISS_SYMBOL',
                        start = field.start,
                        finish = field.start,
                        info = {
                            symbol = ',',
                        }
                    }
                end
                wantField = false
                if field.type == "fieldType2" then
                    if hasIndexer then
                        pushError {
                            type = 'MULTIPLE_TABLE_INDEXER',
                            start = field.start,
                            finish = field.finish,
                        }
                    else
                        hasIndexer = true
                    end
                elseif field.type == "fieldType3" and #list > 1 then
                    pushError {
                        type = 'EXPECTED_FIELD_COLON',
                        start = field.finish,
                        finish = field.finish,
                    }
                end
            end
        end
        return list
    end,
    TypeList = function(...)
        local types = {...}
        local obj = {
            type = "typeList",
            start = table.pick(types, 1),
            finish = table.pick(types, #types),
            types = types
        }
        local wantType = true
        for i, v in pairs(types) do
            if type(v) == "number" then
                if wantType then
                    pushError {
                        type = 'MISS_TYPE',
                        start = v - 1,
                        finish = v - 1,
                    }
                end
                wantType = true
                types[i] = nil
            else
                if not wantType then
                    pushError {
                        type = 'MISS_SYMBOL',
                        start = v.start,
                        finish = v.start,
                        info = {
                            symbol = ',',
                        }
                    }
                end
                if v.type == "variadicType" then
                    if i < #types then
                        local a = types[#types - 1]
                        local b = types[#types]
                        pushError {
                            type = 'ARGS_AFTER_DOTS',
                            start = type(a) == 'number' and a or a.start,
                            finish = type(b) == 'number' and b or b.finish,
                        }
                    end
                end
                wantType = false
            end
        end
        return obj
    end,
    VarType = function(colon, ...)
        if State.Version ~= "Luau" then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = colon.start,
                finish = colon.finish,
                version = 'Luau',
                info = {
                    version = State.Version,
                }
            }
        end
        return {
            type = "varType",
            info = ...
        }
    end,
    ParamType = function(colon, ...)
        if State.Version ~= "Luau" then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = colon.start,
                finish = colon.finish,
                version = 'Luau',
                info = {
                    version = State.Version,
                }
            }
        end
        return {
            type = "paramType",
            start = colon.start,
            info = ...
        }
    end,
    ReturnType = function(colon, ...)
        if State.Version ~= "Luau" then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = colon.start,
                finish = colon.finish,
                version = 'Luau',
                info = {
                    version = State.Version,
                }
            }
        end
        return {
            type = "returnType",
            info = ...
        }
    end,
    Generics = function(start, ...)
        local info = {...}
        local finish = info[#info]
        table.remove(info, #info)
        local obj = {
            type = "typeGenerics",
            start = start,
            finish = finish,
            info = info
        }
        local wantType = true
        for i, v in ipairs(info) do
            if type(v) == "number" then
                if wantType then
                    pushError {
                        type = 'MISS_TYPE',
                        start = v - 1,
                        finish = v - 1,
                    }
                end
                wantType = true
                info[i] = nil
            else
                if not wantType then
                    pushError {
                        type = 'MISS_SYMBOL',
                        start = start + 1,
                        finish = v.start - 1,
                        info = {
                            symbol = ',',
                        }
                    }
                end
                wantType = false
                if v.type == "name" then
                    v.type = "nameType"
                end
            end
        end
        return obj
    end,
    Typeof = function(start, exp, finish)
        local obj = {
            type = "typeof",
            start = start,
            finish = finish,
            [1] = {
                type = "name",
                start = start,
                finish = start + #"typeof",
                [1] = "typeof"
            },
            [2] = {
                type = "call",
                start = start + #"typeof",
                finish = finish,
                [1] = exp
            }
        }
        return obj
    end,
    TypeDef = function (start, name, ...)
        local info = {...}
        local finish = info[#info]
        table.remove(info, #info)
        if State.Version ~= "Luau" then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = start,
                finish = finish,
                version = 'Luau',
                info = {
                    version = State.Version,
                }
            }
        end
        local obj = {
            type = "typeDef",
            start = start,
            name = name,
            finish = finish,
            info = info
        }
        return obj
    end,
    TypeAssert = function (exp)
        -- if State.Version ~= "Luau" then
        --     pushError {
        --         type = 'UNSUPPORT_SYMBOL',
        --         start = start,
        --         finish = finish,
        --         version = 'Luau',
        --         info = {
        --             version = State.Version,
        --         }
        --     }
        -- end
        -- exp.assert = tp
        -- return exp
        return exp
    end,
    DoBody = function (...)
        if ... == '' then
            return {
                type = 'do',
            }
        else
            return {
                type = 'do',
                ...
            }
        end
    end,
    Do = function (start, action, finish)
        action.start  = start
        action.finish = finish - 1
        checkMissEnd(start, action)
        return action
    end,
    Break = function (finish, ...)
        if State.Break > 0 then
            local breakChunk = {
                type = 'break',
            }
            if not ... then
                return breakChunk
            end
            local action = select(-1, ...)
            if not action then
                return breakChunk
            end
            if State.Version == 'Lua 5.1' or State.Version == 'LuaJIT' or State.Version == "Luau" then
                pushError {
                    type = 'ACTION_AFTER_BREAK',
                    start = finish - #'break',
                    finish = finish - 1,
                }
            end
            return breakChunk, action
        else
            pushError {
                type = 'BREAK_OUTSIDE',
                start = finish - #'break',
                finish = finish - 1,
            }
            if not ... then
                return false
            end
            local action = select(-1, ...)
            if not action then
                return false
            end
            return action
        end
    end,
    BreakStart = function ()
        State.Break = State.Break + 1
    end,
    BreakEnd = function ()
        State.Break = State.Break - 1
    end,
    Continue = function (finish, ...)
        if State.Version == "Luau" then
            if State.Break > 0 then
                local breakChunk = {
                    type = 'break',
                }
                if not ... then
                    return breakChunk
                end
                local action = select(-1, ...)
                if not action then
                    return breakChunk
                end
                pushError {
                    type = 'ACTION_AFTER_CONTINUE',
                    start = finish - #'continue',
                    finish = finish - 1,
                }
                return breakChunk, action
            else
                pushError {
                    type = 'CONTINUE_OUTSIDE',
                    start = finish - #'continue',
                    finish = finish - 1,
                }
                if not ... then
                    return false
                end
                local action = select(-1, ...)
                if not action then
                    return false
                end
                return action
            end
        end
    end,
    ContinueStart = function ()
        if State.Version == "Luau" then
            State.Break = State.Break + 1
        end
    end,
    ContinueEnd = function ()
        if State.Version == "Luau" then
            State.Break = State.Break - 1
        end
    end,
    Return = function (start, exp, finish)
        if not finish then
            finish = exp
            exp = {
                type = 'return',
                start = start,
                finish = finish - 1,
            }
        else
            if exp.type == 'list' then
                exp.type = 'return'
                exp.start = start
                exp.finish = finish - 1
            else
                exp = {
                    type = 'return',
                    start = start,
                    finish = finish - 1,
                    [1] = exp,
                }
            end
        end
        return exp
    end,
    Label = function (start, name, finish)
        if State.Version == 'Lua 5.1' or State.Version == "Luau" then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = start,
                finish = finish - 1,
                version = {'Lua 5.2', 'Lua 5.3', 'Lua 5.4', 'LuaJIT'},
                info = {
                    version = State.Version,
                }
            }
            return false
        end
        name.type = 'label'
        local labels = State.Label[#State.Label]
        local str = name[1]
        if labels[str] then
            --pushError {
            --    type = 'REDEFINE_LABEL',
            --    start = name.start,
            --    finish = name.finish,
            --    info = {
            --        label = str,
            --        related = {labels[str].start, labels[str].finish},
            --    }
            --}
        else
            labels[str] = name
        end
        return name
    end,
    GoTo = function (start, name, finish)
        if State.Version == 'Lua 5.1' or State.Version == "Luau" then
            pushError {
                type = 'UNSUPPORT_SYMBOL',
                start = start,
                finish = finish - 1,
                version = {'Lua 5.2', 'Lua 5.3', 'Lua 5.4', 'LuaJIT'},
                info = {
                    version = State.Version,
                }
            }
            return false
        end
        name.type = 'goto'
        local labels = State.Label[#State.Label]
        labels[#labels+1] = name
        return name
    end,
    -- TODO 这里的检查不完整，但是完整的检查比较复杂，开销比较高
    -- 不能jump到另一个局部变量的作用域
    -- 函数会切断goto与label
    -- 不能从block外jump到block内，但是可以从block内jump到block外
    BlockStart = function ()
        State.Label[#State.Label+1] = {}
        State.Dots[#State.Dots+1] = false
    end,
    BlockEnd = function ()
        local labels = State.Label[#State.Label]
        State.Label[#State.Label] = nil
        State.Dots[#State.Dots] = nil
        for i = 1, #labels do
            local name = labels[i]
            local str = name[1]
            if not labels[str] then
                pushError {
                    type = 'NO_VISIBLE_LABEL',
                    start = name.start,
                    finish = name.finish,
                    info = {
                        label = str,
                    }
                }
            end
        end
    end,
    IfBlock = function (exp, start, ...)
        local obj = {
            filter = exp,
            start  = start,
            ...
        }
        local max = #obj
        obj.finish = obj[max]
        obj[max]   = nil
        return obj
    end,
    ElseIfBlock = function (exp, start, ...)
        local obj = {
            filter = exp,
            start  = start,
            ...
        }
        local max = #obj
        obj.finish = obj[max]
        obj[max]   = nil
        return obj
    end,
    ElseBlock = function (start, ...)
        local obj = {
            start  = start,
            ...
        }
        local max = #obj
        obj.finish = obj[max]
        obj[max]   = nil
        return obj
    end,
    If = function (start, ...)
        local obj = {
            type  = 'if',
            start = start,
            ...
        }
        local max = #obj
        obj.finish = obj[max] - 1
        obj[max]   = nil
        checkMissEnd(start, obj)
        return obj
    end,
    Loop = function (start, arg, min, max, step, ...)
        local obj = {
            type  = 'loop',
            start = start,
            arg   = arg,
            min   = min,
            max   = max,
            step  = step,
            ...
        }
        local max = #obj
        obj.finish = obj[max] - 1
        obj[max]   = nil
        checkMissEnd(start, obj)
        return obj
    end,
    In = function (start, arg, exp, ...)
        local obj = {
            type  = 'in',
            start = start,
            arg   = arg,
            exp   = exp,
            ...
        }
        local max = #obj
        obj.finish = obj[max] - 1
        obj[max]   = nil
        checkMissEnd(start, obj)
        local ret = {}
        for i, tp in ipairs(arg) do
            if tp.type == "paramType" then
                ret[#ret+1] = buildEmmy(tp, arg[i - 1])
                table.remove(arg, i)
            end
        end
        ret[#ret + 1] = obj
        return table.unpack(ret)
    end,
    While = function (start, filter, ...)
        local obj = {
            type   = 'while',
            start  = start,
            filter = filter,
            ...
        }
        local max = #obj
        obj.finish = obj[max] - 1
        obj[max]   = nil
        checkMissEnd(start, obj)
        return obj
    end,
    Repeat = function (start, ...)
        local obj = {
            type  = 'repeat',
            start = start,
            ...
        }
        local max = #obj
        obj.finish = obj[max] - 1
        obj.filter = obj[max-1]
        obj[max]   = nil
        obj[max-1] = nil
        return obj
    end,
    Lua = function (...)
        if ... == '' then
            return {}
        end
        return {...}
    end,

    -- EmmyLua 支持
    EmmyName = function (start, str)
        return {
            type   = 'emmyName',
            start  = start,
            finish = start + #str - 1,
            [1]    = str,
        }
    end,
    DirtyEmmyName = function (pos)
        pushError {
            type = 'MISS_NAME',
            level = 'warning',
            start = pos,
            finish = pos,
        }
        return {
            type   = 'emmyName',
            start  = pos-1,
            finish = pos-1,
            [1]    = ''
        }
    end,
    EmmyClass = function (class, startPos, extends)
        if extends and extends[1] == '' then
            extends.start = startPos
        end
        return {
            type = 'emmyClass',
            start = class.start,
            finish = (extends or class).finish,
            [1] = class,
            [2] = extends,
        }
    end,
    EmmyType = function (typeDef)
        return typeDef
    end,
    EmmyCommonType = function (...)
        local result = {
            type = 'emmyType',
            ...
        }
        for i = 1, #result // 2 do
            local startPos = result[i * 2]
            local emmyName = result[i * 2 + 1]
            if emmyName[1] == '' then
                emmyName.start = startPos
            end
            result[i + 1] = emmyName
        end
        for i = #result // 2 + 2, #result do
            result[i] = nil
        end
        result.start = result[1].start
        result.finish = result[#result].finish
        return result
    end,
    EmmyArrayType = function (start, emmy, _, finish)
        emmy.type = 'emmyArrayType'
        emmy.start = start
        emmy.finish = finish - 1
        return emmy
    end,
    EmmyTableType = function (start, keyType, valueType, finish)
        return {
            type = 'emmyTableType',
            start = start,
            finish = finish - 1,
            [1] = keyType,
            [2] = valueType,
        }
    end,
    EmmyFunctionType = function (start, args, returns, finish)
        local result = {
            start = start,
            finish = finish - 1,
            type = 'emmyFunctionType',
            args = args,
            returns = returns,
        }
        return result
    end,
    EmmyFunctionRtns = function (...)
        return {...}
    end,
    EmmyFunctionArgs = function (...)
        local args = {...}
        args[#args] = nil
        return args
    end,
    EmmyAlias = function (name, emmyName, ...)
        return {
            type = 'emmyAlias',
            start = name.start,
            finish = emmyName.finish,
            name,
            emmyName,
            ...
        }
    end,
    EmmyParam = function (argName, emmyName, option, ...)
        local emmy = {
            type = 'emmyParam',
            option = option,
            argName,
            emmyName,
            ...
        }
        emmy.start = emmy[1].start
        emmy.finish = emmy[#emmy].finish
        return emmy
    end,
    EmmyReturn = function (start, type, name, finish, option)
        local emmy = {
            type = 'emmyReturn',
            option = option,
            start = start,
            finish = finish - 1,
            [1] = type,
            [2] = name,
        }
        return emmy
    end,
    EmmyField = function (access, fieldName, ...)
        local obj = {
            type = 'emmyField',
            access, fieldName,
            ...
        }
        obj.start = obj[2].start
        obj.finish = obj[3].finish
        return obj
    end,
    EmmyGenericBlock = function (genericName, parentName)
        return {
            start = genericName.start,
            finish = parentName and parentName.finish or genericName.finish,
            genericName,
            parentName,
        }
    end,
    EmmyGeneric = function (...)
        local emmy = {
            type = 'emmyGeneric',
            ...
        }
        emmy.start = emmy[1].start
        emmy.finish = emmy[#emmy].finish
        return emmy
    end,
    EmmyVararg = function (typeName)
        return {
            type = 'emmyVararg',
            start = typeName.start,
            finish = typeName.finish,
            typeName,
        }
    end,
    EmmyLanguage = function (language)
        return {
            type = 'emmyLanguage',
            start = language.start,
            finish = language.finish,
            language,
        }
    end,
    EmmySee = function (start, className, methodName, finish)
        return {
            type = 'emmySee',
            start = start,
            finish = finish - 1,
            className, methodName
        }
    end,
    EmmyOverLoad = function (EmmyFunctionType)
        EmmyFunctionType.type = 'emmyOverLoad'
        return EmmyFunctionType
    end,
    EmmyModule = function (start, str, finish)
        return {
            [1] = str,
            type = "emmyModule",
            start = start,
            finish = finish
        }
    end,
    EmmyIncomplete = function (emmyName)
        emmyName.type = 'emmyIncomplete'
        return emmyName
    end,
    EmmyComment = function (...)
        local lines = {...}
        for i = 2, #lines do
            local line = lines[i]
            if line:sub(1, 1) == '|' then
                lines[i] = '\n' .. line:sub(2)
            end
        end
        return {
            type = 'emmyComment',
            [1] = table.concat(lines, '\n'),
        }
    end,
    EmmyOption = function (options)
        if not options or options == '' then
            return nil
        end
        local option = {}
        for _, pair in ipairs(options) do
            if pair.type == 'pair' then
                local key = pair[1]
                local value = pair[2]
                if key.type == 'name' then
                    option[key[1]] = value[1]
                end
            end
        end
        return option
    end,
    EmmyTypeEnum = function (default, enum, comment)
        enum.type = 'emmyEnum'
        if default ~= '' then
            enum.default = true
        end
        enum.comment = comment
        return enum
    end,

    -- 捕获错误
    UnknownSymbol = function (start, symbol)
        pushError {
            type = 'UNKNOWN_SYMBOL',
            start = start,
            finish = start + #symbol - 1,
            info = {
                symbol = symbol,
            }
        }
        return
    end,
    UnknownAction = function (start, symbol)
        pushError {
            type = 'UNKNOWN_SYMBOL',
            start = start,
            finish = start + #symbol - 1,
            info = {
                symbol = symbol,
            }
        }
        return false
    end,
    DirtyName = function (pos)
        pushError {
            type = 'MISS_NAME',
            start = pos,
            finish = pos,
        }
        return {
            type   = 'name',
            start  = pos-1,
            finish = pos-1,
            [1]    = ''
        }
    end,
    DirtyExp = function (pos)
        pushError {
            type = 'MISS_EXP',
            start = pos,
            finish = pos,
        }
        return {
            type   = 'name',
            start  = pos,
            finish = pos,
            [1]    = ''
        }
    end,
    MissExp = function (pos)
        pushError {
            type = 'MISS_EXP',
            start = pos,
            finish = pos,
        }
    end,
    MissExponent = function (start, finish)
        pushError {
            type = 'MISS_EXPONENT',
            start = start,
            finish = finish - 1,
        }
    end,
    MissQuote1 = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = '"'
            }
        }
    end,
    MissQuote2 = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = "'"
            }
        }
    end,
    MissEscX = function (pos)
        pushError {
            type = 'MISS_ESC_X',
            start = pos-2,
            finish = pos+1,
        }
    end,
    MissTL = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = '{',
            }
        }
    end,
    MissTR = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = '}',
            }
        }
        return pos + 1
    end,
    MissBR = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = ']',
            }
        }
        return pos + 1
    end,
    MissPL = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = '(',
            }
        }
    end,
    DirtyPR = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = ')',
            }
        }
        return pos + 1
    end,
    MissPR = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = ')',
            }
        }
    end,
    ErrEsc = function (pos)
        pushError {
            type = 'ERR_ESC',
            start = pos-1,
            finish = pos,
        }
    end,
    MustX16 = function (pos, str)
        pushError {
            type = 'MUST_X16',
            start = pos,
            finish = pos + #str - 1,
        }
    end,
    MustX2 = function (pos, str)
        pushError {
            type = 'MUST_X2',
            start = pos,
            finish = pos + #str - 1,
        }
    end,
    MissAssign = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = '=',
            }
        }
    end,
    MissTableSep = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = ','
            }
        }
    end,
    MissField = function (pos)
        pushError {
            type = 'MISS_FIELD',
            start = pos,
            finish = pos,
        }
    end,
    MissMethod = function (pos)
        pushError {
            type = 'MISS_METHOD',
            start = pos,
            finish = pos,
        }
    end,
    MissLabel = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = '::',
            }
        }
    end,
    MissEnd = function (pos)
        State.MissEndErr = pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = 'end',
            }
        }
    end,
    MissDo = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = 'do',
            }
        }
    end,
    MissComma = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = ',',
            }
        }
    end,
    MissIn = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = 'in',
            }
        }
    end,
    MissUntil = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = 'until',
            }
        }
    end,
    MissThen = function (pos)
        pushError {
            type = 'MISS_SYMBOL',
            start = pos,
            finish = pos,
            info = {
                symbol = 'then',
            }
        }
    end,
    ExpInAction = function (start, exp, finish)
        pushError {
            type = 'EXP_IN_ACTION',
            start = start,
            finish = finish - 1,
        }
        return exp
    end,
    AfterReturn = function (rtn, ...)
        if not ... then
            return rtn
        end
        local action = select(-1, ...)
        if not action then
            return rtn
        end
        pushError {
            type = 'ACTION_AFTER_RETURN',
            start = rtn.start,
            finish = rtn.finish,
        }
        return rtn, action
    end,
    MissIf = function (start, block)
        pushError {
            type = 'MISS_SYMBOL',
            start = start,
            finish = start,
            info = {
                symbol = 'if',
            }
        }
        return block
    end,
    MissGT = function (start)
        pushError {
            type = 'MISS_SYMBOL',
            start = start,
            finish = start,
            info = {
                symbol = '>'
            }
        }
    end,
    ErrAssign = function (start, finish)
        pushError {
            type = 'ERR_ASSIGN_AS_EQ',
            start = start,
            finish = finish - 1,
            fix = {
                title = 'FIX_ASSIGN_AS_EQ',
                {
                    start   = start,
                    finish  = finish - 1,
                    text    = '=',
                }
            }
        }
    end,
    ErrEQ = function (start, finish)
        pushError {
            type   = 'ERR_EQ_AS_ASSIGN',
            start  = start,
            finish = finish - 1,
            fix = {
                title = 'FIX_EQ_AS_ASSIGN',
                {
                    start  = start,
                    finish = finish - 1,
                    text   = '==',
                }
            }
        }
        return '=='
    end,
    ErrUEQ = function (start, finish)
        pushError {
            type   = 'ERR_UEQ',
            start  = start,
            finish = finish - 1,
            fix = {
                title = 'FIX_UEQ',
                {
                    start  = start,
                    finish = finish - 1,
                    text   = '~=',
                }
            }
        }
        return '=='
    end,
    ErrThen = function (start, finish)
        pushError {
            type = 'ERR_THEN_AS_DO',
            start = start,
            finish = finish - 1,
            fix = {
                title = 'FIX_THEN_AS_DO',
                {
                    start   = start,
                    finish  = finish - 1,
                    text    = 'then',
                }
            }
        }
    end,
    ErrDo = function (start, finish)
        pushError {
            type = 'ERR_DO_AS_THEN',
            start = start,
            finish = finish - 1,
            fix = {
                title = 'FIX_DO_AS_THEN',
                {
                    start   = start,
                    finish  = finish - 1,
                    text    = 'do',
                }
            }
        }
    end,
}

local function init(state, errs)
    State = state
    Errs = errs
end

return {
    defs = Defs,
    init = init,
}
