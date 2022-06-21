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

local function Position(idx, ln, col, fn, text)
    return setmetatable(
            {
                idx = idx, ln = ln, col = col, fn = fn, text = text,
                copy = function(s) return Position(s.idx, s.ln, s.col, s.fn, s.text) end
            },
            { __name = "position" }
    )
end
local function PositionRange(start, stop)
    return setmetatable(
            {
                start = start, stop = stop, fn = start.fn, text = start.text,
                copy = function(s) return PositionRange(s.start:copy(), s.stop:copy()) end
            },
            { __name = "positionRange" }
    )
end
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
local function Error(type_, details, pos)
    return setmetatable(
            { type = type_, details = details, pos = pos },
            { __name = "error", __tostring = function(s)
                return s.type..": "..s.details
                        .."\n\t"..("\n"):join(table.sub(s.pos.text:split("\n"), s.pos.start.ln, s.pos.stop.ln))
            end }
    )
end

local function Number(number)
    if number == math.floor(number) then number = math.floor(number) end
    return setmetatable(
            { value = number, copy = function(s) return Number(s.value) end },
            {
                __name = "number", __tostring = function(s) return tostring(s.value) end,
                __eq = function(s, o) return s.value == o.value end,
                __le = function(s, o) return s.value <= o.value end,
                __lt = function(s, o) return s.value < o.value end,
                __add = function(s, o) return Number(s.value + o.value) end,
                __sub = function(s, o) return Number(s.value - o.value) end,
                __mul = function(s, o) return Number(s.value * o.value) end,
                __div = function(s, o) return Number(s.value / o.value) end,
                __mod = function(s, o) return Number(s.value % o.value) end,
                __pow = function(s, o) return Number(s.value ^ o.value) end,
                __idiv = function(s, o) return Number(s.value // o.value) end,
                __unm = function(s) return Number(-s.value) end,
                __bnot = function(s) if s.value == 0 then return Number(1) end return Number(0) end
            }
    )
end
local function Macro(proc)
    return setmetatable(
            { proc = proc, copy = function(s) return Macro(s.proc) end },
            { __name = "macro" }
    )
end
local function Var(name)
    return setmetatable(
            { name = name, copy = function(s) return Var(s.name) end },
            { __name = "var" }
    )
end

local opFuncs
opFuncs = {
    ["+"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b + a)
        return stack
    end,
    ["-"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b - a)
        return stack
    end,
    ["*"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b * a)
        return stack
    end,
    ["/"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b / a)
        return stack
    end,
    ["%"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b % a)
        return stack
    end,
    ["**"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, b ^ a)
        return stack
    end,
    ["="] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b == a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["!"] = function(stack)
        local a = pop(stack)
        if not a then return stack end
        push(stack, ~a)
        return stack
    end,
    ["!="] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if a ~= b then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["<"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b < a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    [">"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b > a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["<="] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b <= a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    [">="] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if b >= a then push(stack, Number(1)) else push(stack, Number(0)) end
        return stack
    end,
    ["#"] = function(stack, token)
        local a = pop(stack)
        if not a then return stack end
        if stack[a.value+1] then push(stack, stack[a.value+1]) else return nil, Error("index error", "index out of range", token.pos) end
        return stack
    end,
    ["rot"] = function(stack)
        local a = pop(stack, 1)
        if not a then return stack end
        push(stack, a)
        return stack
    end,
    ["dup"] = function(stack)
        local a = pop(stack)
        if not a then return stack end
        push(stack, a)
        push(stack, a:copy())
        return stack
    end,
    ["swap"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        push(stack, a:copy())
        push(stack, b:copy())
        return stack
    end,
    ["over"] = function(stack)
        if not stack[1] then return stack end
        local a = stack[1]:copy()
        if not a then return stack end
        push(stack, a)
        return stack
    end,
    ["max"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        if a.value > b.value then push(stack, a) else push(stack, b) end
        return stack
    end,
    ["min"] = function(stack)
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
        local a = pop(stack)
        if not a then return stack end
        push(stack, Number(math.floor(a.value)))
        return stack
    end,
    ["ceil"] = function(stack)
        local a = pop(stack)
        if not a then return stack end
        push(stack, Number(math.ceil(a.value)))
        return stack
    end,
    ["pop"] = function(stack)
        pop(stack)
        return stack
    end,
    ["shift"] = function(stack)
        pop(stack, 1)
        return stack
    end,
    ["filter"] = function(stack)
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a ~= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterLT"] = function(stack)
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a <= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterGT"] = function(stack)
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a >= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterLE"] = function(stack)
        local a, i = pop(stack), 1
        if not a then return stack end
        while i <= #stack do
            if a < stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterGE"] = function(stack)
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
        for i = 1, #stack-1 do stack = opFuncs["+"](stack) end
        return stack
    end,
    ["prod"] = function(stack)
        for i = 1, #stack-1 do stack = opFuncs["*"](stack) end
        return stack
    end,
    ["range"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if not a then return stack end
        if not b then return stack end
        for i = b.value, a.value do
            push(stack, Number(i))
        end
        return stack
    end,
    ["int"] = function(stack)
        local a = pop(stack)
        if not a then return stack end
        push(stack, Number(math.floor(a.value)))
        return stack
    end,
    ["print"] = function(stack)
        local a = pop(stack)
        print(a)
        return stack
    end,
    ["input"] = function(stack)
        local number = tonumber(io.read("*n"))
        if not number then number = 0 end
        push(stack, Number(number))
        return stack
    end,
}
local symbols = { "+", "-", "*", "/", "**", "=", "!", "!=", "<", ">", "<=", ">=", "#" }
local keywords = { ["if"] = "if", ["repeat"] = "repeat", ["end"] = "end", ["set"] = "set", ["macro"] = "macro" }

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
            elseif char == "@" then
                local start, stop = pos:copy(), pos:copy()
                advance()
                if not (cont(string.letters, char) or char == "_") then return nil, Error("syntax error", "expected character", PositionRange(pos:copy(), pos:copy())) end
                local word = char
                advance()
                while (cont(string.letters, char) or cont(string.digits, char) or char == "_") and #char > 0 do
                    word = word .. char
                    advance()
                end
                push(tokens, Token("nameRef", word, PositionRange(start, stop)))
            elseif char == "(" then
                local start, stop = pos:copy(), pos:copy()
                advance()
                local subTokens, err = main(")") if err then return nil, err end
                stop = pos:copy()
                advance()
                push(tokens, Token("sub", subTokens, PositionRange(start, stop)))
            else advance() end
        end
        return tokens
    end
    return main()
end

local function interpret(stack, tokens, vars, macros, name)
    if not name then name = "main" end
    if not stack then stack = {} end
    if not vars then vars = {} end
    if not macros then macros = {} end
    local i, token = 0
    local function advance() i=i+1 token=tokens[i] if not token then token = Token("exit") end end
    advance()
    local indent = 0
    local function main(kw)
        local err
        if not kw then kw = "<none>" end
        indent=indent+1
        while true do
            if token.type == "exit" then break end
            if token.type == "op" then stack, err = opFuncs[token.value](stack, token) if err then return nil, err end advance() end
            if token.type == "keyword" then
                if token.value == "if" then
                    advance()
                    local condition = stack[#stack]
                    if condition ~= nil then if condition ~= Number(0) then
                        if token.type == "sub" then stack, err = interpret(stack, token.value, vars, macros, "sub") if err then return nil, err end
                        else stack, err = interpret(stack, { token }, vars, macros, "sub") if err then return nil, err end end
                    end end
                    advance()
                end
                if token.value == "repeat" then
                    advance()
                    local amount = pop(stack)
                    if amount then if amount.value > 0 then
                        local before = i
                        for _ = 1, amount.value do
                            if token.type == "sub" then stack, err = interpret(stack, token.value, vars, macros, "sub") if err then return nil, err end
                            else stack, err = interpret(stack, { token }, vars, macros, "sub") if err then return nil, err end end
                            i = before
                        end
                    end end
                    advance()
                end
                if token.value == "macro" then
                    advance()
                    if token.type ~= "name" then return nil, Error("syntax error", "expected name", token.pos) end
                    local macroName = token.value
                    advance()
                    local proc = token:copy()
                    advance()
                    macros[macroName] = proc
                end
                if token.value == "set" then
                    local value = pop(stack)
                    if not value.value then return nil, Error("stack error", "expected value for top stack slot", token.pos:copy()) end
                    local var = pop(stack)
                    if not var.name then return nil, Error("stack error", "expected name as top stack slot", token.pos:copy()) end
                    vars[var.name] = value
                    advance()
                end
                if token.value == "end" then break end
            end
            if token.type == "sub" then stack = interpret(stack, token.value, vars, macros, "sub") advance() end
            if token.type == "number" then push(stack, Number(token.value)) advance() end
            if token.type == "name" then
                if macros[token.value] then
                    if type(macros[token.value].value) == "table" then interpret(stack, macros[token.value].value, vars, macros, token.value)
                    else interpret(stack, { macros[token.value]:copy() }, vars, macros, token.value) end
                else push(stack, Var(token.value)) end
                advance()
            end
            if token.type == "nameRef" then if vars[token.value] then push(stack, vars[token.value]) advance() else
                return nil, Error("name error", "name "..token.value.." not registered", token.pos:copy()) end end
        end
        indent=indent-1
        return stack
    end
    return main(name)
end

local function test()
    local file = io.open("test.lo", "r")
    local text = file:read("*a")
    file:close()
    local stack, tokens, err = {}
    tokens, err = lex("test.lo", text) if err then return nil, err end
    --for _, t in ipairs(tokens) do io.write(tostring(t), " ") end print()
    stack, err = interpret({}, tokens) if err then return nil, err end
    return stack
end

local function run(fn, text)
    local tokens, stack, err
    tokens, err = lex(fn, text) if err then print(err) return end
    stack, err = interpret({}, tokens) if err then print(err) return end
    return stack
end

local function runfile(fn)
    local file = io.open(fn, "r")
    local text = file:read("*a")
    file:close()
    return run(fn, text)
end

return { run = run, runfile = runfile, test = test }