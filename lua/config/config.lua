AddCSLuaFile()

WMS = WMS or {}
WMS.config = {}
WMS.config.human = {}
WMS.config.enums = {}

-- This part is the ones you should be modifying to please your taste
WMS.DEBUG = true
WMS.config.NO_DMG = true
WMS.config.bleedingSpeed = 5
WMS.config.bleedingImportance = 1 --hp

WMS.config.partialDeathTime = 3
WMS.config.corpsDeleteTime = 50

WMS.config.defaultWalkSpeed = 400   -- 400
WMS.config.defaultRunSpeed = 600    -- 600
WMS.config.fractureWalkSpeed = 200  -- 400
WMS.config.fractureRunSpeed = 400   -- 600

WMS.config.amountOfDamageToKillCorps = 10


-- ############################################################################
-- ############################################################################
-- ############################################################################


-- /!\ This part is NOT to be changed /!\ 

-- if you know what you are doing then good luck, I T   I S   M E S S Y
WMS.config.DMG_BLEEDING = 4294967296

WMS.config.enums.damageTypes = {
    ["BLEED"]     = 1,
    ["PROP"]      = 2,
    ["FALL"]      = 3,
    ["EXPLOSION"] = 4,
    ["VEHICLE"]   = 5,
    ["NO_DAMAGE"] = 6,
    ["NORMAL"]    = 7
}
WMS.config.enums.weaponTypes = {
    ["VEHICLE"]      = 0,
    ["CUT"]          = 1,
    ["PISTOL"]       = 2,
    ["RIFLE"]        = 3,
    ["UNRECOGNIZED"] = 4,
}
WMS.config.enums.damageArea = {
    ["UNRECOGNIZED"] = 0,
    ["SKULL"]   = 1,
    ["NECK"]    = 2,
    ["FACE"]    = 3,

    ["TORSO"]   = 4,
    ["HEART"]   = 5,
    ["LUNGS"]   = 6,

    ["STOMACH"] = 7,
    ["LIVER"]   = 8,

    ["ARM"]     = 9,
    ["HAND"]    = 10,

    ["LEG"]     = 11,
    ["FOOT"]    = 12,
}

WMS.config.human.weaponTypes = {
    [WMS.config.enums.weaponTypes.VEHICLE]      = "vehicle",
    [WMS.config.enums.weaponTypes.CUT]          = "cut",
    [WMS.config.enums.weaponTypes.PISTOL]       = "pistol",
    [WMS.config.enums.weaponTypes.RIFLE]        = "rifle",
    [WMS.config.enums.weaponTypes.UNRECOGNIZED] = "UNRECOGNIZED",
}

WMS.config.human.damageTypes = {
    [WMS.config.enums.damageTypes.BLEED]     = "Saignement",
    [WMS.config.enums.damageTypes.PROP]      = "Objet",
    [WMS.config.enums.damageTypes.FALL]      = "Chute",
    [WMS.config.enums.damageTypes.EXPLOSION] = "Explosion",
    [WMS.config.enums.damageTypes.VEHICLE]   = "Véhicule",
    [WMS.config.enums.damageTypes.NO_DAMAGE] = "NON",
    [WMS.config.enums.damageTypes.NORMAL]    = "Arme à feu"
}

WMS.config.human.damageArea = {
    [WMS.config.enums.damageArea.SKULL]   = "Crâne",
    [WMS.config.enums.damageArea.NECK]    = "Cou",
    [WMS.config.enums.damageArea.FACE]    = "Visage",

    [WMS.config.enums.damageArea.TORSO]   = "Torse",
    [WMS.config.enums.damageArea.HEART]   = "Coeur",
    [WMS.config.enums.damageArea.LUNGS]   = "Poumons",

    [WMS.config.enums.damageArea.STOMACH] = "Estomac",
    [WMS.config.enums.damageArea.LIVER]   = "Foie",

    [WMS.config.enums.damageArea.ARM]     = "Bras",
    [WMS.config.enums.damageArea.HAND]    = "Mains",

    [WMS.config.enums.damageArea.LEG]     = "Jambe",
    [WMS.config.enums.damageArea.FOOT]    = "Pied",
}


WMS.config.damageAreaToImage = {
    [HITGROUP_HEAD]     = "head",

    [HITGROUP_CHEST]    = "torso",
    [HITGROUP_STOMACH]  = "torso",

    [HITGROUP_LEFTARM]  = "arm_left",
    [HITGROUP_RIGHTARM] = "arm_right",

    [HITGROUP_RIGHTLEG] = "leg_right",
    [HITGROUP_LEFTLEG]  = "leg_left",
}
-----------------------------------------------------------------------------


-- This part is meant for tweaking specific things and is generally made for devs, but it won't 
-- break if you touch


WMS.config.DEBUG = true

