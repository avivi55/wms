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
