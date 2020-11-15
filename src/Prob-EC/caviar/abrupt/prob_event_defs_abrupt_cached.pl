/******************************************************************
 * LONG-TERM BEHAVIOURS						  *
 * meeting(Person1, Person2)					  *
,* fighting(Person1, Person2)					  *
 * moving(Person1, Person2)					  *
 * leaving-object(Person1, Person2)				  *		  			  *								  *
 *								  *
 * SHORT-TERM BEHAVIOURS					  *
 * walking, active, inactive, running, abrupt				  *
 ******************************************************************/

/******************************************************************
 * STATICALLY DETERMINED FLUENTS				  *
 * close(Person, Painting)					  *
 ******************************************************************/


% ===== COORDINATES OF PLACES OF INTEREST

place(shop1).
place(shop2).
place(shop3).

holdsAt( coord( shop1 )=(86, 205), _ ).
holdsAt( coord( shop2 )=(101, 260), _ ).
holdsAt( coord( shop3 )=(181, 51), _ ).

% ===== STATE STATICALLY DETERMINED FLUENTS

sdFluent( distance(_, _) ).
sdFluent( close(_, _, _) ).
sdFluent( coord(_) ).
sdFluent( orientation(_) ).
sdFluent( appearance(_) ).


% ===== DEFINE STATICALLY DETERMINED FLUENTS

browseDist( 24 ).
fightDist( 44 ).
moveDist( 34 ).
meetDist( 34 ).
interactDist( 25 ).
leaveDist( 30 ).

holdsAt( close(Person1, Person2, Threshold) = true, T ) :-
	holdsAt( distance(Person1, Person2) = Dist, T ),
	Dist =< Threshold.

holdsAt( close(Person1, Person2, Threshold) = false, T ) :-
	holdsAt( distance(Person1, Person2) = Dist, T ),
	Dist > Threshold.

holdsAt( distance(Person1, Person2) = Ypot, T ) :-
	holdsAt( coord(Person1) = (X1, Y1), T ),
	holdsAt( coord(Person2) = (X2, Y2), T ),
	\+ Person1 = Person2, %TODO: Check if you need to comment this line.
	XDiff is abs(X1-X2),
	YDiff is abs(Y1-Y2),
	SideA is XDiff*XDiff,
	SideB is YDiff*YDiff,
	Temp is SideA + SideB,
	Ypot is sqrt(Temp).

initiatedAt( person(Id)=true, T ) :-
   happensAt( walking(Id), T),
   \+ happensAt( disappear(Id), T).

initiatedAt( person(Id)=true, T ) :-
   happensAt( running(Id), T),
   \+ happensAt( disappear(Id), T).

initiatedAt( person(Id)=true, T ) :-
   happensAt( active(Id), T),
   \+ happensAt( disappear(Id), T).

initiatedAt( person(Id)=true, T ) :-
   happensAt( abrupt(Id), T),
   \+ happensAt( disappear(Id), T).

initiatedAt( person(Id)=false, T) :-
    happensAt( disappear(Id), T).


% ==================================================
% LONG-TERM BEHAVIOUR: fighting(Person, Person2)
% ==================================================


% ----- initiate fighting

initiatedAt(fighting(Person, Person2) = true, T):-
	happensAt(abrupt(Person), T), % This proves that Person is a person.
	holdsAt(person(Person2) = true, T),
	fightDist(Dist),
	holdsAt(close(Person, Person2, Dist) = true, T),
	negate(happensAt( inactive(Person2), T)),
	\+ happensAt(disappear(Person), T),
	\+ happensAt(disappear(Person2), T).

% ----- terminate fighting: split up

initiatedAt(fighting(Person, Person2) = false, T):-
	happensAt(walking(Person), T),
	fightDist(Dist),
	holdsAt(close(Person, Person2, Dist) = false, T).

initiatedAt(fighting(Person2, Person) = false, T):-
	happensAt(walking(Person), T),
	fightDist(Dist),
	holdsAt(close(Person, Person2, Dist) = false, T).

initiatedAt(fighting(Person, Person2) = false, T):-
	happensAt(running(Person), T),
	fightDist(Dist),
	holdsAt(close(Person, Person2, Dist) = false, T).

initiatedAt(fighting(Person2, Person) = false, T):-
	happensAt(running(Person), T),
	fightDist(Dist),
	holdsAt(close(Person, Person2, Dist) = false, T).

initiatedAt(fighting(Person, _) = false, T):-
	happensAt(disappear(Person), T).

initiatedAt(fighting(_, Person) = false, T):-
	happensAt(disappear(Person), T).


% ==================================================
% LONG-TERM BEHAVIOUR: meeting(Person, Person2)
% ==================================================

% allow for a long-term behaviour to be both fighting and meeting
% ie, I cannot tell the difference

% ----- initiate meeting

initiatedAt(meeting(Person, Person2) = true, T):-
	happensAt(active(Person), T),
	holdsAt(person(Person) = true, T),
	holdsAt(person(Person2) = true, T),
	interactDist(Dist),
	holdsAt(close(Person, Person2, Dist) = true, T),
	negate(happensAt(running(Person2), T)),
	negate(happensAt(abrupt(Person2), T)),
	\+ happensAt(disappear(Person), T),
	\+ happensAt(disappear(Person2), T).

