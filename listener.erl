-module(listener).
-author('Maxime Augier <max@xolus.net>').

-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
code_change/3]).


-define(TCP_OPTIONS, [list, {packet, line}, {active, false}, {reuseaddr, true}]).
start_link(Args) -> gen_server:start_link(?MODULE, Args, []).

-record(state, { socket, handler }).


init( { Port, Handler } ) ->
	{ ok, LSocket } = gen_tcp:listen(Port, ?TCP_OPTIONS),
	log:msg('INFO', "Listening on port ~p", [Port]),
	{ ok, #state{ socket=LSocket, handler=Handler }, 0 }.

handle_call(_,_,State) -> { reply, not_impl, State, 0 }.

handle_cast(_,State) -> { noreply, State, 0 }.

handle_info(timeout, State) -> 
	Handler = State#state.handler,
	{ ok, Socket } = gen_tcp:accept(State#state.socket),
	log:msg('INFO', "Accepted client ~p, forking ~p", [Socket,Handler]),
	spawn(fun () -> handle(Socket, Handler) end),
	{ noreply, State, 0 }.

handle(Socket, Handler) ->
	Self = self(),
	spawn_link(fun () -> reaper(Self, Socket) end),
	receive reaper_ready -> 
		Handler:start_client(Socket)
	end.

terminate(_Reason, State) ->
	ok = gen_tcp:close(State#state.socket).



%loop(LSocket, Fun) ->
%	{ ok, Socket } = gen_tcp:accept(LSocket),	
%	_Pid = spawn(fun () -> handle(Socket, Fun) end),
%	log:msg('INFO', "Accepted connection from ~p", [Socket]),
%	loop(LSocket, Fun).

reaper(Parent,Socket) ->
	log:msg('DEBUG', "Starting reaper for ~p", [Socket]),
	process_flag(trap_exit, true),
	Parent ! reaper_ready,
	receive 
		{ 'EXIT', Parent, _Reason } ->
			log:msg('INFO', "Client ~p died, reaping socket ~p",
			[Parent, Socket]),
			gen_tcp:close(Socket);
		Whatever -> 
			log:msg('WARN', "Unknown message to reaper ~p",
				[Whatever])
	end.



code_change(_Old,State,_Extra) -> { ok, State }.
