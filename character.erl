-module(character).
-author("Maxime Augier <max@xolus.net>").

-behaviour(gen_server).

-include("game.hrl").

-export([start_link/1, init/1, handle_call/3, handle_cast/2, 
handle_info/2, terminate/2]).


start_link(Name) ->
	Ctrl = self(),
	gen_server:start_link({global, {character, Name}}, 
		?MODULE, {Name,Ctrl}, []).
	
init({Name,Ctrl}) ->
	log:msg('DEBUG', "Character server [~s] starting", [Name]),
	{ok, Char} = char_db:load(Name),
	{ok, {Char, Ctrl}}.

handle_call({get,name}, _From, {Char,_}) ->
	{ok, Char#character.name, Char}.

handle_cast(shutdown,S) -> 
	{stop, shutdown, S}.

handle_info(_I,S) ->
	{noreply, S}.

terminate(Reason, {Char,_}) ->
	log:msg('DEBUG', "Character server [~s] terminating: ~s",
		[Char#character.name, Reason]),
	char_db:save(Char).


