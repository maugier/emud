-module(terminal).
-author("Maxime Augier <max@xolus.net>").

-export([start/2]).


start(Socket, Login) ->
		spawn_link(fun () -> reaper(Socket) end),
		Self = self(),
		User = spawn_link(fun () -> mud_user:start(Login, Self) end),
		spawn_link(fun () -> receiver(Socket, User) end),
		io:format("Login accepted for [~s]~n",[Login]),
		self() ! { text, "Welcome to EMud 0.1 :)" },
		sender(Socket, User, default_prompt()).


sender(Socket, User, Prompt) -> 
	receive
		{ text, Text } ->
			display(Socket, Prompt, Text),
			sender(Socket, User, Prompt);
		{ prompt, Newprompt } ->
			sender(Socket, User, Newprompt);
		quit ->
			exit(closed);
		Other ->
			io:format("Unknown message in terminal ~p: ~p~n",
				[self(), Other]),
			sender(Socket, User, Prompt)
	end.


receiver(Socket, User) ->
	Line = login:readline(Socket),
	io:format("Got line [~s]~n", [Line]),
	User ! parser:parse(Line),
	receiver(Socket, User).
	
display(Socket, Prompt, Text) ->
	gen_tcp:send(Socket, format:parse([
		Text,
		"\n",
		Prompt,
		[255,249]
	])).


default_prompt() ->
	"EMud> ".

reaper(Socket) -> 
	process_flag(trap_exit,true),
	receive
	{'EXIT', Parent, _Reason } -> 
		io:fwrite("Closing client ~p ~n", [Parent]),
		gen_tcp:close(Socket)
	end.
