-module(listener).
-author('Maxime Augier <max@xolus.net>').

-export([start_link/2, init/2]).

-define(TCP_OPTIONS, [list, {packet, line}, {active, false}, {reuseaddr, true}]).

start_link(Port, Fun) ->
	spawn_link(?MODULE, init, [Port, Fun]).

init(Port, Fun) ->
	{ ok, LSocket } = gen_tcp:listen(Port, ?TCP_OPTIONS),
	log:msg('INFO', "Listening on port ~p", [Port]),
	loop(LSocket, Fun).

handle(Socket, Fun) ->
	spawn_link(fun () -> reaper(Socket) end),
	Fun(Socket).

loop(LSocket, Fun) ->
	{ ok, Socket } = gen_tcp:accept(LSocket),	
	_Pid = spawn(fun () -> handle(Socket, Fun) end),
	log:msg('INFO', "Accepted connection from ~p", [Socket]),
	loop(LSocket, Fun).

reaper(Socket) ->
	process_flag(trap_exit, true),
	receive { 'EXIT', Parent, _Reason } ->
		log:msg('INFO', "Client ~p died, reaping socket ~p",
			[Parent, Socket]),
		gen_tcp:close(Socket)
	end.
