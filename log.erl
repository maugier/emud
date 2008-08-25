-module(log).

-export([msg/2]).

msg(Prio,Msg) ->
	io:fwrite("~p: ~s",[Prio, Msg]),
	ok.
