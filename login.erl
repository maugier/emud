-module(login).
-author("Maxime Augier <max@xolus.net>").

-export([start/1]).

print(L) -> terminal:print(L).
read() -> terminal:read().

vsn_info() ->
	["Welcome to ", world:info(server_name), " running EMud v0.1 !\n"].

start(S) ->
	terminal:init(S),
	print(vsn_info()),
	print("(enter \"new\" for new account)\nlogin: "),
	Login = read(),
	case Login of 
		"new" -> new();
		_ -> pass(Login)
	end.

new() ->
	case world:info(signup) of false ->
		print(["Sorry, signups are closed for now.\n",
		"Try again later :)\n"]),
		signup_closed;

	_ -> 
		print("Desired username: "),
		User = read(),

		case User of "" -> 
			print("No account ? ok, quitting.\n"),
			no_account;

		_ -> case account:exists(User) of true ->
			print("Sorry, already taken !\n"),
			new();
		_ -> 
			print("Password: "),
			Pass = read(),
			account:new(User,Pass,user),
			{ok, Acc} = account:login(User,Pass),
			menu:start(Acc)
		end 
	end 
end.


pass(Login) ->
	print("password: "),
	Pass = read(),
	case account:login(Login,Pass) of
		{error, login_failed} ->
			print("Login incorrect.\n"),
			login_incorrect;
		{ok, Account} ->
			log:msg('INFO', "Login accepted for [~s] from [~p]",
			[Login, terminal:info(peer)]),
			menu:start(Account)
	end.
