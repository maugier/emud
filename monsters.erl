-module(monsters).
-include("game.hrl").

-export([list/0]).

list() -> [
	#monster{ name=carapuce, element=water, attacks=[charge, ecume] },
	#monster{ name=pikachu,	 element=lightning, attacks=[charge, 'cage-eclair'] }
].
