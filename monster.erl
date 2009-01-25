-module(monster).
-include("game.hrl").
-export([getStat/2, get_color/1, add_mod/2, clear_mod/2]).


get_int_mod(Mods, Key) ->
	case lists:keysearch(Key, 1, Mods) of
		false 			-> 0;
		{value, {Key, Val}} 	-> Val
	end.

getStat(#fighting_monster{monster=M, modifiers=Mod}, Stat) -> 
	getStat(M, Stat) + get_int_mod(Mod, Stat);

getStat(M = #monster{}, Stat) -> case Stat of 
	attack 	-> M#monster.attack;
	defense	-> M#monster.defense;
	life	-> M#monster.life;
	speed	-> M#monster.speed;
	precision -> M#monster.precision
end.

get_color(M) -> case M#monster.color of
	undefined -> element:color(M#monster.element);
	Other 	  -> Other
end.


add_mod(M = #monster{modifiers = OldMods}, Mod) -> 
	M#monster{modifiers = add_mod_list(OldMods, Mod)}.

clear_mod(M = #monster{modifiers = Mods}, Mod) ->
	M#monster{modifiers = lists:keydelete(Mod, 1, Mods)}.

add_mod_list([], Mod) -> [Mod];
add_mod_list(OldList = [Old = {Key,_}|Tail], New = {Key,_}) ->
	case is_stronger(Old, New) of
		true -> OldList;
		false -> [New | Tail]
	end;
add_mod_list([H|T],M) -> [H|add_mod_list(T,M)].


is_stronger({_,A},{_,B}) -> A > B.
