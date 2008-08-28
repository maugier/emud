-module(parser).
-author("Maxime Augier <max@xolus.net>").
-export([parse/1]).

parse(L) when is_list(L) -> rparse(L);
parse(B) when is_binary(B) -> rparse(binary_to_list(B)).

rparse([$e,$c,$h,$o,32|Say]) -> { echo, Say };
rparse("quit") -> quit;
rparse("look") -> look;
rparse([$s,$a,$y,32|Say]) -> { say, Say };
rparse(_) -> error.


