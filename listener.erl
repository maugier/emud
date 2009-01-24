-module(listener).
-author('Maxime Augier <max@xolus.net>').

-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
code_change/3]).


-define(TCP_OPTIONS, [list, {packet, line}, {active, false}, {reuseaddr, true}]).
start_link(Args) -> gen_server:start_link(?MODULE, Args, []).

-record(state, { socket, handler }).


init( { Port, Handler, PNum } ) ->
	{ ok, LSocket } = gen_tcp:listen(Port, ?TCP_OPTIONS),
	State = #state{ socket=LSocket, handler=Handler},
	log:msg('INFO', "Listening on port ~p", [Port]),
	lists:duplicate(PNum, spawn_child(State)),
	{ ok, State }.

spawn_child(State) ->
	Self = self(),
	spawn(fun () -> handle(State,Self) end).

handle_call(_,_,State) -> { reply, not_impl, State }.

handle_cast(worker_ok,State) -> 
	spawn_child(State),
	{ noreply, State }.

handle_info(_, State) -> { noreply, State }.

handle(State, Parent) ->
	#state{socket=LSock, handler=Handler} = State,
	{ok, Sock} = gen_tcp:accept(LSock),
	gen_server:cast(Parent, worker_ok),
	{ok, Peer} = inet:peername(Sock),
	log:msg('INFO', "Connection accepted from ~p",[Peer]),
	Exit = (catch Handler(Sock)),
	log:msg('INFO', "Connection terminating from ~p (~p)",[Peer,Exit]),
	Exit.

terminate(_Reason, State) ->
	ok = gen_tcp:close(State#state.socket).

code_change(_Old,State,_Extra) -> { ok, State }.
