-module(parser).
-author("Maxime Augier <max@xolus.net>").
-export([parse/1]).

%debug
-export([split_first_keyword/1]).

parse(L) when is_list(L) -> rparse(L);
parse(B) when is_binary(B) -> rparse(binary_to_list(B)).


split_first_keyword(String) ->
	split_first_keyword(string:strip(String), []).

split_first_keyword([32|Tail],Acc) ->
	{ lists:reverse(Acc), string:strip(Tail) };

split_first_keyword([L|Tail],Acc) ->
	split_first_keyword(Tail, [L|Acc]).

rparse([$e,$c,$h,$o,32|Say]) -> { echo, Say };
rparse("quit") -> quit;
rparse("look") -> look;
rparse([$s,$a,$y,32|Say]) -> { say, Say };
rparse(_) -> error.

