processTimepoint(1):-
	assertz((person(chris))),
	assertz((0.5::happensAt(win_lottery(chris), 1))).

processTimepoint(2):-
	assertz((person(chris))),
	assertz((0.5::happensAt(win_lottery(chris), 2))).

processTimepoint(3):-
	assertz((person(chris))),
	assertz((0.5::happensAt(lose_wallet(chris), 3))).

processTimepoint(4):-
	assertz((person(chris))),
	assertz((0.5::happensAt(win_lottery(chris), 4))).

lastTimepoint(5).