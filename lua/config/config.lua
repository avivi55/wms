AddCSLuaFile()

WMS = WMS or {}
WMS.config = {}

WMS.config.DEBUG = true

WMS.config.DMG_BLEEDING = 4294967296

WMS.config.hemoSpeed = 5
WMS.config.hemoImportance = 1 --hp

WMS.config.PartialDeathTime = 3
WMS.config.CorpsDeleteTime = 50

WMS.config.defaultWalkSpeed = 400   -- 400
WMS.config.defaultRunSpeed = 600    -- 600
WMS.config.fractureWalkSpeed = 200  -- 400
WMS.config.fractureRunSpeed = 400   -- 600

WMS.config.enums = {}
WMS.config.enums.dmgTypes = {
    ["BLEED"]     = 1,
    ["PROP"]      = 2,
    ["FALL"]      = 3,
    ["EXPLOSION"] = 4,
    ["VEHICLE"]   = 5,
    ["NO_DAMAGE"] = 6,
    ["NORMAL"]    = 7
}
WMS.config.enums.wepTypes = {
    ["CUT"]    = 1,
    ["PISTOL"] = 2,
    ["RIFLE"]  = 3,
}
WMS.config.enums.dmgArea = {
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


WMS.config.human = {}
WMS.config.human.dmgTypes = {
    [WMS.config.enums.dmgTypes.BLEED]     = "Saignement",
    [WMS.config.enums.dmgTypes.PROP]      = "Objet",
    [WMS.config.enums.dmgTypes.FALL]      = "Chute",
    [WMS.config.enums.dmgTypes.EXPLOSION] = "Explosion",
    [WMS.config.enums.dmgTypes.VEHICLE]   = "Véhicule",
    [WMS.config.enums.dmgTypes.NO_DAMAGE] = "NON",
    [WMS.config.enums.dmgTypes.NORMAL]    = "Arme à feu"
}
WMS.config.human.dmgArea = {
    [WMS.config.enums.dmgArea.SKULL]   = "Crâne",
    [WMS.config.enums.dmgArea.NECK]    = "Cou",
    [WMS.config.enums.dmgArea.FACE]    = "Visage",

    [WMS.config.enums.dmgArea.TORSO]   = "Torse",
    [WMS.config.enums.dmgArea.HEART]   = "Coeur",
    [WMS.config.enums.dmgArea.LUNGS]   = "Poumons",

    [WMS.config.enums.dmgArea.STOMACH] = "Estomac",
    [WMS.config.enums.dmgArea.LIVER]   = "Foie",

    [WMS.config.enums.dmgArea.ARM]     = "Bras",
    [WMS.config.enums.dmgArea.HAND]    = "Mains",

    [WMS.config.enums.dmgArea.LEG]     = "Jambe",
    [WMS.config.enums.dmgArea.FOOT]    = "Pied",
}


WMS.config.dmgAreaToImage = {
    [HITGROUP_HEAD]     = "head",

    [HITGROUP_CHEST]    = "torso",
    [HITGROUP_STOMACH]  = "torso",

    [HITGROUP_LEFTARM]  = "arm_left",
    [HITGROUP_RIGHTARM] = "arm_right",

    [HITGROUP_RIGHTLEG] = "leg_right",
    [HITGROUP_LEFTLEG]  = "leg_left",
}

WMS.config.chances = {
    [WMS.config.enums.dmgArea.SKULL] = {
        ["chance"] = 40,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 99, partial = 99, hemo = 0, dmgRange = {90, 99}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 98, partial = 97, hemo = 0, dmgRange = {90, 99}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 89, partial = 85, hemo = 90, dmgRange = {90, 96}},
    },
    [WMS.config.enums.dmgArea.NECK] = {
        ["chance"] = 25,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 85, partial = 80, hemo = 66, dmgRange = {80, 85}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 75, partial = 70, hemo = 66, dmgRange = {70, 75}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 70, partial = 40, hemo = 90, dmgRange = {70, 90}},
    },
    [WMS.config.enums.dmgArea.FACE] = {
        ["chance"] = 35,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 78, partial = 80, hemo = 20, dmgRange = {40, 75}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 75, partial = 70, hemo = 20, dmgRange = {30, 55}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 30, partial = 20, hemo = 30, dmgRange = {40, 64}},
    },

    [WMS.config.enums.dmgArea.TORSO] = {
        ["chance"] = 70,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 25, partial = 40, hemo = 37, dmgRange = {61, 80}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 15, partial = 20, hemo = 35, dmgRange = {54, 78}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 10, partial = 5, hemo = 30, dmgRange = {55, 70}},
    },
    [WMS.config.enums.dmgArea.HEART] = {
        ["chance"] = 10,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 99, partial = 99, hemo = 99, dmgRange = {99, 99}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 98, partial = 98, hemo = 98, dmgRange = {99, 99}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 99, partial = 99, hemo = 99, dmgRange = {99, 99}},
    },
    [WMS.config.enums.dmgArea.LUNGS] = {
        ["chance"] = 20,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 80, partial = 70, hemo = 90, dmgRange = {90, 96}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 70, partial = 60, hemo = 90, dmgRange = {91, 95}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 50, partial = 30, hemo = 99, dmgRange = {95, 99}},
    },

    [WMS.config.enums.dmgArea.STOMACH] = {
        ["chance"] = 60,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 20, partial = 40, hemo = 50, dmgRange = {54, 73}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 15, partial = 32, hemo = 35, dmgRange = {45, 69}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 35, partial = 30, hemo = 80, dmgRange = {50, 64}},
    },
    [WMS.config.enums.dmgArea.LIVER] = {
        ["chance"] = 40,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 30, partial = 45, hemo = 60, dmgRange = {60, 78}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 20, partial = 39, hemo = 42, dmgRange = {55, 70}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 20, partial = 30, hemo = 80, dmgRange = {56, 80}},
    },

    [WMS.config.enums.dmgArea.ARM] = {
        ["chance"] = 90,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 20, partial = 25, hemo = 10, dmgRange = {24, 39}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 15, partial = 20, hemo = 9, dmgRange = {21, 35}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 5, partial = 7, hemo = 15, dmgRange = {20, 30}},
    },
    [WMS.config.enums.dmgArea.HAND] = {
        ["chance"] = 10,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 5, partial = 7, hemo = 4, dmgRange = {10, 25}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 3, partial = 5, hemo = 2, dmgRange = {7, 23}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 3, partial = 4, hemo = 5, dmgRange = {4, 20}},
    },

    [WMS.config.enums.dmgArea.LEG] = {
        ["chance"] = 92,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 15, partial = 20, hemo = 35, dmgRange = {38, 63}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 13, partial = 15, hemo = 30, dmgRange = {35, 59}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 10, partial = 14, hemo = 40, dmgRange = {30, 55}},
    },
    [WMS.config.enums.dmgArea.FOOT] = {
        ["chance"] = 8,

        [WMS.config.enums.wepTypes.RIFLE]  = {total = 5, partial = 7, hemo = 4, dmgRange = {10, 25}},
        [WMS.config.enums.wepTypes.PISTOL] = {total = 3, partial = 5, hemo = 2, dmgRange = {7, 23}},
        [WMS.config.enums.wepTypes.CUT]    = {total = 3, partial = 4, hemo = 5, dmgRange = {4, 20}},
    },

    ["cut"] = { -- % of hit because melee damage does not register as area (it is its own hit group)
        [WMS.config.enums.dmgArea.SKULL]    = 5,
        [WMS.config.enums.dmgArea.NECK]     = 2,
        [WMS.config.enums.dmgArea.FACE]     = 3,

        [WMS.config.enums.dmgArea.TORSO]    = 28,
        [WMS.config.enums.dmgArea.HEART]    = 4,
        [WMS.config.enums.dmgArea.LUNGS]    = 8,

        [WMS.config.enums.dmgArea.STOMACH]  = 6,
        [WMS.config.enums.dmgArea.LIVER]    = 4,

        [WMS.config.enums.dmgArea.ARM]      = 8,
        [WMS.config.enums.dmgArea.HAND]     = 2,

        [WMS.config.enums.dmgArea.LEG]      = 28,
        [WMS.config.enums.dmgArea.FOOT]     = 2,
    }
}