%Cache the initial values of all fluents in the application.

groundArguments([],[]).

groundArguments([ArgSort|Sorts], [Arg|Args]):-
	ArgFull =.. [ArgSort, Arg],
	ArgFull,
	groundArguments(Sorts, Args).

% Ground the arguments of a fluent with a combination of possible arguments from the knowledge base. Respect the sort of each argument.
generateGroundFluent(FluentName, GroundFluent):-
	fluent(FluentName, ArgumentSorts, _Values),
	groundArguments(ArgumentSorts, Arguments),
	GroundFluent =.. [FluentName|Arguments].


%getInitially(+FluentList, +FirstTimepointOfApplication).
getInitially([], _T).

getInitially([Fluent|RestFluents], T):-
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

/*
getInitialValues(Fluent, _Values, _T):-
	relational(Fluent), 
	\+meet(Vessel1, Vessel2).

getInitialValues(Fluent, [Value|RestValues], Tstart):-
	((Fluent=withinArea, vessel(Vessel), isArea(Area), FluentParams =.. [Fluent, Vessel, Area]); 
	(relational(Fluent), meet(Vessel1, Vessel2), FluentParams =.. [Fluent, Vessel1, Vessel2]);
	(\+Fluent=withinArea, \+relational(Fluent), vessel(Vessel), FluentParams =.. [Fluent, Vessel])),
	subquery(cached(holdsAt(FluentParams = Value)), P),
	writenl(P, "::holdsAt(", FluentParams, "=", Value, ", ", Tstart, ")."),
	getInitialValues(Fluent, RestValues, Tstart).
*/