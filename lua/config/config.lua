AddCSLuaFile()

WMS = WMS or {}

WMS.DEBUG = true

WMS.HemoSpeed = 5
WMS.HemoImportance = 1 --hp

WMS.PartialDeathTime = 3
WMS.CorpsDeleteTime = 50

WMS.DefaultWalkSpeed = 400 -- 400
WMS.DefaultRunSpeed = 600 -- 600
WMS.FractureWalkSpeed = 200 -- 400
WMS.FractureRunSpeed = 400 -- 600

WMS.enums = {}

WMS.enums.dmgTypes = { 
    ["DT_BLEED"] = 1,
    ["DT_PROP"] = 2,
    ["DT_FALL"] = 3,
    ["DT_EXPLOSION"] = 4,
    ["DT_VEHICLE"] = 5,
    ["DT_NO_DAMAGE"] = 6,
    ["DT_NORMAL"] = 7
}

WMS.enums.wepTypes = { 
    ["WT_CUT"] = 1,
    ["WT_PISTOL"] = 2,
    ["WT_RIFLE"] = 3,
}

WMS.enums.dmgArea = {
    ["DA_SKULL"] = 1,
    ["DA_NECK"] = 2,
    ["DA_FACE"] = 3,

    ["DA_TORSO"] = 4,
    ["DA_HEART"] = 5,
    ["DA_LUNGS"] = 6,

    ["DA_STOMACH"] = 7,
    ["DA_LIVER"] = 8,
    
    ["DA_ARM"] = 9,
    ["DA_HAND"] = 10,
    
    ["DA_LEG"] = 11,
    ["DA_FOOT"] = 12,
}


WMS.human = {}

WMS.human.dmgTypes = { 
    [WMS.enums.dmgTypes.DT_BLEED] = "Saignement",
    [WMS.enums.dmgTypes.DT_PROP] = "Objet",
    [WMS.enums.dmgTypes.DT_FALL] = "Chute",
    [WMS.enums.dmgTypes.DT_EXPLOSION] = "Explosion",
    [WMS.enums.dmgTypes.DT_VEHICLE] = "Véhicule",
    [WMS.enums.dmgTypes.DT_NO_DAMAGE] = "NON",
    [WMS.enums.dmgTypes.DT_NORMAL] = "Arme à feu"
}

WMS.human.dmgArea = {
    [WMS.enums.dmgArea.DA_SKULL] = "Crâne",
    [WMS.enums.dmgArea.DA_NECK] = "Cou",
    [WMS.enums.dmgArea.DA_FACE] = "Visage",

    [WMS.enums.dmgArea.DA_TORSO] = "Torse",
    [WMS.enums.dmgArea.DA_HEART] = "Coeur",
    [WMS.enums.dmgArea.DA_LUNGS] = "Poumons",

    [WMS.enums.dmgArea.DA_STOMACH] = "Estomac",
    [WMS.enums.dmgArea.DA_LIVER] = "Foie",
    
    [WMS.enums.dmgArea.DA_ARM] = "Bras",
    [WMS.enums.dmgArea.DA_HAND] = "Mains",
    
    [WMS.enums.dmgArea.DA_LEG] = "Jambe",
    [WMS.enums.dmgArea.DA_FOOT] = "Pied",
}

WMS.DmgAreaT = {
    [HITGROUP_HEAD] = "head",

    [HITGROUP_CHEST] = "torso",
    [HITGROUP_STOMACH] = "torso",
  
    [HITGROUP_LEFTARM] = "arm_left",
    [HITGROUP_RIGHTARM] = "arm_right",
    
    [HITGROUP_RIGHTLEG] = "leg_right",
    [HITGROUP_LEFTLEG] = "leg_left",
}

