##### **scripts/util/calculations.gd:**



func calculate\_monster\_stat:



\# Calculates new stat value by combining different monster attributes



Takes four arguments:



1. **base:** base stat variable found in monster.gd that holds current value for that stat (base\_hp, etc.)
2. **growth:** variable specific to a stat that holds 
3. **level:** current level of the monster
4. **condition\_bonus:** TBD



Returns: A clamped integer value between 1 and 999 to be used as the new stat value in monster.gd

