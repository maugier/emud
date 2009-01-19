-module(commands).

-export([default_context/1]).

% Context: list of possible commands


default_context([]) -> [ echo, say, quit, test ];
default_context([quit]) -> ['END'];
default_context(_) -> [].
