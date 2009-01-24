-module(menu).
-export([start/1]).

print(P) -> terminal:print(P).
read() -> terminal:read().

start(Account) ->
	print(["--==[ ",world:info(server_name)," ]==--\n",
	world:info(banner),"Pick your character: \n", charlist()]),
	Char = read(),
	case Char of 
		"n" -> create_char(Account);
		_ -> print("What?\n"), start(Account)
	end.

charlist() -> [
	"\n",
	"  (1) Chouddledi\n",
	"  (2) Chouddledum\n",
	"  \n",
	"  (n) <NEW>\n\n *>"].

create_char(Account) ->
	log:msg('INFO', "[~s] creating a character",
		[account:get(Account,user)]).

