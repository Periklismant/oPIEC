% Initial probability values of all fluents are set to 0.
% However the user is free to adjust them from the following probabilistic facts.
0::cached(holdsAt(meeting(_ID1,_ID2)=true)).
0::cached(holdsAt(fighting(_ID1,_ID2)=true)).
0::cached(holdsAt(moving(_ID1,_ID2)=true)).
0::cached(holdsAt(leaving_object(_ID1,_ID2)=true)).
0::cached(holdsAt(person(_ID)=true)).
0::cached(holdsAt(distance(_ID1,_ID2)=true)).
0::cached(holdsAt(close(_ID1,_ID2,_Threshold)=true)).
0::cached(holdsAt(coord(_ID)=true)).
0::cached(holdsAt(orientation(_ID)=true)).
0::cached(holdsAt(appearance(_ID)=true)).

%Subquery initial values
getInitially([], Tuples, _T).

getInitially([Fluent|RestFluents], Tuples, T):-
	%fluent(Fluent, Values),
	getInitialValues(Fluent, Tuples, T), 
	getInitially(RestFluents, Tuples, T).

getInitialValues(_Fluent, [], _T).

getInitialValues(Fluent, [Tuple|RestTuples], Tstart):-
	Tuple=[ID1,ID2],
	FluentParams =.. [Fluent,ID1,ID2],
	Value=true,
	subquery(cached(holdsAt(FluentParams = Value)), P),
	writenl(P, "::holdsAt(", FluentParams, "=", Value, ", ", Tstart, ")."),
	getInitialValues(Fluent, RestTuples, Tstart).