-module(mud_user).
-author('Maxime Augier <max@xolus.net>').

-record(mud_user, { login, password, room=default_room }).


-export([init/0, create/2, login_ok/2, start/2]).


init() -> mnesia:create_table(mud_user, [{attributes, record_info(fields, mud_user)}]).

create(Login, Password) ->
	T = fun() ->
		mnesia:write(#mud_user{login=Login, password=Password})
	end,
	mnesia:transaction(T).

get_user(Login) ->
	{atomic, Res} = mnesia:transaction(fun() -> mnesia:read({mud_user, Login}) end),
	case Res of
		[] -> error;
		[H] -> H
	end.

login_ok(Login, Password) ->
	case get_user(Login) of
		error -> false;
		User ->
			string:equal(User#mud_user.password,Password)
	end.

print(Terminal, Text) -> Terminal ! { text, Text }.

start(Login, Terminal) -> 
	User = get_user(Login),
	true = is_record(User, mud_user),
	User#mud_user.room ! { join, self(), User#mud_user.login },
	loop(User, Terminal).

loop(User, Terminal) ->
	receive
		quit ->
			print(Terminal,"Goodbye!"),
			User#mud_user.room ! { part, self(), User#mud_user.login },
			exit(closing);
		error ->
			print(Terminal,"What ?"),
			loop(User, Terminal);
		{ say, Text } ->
			User#mud_user.room ! { say, self(), User#mud_user.login, Text },
			loop(User, Terminal);
		{ said, _Pid, Pname, Text } ->
			print(Terminal, [Pname, " says: ", Text]),
			loop(User, Terminal);
		{ joined, Name } ->
			print(Terminal, [Name, " has joined."]),
			loop(User, Terminal);
		{ left, Name } ->
			print(Terminal, [Name, " has left."]),
			loop(User, Terminal);
		Other -> 
			io:fwrite("Unknown message: ~p~n",[Other]),
			loop(User, Terminal)
	end.
