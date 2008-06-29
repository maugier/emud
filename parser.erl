-module(parser).
-author("Maxime Augier <max@xolus.net>").
-export([parse/1]).


parse("quit") -> quit;
parse("look") -> look;
parse([115,97,121,32|Say]) -> { say, Say };
parse(_) -> error.


