-module(listener).
-author('Maxime Augier <max@xolus.net>').

-export([start_link/2, start_link/3, init/2]).

-define(TCP_OPTIONS, [list, {packet, line}, {active, false}, {reuseaddr, true}]).

start_link(Port, Module, Function) ->
	start_link(Port, fun (Sock) -> Module:Function(Sock) end).

start_link(Port, Fun) when is_function(Fun) ->
	spawn_link(?MODULE, init, [Port, Fun]);

start_link(Port, Module) when is_atom(Module) ->
	start_link(Port, Module, answer).

init(Port, Fun) ->
	{ ok, LSocket } = gen_tcp:listen(Port, ?TCP_OPTIONS),
	log:msg('INFO', "Listening on port ~p", [Port]),
	loop(LSocket, Fun).

handle(Socket, Fun) ->
	Pid = self(),
	spawn_link(fun () -> reaper(Pid,Socket) end),
	receive reaper_ready -> Fun(Socket) end.

loop(LSocket, Fun) ->
	{ ok, Socket } = gen_tcp:accept(LSocket),	
	_Pid = spawn(fun () -> handle(Socket, Fun) end),
	log:msg('INFO', "Accepted connection from ~p", [Socket]),
	loop(LSocket, Fun).

reaper(Parent,Socket) ->
	log:msg('DEBUG', "Starting reaper for ~p", [Socket]),
	process_flag(trap_exit, true),
	Parent ! reaper_ready,
	receive { 'EXIT', Parent, _Reason } ->
		log:msg('INFO', "Client ~p died, reaping socket ~p",
			[Parent, Socket]),
		gen_tcp:close(Socket)
	end.
