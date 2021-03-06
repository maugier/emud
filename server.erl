-module(server).
-author('Maxime Augier <max@xolus.net>').
-behaviour(supervisor).

-export([init/1]).
-export([start/0, stop/0]).



-define(PORT, 1234).
-define(HOPTS, "Hello, asshole !").
%-define(HANDLER, fun(S) -> greeter:start_client(S,?HOPTS) end).
-define(HANDLER, fun login:start/1).
% Number of tcp listeners
-define(LTS, 5).

start() ->
	{ok, Pid} = supervisor:start_link({local, emud_server},server,[]),
	unlink(Pid),
	{ok, Pid}.

stop() -> 
	case global:whereis_name(emud_server) of
		undefined -> {error, stopped};
		Pid -> exit(Pid, stop_request)
	end.


init(_) ->
	log:msg('INFO', "Server initializing"),
	%ok = mnesia:start(),
	pg2:create(emud_terminal),
	{ ok, {{one_for_all, 5, 60}, [ 
		account(),
		char_db(),
		world(),
		listener()
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
	  { account, start_link, [[]] },
	  permanent,
	  5,
	  worker,
	  [account]
	}.

char_db() -> 
	{ char_db,
	  { char_db, start_link, [[]] },
	  permanent,
	  15,
	  worker,
	  [char_db]
	}.

world() ->
	{ world,
	  { supervisor, start_link, [world,[]] },
	  permanent,
	  20,
	  supervisor,
	  [world]
	}.
