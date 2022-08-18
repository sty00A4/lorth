local lorth = require("src.lorth")
local stack, vars, locals, macros
while true do
    while true do
        io.write("\t")
        local input = io.read()
        local tokens, err = lorth.lex("<shell>", input) if err then print(err) break end
        local stack_, vars_, locals_, macros_
        stack_, vars_, locals_, macros_, err = lorth.interpret(tokens, stack, vars, locals, macros) if err then print(err) break end
        stack, vars, locals, macros = stack_, vars_, locals_, macros_
        lorth.printStack(stack)
        print()
    end
end