local lorth = require("lorth")
local stack, err = lorth.test() if err then print(err) return end
if stack then
    if #stack > 0 then print() end
    lorth.printStack(stack)
end