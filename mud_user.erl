-module(mud_user).
-author('Maxime Augier <max@xolus.net>').

-record(mud_user, { login, password, level, chars=[] }).

-export([init/0, create/3, login_ok/2, start/2]).


init() -> mnesia:create_table(mud_user, [{attributes, record_info(fields, mud_user)}]).

create(Login, Password, Level) ->
	T = fun() ->
		mnesia:write(#mud_user{login=Login, password=Password, level=Level})
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

start(Login, Terminal) -> 
	User = get_user(Login),
	true = is_record(User, mud_user),
	Terminal ! { prompt, user_prompt(User) },
	Terminal ! { text, ["You are connected as ", {color, user_color(User), User#mud_user.login}, "\n"] },
	loop(User, Terminal).

loop(User, Terminal) -> receive

	{ user_input, Command } ->
		Terminal ! { text, ["You sent me: ", io_lib:format("~p", Command)] },
		loop(User, Terminal);

	_ -> loop(User, Terminal) 
end.

user_prompt(User) -> case User#mud_user.level of
	admin -> { color, red, [User#mud_user.login, "#"]};
	_ -> { color, green, [User#mud_user.login, ">"]}
end.

user_color(#mud_user{level=admin}) -> red;
user_color(#mud_user{level=user}) -> green.


