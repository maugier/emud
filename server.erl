-module(server).
-author('Maxime Augier <max@xolus.net>').
-behaviour(supervisor).

-export([init/1]).

-define(PORT, 1234).
-define(HOPTS, "Hello, asshole !").
%-define(HANDLER, fun(S) -> greeter:start_client(S,?HOPTS) end).
-define(HANDLER, fun login:start/1).
-define(LTS, 5).

init(_) ->
	log:msg('INFO', "Server initializing"),
	ok = mnesia:start(),
	{ ok, {{one_for_all, 5, 60}, [ 
		listener(),
		account()
	] }}.
	

listener() -> 
	{ listener,
	  { listener, start_link, [{?PORT, ?HANDLER, ?LTS}] },	
	  permanent,
	  5,
	  worker,
	  [listener]
	}.

account() ->
	{ account,
	  { account, start_link, [] },
	  permanent,
	  5,
	  worker,
	  [account]
	}.
