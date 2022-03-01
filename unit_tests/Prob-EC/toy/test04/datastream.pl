processTimepoint(1):-
	assertz((person(bob))),
	assertz((0.4::happensAt(win_lottery(bob), 1))).

processTimepoint(2):-
	assertz((person(alice))),
	assertz((0.8::happensAt(lose_wallet(alice), 2))),
	assertz((0.6::happensAt(go_to(alice, pub), 2))).

processTimepoint(3):-
	assertz((person(bob))),
	assertz((0.2::happensAt(lose_wallet(bob), 3))).

processTimepoint(4):-
	assertz((person(bob))),
	assertz((person(alice))),
	assertz((0.6::happensAt(win_lottery(alice), 4))),
	assertz((1::happensAt(go_to(bob, pub), 4))).

processTimepoint(5):-
	assertz((person(bob))),
	assertz((0.2::happensAt(go_to(bob, home), 5))).

processTimepoint(6):-
	assertz((person(bob))),
	assertz((person(alice))),
	assertz((0.2::happensAt(lose_wallet(alice), 6))),
	assertz((0.4::happensAt(lose_wallet(bob), 6))).

lastTimepoint(7).