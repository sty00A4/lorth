# Lorth
A stack based programming language written in lua

---
## Syntax

| type                 | examples or description                 |
|----------------------|-----------------------------------------|
| number               | `1`, `2`, `3`, ...                      |
| char                 | `'a`, `'b`, ...                         |
| string               | `"..."`                                 |
| name                 | `var`, `age`, ...                       |
| keyword              | `if`, `repeat`, `local`, `set`, `macro` |
| operation            | `+`, `-`, `dup`, ...                    |
| sub                  | `( ... )`                               |

## Interpreter
If you just write a `number`, `char` or `string` in your program, it'll be put on the stack.
If you write a `name` in your program, the value of that name will be put on the stack if registered in **variables** or **locals**

| operation | action display              | description                                                   |
|-----------|-----------------------------|---------------------------------------------------------------|
| `+`       | `a b -> a+b`                | adds `a` with `b`                                             |
| `-`       | `a b -> a-b`                | subtracts `b` from `a`                                        |
| `*`       | `a b -> a*b`                | multiply `a` with                                             |
| `/`       | `a b -> a/b`                | divides `b` from `a`                                          |
| `**`      | `a b -> a**b`               | raises `a` to the power of `b`                                |
| `=`       | `a b -> 0/1`                | compares `a` and `b` for equality                             |
| `!`       | `0 -> 1` & `1 -> 0`         | negates `a`                                                   |
| `!=`      | `a b -> 0/1`                | compares `a` and `b` for none equality                        |
| `<`       | `a b -> 0/1`                | compares for `a` is less than `b`                             |
| `>`       | `a b -> 0/1`                | compares for `a` is greater than `b`                          |
| `<=`      | `a b -> 0/1`                | compares for `a` is less than or equal to `b`                 |
| `>=`      | `a b -> 0/1`                | compares for `a` is greater than or equal to `b`              |
| `#`       | `a -> a stack[a]`           | gets value of index `a`                                       |
| `drop`    | `a b -> a`                  | removes the top value from stack                              |
| `dup`     | `a b -> a b b`              | copies the top value to the top of the stack                  |
| `swap`    | `a b c -> a c b`            | swaps top two values of the stack                             |
| `over`    | `a b c -> a b c b`          | puts a copy of the second top of the stack value to the top   |
| `pick`    | `a b c -> a b c a`          | puts a copy of the bottom value of the stack to the top       |
| `rot`     | `a b c d -> a c d b`        | moves the third top value of the stack to the top             |
| `roll`    | `a b c d -> b c d a`        | moves the bottom value of the stack to the top                |
| `shift`   | `a b c -> b c`              | pops the last value of the stack                              |
| `sort`    | `a b c -> ` value dependent | sorts the stack values from low to high                       |
| `sum`     | `a b c -> a+b+c`            | sums up the stack values                                      |
| `prod`    | `a b c -> a*b*c`            | multiplies all the stack values                               |
| `range`   | `a b -> ` value dependent   | puts every value from `a` to `b` on the stack                 |
| `print`   | `a b c -> a b`              | prints the top stack value to the console and pops it         |
| `write`   | `a b c -> a b`              | writes the top stack value to the console and pops it         |
| `input`   | `a -> a (number input)`     | takes user input and puts it at the top (`0` if input is NaN) |
| `rev`     | `a b c d -> d c b a`        | reverses the stack values                                     |
| `max`     | `a b -> max(a,b)`           | pops the lower value and keeps the higher value of a and b    |
| `min`     | `a b -> min(a,b)`           | pops the higher value and keeps the lower value of a and b    |
| `flr`     | `a -> floor(a)`             | pops `a` and puts rounded down `a` on the stack               |
| `ceil`    | `a -> ceil(a)`              | pops `a` and puts rounded up `a` on the stack                 |
| `len`     | `a -> a (stack length)`     | puts the stack size as a number on the stack                  |
| `con`     | `a b -> a..b`               | concatenates a with b and puts the string on the stack        |
| `number`  | `a -> tonumber(a)`          | casts the top stack value to a number                         |
| `string`  | `a -> tostring(a)`          | casts the top stack value to a string                         |
| `char`    | `a -> tochar(a)`            | casts the top stack value to a character                      |
| `clock`   | `a -> a (os.clock())`       | puts the clock time as a number on the stack                  |

| keyword  | description                                                                                                     |
|----------|-----------------------------------------------------------------------------------------------------------------|
| `if`     | executes following token if the top stack value isn't `0` and pops the top stack value                          |
| `repeat` | executes following token top stack value's times and pops the top stack value                                   |
| `set`    | sets the following name if registered in **variables** to the top stack value and pops the value of the stack   |
| `local`  | sets the following name if registered in **locals** to the top stack value and pops the value of the stack      |
| `macro`  | registers 1st following name with the second following token in the **macros**                                  |

