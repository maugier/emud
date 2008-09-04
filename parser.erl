-module(parser).
-author("Maxime Augier <max@xolus.net>").
-export([parse/1]).

%debug
-export([split_first_keyword/1]).

parse(B) when is_binary(B) -> parse(binary_to_list(B));
parse(L) when is_list(L) -> rparse(string:strip(L)).

rparse([$.|Text]) -> { say, Text };
rparse([$:|Text]) -> { groupsay, Text };
rparse([$!|Cmd]) -> { command, Cmd };
rparse(String) -> case split_first_keyword(String) of
	{ tell, Rest } -> 
		{ To, Msg } = split_first_keyword(Rest),
		{ tell, To, Msg };
	Other -> Other
end.


split_first_keyword(String) ->
	split_first_keyword(String, []).

split_first_keyword([32|Tail],Acc) ->
	try 
	{ list_to_existing_atom(lists:reverse(Acc)), string:strip(Tail) }
	catch badarg -> unknown end;

split_first_keyword([L|Tail],Acc) ->
	split_first_keyword(Tail, [L|Acc]).


