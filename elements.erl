-module(elements).
-export([modifier/2, color/1, show/1]).

show(E) -> { color, color(E), atom_to_list(E) }.

% elements(Attack, Defense) -> strong|normal|weak|immune
modifier(water, plant) -> weak;
modifier(water, fire) -> strong;
modifier(fire, plant) -> strong;
modifier(plant, fire) -> weak;
modifier(insect, plant) -> strong;
modifier(flying, insect) -> strong;
modifier(ground, flying) -> immune;

modifier(E,E) -> weak;
modifier(_,_) -> normal.

color(water) -> cyan;
color(fire) -> red;
color(plant) -> green;
color(ground) -> yellow;
color(poison) -> magenta;
color(ice) -> white;
color(_) -> normal.
