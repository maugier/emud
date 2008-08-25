-module(attacks).

-include("game.hrl").

-export([get/1]).

list() -> [
	#attack{ name='charge',		power=60 },
	#attack{ name='pistolet-a-o',	element=water, power=80 },
	#attack{ name='mimi-queue',	specials=[{enemy, {defense, -1}}] },
	#attack{ name='ecume', 		element=water, power=40 },
	#attack{ name='cage-eclair',	element=lightning, power=20, specials=[{enemy, paralyzed}] }
].

get(Name) -> {value, Attack} = lists:keysearch(Name, 2, list()),
	     Attack.
