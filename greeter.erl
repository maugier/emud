-module(greeter).
-export([start_client/2]).


message() -> ["Hello ", {color, red, "red"}, " ",
				{color, blue, "blue"}].

send(Socket, Msg) -> gen_tcp:send(Socket, format:parse(Msg)).

start_client(Socket,Msg) ->
	send(Socket, [message(), "\n"]),
	send(Socket, ["The admin message of the day is: ",Msg,"\n"]),
	send(Socket, ui:monster(monsters:get(carapuce))),
	send(Socket, "Please say something for posterity: "),
	{ok, R} = gen_tcp:recv(Socket,0),
	log:msg('INFO', "Client said: ~p",[R]),
	greeter_ok.

