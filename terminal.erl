-module(terminal).
-author("Maxime Augier <max@xolus.net>").

-export([read/0, read/1, print/1, print/2]).
-export([start_client/1]).

read() -> read(get(emud_socket)).
read(Socket) ->
        {ok, Packet} = gen_tcp:recv(Socket, 0),
	lists:delete(13, lists:delete(10, Packet)).  % remove CR & LF

print(Line) -> print(get(emud_socket),Line).
print(Socket, Line) ->
	gen_tcp:send(Socket, format:parse(Line)).




start_client(Socket) ->
		Self = self(),
		User = spawn_link(fun () -> mud_user:start(Self) end),
		spawn_link(fun () -> receiver(Socket, User) end),
		log:msg('INFO', "Login accepted for [~s]",["prout"]),
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
			closed;
		Other ->
			log:msg('DEBUG', "Unknown message in terminal ~p: ~p",
				[self(), Other]),
			sender(Socket, User, Prompt)
	end.


receiver(Socket, User) ->
	Line = login:readline(Socket),
	User ! { user_input, parser:parse(Line) },
	receiver(Socket, User).
	
display(Socket, Prompt, Text) ->
	gen_tcp:send(Socket, format:parse([
		Text,
		"\n",
		Prompt,
		[255,249]
	])).


default_prompt() ->
	[{color, red, "E"},
	 {color, blue, "Mud"},
	 "> "].

