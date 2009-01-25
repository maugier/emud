
% name = String (monster full name)
% specials: list of modifiers

-record(modifier, { effect, impact }).

-record(attack, { name, element=normal, power=0, accuracy=100, specials=[] }).


-record(monster, { name, level=1, element=normal, 
	xp=0, life=0, maxlife=100, attack=10, defense=10, speed=10, precision=20, attacks=[], modifiers=[], color=undefined }).

% used to store temporary modifiers
-record(fighting_monster, { monster, modifiers }).

% vim:set syntax=erlang
