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
                play(lists:nth(Int,Clist))
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
	case char_db:new(AcName, Name) of
        {error, already_exists} ->
            print("Sorry, that character name already exists"),
            start(Account);
        ok -> play(Name)
    end.   

%play(Name) ->
%	print("Sorry, play not implemented :)\n"),
%	play_not_implemented.

play(Name) ->
	case character:start_link(Name) of
				{ok, Pid} ->
                	prompt:interact(Pid);
				{error,{already_started,Pid}} ->
                    case character:attach(Pid) of
                        ok -> prompt:interact(Pid);
                        {error, attached} ->
					        print("Sorry, this character is already connected\n")
                    end
                            
	end.

