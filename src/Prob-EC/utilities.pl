% Retract all facts of dynamic predicates after processing each time-point.
dynamicEntity(happensAt, 2). 
dynamicEntity(holdsAtIE, 2). 

% Assert and retract a fact of these predicates at the start of the execution.
initEntity(happensAt, 2).
initEntity(holdsAtIE, 2).
initEntity(cached, 1).

% Asserts and retracts dynamic predicates which do not appear 
% in probabilistic facts or rules at the starting program
% to avoid unknown predicate errors 
initDynamic:-
	(
		initEntity(Type, ArgNo),
		length(ArgList, ArgNo),
		Instance =..[Type|ArgList],
		assertz(Instance),
		retractall(Instance),
		fail
	;
		true
	).

% Retract all dynamic entities referring to a prior time-point
% to keep the working memory minimal.
forgetDynamic:-
	findall(Instance, 
			(dynamicEntity(Type, ArgNo),
			length(ArgList, ArgNo),
			Instance =..[Type|ArgList],
			retractall(Instance)), List).

% fetchGroundFVPs(+Fluents, -GroundFVPs)

% Given a list of Fluents, generate all possible groundings of their FVPs
% Grounding is guided by domain specific declarations.
% Domain entities are derived by the entities that take part in the events
% taking place at the current time-point.

fetchGroundFVPs([], []).

% If there is no possible grounding of Fluent, so move to the next one.
fetchGroundFVPs([Fluent|RestFluents], GroundFVPs):- 
  \+ groundFluent(Fluent, GroundFluent), 
  fetchGroundFVPs(RestFluents, GroundFVPs).

% Find all possible groundings of Fluent. 
% Next, find all possible combinations of grounded fluent + possible fluent value.
% This works like a cross product. 
% Finally, find all possible groundings of the remaining FVPs and append 
% them in the output list, respecting the given order of fluents.
fetchGroundFVPs([Fluent|RestFluents], GroundFVPs):-
  findall(GroundFluent, (groundFluent(Fluent, GroundFluent)), GroundFluents), 
  GroundFluents\=[],
  fluent(Fluent, _ArgSorts, Values),
  fetchAllValues(GroundFluents, Values, AllCombos),
  fetchGroundFVPs(RestFluents, RestGroundFVPs),
  append(AllCombos, RestGroundFVPs, GroundFVPs).

% fetchAllValues(+GroundFluents, +Values, -AllCombos)

% Computes the cross product of the first two lists.
% Pairs have the form: GroundFluent=Value.
fetchAllValues([], _, []).

fetchAllValues([GroundFluent|RestGroundFluents], Values, AllCombos):-
  fetchAllValues0(GroundFluent, Values, GroundFVPs),
  fetchAllValues(RestGroundFluents, Values, RestAllCombos),
  append(GroundFVPs, RestAllCombos, AllCombos).

fetchAllValues0(_GroundFluent, [], []).

fetchAllValues0(GroundFluent, [Value|RestValues], [GroundFluent=Value|RestFVPs]):-
  fetchAllValues0(GroundFluent, RestValues, RestFVPs).

%Cache the initial values of all fluents in the application.
%getInitially(+FluentList, +FirstTimepointOfApplication).
getInitially([], _T).

getInitially([Fluent|RestFluents], T):-
	debugprint(Fluent),
	fluent(Fluent, _ArgumentSorts, Values),
	getInitialValues(Fluent, Values, T), 
	getInitially(RestFluents, T).

%getInitialValues(+Fluent, +ValuesList, +FirstTimepointOfApplication).
getInitialValues(_Fluent, [], _T).

getInitialValues(FluentName, [Value|RestValues], Tstart):-
	generateGroundFluent(FluentName, GroundFluent),
	subquery(cached(holdsAt(GroundFluent = Value)), P),
	writenl(P,'::holdsAt(',GroundFluent,'=',Value,',',Tstart,').'),
	getInitialValues(FluentName, RestValues, Tstart).

%------- Fluent Hierarchy -------%
%------ Find Path to Target CEs ------%
%TargetEvents ---> List of events user want to compute
%RequiredEvents ---> List of event dependencies of target events

eventDependencies(Event, L):-
	findall(X, dependency(X, Event), L).

member1(X,[H|_]) :- X=H,!.
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
 	
 %%% 
emptyCache:-
	retractall(cached(_)),
	forgetDynamic. 

isSDFluent(GroundFluent):-
	GroundFluent =.. [Fluent|_], 
	sdFluent(Fluent).

updateCache(T):-
	retractall(cached(holdsAt(_, T))).
