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
	log:msg('DEBUG', "Character [~s] starting", [Name]),
	{ok, Char} = char_db:load(Name),
	pg2:join(all_characters, self()),
	gen_server:call({room, Char#character.room}, join),
	{ok, {Char, Ctrl}}.

handle_call({get,name}, _From, {Char,_}) ->
	{ok, Char#character.name, Char}.

handle_cast({say, From, Text}, {Char,Ctrl}) ->
	Ctrl ! {say, From, Text},
	{ok, {Char,Ctrl}};

handle_cast({join,R},{_Char,Ctrl}) ->
	Ctrl ! {display, ["Welcome to", {color, green, R#room.title}]};

handle_cast(shutdown,S) -> 
	{stop, shutdown, S}.

handle_info({input,Text},{Chr,_}=S) ->
	gen_server:cast(Chr#character.room, 
		{ roomcast, { say, self(), Text }}),
	{noreply, S}.

terminate(Reason, {Char,_}) ->
	gen_server:call(Char#character.room, leave),
	log:msg('DEBUG', "Character [~s] terminating: ~s",
		[Char#character.name, Reason]),
	char_db:save(Char).


