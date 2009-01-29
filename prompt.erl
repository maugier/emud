-module(prompt).
-author("Maxime Augier <max@xolus.net>").



-export([interact/1]).

interact(Ctrl) -> 
	Socket = get(emud_socket),
	loop(Ctrl,Socket,default_prompt()).

loop(Ctrl,Sock,Prpt) ->
	inet:setopts(Sock,[{active,once}]),
	receive
		{tcp,Sock,Packet} ->
			Line = terminal:stripln(Packet),
			Ctrl ! {input, Line};
		{tcp_closed,Sock} ->
			conn_closed;
		{prompt,NP} ->
			display(Sock,NP,[]),
			loop(Ctrl,Sock,NP);
		{display, Text} ->
			display(Sock,Prpt,Text),
			loop(Ctrl,Sock,Prpt);
	
		Other ->
			log:msg('DEBUG',"Unknown message in ~p:~p",
				[?MODULE,Other]),
			loop(Ctrl,Sock,Prpt)
	end.

display(S,P,T) ->
	gen_tcp:send(S, format:parse([T,"\n",P,[255,249]])).

default_prompt() -> [
	{color, red, "PoKe"},
	{color, blue, "Mud"},
	"> "].
