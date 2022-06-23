local function isnumber(s) return s:match("^%-?%d+$") == s end
string.letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
string.digits = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
table.contains = function(t, val) for _, v in pairs(t) do if val == v then return true end end return false end
table.containsKey = function(t, key) for k, _ in pairs(t) do if key == k then return true end end return false end
table.containsStart = function(t, val) for _, v in pairs(t) do if val == v:sub(1,#val) then return true end end return false end
table.containsKeyStart = function(t, key) for k, _ in pairs(t) do if key == k:sub(1,#key) then return true end end return false end
table.sub = function(t, i, j)
    local newT = {}
    if not j then j = #t end
    for idx, v in ipairs(t) do
        if idx >= i and idx <= j then table.insert(newT, v) end
    end
    return newT
end
string.split = function(s, sep)
    local t = {}
    local temp = ""
    for i = 1, #s do
        if s:sub(i,i) == sep then if #temp>0 then table.insert(t, temp) temp="" end
        else temp = temp .. s:sub(i,i) end
    end
    if #temp>0 then table.insert(t, temp) temp="" end
    return t
end
string.join = function(s, t)
    local str = ""
    for i, v in ipairs(t) do
        if i == #t then str = str .. tostring(v) else str = str .. tostring(v) .. s end
    end
    return str
end
table.copy = function(t)
    if t.copy then if type(t.copy) == "function" then return t:copy() end end
    local newT = {}
    for k, v in pairs(t) do
        if type(v) == "table" then newT[k] = table.copy(v)
        else newT[k] = v end
    end
    return newT
end
table.extend = function(t1, t2)
    local newT = table.copy(t1)
    if t1[1] and t2[1] then
        for i, v in ipairs(t2) do table.insert(t1, v) end
    else
        for k, v in pairs(t2) do
            newT[k] = v
        end
    end
    return newT
end
local function insertionSort(array)
    local len = #array
    for j = 2, len do
        local key = array[j]
        local i = j - 1
        while i > 0 and array[i] > key do
            array[i + 1] = array[i]
            i = i - 1
        end
        array[i + 1] = key
    end
    return array
end
local function sleep(a)
    local sec = tonumber(os.clock() + a)
    while (os.clock() < sec) do end
end
local push = table.insert
local pop = table.remove
local cont = table.contains
local contKey = table.containsKey
local contStart = table.containsStart
local contKeyStart = table.containsKeyStart
local copy = table.copy
local extend = table.extend
local function printStack(stack) for _, v in ipairs(stack) do io.write("[", v:rawstr(), "] ") end print() end

---@param idx number
---@param ln number
---@param col number
---@param fn string
---@param text string
local function Position(idx, ln, col, fn, text)
    return setmetatable(
            {
                idx = idx, ln = ln, col = col, fn = fn, text = text,
                copy = function(s) return Position(s.idx, s.ln, s.col, s.fn, s.text) end
            },
            { __name = "position" }
    )
end
---@param start number
---@param stop number
local function PositionRange(start, stop)
    return setmetatable(
            {
                start = start, stop = stop, fn = start.fn, text = start.text,
                copy = function(s) return PositionRange(s.start:copy(), s.stop:copy()) end
            },
            { __name = "positionRange" }
    )
end
---@param type_ string
---@param pos table
local function Token(type_, value, pos)
    return setmetatable(
            { type = type_, value = value, pos = pos, copy = function(s) return Token(s.type, s.value) end },
            { __name = "token", __tostring = function(s)
                if s.value then
                    if type(s.value) == "table" then
                        local str = "{ "
                        for _, v in ipairs(s.value) do str = str .. tostring(v) .. ", " end
                        return "["..s.type..":"..str:sub(1,#str-2).."]"
                    else return "["..s.type..":"..tostring(s.value).."]" end
                else return "["..s.type.."]" end
            end }
    )
end
---@param type_ string
---@param details string
---@param pos table
local function Error(type_, details, pos)
    return setmetatable(
            { type = type_, details = details, pos = pos },
            { __name = "error", __tostring = function(s)
                return s.type..": "..s.details
                        .."\n\t"..("\n"):join(table.sub(s.pos.text:split("\n"), s.pos.start.ln, s.pos.stop.ln))
            end }
    )
end

local Number, String, Char, Macro
---@param number number
Number = function(number)
    if number == math.floor(number) then number = math.floor(number) end
    return setmetatable(
            { value = number, copy = function(s) return Number(s.value) end,
              tonumber = function(s) return s:copy() end,
              tostring = function(s) return String(tostring(s.value)) end,
              tochar = function(s) return Char(string.char(s.value)) end,
              rawstr = function(s) return tostring(s) end
            },
            {
                __name = "number", __tostring = function(s) return tostring(s.value) end,
                __eq = function(s, o) return s.value == o:tonumber().value end,
                __le = function(s, o) return s.value <= o:tonumber().value end,
                __lt = function(s, o) return s.value < o:tonumber().value end,
                __add = function(s, o) return Number(s.value + o:tonumber().value) end,
                __sub = function(s, o) return Number(s.value - o:tonumber().value) end,
                __mul = function(s, o) return Number(s.value * o:tonumber().value) end,
                __div = function(s, o) return Number(s.value / o:tonumber().value) end,
                __mod = function(s, o) return Number(s.value % o:tonumber().value) end,
                __pow = function(s, o) return Number(s.value ^ o:tonumber().value) end,
                __concat = function(s, o) return String(s:tostring().value .. o:tostring().value) end,
                __unm = function(s) return Number(-s.value) end,
                __bnot = function(s) if s.value == 0 then return Number(1) end return Number(0) end
            }
    )
end
---@param str string
String = function(str)
    return setmetatable(
            { value = str, copy = function(s) return String(s.value) end,
              tonumber = function(s)
                  local num = 0
                  for i = 1, #s.value do num = num + string.byte(s.value:sub(i,i)) end
                  return Number(num)
              end,
              tostring = function(s) return s:copy() end,
              tochar = function(s) return Char(s.value:sub(1,1)) end,
              rawstr = function(s) return '"'..tostring(s)..'"' end
            },
            {
                __name = "string", __tostring = function(s) return tostring(s.value) end,
                __eq = function(s, o) return s.value == o.value end,
                __le = function(s, o) return s:tonumber().value <= o:tonumber().value end,
                __lt = function(s, o) return s:tonumber().value < o:tonumber().value end,
                __add = function(s, o) return Number(s:tonumber().value + o:tonumber().value) end,
                __sub = function(s, o) return Number(s:tonumber().value - o:tonumber().value) end,
                __mul = function(s, o) return Number(s:tonumber().value * o:tonumber().value) end,
                __div = function(s, o) return Number(s:tonumber().value / o:tonumber().value) end,
                __mod = function(s, o) return Number(s:tonumber().value % o:tonumber().value) end,
                __pow = function(s, o) return Number(s:tonumber().value ^ o:tonumber().value) end,
                __concat = function(s, o) return String(s.value .. o:tostring().value) end,
                __unm = function(s) return Number(-s:tonumber().value) end,
                __bnot = function(s) if #s.value == 0 then return Number(1) end return Number(0) end
            }
    )
end
---@param char string
Char = function(char)
    return setmetatable(
            { value = char, copy = function(s) return Char(s.value) end,
              tonumber = function(s) return Number(string.byte(s.value)) end,
              tostring = function(s) return String(s.value) end,
              tochar = function(s) return s:copy() end,
              rawstr = function(s) return "'"..tostring(s) end
            },
            {
                __name = "char", __tostring = function(s) return tostring(s.value) end,
                __eq = function(s, o) return s.value == o.value end,
                __le = function(s, o) return s:tonumber().value <= o:tonumber().value end,
                __lt = function(s, o) return s:tonumber().value < o:tonumber().value end,
                __add = function(s, o) return Number(s:tonumber().value + o:tonumber().value) end,
                __sub = function(s, o) return Number(s:tonumber().value - o:tonumber().value) end,
                __mul = function(s, o) return Number(s:tonumber().value * o:tonumber().value) end,
                __div = function(s, o) return Number(s:tonumber().value / o:tonumber().value) end,
                __mod = function(s, o) return Number(s:tonumber().value % o:tonumber().value) end,
                __pow = function(s, o) return Number(s:tonumber().value ^ o:tonumber().value) end,
                __concat = function(s, o) return String(s.value .. o:tostring().value) end,
                __unm = function(s) return Number(-s:tonumber().value) end,
                __bnot = function() return Number(0) end
            }
    )
end
---@param proc table
Macro = function(proc)
    return setmetatable(
            { proc = proc, copy = function(s) return Macro(s.proc) end },
            { __name = "macro" }
    )
end

local opFuncs
opFuncs = {
    ["+"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b + a)
        return stack
    end,
    ["-"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b - a)
        return stack
    end,
    ["*"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b * a)
        return stack
    end,
    ["/"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b / a)
        return stack
    end,
    ["%"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b % a)
        return stack
    end,
    ["**"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b ^ a)
        return stack
    end,
    ["="] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b == a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["!"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        if a.value == 0 then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["!="] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if a ~= b then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["<"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b < a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    [">"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b > a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["<="] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b <= a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    [">="] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b >= a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["#"] = function(stack, token)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        if stack[a.value+1] then push(stack, stack[a.value+1]) else return nil, Error("index error", "index out of range", token.pos) end
        return stack
    end,
    ["or"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack) if not a then return stack end a = a:tonumber()
        local b = pop(stack) if not b then return stack end b = b:tonumber()
        if a.value ~= 0 or b.value ~= 0 then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["and"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack) if not a then return stack end a = a:tonumber()
        local b = pop(stack) if not b then return stack end b = b:tonumber()
        if a.value ~= 0 and b.value ~= 0 then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["rot"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack, #stack-2)
        if not a then return stack end
        push(stack, a)
        return stack
    end,
    ["dup"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        push(stack, a)
        push(stack, a:copy())
        return stack
    end,
    ["swap"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, a:copy())
        push(stack, b:copy())
        return stack
    end,
    ["over"] = function(stack)
        if #stack < 1 then return stack end
        local a = stack[#stack-1]:copy()
        if not a then return stack end
        push(stack, a)
        return stack
    end,
    ["pick"] = function(stack)
        if #stack < 1 then return stack end
        local a = stack[1]:copy()
        if not a then return stack end
        push(stack, a)
        return stack
    end,
    ["roll"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack, 1)
        push(stack, a)
        return stack
    end,
    ["max"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if a.value > b.value then push(stack, a) else push(stack, b) end
        return stack
    end,
    ["min"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if a.value < b.value then push(stack, a) else push(stack, b) end
        return stack
    end,
    ["rev"] = function(stack)
        if #stack == 0 then return stack end
        for i = 1, #stack do
            local a = pop(stack)
            if not a then return stack end
            push(stack, i, a)
        end
        return stack
    end,
    ["sort"] = function(stack)
        if #stack <= 1 then return stack end
        return insertionSort(stack)
    end,
    ["flr"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        push(stack, Number(math.floor(a.value)))
        return stack
    end,
    ["ceil"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        push(stack, Number(math.ceil(a.value)))
        return stack
    end,
    ["drop"] = function(stack)
        pop(stack)
        return stack
    end,
    ["shift"] = function(stack)
        pop(stack, 1)
        return stack
    end,
    ["filter"] = function(stack)
        if #stack < 1 then return stack end
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a ~= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterLT"] = function(stack)
        if #stack < 1 then return stack end
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a <= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterGT"] = function(stack)
        if #stack < 1 then return stack end
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a >= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterLE"] = function(stack)
        if #stack < 1 then return stack end
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a < stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterGE"] = function(stack)
        if #stack < 1 then return stack end
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a > stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["len"] = function(stack)
        push(stack, Number(#stack))
        return stack
    end,
    ["sum"] = function(stack)
        if #stack < 1 then return stack end
        for i = 1, #stack-1 do stack = opFuncs["+"](stack) end
        return stack
    end,
    ["prod"] = function(stack)
        for i = 1, #stack-1 do stack = opFuncs["*"](stack) end
        return stack
    end,
    ["range"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        for i = b.value, a.value do
            push(stack, Number(i))
        end
        return stack
    end,
    ["print"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        print(a)
        return stack
    end,
    ["input"] = function(stack)
        local number = tonumber(io.read("*n"))
        if not number then number = 0 end
        push(stack, Number(number))
        return stack
    end,
    ["write"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        io.write(tostring(a))
        return stack
    end,
    ["con"] = function(stack)
        if #stack < 2 then return stack end
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b .. a)
        return stack
    end,
    ["number"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        push(stack, a:tonumber())
        return stack
    end,
    ["string"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        push(stack, a:tostring())
        return stack
    end,
    ["char"] = function(stack)
        if #stack < 1 then return stack end
        local a = pop(stack)
        if not a then return stack end
        push(stack, a:tochar())
        return stack
    end,
    ["clock"] = function(stack)
        push(stack, Number(os.clock()))
        return stack
    end
}
local symbols = { "+", "-", "*", "/", "**", "=", "!", "!=", "<", ">", "<=", ">=", "#" }
local keywords = { ["if"] = "if", ["repeat"] = "repeat", ["set"] = "set", ["local"] = "local", ["macro"] = "macro",
                   ["each"] = "each", ["use"] = "use", ["exit"] = "exit", ["break"] = "break" }
local runfile, run

---@param fn string
---@param text string
local function lex(fn, text)
    local pos, char = Position(0, 1, 0, fn, text)
    local function update() char = text:sub(pos.idx,pos.idx) end
    local function advance()
        pos.idx = pos.idx + 1
        pos.col = pos.col + 1
        update()
        if char == "\n" then pos.ln = pos.ln + 1 end
    end
    advance()
    local function main(stopChar)
        local tokens = {}
        while #char > 0 do
            if char == " " or char == "\t" or char == "\n" then advance()
            elseif char == stopChar then break
            elseif char == ";" then while char ~= "\n" and #char > 0 do advance() end advance()
            elseif char == "'" then
                advance()
                push(tokens, Token("char", char, PositionRange(pos:copy(), pos:copy())))
                advance()
            elseif char == '"' then
                local start = pos:copy()
                advance()
                local str = ""
                while char ~= '"' and #char > 0 do
                    if char == "\\" then
                        advance()
                        if char == "n" then str = str .. "\n"
                        elseif char == "t" then str = str .. "\t"
                        elseif char == "r" then str = str .. "\r"
                        else str = str .. char end
                        advance()
                    else str = str .. char advance() end
                end
                advance()
                local stop = pos:copy()
                push(tokens, Token("string", str, PositionRange(start, stop)))
            elseif cont(string.digits, char) then
                local start, stop = pos:copy(), pos:copy()
                local numStr = char
                local numType = "d"
                advance()
                if char == "x" then
                    numType = char
                    numStr = numStr .. char
                    stop = pos:copy()
                    advance()
                end
                if numType == "d" then
                    while (cont(string.digits, char) or char == ".") and #char > 0 do
                        numStr = numStr .. char
                        stop = pos:copy()
                        advance()
                    end
                end
                if numType == "x" then
                    while (cont(string.digits, char) or cont(table.sub(string.letters, 1, 6), char) or char == ".") and #char > 0 do
                        numStr = numStr .. char
                        stop = pos:copy()
                        advance()
                    end
                end
                push(tokens, Token("number", tonumber(numStr), PositionRange(start, stop)))
            elseif cont(string.letters, char) or char == "_" then
                local start, stop = pos:copy(), pos:copy()
                local word = char
                advance()
                while (cont(string.letters, char) or cont(string.digits, char) or char == "_") and #char > 0 do
                    word = word .. char
                    advance()
                end
                if contKey(opFuncs, word) then push(tokens, Token("op", word, PositionRange(start, stop)))
                elseif cont(keywords, word) then push(tokens, Token("keyword", word, PositionRange(start, stop)))
                else push(tokens, Token("name", word, PositionRange(start, stop))) end
            elseif contStart(symbols, char) then
                local start, stop = pos:copy(), pos:copy()
                local symbol = char
                advance()
                while contStart(symbols, symbol .. char) and #char > 0 do
                    symbol = symbol .. char
                    advance()
                end
                push(tokens, Token("op", symbol, PositionRange(start, stop)))
            elseif char == "(" then
                local start, stop = pos:copy(), pos:copy()
                advance()
                local subTokens, err = main(")") if err then return nil, err end
                stop = pos:copy()
                advance()
                push(tokens, Token("sub", subTokens, PositionRange(start, stop)))
            else return nil, Error("syntax error", "unrecognized character '"..char.."'", PositionRange(pos:copy(), pos:copy())) end
        end
        return tokens
    end
    return main()
end

---@param stack table
---@param tokens table
---@param vars table
---@param macros table
---@param locals table
local function interpret(tokens, stack, vars, locals, macros)
    local meta = getmetatable(tokens)
    if meta then if meta.__name == "token" then if meta.type == "sub" then tokens = meta.value else tokens = { tokens } end end end
    if not stack then stack = {} end
    if not vars then vars = {} end
    if not macros then macros = {} end
    if not locals then locals = {} end
    local i, token = 0
    local function advance() i=i+1 token=tokens[i] if not token then token = Token("exit") end end
    advance()
    local indent = 0
    local err
    indent=indent+1
    while true do
        if token.type == "exit" then break
        elseif token.type == "op" then stack, err = opFuncs[token.value](stack, token) if err then return nil, vars, locals, macros, err end advance()
        elseif token.type == "keyword" then
            if token.value == keywords["if"] then
                advance()
                local condition = pop(stack)
                if condition ~= nil then if condition ~= Number(0) then
                    stack, vars, _, macros, err = interpret(token, copy(stack), extend(copy(vars), copy(locals)), nil, copy(macros)) if err then return nil, vars, locals, macros, err end
                end end
                advance()
            elseif token.value == keywords["repeat"] then
                advance()
                local amount = pop(stack)
                amount = amount:tonumber()
                amount.value = math.floor(amount.value)
                if amount then if amount.value > 0 then
                    local before = i
                    for _ = 1, amount.value do
                        stack, vars, __, macros, err = interpret(token, copy(stack), extend(copy(vars), copy(locals)), nil, copy(macros)) if err then return nil, vars, locals, macros, err end
                        i = before
                    end
                end end
                advance()
            elseif token.value == keywords["each"] then
                advance()
                if #stack > 0 then
                    local before = i
                    for _ = 1, #stack do
                        stack, vars, __, macros, err = interpret(token, copy(stack), extend(copy(vars), copy(locals)), nil, copy(macros)) if err then return nil, vars, locals, macros, err end
                        stack = opFuncs.roll(stack)
                        i = before
                    end
                end
                advance()
            elseif token.value == keywords["macro"] then
                advance()
                if token.type ~= "name" then return nil, vars, locals, macros, Error("syntax error", "expected name", token.pos:copy()) end
                local macroName = token.value
                advance()
                local proc = token:copy()
                advance()
                macros[macroName] = proc
            elseif token.value == keywords["local"] then
                advance()
                if token.type ~= "name" then return nil, vars, locals, macros, Error("syntax error", "expected name", token.pos:copy()) end
                if vars[token.value] then return nil, vars, locals, macros, Error("name error", "name already registered in vars", token.pos:copy()) end
                if locals[token.value] then return nil, vars, locals, macros, Error("name error", "name already registered in locals, did you mean 'set' instead of 'local'", token.pos:copy()) end
                locals[token.value] = pop(stack)
                advance()
            elseif token.value == keywords["set"] then
                advance()
                if token.type ~= "name" then return nil, vars, locals, macros, Error("syntax error", "expected name", token.pos:copy()) end
                if locals[token.value] then locals[token.value] = pop(stack)
                else vars[token.value] = pop(stack) end
                advance()
            elseif token.value == keywords["use"] then
                advance()
                if token.type ~= "string" then return nil, vars, locals, macros, Error("syntax error", "expected string", token.pos:copy()) end
                _, vars, locals, macros, err = runfile(token.value) if err then return nil, vars, locals, macros, err end
                advance()
            elseif token.value == keywords["exit"] then
                local code = pop(stack) if not code then code = Number(0) end
                os.exit(code:tonumber().value)
            elseif token.value == keywords["break"] then break
            else return nil, vars, locals, macros, Error("syntax error", "keyword "..token.value.." not expected", token.pos:copy()) end
        elseif token.type == "sub" then stack, vars, __, macros, err = interpret(token.value, copy(stack), extend(copy(vars), copy(locals)), nil, copy(macros)) if err then return nil, vars, locals, macros, err end advance()
        elseif token.type == "number" then push(stack, Number(token.value)) advance()
        elseif token.type == "char" then push(stack, Char(token.value)) advance()
        elseif token.type == "string" then push(stack, String(token.value)) advance()
        elseif token.type == "name" then
            if macros[token.value] then
                if type(macros[token.value].value) == "table" then stack, vars, __, macros, err = interpret(macros[token.value], copy(stack), extend(copy(vars), copy(locals)), nil, copy(macros)) if err then return nil, vars, locals, macros, err end
                else stack, vars, __, macros, err = interpret({ macros[token.value]:copy() }, copy(stack), extend(copy(vars), copy(locals)), nil, copy(macros)) if err then return nil, vars, locals, macros, err end end
            else
                if vars[token.value] then push(stack, vars[token.value]:copy())
                elseif locals[token.value] then push(stack, locals[token.value]:copy())
                else return nil, vars, locals, macros, Error("name error", "name not registered in the variables", token.pos:copy()) end
            end
            advance()
        else return nil, vars, locals, macros, Error("syntax error", "token type "..token.type.." can't be computed") end
    end
    indent=indent-1
    for _,v in pairs(locals) do vars[v] = nil end
    return stack, vars, locals, macros
end

local function test()
    local file = io.open("test.lo", "r")
    local text = file:read("*a")
    file:close()
    local stack, tokens, vars, locals, macros, err = {}
    tokens, err = lex("test.lo", text) if err then return nil, vars, locals, macros, err end
    stack, vars, locals, macros, err = interpret(tokens) if err then return nil, vars, locals, macros, err end
    return stack, vars, locals, macros
end

---@param fn string
---@param text string
run = function(fn, text)
    local tokens, stack, err, vars, locals, macros
    tokens, err = lex(fn, text) if err then print(err) return end
    stack, vars, locals, macros, err = interpret(tokens) if err then print(err) return end
    return stack, vars, locals, macros
end

---@param fn string
runfile = function(fn)
    local file = io.open(fn, "r")
    local text = file:read("*a")
    file:close()
    return run(fn, text)
end
if os.version then
    if os.version():sub(1,7) == "CraftOS" then
        local args = {...}
        if #args > 0 then
            local stack, vars, locals, macros, err = runfile(args[1]) if err then print(err) return end
            printStack(stack)
        end
    end
end

return { run = run, runfile = runfile, test = test, opFuncs = opFuncs, lex = lex, interpret = interpret, printStack = printStack }
