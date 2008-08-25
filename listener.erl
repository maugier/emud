-module(listener).
-author('Maxime Augier <max@xolus.net>').

-export([start_link/2, init/2]).

-define(TCP_OPTIONS, [list, {packet, line}, {active, false}, {reuseaddr, true}]).

start_link(Port, Fun) ->
	spawn_link(?MODULE, init, [Port, Fun]).

init(Port, Fun) ->
	{ ok, LSocket } = gen_tcp:listen(Port, ?TCP_OPTIONS),
	log:msg("Listening..."),
	loop(LSocket, Module).

loop(LSocket, Fun) ->
	{ ok, Socket } = gen_tcp:accept(LSocket),	
	Pid = spawn(fun () -> Fun(Socket) end),
	log:msg("Listener launched"),
	loop(LSocket, Fun).
