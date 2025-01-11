-- Copyright © 2025 Jacques Soghomonyan <jsoghomonyan164@gmail.com>
-- This work is free. 
-- It comes without any warranty, to the extent permitted by applicable law.
-- You can redistribute it and/or modify it under the terms of the 
-- Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the LICENSE file for more details.


local enum = Enum({
    "ONE",
    "TWO",
    "THREE"
})
return {
    groupName = "Enums",
    cases = {
        {
            name = "Enum creation",
            func = function()
                expect(enum.ONE:getOrdinal()).to.equal(1)
                expect(enum.TWO:getOrdinal()).to.equal(2)
                expect(enum.THREE:getOrdinal()).to.equal(3)

                expect(enum.ONE:getName()).to.equal("ONE")
                expect(enum.TWO:getName()).to.equal("TWO")
                expect(enum.THREE:getName()).to.equal("THREE")
            end
        },
        {
            name = "EnumField equality",
            func = function()
                expect(enum.ONE).to.equal(EnumField("ONE", 1))
                expect(enum.TWO).to.equal(EnumField("TWO", 2))
                expect(enum.THREE).to.equal(EnumField("THREE", 3))
            end
        },
        {
            name = "Enum equality",
            func = function()
                local enum2 = Enum({
                    "ONE",
                    "TWO",
                    "THREE"
                })
                expect(enum).to.equal(enum2)
            end
        }
    }
}
