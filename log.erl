-module(log).

-export([msg/1, msg/2, msg/3]).

prio_color('DEBUG') -> white;
prio_color('INFO') -> cyan;
prio_color('NOTICE') -> green;
prio_color('WARN') -> yellow;
prio_color('ERR') -> red.
prio_color('CRIT') -> red.

prio('DEBUG')	-> 0;
prio('INFO')	-> 1;
prio('NOTICE')	-> 2;
prio('WARN')	-> 3;
prio('ERR')	-> 4;
prio('CRIT')	-> 5;

msg(Msg) ->
	msg('DEBUG', Msg).

msg(Prio,Msg) ->
	%CP = format:parse({color, prio_color(Prio), io_lib:format("~s",[Prio])}),
	io:format("~s: ~s~n",[Prio, Msg]),
	%io:put_chars(CP),
	%io:put_chars(Text),
	ok.

msg(Prio,Mask,Data) ->
	msg(Prio, io_lib:fwrite(Mask, Data)).
