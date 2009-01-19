-module(server).
-author('Maxime Augier <max@xolus.net>').
-behaviour(supervisor).

-export([init/1]).

-define(PORT, 1234).
-define(HANDLER, greeter).

init(_) ->
	log:msg('INFO', "Server initializing"),
	ok = mnesia:start(),
	{ ok, {{one_for_all, 5, 60}, [ 
		listener() 
		%, connmanager()
	] }}.
	

listener() -> 
	{ listener,
	  { listener, start_link, [{?PORT, ?HANDLER}] },	
	  permanent,
	  5,
	  worker,
	  [listener]
	}.


% start() ->
% 	log:msg('INFO', "Server booting"),
%	ok = mnesia:start(),
%	{atomic,ok} = mud_user:init(),
%	true = room:create_default(),
%	{atomic,ok} = mud_user:create("admin", "admin", admin),
%	{atomic,ok} = mud_user:create("user", "user", user),
%	log:msg('INFO', "Binding port ~p",[?PORT]),
%	listener:start_link(?PORT, fun login:start/1),
%	log:msg('INFO', "Server boot complete"),
%	ok .


