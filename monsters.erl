-module(monsters).
-include("game.hrl").

-export([list/0, get/1]).

list() -> [
	#monster{ name=carapuce, element=water, attacks=[charge, ecume] },
	#monster{ name=pikachu,	 element=lightning, attacks=[charge, 'cage-eclair'] }
].

get(Name) ->
	{ value, M } = lists:keysearch(Name, #monster.name, list()),
	M.
