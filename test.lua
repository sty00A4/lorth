local lorth = require("lorth")
local stack, err = lorth.test() if err then print(err) return end
if stack then
    if #stack > 0 then print() end
    for _, v in ipairs(stack) do io.write("[", v:rawstr(), "] ") end print()
end