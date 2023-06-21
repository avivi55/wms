AddCSLuaFile()

WMS = WMS or {}


-- if you want to add specific weapons to this list follow the exemple


-- ["weapon_class"] = true,

-- this works  :   ["cw_kk_ins2_doi_stg44"] = true,


WMS.weapons = {
    rifle = {
    },

    pistol = {
    },

    cut = {
        ["tfa_ww2_ussr_flag"] = true,
        ["cw_kk_ins2_damage_melee"] = true,
    },

    fire = {
        ["codww2_molotov"] =  true,
    },

    noDamage = {
        ["prop_physics"] = true,
        ["gmod_balloon"] = true
    },

    oneArm = {
        ["cw_kk_ins2_doi_luger"] = true,
        ["cw_kk_ins2_doi_p38"] = true,
        ["cw_kk_ins2_doi_c96"] = true,

        ["cw_kk_ins2_doi_m1911"] = true,
        ["cw_kk_ins2_doi_browninghp"] = true,
        ["cw_kk_ins2_doi_m1917"] = true,

        ["cw_kk_ins2_doi_webley"] = true,
        ["cw_kk_ins2_doi_welrod"] = true,

        ["cw_kk_ins2_doi_east_tt33"] = true,
        ["cw_kk_ins2_doi_ppk"] = true,
    }
}


-- ############################################################################
-- ############################################################################
-- ############################################################################



-- /!\ This part is NOT to be changed /!\ 

-- if you know what you are doing then good luck, I T   I S   M E S S Y
for _, w in pairs(weapons.GetList()) do
    if (w.Category == "CW 2.0 KK INS2 DOI") then
        if (w.Base == "cw_kk_ins2_base_melee") then
            WMS.weapons.cut[w.ClassName] = true

        elseif (w.magType) then
            local m = w.magType

            if (m == "arMag" or m == "m1Clip" or m == "brMag") then
               WMS.weapons.rifle[w.ClassName] = true

            elseif (m == "smgMag" or m == "pistolMag") then
               WMS.weapons.pistol[w.ClassName] = true
            end

        else
            if (w.NormalHoldType == "pistol" or (w.ShotgunReload and w.Shots > 1)) then
                WMS.weapons.pistol[w.ClassName] = true

            elseif (w.NormalHoldType == "ar2") then
                WMS.weapons.rifle[w.ClassName] = true
            end
        end
    end
end

PrintTable(WMS.weapons)



-- save

-- rifle
    -- ["cw_kk_ins2_doi_stg44"] = true,
    -- ["cw_kk_ins2_doi_mg34"] = true,
    -- ["cw_kk_ins2_doi_mg42"] = true,
    -- ["cw_kk_ins2_doi_k98k"] = true,
    -- ["cw_kk_ins2_doi_fg42"] = true,
    -- ["cw_kk_ins2_doi_g43"] = true,

    -- ["cw_kk_ins2_doi_wicked"] = true,
    -- ["cw_kk_ins2_doi_enfield"] = true,
    -- ["cw_kk_ins2_doi_bren"] = true,
    -- ["cw_kk_ins2_doi_lewis"] = true,

    -- ["cw_kk_ins2_doi_garand"] = true,
    -- ["cw_kk_ins2_doi_spring"] = true,
    -- ["cw_kk_ins2_doi_bar"] = true,
    -- ["cw_kk_ins2_doi_browning"] = true,
    -- ["cw_kk_ins2_doi_m1a1"] = true,
    -- ["cw_kk_ins2_doi_m1"] = true,


    -- ["cw_kk_ins2_doi_east_svt40"] = true,
    -- ["cw_kk_ins2_doi_east_avs36"] = true,
    -- ["cw_kk_ins2_doi_east_avt40"] = true,
    -- ["cw_kk_ins2_doi_east_dp27"] = true,
    -- ["cw_kk_ins2_doi_east_m38"] = true,
    -- ["cw_kk_ins2_doi_east_mn9130"] = true,
    -- ["cw_kk_ins2_doi_east_mn9130_sniper"] = true,
    -- ["cw_kk_ins2_doi_east_mp43"] = true,
    -- ["cw_kk_ins2_doi_east_m44"] = true,

-- pistol
    -- ["cw_kk_ins2_doi_luger"] = true,
    -- ["cw_kk_ins2_doi_mp40"] = true,
    -- ["cw_kk_ins2_doi_p38"] = true,
    -- ["cw_kk_ins2_doi_c96"] = true,
    -- ["cw_kk_ins2_doi_c96_c"] = true,


    -- ["cw_kk_ins2_doi_thom_m1a1"] = true,
    -- ["cw_kk_ins2_doi_thom_1928"] = true,
    -- ["cw_kk_ins2_doi_east_thom_1921"] = true,
    -- ["cw_kk_ins2_doi_east_thom_m1a1"] = true,
    -- ["cw_kk_ins2_doi_m3a1"] = true,
    -- ["cw_kk_ins2_doi_m3"] = true,
    -- ["cw_kk_ins2_doi_m1911"] = true,
    -- ["cw_kk_ins2_doi_browninghp"] = true,
    -- ["cw_kk_ins2_doi_m1917"] = true,

    -- ["cw_kk_ins2_doi_sten_mk5"] = true,
    -- ["cw_kk_ins2_doi_sten_mk2"] = true,
    -- ["cw_kk_ins2_doi_owen_mk2"] = true,
    -- ["cw_kk_ins2_doi_owen_mk1"] = true,
    -- ["cw_kk_ins2_doi_webley"] = true,
    -- ["cw_kk_ins2_doi_welrod"] = true,


    -- ["cw_kk_ins2_doi_east_pps43"] = true,
    -- ["cw_kk_ins2_doi_east_ppsh41"] = true,
    -- ["cw_kk_ins2_doi_east_ppsh41_drum"] = true,
    -- ["cw_kk_ins2_doi_east_tt33"] = true,
    -- ["cw_kk_ins2_doi_ppk"] = true,

    -- ["cw_kk_ins2_doi_m1912"] = true,
    -- ["cw_kk_ins2_doi_ithaca"] = true

-- cut 
    -- ["cw_kk_ins2_doi_mel_shovel_de"] = true,
    -- ["cw_kk_ins2_doi_mel_k98k"] = true,

    -- ["tfa_ww2_ussr_flag"] = true,
    -- ["cw_kk_ins2_doi_east_mel_shovel_sov"] = true,
    -- ["cw_kk_ins2_doi_east_mel_svt40bayonet"] = true,

    -- ["cw_kk_ins2_doi_mel_kabar"] = true,
    -- ["cw_kk_ins2_doi_mel_kabar2"] = true,
    -- ["cw_kk_ins2_doi_mel_kabar3"] = true,
    -- ["cw_kk_ins2_doi_mel_kabar4"] = true,
    -- ["cw_kk_ins2_doi_mel_kabar5"] = true,
    -- ["cw_kk_ins2_doi_mel_shovel_gb"] = true,
    -- ["cw_kk_ins2_doi_mel_shovel_us"] = true,
    -- ["cw_kk_ins2_doi_mel_garand"] = true,
    -- ["cw_kk_ins2_doi_mel_enfield"] = true,
    -- ["cw_kk_ins2_doi_mel_brass"] = true,
    -- ["cw_kk_ins2_damage_melee"] = true,
