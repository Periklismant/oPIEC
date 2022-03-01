processTimepoint(1):-
	assertz((person(chris))),
	assertz((0.8::happensAt(win_lottery(chris), 1))).

processTimepoint(2):-
	assertz((person(chris))),
	assertz((0.6::happensAt(go_to(chris, pub), 2))).

processTimepoint(3):-
	assertz((person(chris))),
	assertz((0.4::happensAt(go_to(chris, pub), 3))).

processTimepoint(4):-
	assertz((person(chris))),
	assertz((0.2::happensAt(win_lottery(chris), 4))).

lastTimepoint(5).