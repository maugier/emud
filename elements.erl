-module(elements).
-export([modifier/2]).

% elements(Attack, Defense) -> strong|normal|weak|immune
modifier(water, plant) -> weak;
modifier(water, fire) -> strong;
modifier(fire, plant) -> strong;
modifier(plant, fire) -> weak;

modifier(_,_) -> normal.
