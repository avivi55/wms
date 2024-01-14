return {
    cases = {
        {
            name = "DeathChance",
            func = function()
                local chance = DeathChance(50, 50, 50, Couple(10, 20))

                expect(chance.range).to.exist()

                expect(chance.range).to.equal(Couple(10, 20))

                expect(chance:getDamage()).to.beGreaterThan(10)
            end
        },
        {
            name = "ArtificialDamageAreaChance",
            func = function()
                local chance = ArtificialDamageAreaChance(
                    40,
                    DeathChance(80, 40, 0, Couple(80, 90)),
                    DeathChance(40, 20, 0, Couple(40, 50)),
                    DeathChance(20, 10, 0, Couple(20, 30))
                )

                expect(chance:getDamage(WMS.enums.damageTypes.RIFLE)).to.beGreaterThan(80 - 1)
                expect(chance:getDamage(WMS.enums.damageTypes.RIFLE)).to.beLessThan(90 + 1)

                expect(chance:getDamage(WMS.enums.damageTypes.PISTOL)).to.beGreaterThan(40 - 1)
                expect(chance:getDamage(WMS.enums.damageTypes.PISTOL)).to.beLessThan(50 + 1)

                expect(chance:getDamage(WMS.enums.damageTypes.MELEE)).to.beGreaterThan(20 - 1)
                expect(chance:getDamage(WMS.enums.damageTypes.MELEE)).to.beLessThan(30 + 1)

                expect(chance:getPourcentageOfHappening()).to.equal(40)
            end
        },
        {
            name = "AreaChance error",
            func = function()
                expect(
                    function(table) AreaChance(table) end,
                    {
                        ArtificialDamageAreaChance(
                            40,
                            DeathChance(80, 40, 0, Couple(80, 90)),
                            DeathChance(40, 20, 0, Couple(40, 50)),
                            DeathChance(20, 10, 0, Couple(20, 30))
                        ),
                        ArtificialDamageAreaChance(
                            40,
                            DeathChance(80, 40, 0, Couple(80, 90)),
                            DeathChance(40, 20, 0, Couple(40, 50)),
                            DeathChance(20, 10, 0, Couple(20, 30))
                        ),
                        ArtificialDamageAreaChance(
                            40,
                            DeathChance(80, 40, 0, Couple(80, 90)),
                            DeathChance(40, 20, 0, Couple(40, 50)),
                            DeathChance(20, 10, 0, Couple(20, 30))
                        ),
                    }
                ).to.errWith("Total of chance must be 100, got 120")
            end
        },
        {
            name = "AreaChance",
            func = function()
                local chance = AreaChance({
                    ArtificialDamageAreaChance(
                        40,
                        DeathChance(80, 40, 0, Couple(80, 90)),
                        DeathChance(40, 20, 0, Couple(40, 50)),
                        DeathChance(20, 10, 0, Couple(20, 30))
                    ),
                    ArtificialDamageAreaChance(
                        25,
                        DeathChance(80, 40, 0, Couple(80, 90)),
                        DeathChance(40, 20, 0, Couple(40, 50)),
                        DeathChance(20, 10, 0, Couple(20, 30))
                    ),
                    ArtificialDamageAreaChance(
                        35,
                        DeathChance(80, 40, 0, Couple(80, 90)),
                        DeathChance(40, 20, 0, Couple(40, 50)),
                        DeathChance(20, 10, 0, Couple(20, 30))
                    ),
                })

                local a, c = chance:getRandomArea()

                expect(type(a)).to.eq("number")
                expect(c:__type()).to.eq("ArtificialDamageAreaChance")
            end
        },
    }
}
