%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Init Complex Event Recognition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
performFullER:-
  firstTimepoint(FirstTimepoint),
  initDynamic,
  %unknownDynamic,
  findall(FluentName, fluent(FluentName, _, _), FluentNames), 
  findDependencies(FluentNames, FluentsOrdered), 
  %debugprint(FluentsOrdered),
  % Grounding before retrieving initial values is impossible since dynamic entities have not been asserted.
  % getInitially(FluentsOrdered, FirstTimepoint), % Assert the initial values of fluents.
  eventRec(FirstTimepoint, FluentsOrdered).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ER utils
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Perform ER for all fluents per timepoint
%
eventRec(Timepoint, _Fluents):-
  lastTimepoint(LastTimepoint),
  Timepoint>LastTimepoint.

eventRec(Timepoint, Fluents):-
  lastTimepoint(LastTimepoint),
  LastTimepoint>Timepoint,
  debugprint("Timepoint: ", Timepoint),
  \+processTimepoint(Timepoint),
  nextTimepoint(Timepoint, NextTimepoint),
  eventRec(NextTimepoint, Fluents).  


eventRec(Timepoint, Fluents):-
  lastTimepoint(LastTimepoint),
  LastTimepoint>Timepoint,
  (processTimepoint(Timepoint), fail ; true),
  fetchGroundFVPs(Fluents, GroundFVPs),
  recFVPs(GroundFVPs, Timepoint),
  %updateFVPs(GroundFVPs, Timepoint),
  forgetDynamic,
  nextTimepoint(Timepoint, NextTimepoint),
  eventRec(NextTimepoint, Fluents).  


%
% At current Timepoint, perform ER for all Fluents 
%
fetchGroundFVPs([], []).

fetchGroundFVPs([Fluent|RestFluents], GroundFVPs):- 
  \+ groundFluent(Fluent, GroundFluent), 
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|Arguments], debugprint(Fluent)), []),
  fetchGroundFVPs(RestFluents, GroundFVPs).

fetchGroundFVPs([Fluent|RestFluents], GroundFVPs):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), GroundFluents),
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|_Arguments], debugprint(Fluent)), GroundFluents),
  findall(GroundFluent, (groundFluent(Fluent, GroundFluent)), GroundFluents), 
  GroundFluents\=[],
  %groundFluent(Fluent, GroundFluent),
  fluent(Fluent, _ArgSorts, Values),
  fetchAllValues(GroundFluents, Values, AllCombos),
  fetchGroundFVPs(RestFluents, RestGroundFVPs),
  append(AllCombos, RestGroundFVPs, GroundFVPs).

fetchAllValues([], _, []).

fetchAllValues([GroundFluent|RestGroundFluents], Values, AllCombos):-
  fetchAllValues0(GroundFluent, Values, GroundFVPs),
  fetchAllValues(RestGroundFluents, Values, RestAllCombos),
  append(GroundFVPs, RestAllCombos, AllCombos).

fetchAllValues0(_GroundFluent, [], []).

fetchAllValues0(GroundFluent, [Value|RestValues], [GroundFluent=Value|RestFVPs]):-
  fetchAllValues0(GroundFluent, RestValues, RestFVPs).
  

recFVPs([], _T).

recFVPs([GroundFVP|RestGroundFVPs], T):-
  %debugprint(GroundFVP),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFVP, Tnext), P),
  subquery(cached(holdsAt(GroundFVP)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.01, 
  writenl(P, '::holdsAt(', GroundFVP, ',', Tnext, ').'),
  %debugprint(P, '::holdsAt(', GroundFVP, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(GroundFVP))), 
  assertz((P::cached(holdsAt(GroundFVP)))));
  Pdiff =< 0.01),
  recFVPs(RestGroundFVPs, T).

  %updateFVPs(RestGroundFVPs, T).

  %(P>0.0, writenl(P, '::holdsAt(', GroundFVP, ',', Tnext, ').')
  % ;
  %  P=0.0),
  %recFVPs(RestGroundFVPs, T).

updateFVPs([], _T).

updateFVPs([GroundFVP|RestGroundFVPs], T):- 
  %debugprint(GroundFVP),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFVP , Tnext), P),
  subquery(cached(holdsAt(GroundFVP)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.01, 
  %writenl(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  %debugprint(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(GroundFVP))), 
  assertz((P::cached(holdsAt(GroundFVP)))));
  Pdiff =< 0.01),
  updateFVPs(RestGroundFVPs, T).


