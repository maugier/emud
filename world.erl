-module(world).

-export([info/1]).


info(motd) -> "Welcome to PoKeMuD !";
info(server_name) -> {color, red, "PoKeMuD"}.
