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
                expect(enum.ONE:getOrdinal()).to.eq(1)
                expect(enum.TWO:getOrdinal()).to.eq(2)
                expect(enum.THREE:getOrdinal()).to.eq(3)

                expect(enum.ONE:getName()).to.eq("ONE")
                expect(enum.TWO:getName()).to.eq("TWO")
                expect(enum.THREE:getName()).to.eq("THREE")
            end
        },
        {
            name = "EnumField equality",
            func = function()
                expect(enum.ONE).to.eq(EnumField("ONE", 1))
                expect(enum.TWO).to.eq(EnumField("TWO", 2))
                expect(enum.THREE).to.eq(EnumField("THREE", 3))
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
                expect(enum).to.eq(enum2)
            end
        }
    }
}