%%%% OLD %%%% 

recAllFluents(_Timepoint, []).

/*
recAllFluents(Timepoint, _Fluents):-
  \+ processTimepoint(Timepoint).

recAllFluents(Timepoint, Fluents):-
  processTimepoint(Timepoint), 
  recAllFluents0(Timepoint, Fluents).
*/

recAllFluents(Timepoint, [Fluent|RestFluents]):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), []),
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), []), 
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|Arguments], debugprint(Fluent)), []),
  recAllFluents(Timepoint, RestFluents).

recAllFluents(Timepoint, [Fluent|RestFluents]):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), GroundFluents),
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|_Arguments], debugprint(Fluent)), GroundFluents),
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), GroundFluents), 
  GroundFluents\=[],
  %debugprint(GroundFluents),
  %debugprint('Fluent:', Fluent, 'GroundFluents:', GroundFluents),
  fluent(Fluent, _ArgSorts, Values),
  recognizeAllValues(GroundFluents, Timepoint, Values),
  recAllFluents(Timepoint, RestFluents).

%
% Fluent has been instantiated. Compute its probability for each possible value
%
recognizeAllValues(_GroundFluents, _T, []).

recognizeAllValues(GroundFluents, T, [Value|RestValues]):-
  recognizeAllGroundFVPs(GroundFluents, T, Value),
  recognizeAllValues(GroundFluents, T, RestValues).

recognizeAllGroundFVPs([], _T, _Value).

recognizeAllGroundFVPs([GroundFluent|Rest], T, Value):-
  recognize(GroundFluent, T, Value),
  recognizeAllGroundFVPs(Rest, T, Value).

recognize(GroundFluent, T, Value):-
  %debugprint('Recognising:', GroundFluent, Value, 'at', T),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFluent = Value , Tnext), P),
  (P>0.0, writenl(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').');
    P=0.0).



%
% At current Timepoint, perform ER for all Fluents 
%
updateAllFluents(_Timepoint, []).

/*
recAllFluents(Timepoint, _Fluents):-
  \+ processTimepoint(Timepoint).

recAllFluents(Timepoint, Fluents):-
  processTimepoint(Timepoint), 
  recAllFluents0(Timepoint, Fluents).
*/

updateAllFluents(Timepoint, [Fluent|RestFluents]):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), []),
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), []), 
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|Arguments], debugprint(Fluent)), []),
  updateAllFluents(Timepoint, RestFluents).

updateAllFluents(Timepoint, [Fluent|RestFluents]):-
  %findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), GroundFluents),
  %findall(GroundFluent, (groundFluent(GroundFluent), debugprint(GroundFluent), GroundFluent =.. [Fluent|_Arguments], debugprint(Fluent)), GroundFluents),
  findall(GroundFluent, (fluent(Fluent, ArgList, _), length(ArgList, ArgNo), length(X, ArgNo), GroundFluent =.. [Fluent|X], groundFluent(GroundFluent)), GroundFluents), 
  GroundFluents\=[],
  %debugprint(GroundFluents),
  %debugprint('Fluent:', Fluent, 'GroundFluents:', GroundFluents),
  fluent(Fluent, _ArgSorts, Values),
  updateAllValues(GroundFluents, Timepoint, Values),
  updateAllFluents(Timepoint, RestFluents).

%
% Fluent has been instantiated. Compute its probability for each possible value
%
updateAllValues(_GroundFluents, _T, []).

updateAllValues(GroundFluents, T, [Value|RestValues]):-
  updateAllGroundFVPs(GroundFluents, T, Value),
  updateAllValues(GroundFluents, T, RestValues).

updateAllGroundFVPs([], _T, _Value).

updateAllGroundFVPs([GroundFluent|Rest], T, Value):-
  update(GroundFluent, T, Value),
  updateAllGroundFVPs(Rest, T, Value).

update(GroundFluent, T, Value):-
  %debugprint('Recognising:', GroundFluent, Value, 'at', T),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFluent = Value , Tnext), P),
  subquery(cached(holdsAt(GroundFluent = Value)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0, 
  %writenl(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  %debugprint(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(GroundFluent = Value))), 
  assertz((P::cached(holdsAt(GroundFluent = Value)))));
  Pdiff =< 0).
