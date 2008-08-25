-module(log).

-export([msg/1, msg/2]).

msg(Msg) ->
	msg('DEBUG', Msg).

msg(Prio,Msg) ->
	io:fwrite("~p: ~s",[Prio, Msg]),
	ok.
