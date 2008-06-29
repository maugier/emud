-module(room).
-author('Maxime Augier <max@xolus.net>').

-export([create_default/0, start/1, loop/2]).


create_default() ->
	register(default_room, start("Default")).	

start(Name) ->
	pg2:create(all_rooms),
	Roompid = spawn (fun () -> loop(Name, dict:new()) end),
	ok = pg2:join(all_rooms, Roompid),
	Roompid.

loop(Name, Members) ->
	receive
		swapcode ->
			room:loop(Name, Members);
  		{join, Pid, Pname} ->
			bcast({ joined, Pname }, Members),
			loop(Name, dict:append(Pid, Pid, Members));
		{part, Pid, Pname} ->
			Nmem = dict:erase(Pid, Members),
			bcast({ left, Pname }, Nmem),
			loop(Name, Nmem);
		{say, Pid, Pname, Text} ->
			bcast({ said, Pid, Pname, Text }, Members),
			loop(Name,Members);
		{look, Pid} -> 
			io:format("Looking..."),
			Pid ! { see, "This is a blank room..." },
			dict:map(fun(Obj,_) ->
				if Obj == Pid -> ok; true -> Obj ! { look, Pid } end end, Members),
			loop(Name, Members);

		Other -> io:format("unknown message in room: ~p~n", [Other])

	end.

bcast(Msg, Members) ->
	dict:map(fun(Pid,_) -> Pid ! Msg end, Members).

