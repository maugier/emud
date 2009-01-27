-module(character).
-author("Maxime Augier <max@xolus.net>").

-behaviour(gen_server).

-include("game.hrl").

-export([start_link/1, init/1, handle_call/3, terminate/2]).


start_link(Name) ->
	Ctrl = self(),
	gen_server:start_link({global, {character, Name}}, 
		?MODULE, {Name,Ctrl}, []).
	
init({Name,_Ctrl}) ->
	{ok, _Char} = char_db:load(Name).

handle_call({get,name}, _From, Char) -> {ok, Char#character.name, Char}.

terminate(_Reason, Char) ->
	char_db:save(Char).


