-module(terminal).
-author("Maxime Augier <max@xolus.net>").

-export([init/1, read/0, read/1, print/1, print/2, info/1, print_prompt/2]).
-export([list/0, stripln/1, striptelnet/1]).

stripln(Packet) ->
	lists:delete(13, lists:delete(10, Packet)).

striptelnet([255,X,Y|T]) ->
	case lists:any(fun(C) -> X == C end, [251,252,253,254]) of
		true -> striptelnet(T);
		false -> striptelnet([Y|T])
	end;
striptelnet([X|T]) -> [X|striptelnet(T)];
striptelnet([]) -> [].
		

init(Socket) ->
	put(emud_socket,Socket),
	ok = pg2:join(emud_terminal, self()).

read() -> read(get(emud_socket)).
read(Socket) ->
        {ok, Packet} = gen_tcp:recv(Socket, 0),
	Line = stripln(striptelnet(Packet)),
	log:msg('DEBUG', "received: ~p", [Line]),
	Line.



print(Line) -> print(get(emud_socket),Line).

print(Socket, Line) ->
	gen_tcp:send(Socket, format:parse(Line)).

print_prompt(Line,Prompt) ->
	print([Line,"\n",Prompt,[255,249]]).




info(peer) -> { ok, Peer } = inet:peername(get(emud_socket)), Peer.

list() -> pg2:get_members(emud_terminal).

