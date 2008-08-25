
-record(attack, { name, element=normal, power=0, accuracy=100, specials=[] }).
-record(monster, { name, level=1, element=normal, 
	xp=0, life=0, maxlife=100, attack=10, defense=10, speed=10, attacks=[] }).

-record(fighting_monster, { monster, modifiers }).
