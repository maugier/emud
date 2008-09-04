-module(server).
-author('Maxime Augier <max@xolus.net>').

-export([start/0]).

-define(PORT, 1234).

start() ->
	log:msg('INFO', "Server booting"),
	ok = mnesia:start(),
	{atomic,ok} = mud_user:init(),
	true = room:create_default(),
	{atomic,ok} = mud_user:create("admin", "admin", admin),
	{atomic,ok} = mud_user:create("user", "user", user),
	log:msg('INFO', "Binding port ~p",[?PORT]),
	listener:start_link(?PORT, fun login:start/1),
	log:msg('INFO', "Server boot complete"),
	ok .


