-module(login).
-author("Maxime Augier <max@xolus.net>").

-export([start/1]).

print(S,L) -> terminal:printline(S,L).
read(S) -> terminal:readline(S).

vsn_info() ->
	["Welcome to ", world:info(server_name), " running EMud v0.1 !\n"].

start(S) ->
	print(S,vsn_info()),
	print(S,"(enter \"new\" for new account)\nlogin: "),
	Login = read(S),
	case Login of 
		"new" -> new(S);
		_ -> pass(S,Login)
	end.

new(S) ->
	print(S,"Sorry, signups are closed for now. Try again later :)\n"),
	signup_closed.

pass(S,Login) ->
	print(S,"password: "),
	Pass = read(S),
	log:msg('INFO', "Login accepted for [~s/~s]",[Login,Pass]),
	nothing_to_do.

bye(Socket) ->
	log:msg('WARN',"Login rejected on ~p",[Socket]),
	gen_tcp:send(Socket, "Sorry, bad login\n"),
	incorrect_login.
