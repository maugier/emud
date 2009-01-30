-module(login).
-author("Maxime Augier <max@xolus.net>").

-export([start/1]).

print(L) -> terminal:print(L).
print_prompt(L,P) -> terminal:print_prompt(L,P).
read() -> terminal:read().

vsn_info() ->
	["Welcome to ", settings:info(server_name), " running EMud v0.1 !\n"].

start(S) ->
	terminal:init(S),
	print(vsn_info()),
	print_prompt("(enter \"new\" for new account)","login: "),
	Login = read(),
	case Login of 
		"new" -> new();
		_ -> pass(Login)
	end.

new() ->
	case settings:info(signup) of false ->
		print(["Sorry, signups are closed for now.\n",
		"Try again later :)\n"]),
		signup_closed;

	_ -> 
		print_prompt("","Desired username: "),
		User = read(),

		case User of "" -> 
			print("No account ? ok, quitting.\n"),
			no_account;

		_ -> case account:exists(User) of true ->
			print("Sorry, already taken !\n"),
			new();
		_ -> 
			print_prompt("","Password: "),
			Pass = read(),
			account:new(User,Pass,user),
			{ok, Acc} = account:login(User,Pass),
			menu:start(Acc)
		end 
	end 
end.


pass(Login) ->
	print_prompt("","password: "),
	Pass = read(),
	case account:login(Login,Pass) of
		{error, login_failed} ->
			print("Login incorrect.\n"),
			login_incorrect;
		{ok, Account} ->
			log:msg('INFO', "Login accepted for [~s] from [~p]",
			[Login, terminal:info(peer)]),
			case (catch menu:start(Account)) of
				shutdown -> ok;
				ok -> ok;
				R -> 	print(["===ERROR===\n",
					io_lib:format("~p",[R])]),
					throw(R)
			end
	end.
