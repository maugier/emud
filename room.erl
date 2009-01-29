-module(room).
-author("Maxime Augier <max@xolus.net>").

-behaviour(gen_server).
-include("game.hrl").

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
code_change/3]).
-export([call/2,cast/2]).


call(Name,Call) ->
	gen_server:call({global, {room,Name}}, Call).
cast(Name,Cast) ->
	gen_server:cast({global, {room,Name}}, Cast).

rn(R) -> {room,R#room.title}.

start_link(R) ->
	gen_server:start({global, rn(R) },?MODULE,R,[]).

init(R) -> 
	pg2:create(rn(R)),
	log:msg('DEBUG', "Loading room <~s>", [R#room.title]),
	{ ok, R}.

handle_call(get_name,_From,R) ->
	{ reply, R#room.description, R };

handle_call(join,{From,_},R) ->
	pg2:join(rn(R), From),	
	{ reply, {joined, R}, R};

handle_call(leave,{From,_},R) ->
	pg2:leave(rn(R), From),
	{ reply, {left,R}, R}.

handle_cast({roomcast,Msg},R) ->
	log:msg('DEBUG', "Roomcast <~p>: ~p", [R#room.title,Msg]),
	Fun = fun (Pid) -> gen_server:cast(Pid,Msg) end, 
	lists:map(Fun, pg2:get_members(rn(R))),
	{ noreply, R}.

handle_info({'DOWN',_,process,_Pid,_R}, R) ->
	gen_server:cast(self(), {msg, "Player has disconnected."}),
	{ noreply, R}.

terminate(_Reason,R) -> 
	pg2:delete(rn(R)),
	log:msg('DEBUG', "Room <~s> terminating", [R#room.title]),
	ok.

code_change(_O,S,_E) ->
	{ok, S}.
