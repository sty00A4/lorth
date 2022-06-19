local function isnumber(s) return s:match("^%-?%d+$") == s end
string.letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" }
string.digits = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
table.contains = function(t, val) for _, v in pairs(t) do if val == v then return true end end return false end
table.containsKey = function(t, key) for k, _ in pairs(t) do if key == k then return true end end return false end
local push = table.insert
local pop = table.remove
local cont = table.contains
local contKey = table.containsKey

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
local function Token(type_, value)
    return setmetatable(
            { type = type_, value = value, copy = function(s) return Token(s.type, s.value) end },
            { __name = "token", __tostring = function(s) if s.value then return "["..s.type..":"..tostring(s.value).."]" else return "["..s.type.."]" end end }
    )
end

local opFuncs = {
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
    ["^"] = function(stack)
        local a = pop(stack)
        local b = pop(stack)
        push(stack, b ^ a)
        return stack
    end,
    ["rot"] = function(stack)
        local a = pop(stack)
        push(stack, 1, a)
        return stack
    end,
    ["flr"] = function(stack)
        local a = pop(stack)
        push(stack, math.floor(a))
        return stack
    end,
    ["ceil"] = function(stack)
        local a = pop(stack)
        push(stack, math.ceil(a))
        return stack
    end,
    ["pop"] = function(stack)
        pop(stack)
        return stack
    end,
}

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
        if char == " " or char == "\n" then advance()
        elseif cont(string.digits, char) then
            local numStr = char
            advance()
            while cont(string.digits, char) or char == "." do
                numStr = numStr .. char
                advance()
            end
            push(tokens, Token("number", tonumber(numStr)))
        elseif cont(string.letters, char) then
            local word = char
            advance()
            while cont(string.letters, char) or char == "_" do
                word = word .. char
                advance()
            end
            if contKey(opFuncs, word) then push(tokens, Token("op", word))
            else push(tokens, Token("name", word)) end
        elseif contKey(opFuncs, char) then
            local str = char
            advance()
            while contKey(opFuncs, char) or char == "_" do
                str = str .. char
                advance()
            end
            push(tokens, Token("op", str))
        else advance() end
    end
    return tokens
end

local function interpret(tokens)
    local stack = {}
    for i, token in ipairs(tokens) do
        if token.type == "number" then push(stack, token.value) end
        if token.type == "op" then stack = opFuncs[token.value](stack) end
    end
    return stack
end

local function test()
    local file = io.open("test.lo", "r")
    local text = file:read("*a")
    file:close()
    local stack, tokens, err = {}
    tokens, err = lex("test.lo", text) if err then print(err) return err end
    for _, t in ipairs(tokens) do io.write(tostring(t), " ") end print()
    stack, err = interpret(tokens) if err then print(err) return err end
    for _, v in pairs(stack) do io.write("[",tostring(v), "] ") end print()
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