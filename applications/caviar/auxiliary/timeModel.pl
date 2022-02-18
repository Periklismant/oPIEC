%assertFirstTimepoint:-
%	assertz(firstTimepoint(1443650401)).
firstTimepoint(0).
nextTimepoint(T, Tnext):-
	Tnext is T+40.
prevTimepoint(T, Tprev):-
	Tprev is T-40.