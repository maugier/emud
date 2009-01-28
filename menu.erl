-module(menu).
-export([start/1]).

-include("game.hrl").
-export([charlist/1]).

print(P) -> terminal:print(P).
read() -> terminal:read().

start(Account) ->
	Clist = char_db:list(account:get(Account,user)),
	print(["--==[ ",world:info(server_name)," ]==--\n",
		world:info(banner),
		"Pick your character: \n",
		charlist(Clist)]),
	Char = read(),
	case Char of 
		"n" -> create_char(Account);
		_ -> print("What?\n"), start(Account)
	end.

charlist([]) ->
	["You have no characters !\n", charlist([],0)];
charlist(CL) ->
	["\n" , charlist(CL,1)].
charlist([],_) ->
	"\n  (n) <NEW>\n\n";
charlist([C|CL], N) ->
	["  (",io_lib:format("~w",[N]),") ", C, "\n" | charlist(CL,N+1) ].

create_char(Account) ->
	print("What is the name of your new character ?\nname: "),
	CharName = read(),
	case char_db:call({exists, CharName}) of
		true -> 
			print("Sorry, name exists already.\n"),
			create_char(Account);
		_ -> create_char(Account, CharName)
	end.

create_char(Account, Name) ->
	AcName = account:get(Account,user),
	char_db:new(AcName, Name),
	play(Name).

play(Name) ->
	print("Sorry, play not implemented :)\n"),
	play_not_implemented.

