-module(format).

-export([parse/1]).

color(black) 	-> "1;30";
color(red) 	-> "1;31";
color(green) 	-> "1;32";
color(yellow) 	-> "1;33";
color(blue) 	-> "1;34";
color(magenta) 	-> "1;35";
color(cyan) 	-> "1;36";
color(white) 	-> "1;37";
color(normal)	-> "0".

ansi_escape(Code) -> [27, $[, Code, $m ].

parse({color, Color, Iolist}) -> [ansi_escape(color(Color)), Iolist, ansi_escape("0")];

parse(L) when is_list(L) -> lists:map(fun parse/1, L);
parse(Other) -> Other.
