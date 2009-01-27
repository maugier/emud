-module(menu).
-export([start/1]).

-include("game.hrl").

print(P) -> terminal:print(P).
read() -> terminal:read().

start(Account) ->
	print(["--==[ ",world:info(server_name)," ]==--\n",
	CL = char_db:list(Account),
	world:info(banner),"Pick your character: \n", charlist(CL)]),
	Char = read(),
	case Char of 
		"n" -> create_char(Account);
		_ -> print("What?\n"), start(Account)
	end.

charlist(CL) ->
	["\n" , charlist(CL,1)].
charlist([],_) ->
	"\n  (n) <NEW>\n\n".
charlist([C|CL], N) ->
	["  (",N,") ", C#character.name, "\n" | charlist(CL,N+1) ].

create_char(Account) ->
	log:msg('INFO', "[~s] creating a character",
		[account:get(Account,user)]).

