-module(login).
-author("Maxime Augier <max@xolus.net>").

-export([start/1]).

print(L) -> terminal:print(L).
read() -> terminal:read().

vsn_info() ->
	["Welcome to ", world:info(server_name), " running EMud v0.1 !\n"].

start(_S) ->
	print(vsn_info()),
	print("(enter \"new\" for new account)\nlogin: "),
	Login = read(),
	case Login of 
		"new" -> new();
		_ -> pass(Login)
	end.

new() ->
	print("Sorry, signups are closed for now. Try again later :)\n"),
	signup_closed.

pass(Login) ->
	print("password: "),
	Pass = read(),
	log:msg('INFO', "Login accepted for [~s/~s]",[Login,Pass]),
	nothing_to_do.
