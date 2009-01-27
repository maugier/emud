-module(account).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
	code_change/3]).

-export([start_link/1, save/0, new/3, login/2, get/2, exists/1]).

-record(account, { user, pass, level }).

-define(ACCOUNT_FILE, "account.dat").

start_link(A) ->
	gen_server:start_link({local,account},?MODULE,A,[]).

init(_) -> 
	case ets:file2tab(?ACCOUNT_FILE) of
		{ok, Tab} ->
			log:msg('INFO', 
			"Account database loaded (~p accounts)",
			[ets:info(Tab,size)]),
			{ok, Tab};
		{error,{read_error,{file_error,_,enoent}}} ->
			log:msg('INFO',
			"No database found, you must create accounts !"),
			Tab = ets:new(account, [set,private,{keypos,2}]),
			{ok, Tab}
	end.

do_save(Tab) ->
	ok = ets:tab2file(Tab, ?ACCOUNT_FILE),
	log:msg('INFO',"Account database saved.").

handle_cast(save, Tab) ->
	do_save(Tab),
	{noreply, Tab}.


handle_call({new,Log,Pass,Lvl}, _From, Tab) ->

	Res = ets:insert_new(Tab, 
			#account{ user=Log, pass=Pass, level=Lvl}),
	do_save(Tab),
	{ reply, Res, Tab };

handle_call({login,Log,Pass}, _From, Tab) ->
	case ets:lookup(Tab,Log) of
		[Acc = #account{pass=Pass}] -> { reply, { ok, Acc }, Tab };
		_ -> { reply, { error, login_failed }, Tab }
	end;
	
handle_call({exists,Log},_From, Tab) ->
	{ reply, ets:member(Tab,Log), Tab };

handle_call(_,_,Tab) -> {reply, {error, notimpl}, Tab}.

handle_info(_,Tab) -> {noreply, Tab}.

terminate(_Ex,Tab) -> 
	do_save(Tab),
	ok.

code_change(_Old,St,_Ex) -> { ok, St }.


save() -> gen_server:cast(account, save).

new(Login, Pass, Level) ->
	case gen_server:call(account, {new, Login, Pass, Level}) of
		true -> ok;
		false -> { error, exists, Login }
	end.

login(Log,Pass) ->
	gen_server:call(account, {login, Log, Pass}).

exists(Log) -> gen_server:call(account, {exists, Log}).

get(#account{user=N},user) -> N.
