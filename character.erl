-module(character).
-author('Maxime Augier <max@xolus.net>').

-record(character, { name, room=default_room, team=[] }).

-export([init/0, create/1, start/2]).


init() -> mnesia:create_table(character, [{attributes, record_info(fields, character)}]).

create(Login) ->
	T = fun() ->
		mnesia:write(#character{name=Login})
	end,
	mnesia:transaction(T).

get_character(Login) ->
	{atomic, Res} = mnesia:transaction(fun() -> mnesia:read({character, Login}) end),
	case Res of
		[] -> error;
		[H] -> H
	end.


print(Terminal, Text) -> Terminal ! { text, Text }.

start(Login, Terminal) -> 
	User = get_character(Login),
	true = is_record(User, character),
	User#character.room ! { join, self(), User#character.name },
	loop(User, Terminal).

loop(User, Terminal) ->
	receive
		quit ->
			log:msg('INFO',"Character ~s logging out",[User#character.name]),
			print(Terminal,"Goodbye!"),
			User#character.room ! { part, self(), User#character.name },
			exit(closing);
		error ->
			print(Terminal,"What ?"),
			loop(User, Terminal);

		look ->
			print(Terminal, "Looking!"),
			User#character.room ! { look, self() },
			loop(User, Terminal);

		{ look, Pid } ->
			Pid ! { see, [ User#character.name, " is standing here."] },
			loop(User, Terminal);

		{ see, Text } -> 
			print(Terminal, Text),
			loop(User, Terminal);

		{ say, Text } ->
			User#character.room ! { say, self(), User#character.name, Text },
			loop(User, Terminal);
		{ move, Room } ->
			User#character.room ! { part, self(), User#character.name },
			Room ! { join, self(), User#character.name },
			loop(User#character{room=Room}, Terminal);
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
