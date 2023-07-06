if (SERVER) then

    -- for k,v in pairs(player.GetAll()) do
    --     print(v, v:Alive())
    --     v:SetUserGroup("superadmin")
    --     print(v:GetNWBool("rightArmFracture"))
    --     print(v:GetNWBool("leftArmFracture"))
    --     v:SetActiveWeapon(v:Give("weapon_crowbar"))
    -- end

    print("-----------------------")

    for _, wepTable in pairs(weapons.GetList()) do
        --PrintTable(wepTable)
        -- for k, v in pairs(wepTable)do
        --     print(k)
        -- end

        --wepTable.BipodInstalled
        if (wepTable.ClassName == "cw_kk_ins2_doi_mel_shovel_de") then
            for k, v in pairs(wepTable) do
                print("\t", k, v)
            end

            break
        end
        -- if (wepTable.Category == "CW 2.0 KK INS2 DOI") then
        --     if (wepTable.magType) then
        --         --print(wepTable.ClassName, wepTable.magType, wepTable.BipodInstalled)
        --     else
        --         print(wepTable.ClassName, "\t", wepTable.WeaponLength, wepTable.NormalHoldType, wepTable.Chamberable, wepTable.BipodInstalled)
        --         -- for k, v in pairs(wepTable)do
        --         --     print("\t", k, v)
        --         -- end
        --     end
        -- end

        -- if (wepTable.ShotgunReload) then
        --     print(wepTable.ClassName)
        -- end
    end

end