-module(terminal).
-author("Maxime Augier <max@xolus.net>").

-export([init/1, read/0, read/1, print/1, print/2, info/1]).
-export([list/0, stripln/1]).

stripln(Packet) ->
	lists:delete(13, lists:delete(10, Packet)).

init(Socket) ->
	put(emud_socket,Socket),
	ok = pg2:join(emud_terminal, self()).

read() -> read(get(emud_socket)).
read(Socket) ->
        {ok, Packet} = gen_tcp:recv(Socket, 0),
	stripln(Packet).

print(Line) -> print(get(emud_socket),Line).
print(Socket, Line) ->
	gen_tcp:send(Socket, format:parse(Line)).


info(peer) -> { ok, Peer } = inet:peername(get(emud_socket)), Peer.

list() -> pg2:get_members(emud_terminal).

