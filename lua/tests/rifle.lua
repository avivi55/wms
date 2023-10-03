WMS = WMS or {}

-- print(HITGROUP_HEAD)

if(true)then
    
    local attacker = player.CreateNextBot("Attacker2")

    local weapon = attacker:Give(table.Random(table.GetKeys(WMS.weapons.rifle)))
    attacker:SetActiveWeapon(weapon)

    local testDamage = DamageInfo()
    testDamage:SetAttacker(attacker)
    testDamage:SetDamage(50) -- don't really care
    testDamage:SetInflictor(weapon)

    local victim = player.CreateNextBot("Victim2")

 
    WMS.config.NO_DMG = true

    for hitgroup = 2, 8 do
        victim:SetLastHitGroup(hitgroup)
        victim:TakeDamageInfo(testDamage)
    end

    do
        local PrintTable = WMS.utils.__debugPrintDamageTable
        PrintTable(victim.damagesTable)
    end

    WMS.config.NO_DMG = false

    print(attacker)

    function test()
        for _, ply in pairs(player.GetBots())do
            ply:Kick()            
        end
    end

    timer.Simple(1, test)
end
