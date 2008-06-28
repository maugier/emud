-module(server).
-author('Maxime Augier <max@xolus.net>').

-export([init/0, listen/1]).

-define(TCP_OPTIONS, [list, {packet, line}, {active, false}, {reuseaddr, true}]).

init() ->
	ok = mnesia:start(),
	{atomic,ok} = mud_user:init(),
	ok .

listen(Port) ->
  { ok, LSocket } = gen_tcp:listen(Port, ?TCP_OPTIONS),
  io:fwrite("Listening on port ~p~n", [Port]),
  spawn(fun () -> accept(LSocket) end).

accept(LSocket) ->
  { ok, Socket } = gen_tcp:accept(LSocket),
  Pid = spawn( fun() -> login:login(Socket) end),
  io:fwrite("New connection ~p handled by ~p~n", [Socket, Pid]),
  accept(LSocket).
