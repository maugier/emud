-module(character).
-author("Maxime Augier <max@xolus.net>").
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).
-export([save/1]).

-record(character, { name, owner, room=default_room, team=[], objects=[] }).


terminate(Reason,State) ->
	do_save(State), ok.


save(C) -> gen_server:call(C, save).
