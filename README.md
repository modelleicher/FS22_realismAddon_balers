# FS22_realismAddon_balers
This Script is made to enhance realism on balers.


# Credits
- Modelleicher

# Important to know
Due to the script recalculating power usage this can have negative sideeffects.
Not all mods are created equal when it comes to default power usage and since
the script has no way of knowing the size and power requirements of each baler
I have to use the power value set in the XML as basis for the new calculation.
Meaning, if the baler you use seems to require way too much or way too little
power with this script enabled you need to adjust the power requirement in the
xml of the baler.
Unfortunately things like that can't be 100% bullet proof globally due to
how inconsistent even the basegame vehicles are set up.


This Scripts main goal is to enhance realism for balers. 

# For square-balers this script does the following

- new power requirement calculation depending on the amount of material picked up and the 
current position of the plunger. It now has power-requirement spikes each time the plunger 
hits. Depending on the tractor and soundcalculation this can be heard in the load-sound at
least on singleplayer.

- and the BEST FEATURE, the animation of the bale isn't continuous but instead moves in 
steps analog to the plunger animation movements.

- also the entire baler is moved back and forth with the plunger movements. This is a bit 
of a gimmicky feature, if the tractor has the handbrake set or is a CVT the baler can't
really move the tractor so the entire baler just hops up and down a little.. 
So not quite realistic as it could be but with gearbox vehicles and in neutral this 
is fun to watch.


# For round-balers this script does the following
- new power requirement calculation depending on the amount of material picked up.
Power requirement is also dependend on percentage filled so when the bale is almost full
the power requirement goes up drastically.

- Bales can be unloaded before 100% is reached.

