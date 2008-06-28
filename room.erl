-module(room).
-author('Maxime Augier <max@xolus.net>').

-export([start/0]).

start() ->
	spawn (fun () -> loop(dict:new()) end).

loop(Members) ->
	receive
		reload ->
			room:loop(Members);
  		{join, Pid} ->
			io:format("Joined~n", []),
			loop(dict:append(Pid, Pid, Members));
		{part, Pid} ->
			loop(dict:erase(Pid, Members));
		{msg, Pid, Msg} ->
			io:format("Message: [~p]~n", [Msg]),
			bcast(Pid, Msg, Members),
			loop(Members)
	end.


bcast(Src, Msg, Members) -> dict:map(fun (Pid,_) -> Pid ! {msg, Src, Msg} end, Members).
