holdsAt(F=V,T):-
  \+ sdFluent(F),
  cached(holdsAt(F=V)),
  prevTimepoint(T, Tprev),
  \+ broken(F=V, Tprev).

holdsAt(F=V,T):-
  \+ sdFluent(F),
  prevTimepoint(T, Tprev),
  initiatedAt(F=V,Tprev).

broken(F=V1, T):-
  initiatedAt(F=V2,T),
  V1 \= V2.