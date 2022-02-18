%% These rules also consider the "abrupt" event.

% ===== DEFINE STATICALLY DETERMINED FLUENTS

% close/3
%% distance definition integrated in the rules of close.
holdsAtMacro(close(Person1, Person2, Threshold) = true, T) :-
    holdsAtIE( coord(Person1) = (X1, Y1), T ),
    %writeln('Person1:', Person1),
    holdsAtIE( coord(Person2) = (X2, Y2), T ),
    %writeln('Person2:', Person2),
    \+ Person1 = Person2,
    XDiff is abs(X1-X2),
    YDiff is abs(Y1-Y2),
    SideA is XDiff*XDiff,
    SideB is YDiff*YDiff,
    Temp is SideA + SideB,
    Dist is sqrt(Temp),
    %writeln('Dist:', Dist),
    Dist =< Threshold.

holdsAtMacro(close(Person1, Person2, Threshold) = false, T) :-
    holdsAtIE( coord(Person1) = (X1, Y1), T ),
    holdsAtIE( coord(Person2) = (X2, Y2), T ),
    \+ Person1 = Person2,
    XDiff is abs(X1-X2),
    YDiff is abs(Y1-Y2),
    SideA is XDiff*XDiff,
    SideB is YDiff*YDiff,
    Temp is SideA + SideB,
    Dist is sqrt(Temp),
    Dist > Threshold.

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
    cached(holdsAt(person(Person2) = true, T)),
    fightDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = true, T),
    \+ happensAt( inactive(Person2), T),
    \+ happensAt(disappear(Person), T),
    \+ happensAt(disappear(Person2), T).

/*
initiatedAt(fighting(Person, Person2) = true, T):-
    happensAt(running(Person), T),
    fightDist(Dist),
    cached(holdsAt(close(Person, Person2, Dist) = true)),
    \+ happensAt(inactive(Person2), T),
    \+ happensAt(disappear(Person), T),
    \+ happensAt(disappear(Person2), T).


initiatedAt(fighting(Person, Person2) = true, T):-
    happensAt(active(Person), T),
    fightDist(Dist),
    cached(holdsAt(close(Person, Person2, Dist) = true)),
    \+ happensAt(inactive(Person2), T),
    \+ happensAt(running(Person2), T),
    \+ happensAt(disappear(Person), T),
    \+ happensAt(disappear(Person2), T).
*/
% ----- terminate fighting: split up

initiatedAt(fighting(Person, Person2) = false, T):-
    happensAt(walking(Person), T),
    fightDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = false).

initiatedAt(fighting(Person2, Person) = false, T):-
    happensAt(walking(Person), T),
    fightDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = false).

initiatedAt(fighting(Person, Person2) = false, T):-
    happensAt(running(Person), T),
    fightDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = false).

initiatedAt(fighting(Person2, Person) = false, T):-
    happensAt(running(Person), T),
    fightDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = false).

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
    cached(holdsAt(person(Person2) = true)),
    interactDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = true, T),
    \+ happensAt(abrupt(Person2), T),
    \+ happensAt(running(Person2), T),
    \+ happensAt(disappear(Person), T),
    \+ happensAt(disappear(Person2), T).

initiatedAt(meeting(Person, Person2) = true, T):-
    happensAt(inactive(Person), T),
    cached(holdsAt(person(Person) = true)),
    cached(holdsAt(person(Person2) = true)),
    interactDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = true, T),
    \+ happensAt(running(Person2), T),
    \+ happensAt(active(Person2), T),
    \+ happensAt(abrupt(Person2), T),
    \+ happensAt(disappear(Person), T),
    \+ happensAt(disappear(Person2), T).

% ----- terminate meeting: split up

initiatedAt(meeting(Person, Person2) = false, T):-
    happensAt(walking(Person), T),
    meetDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = false, T).

initiatedAt(meeting(Person2, Person) = false, T):-
    happensAt(walking(Person), T),
    meetDist(Dist),
    holdsAtMacro(close(Person, Person2, Dist) = false, T).

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
    holdsAtMacro(close(Person, Person2, Dist)=true, T),
    happensAt( walking(Person2), T ), % This will be enough to prove that Person2 is a person entity as well.
    \+ happensAt(disappear(Person), T),
    \+ happensAt(disappear(Person2), T),
    holdsAtIE(orientation(Person)=O, T),
    holdsAtIE(orientation(Person2)=O2, T),
    Diff is abs(O-O2),
    Diff < 45.

% ----- terminate moving: split up

initiatedAt(moving(Person, Person2) = false, T):-
    happensAt(walking(Person), T),
    moveDist( Dist ),
    holdsAtMacro(close(Person, Person2, Dist)=false, T).

initiatedAt(moving(Person2, Person) = false, T):-
    happensAt(walking(Person), T),
    moveDist( Dist ),
    holdsAtMacro(close(Person, Person2, Dist)=false, T).

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
    holdsAtIE(appearance(Object) = appear, T),
    leaveDist( Dist ),
    holdsAtMacro(close(Person, Object, Dist)=true),
    cached(holdsAt(person(Person)=true)).

% ----- terminate leaving_object: pick up object
%       disappear(Object) means that the Object has disappeared
%       which is what will happen if it has been picked up

initiatedAt(leaving_object(_, Object) = false, T):-
    happensAt(disappear(Object), T).

% ====================================
% DEFINITION OF DERIVED EVENTS
% ====================================

happensAt(appear(ID), T):-
    holdsAtIE(appearance(ID) = appear, T).

happensAt(disappear(ID), T):-
    holdsAtIE(appearance(ID) = disappear, T).
