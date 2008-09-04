-module(greeter).
-export([answer/1, run/0, stop/0]).


message() -> ["Hello ", {color, red, "red"}, " ",
				{color, blue, "blue"}].

send(Socket, Msg) -> gen_tcp:send(Socket, format:parse(Msg)).

answer(Socket) ->
	send(Socket, [message(), "\n"]),
	send(Socket, ui:monster(monsters:get(carapuce))),
	ok.


run() ->
	register(greeter, listener:start_link(1234, fun greeter:answer/1)).

stop() -> exit(whereis(greeter), kill).
