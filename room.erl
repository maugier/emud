-module(room).
-author("Maxime Augier <max@xolus.net>").

-behaviour(gen_server).
-include("game.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).


rn(R) -> {room,R#room.title}.

init(R) -> 
	global:register_name({room, rn(R)}),
	pg2:create(rn(R)),
	log:msg('DEBUG', "Loading room <~s>", [R#room.title]),
	{ ok, R}.

handle_call(join,From,R) ->
	gen_server:cast(From, {join, R}),
	pg2:join(rn(R), From),	
	{ noreply, R};

handle_call(leave,From,R) ->
	pg2:leave(rn(R), From),
	{ noreply, R}.

handle_cast({roomcast,Msg},R) ->
	log:msg('DEBUG', "Roomcast <~s>: ~s", [rn(R),Msg]),
	Fun = fun (Pid) -> gen_server:cast(Pid,Msg) end, 
	lists:map(Fun, pg2:get_members(rn(R))),
	{ noreply, R}.

handle_info({'DOWN',_,process,_Pid,_R}, R) ->
	gen_server:cast(self(), {msg, "Player has disconnected."}),
	{ noreply, R}.

terminate(_Reason,{R,_}) -> 
	pg2:delete(rn(R)),
	log:msg('DEBUG', "Room <~s> terminating", [R#room.title]),
	ok.
