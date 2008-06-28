-module(login).
-author("Maxime Augier <max@xolus.net>").

-export([login/1, readline/1]).


readline(Socket) ->
	{ok, Packet} = gen_tcp:recv(Socket, 0),
	lists:delete(13, lists:delete(10, Packet)).  % remove CR & LF
		

login(Socket) ->
	gen_tcp:send(Socket, "login: "),
	User = readline(Socket),
	case User of 
	 %"new" -> create_user(Socket);
	     _ -> gen_tcp:send(Socket, "password: "),
		  Password = readline(Socket),
		  io:format("Login [~s] pass [~s]~n", [User, Password]),
		  case mud_user:login_ok(User, Password) of
		  	false -> bye(Socket);
			true -> terminal:start(Socket, User)
		  end
	end.

bye(Socket) ->
	io:fwrite("Login rejected on ~p~n",[Socket]),
	gen_tcp:send(Socket, "Sorry, bad login\n"),
	gen_tcp:close(Socket).