WMS.Chances = {
    [WMS.enums.dmgArea.DA_SKULL] = {
        ["chance"] = 40,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 99, partial = 99, hemo = 0, dmgRange = {90, 99}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 98, partial = 97, hemo = 0, dmgRange = {90, 99}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 89, partial = 85, hemo = 90, dmgRange = {90, 96}},
    },
    [WMS.enums.dmgArea.DA_NECK] = {
        ["chance"] = 25,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 85, partial = 80, hemo = 66, dmgRange = {80, 85}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 75, partial = 70, hemo = 66, dmgRange = {70, 75}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 70, partial = 40, hemo = 90, dmgRange = {70, 90}},
    },
    [WMS.enums.dmgArea.DA_FACE] = {
        ["chance"] = 35,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 78, partial = 80, hemo = 20, dmgRange = {40, 75}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 75, partial = 70, hemo = 20, dmgRange = {30, 55}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 30, partial = 20, hemo = 30, dmgRange = {40, 64}},
    },

    [WMS.enums.dmgArea.DA_TORSO] = {
        ["chance"] = 70,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 25, partial = 40, hemo = 37, dmgRange = {61, 80}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 15, partial = 20, hemo = 35, dmgRange = {54, 78}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 10, partial = 5, hemo = 30, dmgRange = {55, 70}},
    },
    [WMS.enums.dmgArea.DA_HEART] = {
        ["chance"] = 10,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 99, partial = 99, hemo = 99, dmgRange = {99, 99}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 98, partial = 98, hemo = 98, dmgRange = {99, 99}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 99, partial = 99, hemo = 99, dmgRange = {99, 99}},
    },
    [WMS.enums.dmgArea.DA_LUNGS] = {
        ["chance"] = 20,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 80, partial = 70, hemo = 90, dmgRange = {90, 96}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 70, partial = 60, hemo = 90, dmgRange = {91, 95}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 50, partial = 30, hemo = 99, dmgRange = {95, 99}},
    },

    [WMS.enums.dmgArea.DA_STOMACH] = {
        ["chance"] = 60,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 20, partial = 40, hemo = 50, dmgRange = {54, 73}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 15, partial = 32, hemo = 35, dmgRange = {45, 69}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 35, partial = 30, hemo = 80, dmgRange = {50, 64}},
    },
    [WMS.enums.dmgArea.DA_LIVER] = {
        ["chance"] = 40,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 30, partial = 45, hemo = 60, dmgRange = {60, 78}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 20, partial = 39, hemo = 42, dmgRange = {55, 70}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 20, partial = 30, hemo = 80, dmgRange = {56, 80}},
    },

    [WMS.enums.dmgArea.DA_ARM] = {
        ["chance"] = 90,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 20, partial = 25, hemo = 10, dmgRange = {24, 39}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 15, partial = 20, hemo = 9, dmgRange = {21, 35}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 5, partial = 7, hemo = 15, dmgRange = {20, 30}},
    },
    [WMS.enums.dmgArea.DA_HAND] = {
        ["chance"] = 10,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 5, partial = 7, hemo = 4, dmgRange = {10, 25}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 3, partial = 5, hemo = 2, dmgRange = {7, 23}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 3, partial = 4, hemo = 5, dmgRange = {4, 20}},
    },

    [WMS.enums.dmgArea.DA_LEG] = {
        ["chance"] = 92,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 15, partial = 20, hemo = 35, dmgRange = {38, 63}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 13, partial = 15, hemo = 30, dmgRange = {35, 59}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 10, partial = 14, hemo = 40, dmgRange = {30, 55}},
    },
    [WMS.enums.dmgArea.DA_FOOT] = {
        ["chance"] = 8,
        [WMS.enums.wepTypes.WT_RIFLE] = {total = 5, partial = 7, hemo = 4, dmgRange = {10, 25}},
        [WMS.enums.wepTypes.WT_PISTOL] = {total = 3, partial = 5, hemo = 2, dmgRange = {7, 23}},
        [WMS.enums.wepTypes.WT_CUT] = {total = 3, partial = 4, hemo = 5, dmgRange = {4, 20}},
    },

    ["cut"] = {
        [WMS.enums.dmgArea.DA_SKULL] = 5,
        [WMS.enums.dmgArea.DA_NECK] = 2,
        [WMS.enums.dmgArea.DA_FACE] = 3,
    
        [WMS.enums.dmgArea.DA_TORSO] = 28,
        [WMS.enums.dmgArea.DA_HEART] = 4,
        [WMS.enums.dmgArea.DA_LUNGS] = 8,
    
        [WMS.enums.dmgArea.DA_STOMACH] = 6,
        [WMS.enums.dmgArea.DA_LIVER] = 4,
        
        [WMS.enums.dmgArea.DA_ARM] = 8,
        [WMS.enums.dmgArea.DA_HAND] = 2,
        
        [WMS.enums.dmgArea.DA_LEG] = 28,
        [WMS.enums.dmgArea.DA_FOOT] = 2,
    }
}