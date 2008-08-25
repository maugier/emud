-module(combat).

-include("game.hrl").

-export([round/3]).

damage_modifier(Atk, Def, Dmg) ->
	Delta = Atk - Def,
	if
		Delta < 10 -> Dmg - 10;
		Delta > 10 -> Dmg + 10;
		_ -> Dmg + Delta
	end.
	
element_modifier(Attack, Defender) ->
	case elements:modifier(
		Attack#attack.element,
		Defender#monster.element) of
	
		strong -> 2;
		normal -> 1;
		weak -> 0.5;
		immune -> 0;
	end.


% round(Attacker, Defender, AttackName) -> { Outcome, AttackerState, DefenderState }
% Attackname = term()
% Attacker = Defender = fighting_monster()

round(Attacker, Defender, AttackName) ->
	Attack = attacks:get(AttackName),	
	Damage = (Attack#attack.power + damage_modifier(Attacker#monster.attack, 
					Defender#monster.defense)) 
					* element_modifier(Attack, Defender),
	

	
	{ hit, Attacker, Defender#monster 
