-module(world).
-author("Maxime Augier <max@xolus.net>").

-behaviour(supervisor).

-include("game.hrl").

-export([init/1]).


init(_O) ->
	{ok, {{one_for_one, 10, 10}, [ room(X) || X <- rooms() ]}}.

room(R) -> {
		R#room.title,
		{room, start_link, [R]},
		permanent,
		brutal_kill,
		worker,
		[room]
	    }.

rooms() -> [
	#room{title=default_room, description="Welcome Room"},
	#room{title=admin_room,   description="Admin Secret Room"}
].
