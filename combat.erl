-module(combat).

-include("game.hrl").

-export([round/3]).

damage_modifier(Atk, Def) ->
	Delta = Atk - Def,
	if
		Delta < 10 -> -10;
		Delta > 10 -> +10;
		true -> Delta
	end.
	
element_modifier(Attack, Defender) ->
	case elements:modifier(
		Attack#attack.element,
		Defender#monster.element) of
	
		strong -> 2;
		normal -> 1;
		weak -> 0.5;
		immune -> 0
	end.


% round(Attacker, Defender, AttackName) -> { Outcome, AttackerState, DefenderState }
% Attackname = term()
% Attacker = Defender = fighting_monster()
% Outcome = kill|hit|miss

round(Attacker, Defender, AttackName) ->
	case hitchance(Attacker, Defender, AttackName) of
		miss -> { miss, Attacker, Defender };
		hit -> hit(Attacker, Defender, AttackName)
	end.


hitchance(Attacker, _Defender, _AttackName) ->
	Modifier = Attacker#monster.precision,
	case random:uniform(20) of
		19 -> miss;  % critical failure
		Die when Die > Modifier -> miss;
		_ -> hit
	end.


hit(Attacker, Defender, AttackName) ->
	Attack = attacks:get(AttackName),	
	Damage = (Attack#attack.power + damage_modifier(Attacker#monster.attack, 
					Defender#monster.defense)) 
					* element_modifier(Attack, Defender),
	
	CurrentLife = Defender#monster.life,

	case CurrentLife - Damage of
		N when N < 0 ->
			{ kill, Attacker, Defender#monster{life=0} };
		L ->
			{ hit, Attacker, Defender#monster{life=L} }
	end.
