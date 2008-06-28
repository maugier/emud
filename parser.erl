-module(parser).
-author("Maxime Augier <max@xolus.net>").
-export([parse/1]).


parse(Text) -> case Text of
	"quit" -> quit ;
	[115|[97|[121|[32|Say]]]] -> { say, Say };
	_ -> error
end.
