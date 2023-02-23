# WNS/WMS

The WNS (War Nursing System) is a addon with the intent to bring a little bit of realism into garry's mod (especially for roleplay). It is meant to replicate a WW2 perspective of nursing.

- high chance of death upon being hit
- hemorrhage
- limp
- grabbing your mate when he is limp
- [ACE3](https://github.com/acemod/ACE3) like diagnostic sheet
- Death screen
- low health effects
- pulse
- morphine
- antibiotics
- infections
- coma
- Somewhat compatible with simfphys armed
### **THE ADDON IS UNFINISHED**

and it's use is still buggy but I am working on it daily 


### TODO
- [x] Damage System
- [ ] Healing System
- [ ] CLEANING CODE
- [ ] Automatic weapons registration
---

## Dependencies

- [~~Entity Position Kit~~](https://github.com/Pika-Software/plib_entity_position_kit)
- [~~Plib~~](https://github.com/Pika-Software/gmod_plib)
- [~~G-Core lib~~](https://github.com/SlownLS-Gmod/gcore-lib)

### Integrated in the addon
- [gmod_improved_player_ragdolls](https://github.com/Pika-Software/gmod_improved_player_ragdolls)
- [Low Health Effect](https://steamcommunity.com/sharedfiles/filedetails/?id=652896605)

---
## CONFIG and Install

### Install

Installing the addon is the basic put `wms/` in `garrysmod/addons/`

### $Confi.g)

the config files are in `wms/lua/config/` . Most of it is developer side and isn't meant to be tampered with.

<br>
<br>

**Note concerning the weapon detection system**

On release the addon will have a limited scope of the weapons mode systems.
This addon is based on 3 different *types* of weapons dealing damage : 
* rifle
* pistol
* melee

They simulate the caliber of the weapon used, and it deals the damage accordingly.
Following that path we must distinguish which weapon fires which caliber. Here relies the source of the problem. Not all popular weapon modes make it easy to identify and discriminate between weapons. Here the CW 2.0 KK INS2 DOI is the basis.

So if the weapon mode (or any rework of any weapon base) that you're using isn't automatically detected you can manually put your weapon classes in [the weapon list](./lua/config/weapons.lua#L14-L50)

```lua
 ...
WMS.weapons = {
    rifle = {
        ["any_class"] = true,
        ["any_other_class"] = true
    },

    pistol = {
        ["another_class"] = true,
        ["yet_another_class"] = true,
        ["and_the_last_pistol"] = true
    },

    cut = {
        ["i_think_you_understand_by_now"] = true,
        ["why_do_you_even_bother"] = true
    },
 
 ...
```

or if you are a good and sain developer you can add use cases to the [loop](./lua/config/weapons.lua#L62-L86)

```lua
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

    elseif (--[[JUST END ME]]) then
        -- PUT YOUR CODE HERE
    end
end
```


---
> this addon is originally made for the LPS server

`Winnie's Natural Selection`

`Winnie's Medical System`

🇦🇲❤️🇫🇷