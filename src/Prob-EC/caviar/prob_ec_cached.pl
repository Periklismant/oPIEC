
simpleFluent(meeting(_ID1,_ID2)).
simpleFluent(fighting(_ID1,_ID2)).
simpleFluent(moving(_ID1,_ID2)).
simpleFluent(leaving_object(_ID1,_ID2)).

holdsAt(F=V,T):-
  simpleFluent(F),
  cached(holdsAt(F = V)),
  previousTimePoint(T, Tprev),
  \+ broken(F = V, Tprev). % crisp version contains a cut here

holdsAt(F=V,T):-
  simpleFluent(F),
  previousTimePoint(T, Tprev),
  initiatedAt(F = V,Tprev).

%:-dynamic broken/2.

broken(F = V1, T) :-
  initiatedAt(F=V2,T),  % Ts < Tstar < T
  V1 \= V2.

%:- problog_table broken/2.

previousTimePoint(T, Tprev):- Tprev is T - 40.

% negate2.

%negate2(Pred):- problog_neg(Pred).

%negate2(Pred):- \+ Pred.
