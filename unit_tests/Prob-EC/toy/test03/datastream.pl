processTimepoint(1):-
	assertz((person(chris))),
	assertz((0.8::happensAt(win_lottery(chris), 1))).

processTimepoint(2):-
	assertz((person(chris))),
	assertz((0.6::happensAt(go_to(chris, pub), 2))).

processTimepoint(3):-
	assertz((person(chris))),
	assertz((0.4::happensAt(lose_wallet(chris), 3))).

processTimepoint(4):-
	assertz((person(chris))),
	assertz((0.2::happensAt(go_to(chris, home), 4))).

lastTimepoint(5).