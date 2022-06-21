local lorth = require("lorth")
local stack, err = lorth.test() if err then print(err) return end
print("\n---- TEST OUTPUT ----")
for _, v in ipairs(stack) do io.write("[", tostring(v), "] ") end print()