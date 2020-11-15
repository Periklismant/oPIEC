sdFluent(anchoredOrMoored(_)).
sdFluent(loitering(_)).
sdFluent(underway(_)).
sdFluent(rendezVous(_, _)).
sdFluent(pilotBoarding(_, _)).
sdFluent(tugging(_, _)).

holdsAt(F=V,T):-
  \+ sdFluent(F),
  cached(holdsAt(F=V)),
  Tprev is T - 1,
  \+ broken(F=V, Tprev).

holdsAt(F=V,T):-
  \+ sdFluent(F),
  Tprev is T - 1,
  initiatedAt(F=V,Tprev).

broken(F=V1, T):-
  initiatedAt(F=V2,T),
  V1 \= V2.