WMS.config.chances = {
    [WMS.config.enums.damageArea.SKULL] = {
        ["chance"] = 40,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 99, partial = 99, hemorrhage = 0, dmgRange = {90, 99}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 98, partial = 97, hemorrhage = 0, dmgRange = {90, 99}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 89, partial = 85, hemorrhage = 90, dmgRange = {90, 96}},
    },
    [WMS.config.enums.damageArea.NECK] = {
        ["chance"] = 25,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 85, partial = 80, hemorrhage = 66, dmgRange = {80, 85}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 75, partial = 70, hemorrhage = 66, dmgRange = {70, 75}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 70, partial = 40, hemorrhage = 90, dmgRange = {70, 90}},
    },
    [WMS.config.enums.damageArea.FACE] = {
        ["chance"] = 35,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 78, partial = 80, hemorrhage = 20, dmgRange = {40, 75}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 75, partial = 70, hemorrhage = 20, dmgRange = {30, 55}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 30, partial = 20, hemorrhage = 30, dmgRange = {40, 64}},
    },

    [WMS.config.enums.damageArea.TORSO] = {
        ["chance"] = 70,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 25, partial = 40, hemorrhage = 37, dmgRange = {61, 80}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 15, partial = 20, hemorrhage = 35, dmgRange = {54, 78}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 10, partial = 5, hemorrhage = 30, dmgRange = {55, 70}},
    },
    [WMS.config.enums.damageArea.HEART] = {
        ["chance"] = 10,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 99, partial = 99, hemorrhage = 99, dmgRange = {99, 99}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 98, partial = 98, hemorrhage = 98, dmgRange = {99, 99}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 99, partial = 99, hemorrhage = 99, dmgRange = {99, 99}},
    },
    [WMS.config.enums.damageArea.LUNGS] = {
        ["chance"] = 20,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 80, partial = 70, hemorrhage = 90, dmgRange = {90, 96}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 70, partial = 60, hemorrhage = 90, dmgRange = {91, 95}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 50, partial = 30, hemorrhage = 99, dmgRange = {95, 99}},
    },

    [WMS.config.enums.damageArea.STOMACH] = {
        ["chance"] = 60,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 20, partial = 40, hemorrhage = 50, dmgRange = {54, 73}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 15, partial = 32, hemorrhage = 35, dmgRange = {45, 69}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 35, partial = 30, hemorrhage = 80, dmgRange = {50, 64}},
    },
    [WMS.config.enums.damageArea.LIVER] = {
        ["chance"] = 40,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 30, partial = 45, hemorrhage = 60, dmgRange = {60, 78}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 20, partial = 39, hemorrhage = 42, dmgRange = {55, 70}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 20, partial = 30, hemorrhage = 80, dmgRange = {56, 80}},
    },

    [WMS.config.enums.damageArea.ARM] = {
        ["chance"] = 90,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 20, partial = 25, hemorrhage = 10, dmgRange = {24, 39}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 15, partial = 20, hemorrhage = 9, dmgRange = {21, 35}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 5, partial = 7, hemorrhage = 15, dmgRange = {20, 30}},
    },
    [WMS.config.enums.damageArea.HAND] = {
        ["chance"] = 10,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 5, partial = 7, hemorrhage = 4, dmgRange = {10, 25}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 3, partial = 5, hemorrhage = 2, dmgRange = {7, 23}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 3, partial = 4, hemorrhage = 5, dmgRange = {4, 20}},
    },

    [WMS.config.enums.damageArea.LEG] = {
        ["chance"] = 92,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 15, partial = 20, hemorrhage = 35, dmgRange = {38, 63}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 13, partial = 15, hemorrhage = 30, dmgRange = {35, 59}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 10, partial = 14, hemorrhage = 40, dmgRange = {30, 55}},
    },
    [WMS.config.enums.damageArea.FOOT] = {
        ["chance"] = 8,

        [WMS.config.enums.weaponTypes.RIFLE]  = {total = 5, partial = 7, hemorrhage = 4, dmgRange = {10, 25}},
        [WMS.config.enums.weaponTypes.PISTOL] = {total = 3, partial = 5, hemorrhage = 2, dmgRange = {7, 23}},
        [WMS.config.enums.weaponTypes.CUT]    = {total = 3, partial = 4, hemorrhage = 5, dmgRange = {4, 20}},
    },

    ["cut"] = { -- % of hit because melee damage does not register as area (it is its own hit group)
        [WMS.config.enums.damageArea.SKULL]    = 5,
        [WMS.config.enums.damageArea.NECK]     = 2,
        [WMS.config.enums.damageArea.FACE]     = 3,

        [WMS.config.enums.damageArea.TORSO]    = 28,
        [WMS.config.enums.damageArea.HEART]    = 4,
        [WMS.config.enums.damageArea.LUNGS]    = 8,

        [WMS.config.enums.damageArea.STOMACH]  = 6,
        [WMS.config.enums.damageArea.LIVER]    = 4,

        [WMS.config.enums.damageArea.ARM]      = 8,
        [WMS.config.enums.damageArea.HAND]     = 2,

        [WMS.config.enums.damageArea.LEG]      = 28,
        [WMS.config.enums.damageArea.FOOT]     = 2,
    }
}

