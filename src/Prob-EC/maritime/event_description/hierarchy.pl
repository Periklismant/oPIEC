%------- Event Hierarchy -------%
% Defining an event hierarchy allows Prob-EC to compute only the constituent fluents of the target fluents(which are given by the users).
% This avoid unnecessary computations. E.g., tuggingSpeed should not be computed if the target fluent is loitering.

% dependency(_ToBeComputedFirst, _Target).
dependency(withinArea, gap).
dependency(withinArea, highSpeedNearCoast).
dependency(withinArea, stopped).
dependency(withinArea, rendezVous).
dependency(withinArea, anchoredOrMoored).
dependency(withinArea, loitering).


dependency(gap, stopped).
dependency(gap, lowSpeed).
dependency(gap, tuggingSpeed).
dependency(gap, movingSpeed).

dependency(stopped, anchoredOrMoored).
dependency(stopped, rendezVous).
dependency(stopped, pilotBoarding).

dependency(lowSpeed, rendezVous).
dependency(lowSpeed, pilotBoarding).
dependency(lowSpeed, loitering).

dependency(tuggingSpeed, tugging).

dependency(movingSpeed, underWay).

dependency(underWay, drifting).

dependency(anchoredOrMoored, loitering).

%Add proximity as a dependency for all relational Events.
dependency(proximity, rendezVous).
dependency(proximity, pilotBoarding).
dependency(proximity, tugging).


%------ Find Path to Target CEs ------%
%TargetEvents ---> List of events user want to compute
%RequiredEvents ---> List of event dependencies of target events

eventDependencies(Event, L):-
	findall(X, dependency(X, Event), L).

member1(X,[H|_]) :- X==H,!.
member1(X,[_|T]) :- member1(X,T).
 
distinct([],[]).
distinct([H|T],C) :- member1(H,T),!, distinct(T,C).
distinct([H|T],[H|C]) :- distinct(T,C).

deleteDuplicates([], UniqueEvents, UniqueEvents).

deleteDuplicates([Event|RestEvents], FoundList, UniqueEvents):-
	((member(Event, FoundList), NewFound=FoundList); 
	(\+member(Event, FoundList), append(FoundList, [Event], NewFound))),
	deleteDuplicates(RestEvents, NewFound, UniqueEvents).

traverseDependecies([], Result, Result).

traverseDependecies([Event|RestEvents], Buffer, Result):-
	append([Event], Buffer, Buffer1),
	eventDependencies(Event, NextLevel),
	NextLevel=[],
	traverseDependecies(RestEvents, Buffer1, Result).

traverseDependecies([Event|RestEvents], Buffer, Result):-
	append([Event], Buffer, Buffer1),
	eventDependencies(Event, NextLevel),
	\+NextLevel=[],
	append(NextLevel, RestEvents, NewEvents),
	traverseDependecies(NewEvents, Buffer1, Result).

findDependencies(Events, RequiredEvents):-
	traverseDependecies(Events, [], ListOfDependencies),
	deleteDuplicates(ListOfDependencies, [], RequiredEvents).
 	