-module(monster).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, { monster, adversary=nobody, mods=[] }).


init(Monster) -> {ok, #state{monster=Monster}}.


handle_cast({ set_adversary, Pid }, State) ->
	{ noreply, State#state{adversary=Pid}}.

handle_cast({ do_attack, 
