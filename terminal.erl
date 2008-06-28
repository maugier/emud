-module(terminal).
-author("Maxime Augier <max@xolus.net>").

-export([start/2]).


start(Socket, Login) ->
		spawn_link(fun () -> reaper(Socket) end),
		Self = self(),
		User = spawn_link(fun () -> mud_user:start(Login, Self) end),
		spawn_link(fun () -> receiver(Socket, User) end),
		io:format("Login accepted for [~s]~n",[Login]),
		sender(Socket, User).


sender(Socket, User) -> 
	receive
		{ text, Text } ->
			display(Socket, User, Text),
			sender(Socket, User);
		quit ->
			exit(closed);
		Other ->
			io:format("Unknown message in terminal ~p: ~p~n",
				[self(), Other]),
			sender(Socket, User)
	end.


receiver(Socket, User) ->
	Line = login:readline(Socket),
	io:format("Got line [~s]~n", [Line]),
	User ! parser:parse(Line),
	receiver(Socket, User).
	
display(Socket, User, Text) ->
	gen_tcp:send(Socket, Text),
	gen_tcp:send(Socket, "\n"),
	gen_tcp:send(Socket, prompt(User)),
	gen_tcp:send(Socket, [255,249]).


prompt(_User) ->
	"EMud> ".

reaper(Socket) -> 
	process_flag(trap_exit,true),
	receive
	{'EXIT', Parent, _Reason } -> 
		io:fwrite("Closing client ~p ~n", [Parent]),
		gen_tcp:close(Socket)
	end.
