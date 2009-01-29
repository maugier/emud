-module(character).
-author("Maxime Augier <max@xolus.net>").

-behaviour(gen_server).

-include("game.hrl").

-export([start_link/1, init/1, handle_call/3, handle_cast/2, 
handle_info/2, terminate/2, code_change/3]).


start_link(Name) ->
	Ctrl = self(),
	gen_server:start_link({global, {character, Name}}, 
		?MODULE, {Name,Ctrl}, []).
	
init({Name,Ctrl}) ->
	log:msg('DEBUG', "Character [~s] starting", [Name]),
	{ok, Char} = char_db:load(Name),
	pg2:join(all_characters, self()),
	{joined, R} = room:call(Char#character.room, join),
	show_room(Ctrl,R),
	{ok, {Char, Ctrl}}.

handle_call({get,name}, _From, S={Char,_}) ->
	{reply, Char#character.name, S}.

handle_cast({say, From, Text}, {Char,Ctrl}) ->
	FromName = case self of
		From -> {color, green, Char#character.name};
		_    -> {color, blue, gen_server:call(From,{get,name}
	case self() of From -> 
		Ctrl ! {display, [{color, green, "You "},"say: ",{color,green,
		Text}]};
	_ ->
		FromName = gen_server:call(From,{get,name}),
		Ctrl ! {display, [{color, red, FromName}, " says: ", {color, blue, Text}]}
	end,
	{noreply, {Char,Ctrl}};

handle_cast({join,R},S={_,Ctrl}) ->
	show_room(Ctrl,R),
	{reply, S};

handle_cast(shutdown,S) -> 
	{stop, shutdown, S}.

handle_info({input,Text},{Chr,_}=S) ->
	room:cast(Chr#character.room, 
		{ roomcast, { say, self(), Text }}),
	{noreply, S}.

terminate(Reason, {Char,_}) ->
	room:call(Char#character.room, leave),
	log:msg('DEBUG', "Character [~s] terminating: ~p",
		[Char#character.name, Reason]),
	char_db:save(Char).

code_change(_O,S,_E) ->
        {ok, S}.


show_room(Ctrl,R) ->
	Ctrl ! { display, ["Welcome to ", {color, green, R#room.description}]}.

