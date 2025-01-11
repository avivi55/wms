-- Copyright © 2025 Jacques Soghomonyan <jsoghomonyan164@gmail.com>
-- This work is free. 
-- It comes without any warranty, to the extent permitted by applicable law.
-- You can redistribute it and/or modify it under the terms of the 
-- Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the LICENSE file for more details.


return {
    groupName = "Couple",
    cases = {
        {
            name = "Test basic fonctionnality of my Couple class",
            func = function()
                local tuple = Couple(50, 100)

                expect(tuple:getFirst()).to.equal(50)
                expect(tuple:getSecond()).to.equal(100)
            end
        },
        {
            name = "Equals operator override",
            func = function()
                local tuple1 = Couple(50, 100)
                local tuple2 = Couple(50, 100)

                expect(tuple1).to.equal(tuple2)
            end
        },
        {
            name = "to string",
            func = function()
                local tuple1 = Couple(50, 100)

                expect(tostring(tuple1)).to.equal("(50, 100)")
            end
        },
    }
}
