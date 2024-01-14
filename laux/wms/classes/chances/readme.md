Here we deal with how I chose to deal with the harsh damage system.

```
AreaChance
    └── ArtificialDamageAreaChance
             └── DeathChance

```

The basis is the `DeathChance` class. This class just generates a random result of simple parameters: 
* pourcentage of chance of a total death
* pourcentage of chance of a partial death (coma)
* pourcentage of chance of the start of a hemorrhage
* the range of possible damage

<br>

Then, the `ArtificialDamageAreaChance` class simulates more possible areas that you can be hit in (skull, neck, lungs ...) than with basic gmod.

This class bundles:
* The chance of that specific area to be hit (if the game tells us we hit the head what is the probability of hitting the neck ...)
* The `DeathChance` conserning rifles
* The `DeathChance` conserning pistols
* The `DeathChance` conserning melee weapons

<br>

Finally, the `AreaChance` class takes in a table of the `ArtificialDamageAreaChance` and is able to select one randomly and give the resulting damage, death ...