-module(monster).
-include("game.hrl").
-export([getStat/2]).


getIntMod(Mods, Key) ->
	case lists:keysearch(Key, 1, Mods) of
		false 			-> 0;
		{value, {Key, Val}} 	-> Val
	end.

getStat(#fighting_monster{monster=M, modifiers=Mod}, Stat) -> 
	getStat(M, Stat) + getIntMod(Mod, Stat);

getStat(M = #monster{}, Stat) -> case Stat of 
	attack 	-> M#monster.attack;
	defense	-> M#monster.defense;
	life	-> M#monster.life;
	speed	-> M#monster.speed;
	precision -> M#monster.precision
end.