initiatedAt(meeting(Person, Person2) = true, T):-
	happensAt(inactive(Person), T),
	holdsAt(person(Person) = true, T),
	holdsAt(person(Person2) = true, T),
	interactDist(Dist),
	holdsAt(close(Person, Person2, Dist) = true, T),
	negate(happensAt(running(Person2), T)),
	negate(happensAt(active(Person2), T)),
	negate(happensAt(abrupt(Person2), T)),
	\+ happensAt(disappear(Person), T),
	\+ happensAt(disappear(Person2), T).

% ----- terminate meeting: split up

initiatedAt(meeting(Person, Person2) = false, T):-
	happensAt(walking(Person), T),
	meetDist(Dist),
	holdsAt(close(Person, Person2, Dist) = false, T).

initiatedAt(meeting(Person2, Person) = false, T):-
	happensAt(walking(Person), T),
	meetDist(Dist),
	holdsAt(close(Person, Person2, Dist) = false, T).

initiatedAt(meeting(Person, _) = false, T):-
	happensAt(running(Person), T).

initiatedAt(meeting(_, Person) = false, T):-
	happensAt(running(Person), T).

initiatedAt(meeting(Person, _) = false, T):-
	happensAt(abrupt(Person), T).

initiatedAt(meeting(_, Person) = false, T):-
	happensAt(abrupt(Person), T).

initiatedAt(meeting(Person, _) = false, T):-
	happensAt(disappear(Person), T).

initiatedAt(meeting(_, Person) = false, T):-
	happensAt(disappear(Person), T).

% ==================================================
% LONG-TERM BEHAVIOUR: moving(Person, Person2)
% ==================================================


% two people are moving together

% ----- initiate moving

initiatedAt(moving(Person, Person2) = true, T):-
	happensAt(walking(Person), T),
	moveDist( Dist ),
	holdsAt( close(Person, Person2, Dist)=true, T ),
	happensAt( walking(Person2), T ), % This will be enough to prove that Person2 is a person entity as well.
	\+ happensAt(disappear(Person), T),
	\+ happensAt(disappear(Person2), T),
	holdsAt( orientation(Person)=O, T ),
	holdsAt( orientation(Person2)=O2, T ),
	Diff is abs(O-O2),
	Diff < 45.

% ----- terminate moving: split up

initiatedAt(moving(Person, Person2) = false, T):-
	happensAt(walking(Person), T),
	moveDist( Dist ),
	holdsAt( close(Person, Person2, Dist)=false, T ).

initiatedAt(moving(Person2, Person) = false, T):-
	happensAt(walking(Person), T),
	moveDist( Dist ),
	holdsAt( close(Person, Person2, Dist)=false, T ).

% ----- terminate moving: stop moving

initiatedAt(moving(Person, Person2) = false, T):-
	happensAt(active(Person), T),
	happensAt( active( Person2 ), T ).

initiatedAt(moving(Person, Person2) = false, T):-
	happensAt(active(Person), T),
	happensAt( inactive( Person2 ), T ).

initiatedAt(moving(Person2, Person) = false, T):-
	happensAt(active(Person), T),
	happensAt( active( Person2 ), T ).

initiatedAt(moving(Person2, Person) = false, T):-
	happensAt(active(Person), T),
	happensAt( inactive( Person2 ), T ).

% ----- terminate moving: start running

initiatedAt(moving(Person, _) = false, T):-
	happensAt(running(Person), T).

initiatedAt(moving(_, Person) = false, T):-
	happensAt(running(Person), T).

% ----- terminate moving: abrupt motion

initiatedAt(moving(Person, _) = false, T):-
	happensAt(abrupt(Person), T).

initiatedAt(moving(_, Person) = false, T):-
	happensAt(abrupt(Person), T).

initiatedAt(moving(Person, _) = false, T):-
	happensAt(disappear(Person), T).

initiatedAt(moving(_, Person) = false, T):-
	happensAt(disappear(Person), T).


% ==================================================
% LONG-TERM BEHAVIOUR: leaving_object(Person, Object)
% ==================================================

% ----- initiate leaving_object

initiatedAt(leaving_object(Person, Object) = true, T):-
	happensAt(inactive(Object), T),
	happensAt( appear(Object), T ),
	leaveDist( Dist ),
	holdsAt( close(Person, Object, Dist)=true, T),
	holdsAt(person(Person) = true, T).
	%happensAt( appear(Person), T0 ),
	%T0 < T.

% ----- terminate leaving_object: pick up object
%       disappear(Object) means that the Object has disappeared
%       which is what will happen if it has been picked up

initiatedAt(leaving_object(_, Object) = false, T):-
	happensAt(disappear(Object), T).


% ====================================
% DEFINITION OF DERIVED EVENTS
% ====================================

happensAt(appear(ID), T):-
	holdsAt(appearance(ID) = appear, T).

happensAt(disappear(ID), T):-
	holdsAt(appearance(ID) = disappear, T).


% Probabilistic negation

negate(SDE):- problog_not(SDE). % TODO: Check whether you need to add a cut.

negate(SDE):- \+ SDE.
