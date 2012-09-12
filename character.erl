-module(character).
-author("Maxime Augier <max@xolus.net>").

-behaviour(gen_server).

-include("game.hrl").

-export([init/1, handle_call/3, handle_cast/2, 
handle_info/2, terminate/2, code_change/3]).

-export([start_link/1, is_running/1]).

start_link(Name) ->
	Ctrl = self(),
	gen_server:start_link({global, {character, Name}}, 
		?MODULE, {Name,Ctrl}, []).
	
is_running(Name) ->
	case global:whereis_name({character,Name}) of
		undefined -> false;
		_Pid -> true
	end.


init({Name,Ctrl}) ->
    process_flag(trap_exit, true),
	log:msg('DEBUG', "Character [~s] starting", [Name]),
	{ok, Char} = char_db:load(Name),
	pg2:join(all_characters, self()),
	{joined, R} = room:call(Char#character.room, join),
	show_room(Ctrl,R),
	{ok, {Char, Ctrl}}.

handle_call({get,name}, _From, S={Char,_}) ->
	{reply, Char#character.name, S}.

% DANGER - risk of deadlock here !
handle_cast({say, From, Text}, {Char,Ctrl}) ->
	FromName = case self() of
		From -> {color, green, Char#character.name};
		_    -> {color, blue, gen_server:call(From,{get,name})}
	end,
	send(Ctrl,{display, [FromName, " says: ", {color, blue, Text}]}),
	{noreply, {Char,Ctrl}};

handle_cast({join,R},S={_,Ctrl}) ->
	show_room(Ctrl,R),
	{reply, S};

handle_cast({attach,Ctrl},{Chr,linkdead}) ->
    {noreply, {Chr,Ctrl}};

handle_cast(shutdown,S) -> 
	{stop, shutdown, S}.

handle_info({'EXIT', Ctl, Reason}, {Chr,Ctl}) ->
    log:msg('INFO', "Character [~s] terminal error: ~p", [Chr,Reason]),
    % Going link-dead
    {noreply, {Chr,linkdead}};

handle_info({input,Cmd},{Chr,Ctl}) ->
	%log:msg('DEBUG',"Got message: ~p",[Cmd]),
	case Cmd of 
		{say, Text} ->
			room:cast(Chr#character.room, 
			{ roomcast, { say, self(), Text }});
		_ -> send(Ctl,{display, "What ?"})
	end,
	{noreply, {Chr,Ctl}}.

terminate(Reason, {Char,_}) ->
	room:call(Char#character.room, leave),
	log:msg('DEBUG', "Character [~s] terminating: ~p",
		[Char#character.name, Reason]),
	char_db:save(Char).

code_change(_O,S,_E) ->
        {ok, S}.

send(Pid,Msg) when is_pid(Pid) -> Pid ! Msg;
send(_,Msg) -> Msg.

show_room(Ctrl,R) ->
	send(Ctrl, { display, ["Welcome to ", {color, green, R#room.description}]}).

