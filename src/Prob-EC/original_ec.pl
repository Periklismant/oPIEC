holdsAt(F=V,T):-
  \+ isSDFluent(F),
  T>1443650400,
  %debugprint('Inertia: ', F=V, ' ', T), nl,
  prevTimepoint(T, Tprev),
  holdsAt(F=V, Tprev),
  \+ broken(F=V, Tprev).

holdsAt(F=V,T):-
  \+ isSDFluent(F),
  T>1443650400,
  %debugprint('Initiation: ', F=V, ' ', T), nl,
  %write('Initiation: '), write(F=V), write(' '), write(T), nl,
  prevTimepoint(T, Tprev),
  initiatedAt(F=V,Tprev).

broken(F=V1, T):-
  initiatedAt(F=V2,T),
  V1 \= V2.