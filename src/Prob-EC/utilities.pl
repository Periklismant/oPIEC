

%
dynamicEntity(happensAt, 2). % Retract all happensAt facts after each window.
dynamicEntity(holdsAtIE, 2). % Retract all holdsAtIE facts after each window.

initEntity(happensAt, 2).
initEntity(holdsAtIE, 2).
initEntity(cached, 1).
%initEntity(sdFluent, 1).
%initEntity(sdMacro, 1).

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
forgetDynamic:-
	findall(Instance, 
			(dynamicEntity(Type, ArgNo),
			length(ArgList, ArgNo),
			Instance =..[Type|ArgList],
			retractall(Instance)), List). %% does it really retract?
	%writenl(List).
	%(
	%	dynamicEntity(Type, ArgNo),
	%	length(ArgList, ArgNo),
	%	Instance =..[Type|ArgList],
	%	retractall(Instance),
	%	fail
	%;
	%	true
	%).

member0(X, [X|T]).

member0(X, [H|T]):-
	X\=H,
	member0(X, T).

uniqueArguments([]).

uniqueArguments([H|T]):-
	\+ member0(H, T), 
	uniqueArguments(T).	

% Generate valid grounding. 
groundArguments([],[]).
groundArguments([ArgSort|Sorts], [Arg|Args]):-
	ArgFull =.. [ArgSort, Arg],
	ArgFull,
	groundArguments(Sorts, Args).

% Ground the arguments of a fluent with a combination of possible arguments from the knowledge base. Respect the sort of each argument.
generateGroundFluent(FluentName, GroundFluent):-
	fluent(FluentName, ArgumentSorts, _Values),
	groundArguments(ArgumentSorts, Arguments),
	subquery(uniqueArguments(Arguments), P), P>0,
	GroundFluent =.. [FluentName|Arguments].


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