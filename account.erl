-module(account).
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
	code_change/3]).

-record(account, { user, pass, level, chars }).

-define(ACCOUNT_FILE, "account.dat").

init(_) -> 
	case ets:file2tab(?ACCOUNT_FILE) of
		{ok, Tab} ->
			{ok, Tab};
		{error,{read_error,{file_error,_,enoent}}} ->
			Tab = ets:new(account, [set,private]),
			{ok, Tab}
	end.

save(Tab) ->
	ok = ets:tab2file(Tab, ?ACCOUNT_FILE).

handle_cast(save, Tab) ->
	save(Tab),
	{noreply, Tab}.


handle_call(R,F,Tab) -> {reply, {error, notimpl}, Tab}.

handle_info(_,Tab) -> {noreply, Tab}.

terminate(_Ex,Tab) -> 
	save(Tab),
	ok.

code_change(_Old,St,_Ex) -> { ok, St }.
