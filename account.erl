-module(account).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
	code_change/3]).

-export([start_link/1]).

-record(account, { user, pass, level, chars }).

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
			"No database found,"),
			Tab = ets:new(account, [set,private]),
			{ok, Tab}
	end.

do_save(Tab) ->
	ok = ets:tab2file(Tab, ?ACCOUNT_FILE),
	log:msg('INFO',"Account database saved.").

handle_cast(save, Tab) ->
	do_save(Tab),
	{noreply, Tab}.


handle_call(R,F,Tab) -> {reply, {error, notimpl}, Tab}.

handle_info(_,Tab) -> {noreply, Tab}.

terminate(_Ex,Tab) -> 
	do_save(Tab),
	ok.

code_change(_Old,St,_Ex) -> { ok, St }.


save() -> gen_server:cast(account, save).
