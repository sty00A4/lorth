local lorth = require("lorth")
local stack, err = lorth.test() if err then print(err) return end
for _, v in pairs(stack) do io.write("[",tostring(v), "] ") end print()