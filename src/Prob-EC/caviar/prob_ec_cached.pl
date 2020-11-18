holdsAt(F=V,T):-
  simpleFluent(F),
  cached(holdsAt(F = V)),
  previousTimePoint(T, Tprev),
  \+ broken(F = V, Tprev).

holdsAt(F=V,T):-
  simpleFluent(F),
  previousTimePoint(T, Tprev),
  initiatedAt(F = V,Tprev).

broken(F = V1, T) :-
  initiatedAt(F=V2,T), 
  V1 \= V2.

previousTimePoint(T, Tprev):- Tprev is T - 40.
