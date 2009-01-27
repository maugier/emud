-module(char_db).
-author("Maxime Augier <max@xolus.net>").
-behaviour(gen_server).

-export([init/1, handle_call/3, terminate/2]).
-export([start_link/1, save/0, save/1, load/1, list/1, new/2]).

-record(character, { name, owner, room=default_room, team=[], objects=[] }).

-define(CHARS_FILE, "char_db.dat").

start_link(A) ->
	gen_server:start_link({local,?MODULE},?MODULE,A,[]).

init(_) ->
	case ets:file2tab(?CHARS_FILE) of
		{ok, Tab} ->
			log:msg('INFO',
			"Characters database loaded (~p accounts)",
			[ets:info(Tab,size)]),
			{ok, Tab};
		{error, {read_error,{file_error,_,enoent}}} ->
			log:msg('INFO',
			"No character file found. Creating new."),
			Tab = ets:new(account, [set,private,{keypos,2}]),
			{ok, Tab}
	end.


do_save(State) ->
	ets:tab2file(State,?CHARS_FILE).

handle_call(save,_From,State) ->
	do_save(State),
	{reply, ok, State};

handle_call({save,C},_From,State) ->
	{reply, ets:insert(State,C), State};

handle_call({load,Name},_From,State) ->
	R = case ets:lookup(State,Name) of
		[] -> { error, notfound };
		[C] -> { ok, C }
	end,
	{reply, R, State};

handle_call({list,Owner},_From,State) ->
	{reply, ets:match(State, #character{owner=Owner}), State}.


terminate(_Reason,State) ->
	do_save(State), ok.

save() -> gen_server:call(character,save).
save(C) -> gen_server:call(character, {save,C}).
load(Name) -> gen_server:call(character, {load, Name}).
list(Owner) -> gen_server:call(character, {list, Owner}).

new(Owner,Name) ->
	Char = #character{name=Name,owner=Owner},
	save(Char),
	Char.
