-module(ui).
-include("game.hrl").

-export([monster/1]).

print_int(Int) -> io_lib:fwrite("~w", [Int]).

monster(M) -> [
		"-=[ ", atom_to_list(M#monster.name), " ]=-\n",
		"Element: ", elements:show(M#monster.element), "\n",
		"Attack: ", {color, white, print_int(M#monster.attack)}, "\n",
		"Defense: ", {color, white, print_int(M#monster.defense)}, "\n"
		].
