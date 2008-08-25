-module(log).

-export([msg/1, msg/2, msg/3]).

msg(Msg) ->
	msg('DEBUG', Msg).

msg(Prio,Msg) ->
	io:fwrite("~p: ~s~n",[Prio, Msg]),
	ok.

msg(Prio,Mask,Data) ->
	msg(Prio, io_lib:fwrite(Mask, Data)).
