%assertFirstTimepoint:-
%	assertz(firstTimepoint(1443650401)).
firstTimepoint(1443650401).
nextTimepoint(T, Tnext):-
	Tnext is T+1.
prevTimepoint(T, Tprev):-
	Tprev is T-1.