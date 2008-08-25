-module(parser).
-author("Maxime Augier <max@xolus.net>").
-export([parse/1]).

parse(L) when is_list(L) -> rparse(L);
parse(B) when is_binary(B) -> rparse(binary_to_list(B)).

rparse("quit") -> quit;
rparse("look") -> look;
rparse([115,97,121,32|Say]) -> { say, Say };
rparse(_) -> error.


