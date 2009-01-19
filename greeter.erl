-module(greeter).
-export([start_client/1]).


message() -> ["Hello ", {color, red, "red"}, " ",
				{color, blue, "blue"}].

send(Socket, Msg) -> gen_tcp:send(Socket, format:parse(Msg)).

start_client(Socket) ->
	send(Socket, [message(), "\n"]),
	send(Socket, ui:monster(monsters:get(carapuce))),
	gen_tcp:close(Socket),
	ok.

