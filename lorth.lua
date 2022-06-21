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
            { __name = "token", __tostring = function(s) if s.value then return "["..s.type..":"..tostring(s.value).."]" else return "["..s.type.."]" end end }
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
            }
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
        push(stack, b + a)
        return stack
    end,
    ["-"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        push(stack, b - a)
        return stack
    end,
    ["*"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        push(stack, b * a)
        return stack
    end,
    ["/"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        push(stack, b / a)
        return stack
    end,
    ["%"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        push(stack, b % a)
        return stack
    end,
    ["**"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        push(stack, b ^ a)
        return stack
    end,
    ["="] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if b == a then push(stack, 1) else push(stack, 0) end
        return stack
    end,
    ["<"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if b < a then push(stack, 1) else push(stack, 0) end
        return stack
    end,
    [">"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if b > a then push(stack, 1) else push(stack, 0) end
        return stack
    end,
    ["<="] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if b <= a then push(stack, 1) else push(stack, 0) end
        return stack
    end,
    [">="] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if b >= a then push(stack, 1) else push(stack, 0) end
        return stack
    end,
    ["#"] = function(stack, token)
        local a = pop(stack)
        if stack[a.value+1] then push(stack, stack[a.value+1]) else return nil, Error("index error", "index out of range", token.pos) end
        return stack
    end,
    ["rot"] = function(stack)
        local a = pop(stack)
        if not a then return stack end
        push(stack, 1, a)
        return stack
    end,
    ["dup"] = function(stack)
        local a = pop(stack)
        push(stack, a)
        push(stack, a:copy())
        return stack
    end,
    ["swap"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        push(stack, a:copy())
        push(stack, b:copy())
        return stack
    end,
    ["over"] = function(stack)
        if not stack[1] then return stack end
        local a = stack[1]:copy()
        push(stack, a)
        return stack
    end,
    ["max"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if a.value > b.value then push(stack, a) else push(stack, b) end
        return stack
    end,
    ["min"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        if a.value < b.value then push(stack, a) else push(stack, b) end
        return stack
    end,
    ["rev"] = function(stack)
        if #stack == 0 then return stack end
        for i = 1, #stack do
            local a = pop(stack)
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
        push(stack, Number(math.floor(a.value)))
        return stack
    end,
    ["ceil"] = function(stack)
        local a = pop(stack)
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
        while i <= #stack do
            if a ~= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterLT"] = function(stack)
        local a, i = pop(stack), 1
        while i <= #stack do
            if a <= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterGT"] = function(stack)
        local a, i = pop(stack), 1
        while i <= #stack do
            if a >= stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterLE"] = function(stack)
        local a, i = pop(stack), 1
        while i <= #stack do
            if a < stack[i] then pop(stack, i) else i=i+1 end
        end
        return stack
    end,
    ["filterGE"] = function(stack)
        local a, i = pop(stack), 1
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
        for i = b.value, a.value do
            push(stack, Number(i))
        end
        return stack
    end,
    ["int"] = function(stack)
        local a = pop(stack)
        push(stack, Number(math.floor(a.value)))
        return stack
    end,
    ["print"] = function(stack)
        local a = pop(stack)
        print(a)
        return stack
    end,
}
local symbols = { "+", "-", "*", "/", "**", "=", "<", ">", "<=", ">=", "#" }
local keywords = { ["if"] = "if", ["repeat"] = "repeat", ["end"] = "end", ["set"] = "set" }
local reqEnd = { keywords["if"], keywords["repeat"], }

local function lex(fn, text)
    local tokens, pos, char = {}, Position(0, 1, 0, fn, text)
    local function update() char = text:sub(pos.idx,pos.idx) end
    local function advance()
        pos.idx = pos.idx + 1
        pos.col = pos.col + 1
        update()
        if char == "\n" then pos.ln = pos.ln + 1 end
    end
    advance()
    while #char > 0 do
        if char == " " or char == "\t" or char == "\n" then advance()
        elseif cont(string.digits, char) then
            local start, stop = pos:copy(), pos:copy()
            local numStr = char
            advance()
            while (cont(string.digits, char) or char == ".") and #char > 0 do
                numStr = numStr .. char
                stop = pos:copy()
                advance()
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
        else advance() end
    end
    push(tokens, Token("eof", nil, PositionRange(pos:copy(), pos:copy())))
    return tokens
end

local function interpret(tokens)
    local stack, vars, i, token = {}, {}, 0
    local indent = 0
    local function advance() i=i+1 token=tokens[i] end
    advance()
    local function main(kw)
        local err
        if not kw then kw = "<none>" end
        --for __=1,indent do io.write(" ") end print(kw.." "..tostring(indent))
        indent=indent+1
        while true do
            --for __=1,indent do io.write(" ") end for _, v in pairs(stack) do io.write("[",tostring(v), "] ") end print("("..tostring(#stack)..")")
            if token.type == "keyword" then
                if token.value == "if" then
                    if stack[#stack] == 0 then
                        pop(stack)
                        local count = 1
                        while count > 0 and token do
                            advance()
                            if token.type == "keyword" and cont(reqEnd, token.value) then count=count+1 end
                            if token.value == "end" then count=count-1 end
                        end
                    end
                    advance()
                end
                if token.value == "repeat" then
                    advance()
                    if stack[#stack].value > 0 then
                        local amount = stack[#stack]
                        pop(stack)
                        local before = i
                        for _ = 1, amount.value-1 do
                            stack, err = main("repeat") if err then return nil, err end
                            i = before token=tokens[i]
                        end
                    else
                        pop(stack)
                        local count = 1
                        while count > 0 and token do
                            if token.type == "keyword" and cont(reqEnd, token.value) then count=count+1 end
                            if token.value == "end" then count=count-1 end
                            advance()
                        end
                    end
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
            if token.type == "number" then push(stack, Number(token.value)) advance() end
            if token.type == "name" then push(stack, Var(token.value)) advance() end
            if token.type == "nameRef" then if vars[token.value] then push(stack, vars[token.value]) advance() else
                return nil, Error("name error", "name "..token.value.." not registered", token.pos:copy()) end end
            if token.type == "op" then stack, err = opFuncs[token.value](stack, token) if err then return nil, err end advance() end
            if token.type == "eof" then break end
        end
        indent=indent-1
        --for __=1,indent do io.write(" ") end print("end")
        return stack
    end
    return main("main")
end

local function test()
    local file = io.open("test.lo", "r")
    local text = file:read("*a")
    file:close()
    local stack, tokens, err = {}
    tokens, err = lex("test.lo", text) if err then return nil, err end
    --for _, t in ipairs(tokens) do io.write(tostring(t), " ") end print()
    stack, err = interpret(tokens) if err then return nil, err end
    return stack
end

local function run(fn, text)
    local tokens, stack, err
    tokens, err = lex(fn, text) if err then print(err) return end
    stack, err = interpret(tokens) if err then print(err) return end
    return stack
end

local function runfile(fn)
    local file = io.open(fn, "r")
    local text = file:read("*a")
    file:close()
    return run(fn, text)
end

return { run = run, runfile = runfile, test = test }