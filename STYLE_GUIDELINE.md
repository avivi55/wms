This file is a guide to my weird coding style in laux

This style guide is heavily inspired by [CFC's one](https://github.com/CFC-Servers/cfc_glua_style_guidelines/blob/main/README.md) and python's [PEP 8](https://peps.python.org/pep-0008/)

### Indentation

I use 4 whitespaces as indentation.

---

# Spacing

## Add spacing around operators

✅
```lua
a < 2
b = 5 * 2 * c
```

❌
```lua
a<2
b=5*2*c
```

## Normal parenthesis use

Contrary to most Glua styles I don't like spaces in parenthesis.

✅
```lua
if (a == 5) then end
f = {a, b, 5}
```

❌
```lua
if ( a == 5 ) then end
f = { a, b, 5 }
```

## Single space after comment operators and before if not at start of line

✅
```lua
-- Nice space
a = random() -- This is nice and readable
```

❌
```lua
--This not nicely readable
a = random()-- This comment starts too close to the code
```

# New lines

## Never have more than 2 newlines
✅
```lua
function1()

function2()


otherFunction1()
```

❌
```lua
function1()



function2()




otherFunction1()
```

## Always have minimum 1 new line between blocks

✅
```lua
function function1()
-- ...
end

function function2()
-- ...
end


function function3()
-- ...
end
```

❌
```lua
function function1()
-- ...
end
function function2()
-- ...
end
```

## Add newline before and after `if`, `function` ... except if it is one line
You can do inline when simple `if` and `function` statements

✅
```lua
if (cond) then return end

function function1()
    return 5
end

function function2()

    doStuff()

    if (condition) then

       yes()
       no()

    end

    return result()

end
```

❌
```lua
function function2()
    doStuff()

    if (condition) then
       yes()
       no()
    end

    return result()
end
```
# GLua specifics

## GLua operators

Prefer the use of `&&` `||` `!=` `!`, I am just used to it.

## Comments

Use native lua comments

✅
```lua
--[[
  good
]]
function function1() -- good
-- ...
end
```

❌
```lua
/*
    bad
*/
function function1() // bad
-- ...
end
```

# Case

## Use camelCase almost everywhere
✅
```lua
beautifulVariable = 5
function magnificantFunction() end
```

❌
```lua
beautiful_variable = 5
function MagnificantFunction() end
```

## Use PascalCase for class names

✅
```lua
class List end
```

❌
```lua
class list end
class arrayList end
```

## Use SCREAMING_SNAKE_CASE for enum fields, globals ...

✅
```lua
PI = 3.141592

randomEnum = Enum({
    "YES",
    "NO"
})
```

❌
```lua
pi = 3.141592

randomEnum = Enum({
    "Yes",
    "no"
})
```

# Documenting

to document fields use `{type} description`

✅
```lua
-- A simple implementation of a 2 item tuple
public class Couple

    -- {any} The first element of the couple.
    _get first
    
    -- {any} The second element of the couple.
    _get second

    constructor(first, second)

        self.first = first
        self.second = second
        
    end
end


-- Generates a random area and gets the resulting life state and damage. 
--
-- @returns {table} the result table.
--      @field state {WMS.enums.lifeStates} The life state.
--      @field damage {number} The damage.
getResult(weaponType: EnumField)

    local area, chance = self:getRandomArea()

    return {
        state = chance:getDeath(weaponType),
        damage = chance:getDamage(weaponType)
    }

end
```

## Don't document unessessary function unless to explain logic.

```lua
    -- constructor
    --
    -- When creating an Enum we take in a table of strings. The string will be our identifiers.
    -- Then the ordinal of each elements will be the numberical key.
    --
    -- I use the fact that every object is a table under the hood to store an EnumField object
    -- in the value associated with the identifier.
    -- 
    -- @param {table} fields The table input.
    constructor(fields: table)

        for number, name of fields do
            if(type(number) != "number" && type(name) != "string")then 
                error("Enum class takes a list table of strings") 
            end

            self[name] = EnumField(name, number)
        end
        
    end
```

esspecially for **magic methods** (`__tostring`, `__eq`, ...)


