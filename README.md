# WNS/WMS (WIP)

> [!WARNING]
> The addon is being rewriten in the laux language to use a more object oriented design.

The WNS (War Nursing System or Winnies Medical System) is a addon with the intent to bring a little bit of realism into garry's mod (especially for roleplay). It is meant to replicate a WW2 perspective of nursing.

I was inspired by Arma III's [ACE3](https://github.com/acemod/ACE3) mod.
A lot of visuals are based on it.

This mod adds :
- Better hit areas
- More realistic damage types
- Contraints when injured (no more rules to enforced by staff)
- [ACE3](https://github.com/acemod/ACE3) like diagnostic sheet
- A [HLL](https://www.hellletloose.com/) like death screen
- Visuals when injured
- An advanced medical system for medics

### **THE ADDON IS UNFINISHED**

and it's use is still buggy but I am working on it ~~daily~~ 


### Roadmap
- [ ] Damage System
- [ ] Medical System
- [ ] Automatic weapons registration

---
## Installation & configuration

### Install

Installing the addon is a bit technical.

1. Download the [laux compiler](https://github.com/8char/laux-compiler)
2. Clone the repo on in the servers `addons/` folder.
3. If your are sane, use GNU make. Or transpile the `laux/` directory to a new `lua/` directory 
4. It should be installed 🎊

or 

When it is finished I will probably upload the pre-transpiled source code in the `release` section.

So just download it in the `addons/` folder.

### Config


the config files are in `wms/laux/wms/config/` . Most of it is developer side and isn't meant to be tampered with.

<br>
<br>

> [!NOTE]
> #### Concerning the weapon detection system
> On release the addon will have a limited scope of the weapons mode systems.
This addon is based on 3 different *types* of weapons dealing damage : 
>* rifle
>* pistol
>* melee
>
>They simulate the caliber of the weapon used, and it deals the damage accordingly.
Following that path we must distinguish which weapon fires which caliber. Here relies the source of the problem. Not all popular weapon modes make it easy to identify and discriminate between weapons. Here the CW 2.0 KK INS2 DOI is the base.
>
>So if the weapon mode (or any rework of any weapon base) that you're using isn't automatically detected you can manually put your weapon classes in [the weapon list](.laux/wms/config/weapons.laux#L10-L30)

```lua
 ...
WMS.weapons = {
    [WMS.enums.damageTypes.RIFLE] = {
        ["any_class"] = true,
        ["any_other_class"] = true
    },

    [WMS.enums.damageTypes.PISTOL] = {
        ["another_class"] = true,
        ["yet_another_class"] = true,
        ["and_the_last_pistol"] = true
    },

    [WMS.enums.damageTypes.MELEE] = {
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
# Contributing

> [!IMPORTANT]
> This addon is made for a server, so it can have weird hard-coded things.
> I'll try to minimize the occurence of this kind of code.

If you want to contribute you must know about the [laux compiler](https://github.com/8char/laux-compiler)

For any pull request to be accepted you must follow the [style guide](./STYLE_GUIDELINE.md).


---
> this addon is originally made for the LPS server

`Winnie's Natural Selection`

`Winnie's Medical System`

🇦🇲❤️🇫🇷