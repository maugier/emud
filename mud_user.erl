-module(mud_user).
-author('Maxime Augier <max@xolus.net>').

-record(mud_user, { login, password }).


-export([init/0, create/2, login_ok/2, start/2]).


init() -> mnesia:create_table(mud_user, [{attributes, record_info(fields, mud_user)}]).

create(Login, Password) ->
	T = fun() ->
		mnesia:write(#mud_user{login=Login, password=Password})
	end,
	mnesia:transaction(T).

login_ok(Login, Password) ->
	{atomic, Res} = mnesia:transaction(fun() -> mnesia:read({mud_user, Login}) end),
	case Res of
		[] -> false;
		[User] ->
			string:equal(User#mud_user.password,Password)
	end.

start(User, Terminal) -> loop(User, Terminal).

loop(User, Terminal) ->
	receive
		quit ->
			Terminal ! { text, "Goodbye!" },
			exit(closing);
		error ->
			Terminal ! { text, "What ?" },
			loop(User, Terminal);
		{ say, _Text } ->
			Terminal ! { text, "says something..." },	
			loop(User, Terminal);
		{ input, Line } ->
			Terminal ! { text, Line },
			loop(User, Terminal);
		Other -> 
			io:fwrite("Unknown message: ~p~n",[Other]),
			loop(User, Terminal)
	end.
