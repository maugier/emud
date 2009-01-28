-module(char_db).
-author("Maxime Augier <max@xolus.net>").
-behaviour(gen_server).

-include("game.hrl").

-export([init/1, handle_call/3, terminate/2]).
-export([call/1]).
-export([start_link/1, save/0, save/1, load/1, list/1, new/2, list/0]).

-define(CHARS_FILE, "char_db.dat").

start_link(A) ->
	gen_server:start_link({local,?MODULE},?MODULE,A,[]).

init(_) ->
	case ets:file2tab(?CHARS_FILE) of
		{ok, Tab} ->
			log:msg('INFO',
			"Characters database loaded (~p chars)",
			[ets:info(Tab,size)]),
			{ok, Tab};
		{error, {read_error,{file_error,_,enoent}}} ->
			log:msg('INFO',
			"No character file found. Creating new."),
			Tab = ets:new(?MODULE, [set,private,{keypos,2}]),
			{ok, Tab}
	end.


do_save(State) ->
	ets:tab2file(State,?CHARS_FILE).

handle_call({exists,Name},_From, State) ->
	{ reply, 
		case ets:lookup(State, Name) of
			[] -> false;
			_ -> true
		end,
	  State };

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

handle_call(list,_From,State) ->
	{reply, ets:tab2list(State), State};

handle_call({list,Owner},_From,State) ->
	{reply, lists:concat(
		ets:match(State, #character{name='$1', owner=Owner}))
	, State}.


terminate(_Reason,State) ->
	do_save(State), ok.

save() -> gen_server:call(?MODULE,save).
save(C) -> gen_server:call(?MODULE, {save,C}).
load(Name) -> gen_server:call(?MODULE, {load, Name}).
list(Owner) -> gen_server:call(?MODULE, {list, Owner}).
list() -> gen_server:call(?MODULE, list).


call(Msg) -> gen_server:call(?MODULE, Msg).

new(Owner,Name) ->
	Char = #character{name=Name,owner=Owner},
	save(Char),
	log:msg('NOTICE',"[~s] created character [~s]", [Name, Owner]),
	Char.
