-module(greeter).
-export([answer/1, run/0]).


message() -> format:parse(["Hello ", {color, red, "red"}, " ",
				{color, blue, "blue"}]).


answer(Socket) ->
	gen_tcp:send(Socket, [message(), "\n"]),
	ok.


run() ->
	listener:start_link(1234, fun greeter:answer/1).
