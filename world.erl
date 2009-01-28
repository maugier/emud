-module(world).

-export([info/1]).

info(motd) -> "Welcome to PoKeMuD !";
info(server_name) -> "PoKeMuD";
info(banner) -> ["Welcome to ", {color,red,"PoKeMuD"}, ", the ",
"experimental Erlang MUD !\n"];
info(version) -> "1.0";
% Open signups ?
info(signup) -> true.
