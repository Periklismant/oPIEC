% Initial probability values of all fluents are set to 0.
% However the user is free to adjust them from the following probabilistic facts.
0::cached(holdsAt(withinArea(_Vessel,anchorage)=true)).
0::cached(holdsAt(withinArea(_Vessel,nearCoast)=true)).
0::cached(holdsAt(withinArea(_Vessel,nearCoast5k)=true)).
0::cached(holdsAt(withinArea(_Vessel,natura)=true)).
0::cached(holdsAt(withinArea(_Vessel,fishing)=true)).
0::cached(holdsAt(withinArea(_Vessel,nearPorts)=true)).

0::cached(holdsAt(gap(_Vessel)=nearPorts)).
0::cached(holdsAt(gap(_Vessel)=farFromPorts)).
0::cached(holdsAt(stopped(_Vessel)=nearPorts)).
0::cached(holdsAt(stopped(_Vessel)=farFromPorts)).

0::cached(holdsAt(lowSpeed(_Vessel)=true)).
0::cached(holdsAt(tuggingSpeed(_Vessel)=true)).
0::cached(holdsAt(changingSpeed(_Vessel)=true)).
0::cached(holdsAt(highSpeedNearCoast(_Vessel)=true)).

0::cached(holdsAt(movingSpeed(_Vessel)=below)).
0::cached(holdsAt(movingSpeed(_Vessel)=normal)).
0::cached(holdsAt(movingSpeed(_Vessel)=above)).

0::cached(holdsAt(anchoredOrMoored(_Vessel)=true)).
0::cached(holdsAt(loitering(_Vessel)=true)).
0::cached(holdsAt(underWay(_Vessel)=true)).
0::cached(holdsAt(drifting(_Vessel)=true)).
0::cached(holdsAt(proximity(_Vessel1, _Vessel2)=true)).
0::cached(holdsAt(tugging(_Vessel1, _Vessel2)=true)).
0::cached(holdsAt(rendezVous(_Vessel1, _Vessel2)=true)).
0::cached(holdsAt(pilotBoarding(_Vessel1, _Vessel2)=true)).

%Subquery initial values
getInitially([], _T).

getInitially([Fluent|RestFluents], T):-
	fluent(Fluent, Values),
	getInitialValues(Fluent, Values, T), 
	getInitially(RestFluents, T).

getInitialValues(_Fluent, [], _T).
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

	