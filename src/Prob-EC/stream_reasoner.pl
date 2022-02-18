%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Init Complex Event Recognition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
performFullER:-
  firstTimepoint(FirstTimepoint),
  initDynamic,
  findall(FluentName, fluent(FluentName, _, _), FluentNames), 
  findDependencies(FluentNames, FluentsOrdered), 
  debugprint(FluentsOrdered),
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
  writenl('Timepoint: ', Timepoint),
  %debugprint('Timepoint: ', Timepoint),
  %( %%% Executes all rules defining processTimepoint.
  %  processTimepoint(Timepoint),  
  %  fail 
  %; true
  %),
  findall(Timepoint, processTimepoint(Timepoint), TList),
  %writenl(TList),
  %debugprint(TList),
  findall(happensAt(X, T), (happensAt(X, T), writenl(happensAt(X, T))), Events),
  %writenl(Events),
  %debugprint(Events),
  findall(holdsAtIE(X, T), (holdsAtIE(X, T), writenl(holdsAtIE(X, T))), HoldsAtIE),
  %writenl(HoldsAtIE),
  %debugprint(HoldsAtIE),
  recAllFluents(Timepoint, Fluents),
  forgetDynamic,
  nextTimepoint(Timepoint, NextTimepoint),
  eventRec(NextTimepoint, Fluents).  

%
% At current Timepoint, perform ER for all Fluents 
%
recAllFluents(_Timepoint, []).

recAllFluents(Timepoint, [Fluent|RestFluents]):-
  findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), []).

recAllFluents(Timepoint, [Fluent|RestFluents]):-
  findall(GroundFluent, (subquery(generateGroundFluent(Fluent, GroundFluent), P), P>0), GroundFluents),
  GroundFluents\=[],
  %writenl('Fluent:', Fluent, 'GroundFluents:', GroundFluents),
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
  %writenl('Recognising:', GroundFluent, Value, 'at', T),
  %writenl(Fluent),
  nextTimepoint(T, Tnext),
  subquery(holdsAt(GroundFluent = Value , Tnext), P),
  subquery(cached(holdsAt(GroundFluent = Value)), Pcached),
  Pdiff is abs(P-Pcached),
  ((Pdiff>0.01, 
  writenl(P, '::holdsAt(', GroundFluent, '=', Value, ',', Tnext, ').'),
  retractall(cached(holdsAt(GroundFluent = Value))), 
  assertz((P::cached(holdsAt(GroundFluent = Value)))));
  Pdiff =< 0.01).
