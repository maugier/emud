-module(menu).
-export([start/1]).

-include("game.hrl").
-export([charlist/1]).

print(P) -> terminal:print(P).
print_prompt(L,P) -> terminal:print_prompt(L,P).
read() -> terminal:read().

start(Account) ->
	Clist = char_db:list(account:get(Account,user)),
	print_prompt(["--==[ ",settings:info(server_name)," ]==--\n",
		settings:info(banner),
		"Pick your character: \n",
		charlist(Clist)], "> "),
	Char = read(),
	case Char of 
		"n" -> create_char(Account);
		Num -> case string:to_integer(Num) of
			
			{error,_} ->	print("What?\n"),
					start(Account);
			{Int,_}   ->   
				case character:start_link(
				lists:nth(Int,Clist)) of
				{ok, Pid} ->
					play(Pid);
				{error,{already_started,_}} ->
					print("Sorry, this character is already connected\n"),
					start(Account)
				end
		end
	end.

charlist([]) ->
	["You have no characters !\n", charlist([],0)];
charlist(CL) ->
	["\n" , charlist(CL,1)].
charlist([],_) ->
	"\n  (n) <NEW>\n\n";
charlist([C|CL], N) ->
	Color = case character:is_running(C) of
		true -> red;
		false -> green
	end,
	[{color, Color, ["  (",io_lib:format("~w",[N]),") ", C]}, "\n" | charlist(CL,N+1) ].

create_char(Account) ->
	print_prompt("What is the name of your new character ?", "name:"),
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

%play(Name) ->
%	print("Sorry, play not implemented :)\n"),
%	play_not_implemented.

play(Pid) ->
	link(Pid),
	prompt:interact(Pid).
